import subprocess
import time
import os
import argparse
import re

report_dir = '/misc/scratch/zwei1/reports/'
root_dir = '/misc/scratch/zwei1/raw_data'

class Design:
  def __init__(self, r_dir, filepath):
    self.name = filepath.split('/')[-1][:-2]
    self.filepath = filepath.strip()
    self.r_dir = r_dir.strip()
    self.cmd = 'vivado -mode batch -source ' + r_dir + os.sep + 'run_tcl.tcl'
    self.create_directory()

  def create_directory(self):
    directory = self.r_dir
    if os.path.exists(directory) == True:
      #print('error: ' + self.name)
      #print('error: ' + self.filepath)
      return
    os.makedirs(directory, exist_ok = True)

class Task:
  def __init__(self, design, subproc, log, err):
    self.design = design
    self.subproc = subproc
    self.log = log
    self.err = err

remain_designs = []

def replace_tcl(design):
  top_module = find_topmodule(design)
  with open(design.filepath, 'r') as f:
    lines = f.readlines()
  create_clock = ''
  #find out the top module clock port
  start_parse = False
  for line in lines:
    if line.find("module") >= 0:
      x = line.split()
      if x[0] == "module":
        k = x[1].split('(')
        k = k[0].split('#')
        if k[0] == top_module:
          start_parse = True
      
    if start_parse == True:
      z = re.split('[\s(,;)]', line)
      for ele in z:
        if 'clk' in ele or 'clock' in ele:
          create_clock = ele
          break

      if create_clock != '' or ';' in line:
        break

  with open(report_dir + os.sep + 'tcl_temp.tcl', 'r') as f:
    lines = f.readlines()

  with open(design.r_dir + os.sep + 'run_tcl.tcl', 'w') as f:
    for line in lines:
        line = line.replace('[OUTPUTDIR]', design.r_dir)
        line = line.replace('[V_FILE]', design.filepath)
        line = line.replace('[TOP]', top_module)
        line = line.replace('[CLOCK]', create_clock)
        f.write(line)

def remove_design(design):
  with open(report_dir + os.sep + 'remain_jobs.txt', 'r') as f:
    lines = f.readlines()

  with open(report_dir + os.sep + 'remain_jobs.txt', 'w') as f:
    for line in lines:
      if line.find(design.filepath) >= 0:
        continue
      f.write(line)

  with open(report_dir + os.sep + 'complete_jobs.txt', 'a+') as f:
    f.write(design.r_dir + ',' + design.filepath + '\n');

def find_topmodule(design):
  with open(design.filepath.rstrip() + '.out', 'r') as f:
    lines = f.readlines()

  hierarchy = False
  for line in lines:
    if line.find('design hierarchy') >= 0:
      hierarchy = True
      break

  if hierarchy == True:
    st = False
    for line in lines:
      if line.find('design hierarchy') >= 0:
        st = True
        continue
      if st == True and line.rstrip():
        return line.split()[0]
  else:
    for line in lines:
      if line.find('===') >= 0:
        return line.split()[1]

def parse_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('-i',
                     '--input',
                     required = True,
                     type = str,
                     help = 'the clean.feat file generated from collect.py as the guide to generate directories and jobs')
  parser.add_argument('-d',
                      '--directory',
                      required = True,
                      type = str,
                      help = 'the directory to generate reports, example: [reports] [reports_2]')
  parser.add_argument('-cd',
                      '--create_directory',
                      dest = 'create_directory',
                      action = 'store_true')
  parser.set_defaults(create_directory=False)

  parser.add_argument('-rc',
                      '--run_cmds',
                      dest = 'run_cmds',
                      action = 'store_true')
  parser.set_defaults(run_cmds = False)

  parser.add_argument('-ce',
                      '--count_error',
                      dest = 'count_error',
                      action = 'store_true')
  parser.set_defaults(count_error = False)

  parser.add_argument('-f',
                      '--file',
                      default = '/misc/scratch/zwei1/reports/complete_jobs.txt',
                      type = str,
                      help = 'complete_jobs path')

  args = parser.parse_args()
  return args

def check_error(design):
  err_file = design.r_dir + os.sep + 'err'
  if os.stat(err_file).st_size == 0:
    return False
  else:
    return True

def log_err_design(design):
  with open(report_dir + os.sep + 'err_designs', 'a+') as f:
    f.write(design.r_dir + ',' + design.filepath + '\n')

def log_effective_design(design):
  with open(report_dir + os.sep + 'effective_design', 'a+') as f:
    f.write(design.r_dir + ',' + design.filepath + '\n')

if __name__ == "__main__":

  args = parse_args()

  if args.create_directory == True:
    file_list = open(args.input, 'rt')
    list_designs = []
    for line in file_list:
      verilog_filepath = line.split(',')[1][:-4]
      design = Design(verilog_filepath.replace('raw_data', args.directory)[:-2], verilog_filepath)
      list_designs.append(design)
    
    remain_jobs = open(report_dir + os.sep + 'remain_jobs.txt', 'w')
    for design in list_designs:
      remain_jobs.write(design.r_dir + ',' + design.filepath + '\n')
      #print(design.filepath + '  ' + find_topmodule(design))
      replace_tcl(design)

    remain_jobs.close()

  if args.run_cmds == True:
    remain_jobs_f = open(report_dir + os.sep + 'remain_jobs.txt', 'rt')
    for line in remain_jobs_f:
      design = Design(line.split(',')[0], line.split(',')[1])
      remain_designs.append(design)
    remain_jobs_f.close() 

    num_jobs = 5
    running_jobs = []
    launched = False

    while True:
      if len(running_jobs) == 0 and launched == True:
        break

      for task in running_jobs:
        if task.subproc.poll() is not None:
          design = task.design

          #remove design from the remain_jobs.txt and add it to complete_jobs.txt
          remove_design(design)

          running_jobs.remove(task)
          task.log.close()
          task.err.close()

      while len(running_jobs) < num_jobs and len(remain_designs) > 0:
        design = remain_designs[0]
        remain_designs.remove(design)
        log = open(design.r_dir + os.sep + 'log', 'w')
        err = open(design.r_dir + os.sep + 'err', 'w')
        subproc = subprocess.Popen([design.cmd], stdout=log, stderr=err, shell=True)
        launched = True
        task = Task(design, subproc, log, err)
        running_jobs.append(task)

  if args.count_error == True:
    with open(args.file) as f:
      lines = f.readlines()

    total = 0
    complete_designs = []
    for line in lines:
      total = total + 1
      design = Design(line.split(',')[0], line.split(',')[1])
      complete_designs.append(design)

    err_count = 0
    for design in complete_designs:
      if check_error(design) > 0:
        err_count += 1
        log_err_design(design)
      else:
        log_effective_design(design)

    print('the number of complete designs is: ' + str(total))
    print('the number of error designs is: ' + str(err_count))
    print('the fraction of error designs is: ' + str(err_count/total))

