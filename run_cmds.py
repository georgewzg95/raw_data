import subprocess
import time
import os
import argparse

report_dir = '/misc/scratch/zwei1/reports/'
root_dir = '/misc/scratch/zwei1/raw_data'
cmd = 'vivado -mode batch -source /misc/scratch/zwei1/reports/run_tcl.tcl'

class Design:
  def __init__(self, r_dir, filepath):
    self.name = filepath.split('/')[-1][:-2]
    self.filepath = filepath
    self.r_dir = r_dir
    self.topmodule = topmodule
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
  with open(report_dir + os.sep + 'tcl_temp.tcl', 'r') as f:
    lines = f.readlines()

  with open(report_dir + os.sep + 'run_tcl.tcl', 'w') as f:
    for line in lines:
        line = line.replace('[OUTPUTDIR]', design.r_dir)
        line = line.replace('[V_FILE]', design.filepath)
        line = line.replace('[TOP]', find_topmodule(design))
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
    f.write(design.r_dir + ',' + design.filepath)

def find_topmodule(design):
  with open(design.filepath + '.out', 'r') as f:
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

  args = parser.parse_args()
  return args

if __name__ == "__main__":

  args = parse_args()

  if args.create_directory == True:
    file_list = open('out_data.csv', 'rt')
    list_designs = []
    for line in file_list:
      verilog_filepath = line.split(',')[1][:-4]
      design = Design(report_dir + verilog_filepath[:-2], root_dir + os.sep + verilog_filepath)
      list_designs.append(design)
    
    remain_jobs = open(report_dir + os.sep + 'remain_jobs.txt', 'w')
    for design in list_designs:
      remain_jobs.write(design.r_dir + ',' + design.filepath + '\n')
      #print(design.filepath + '  ' + find_topmodule(design))

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
        replace_tcl(design)
        subproc = subprocess.Popen([cmd], stdout=log, stderr=err, shell=True)
        launched = True
        task = Task(design, subproc, log, err)
        running_jobs.append(task)

#cmd = 'vivado -mode batch -source tcl_scripts.tcl'
#log = open('log', 'wt')
#err = open('err', 'wt')
#subproc = subprocess.Popen([cmd], stdout=log, stderr=err, shell=True)
#while True:
#  p = subproc.poll()
#  time.sleep(0.5)
#  if p is not None:
#    break
#    log.close()
#    err.close()
#    print('task finised')


