import subprocess
import time
import os

report_dir = '/home/zhigang/reports/'

class Design:
  def __init__(self, report_dir, filepath):
    self.cmd = 'vivado -mode batch -source tcl_scripts.tcl'
    self.name = filepath.split('/')[-1][:-6]
    self.report_dir = report_dir
    self.filepath = filepath
    self.create_directory()

  def create_directory(self):
    directory = self.report_dir + os.sep + self.filepath[-2]
    if os.path.exists(directory) == True:
      print('error: ' + self.name)
      print('error: ' + self.filepath)
      return
    os.makedirs(directory, exist_ok = True)

list_designs = [] 
if __name__ == "__main__":
  file_list = open('out_data.csv', 'rt')
  for line in file_list:
    verilog_filepath = line.split(',')[1][-4]
    design = Design(report_dir, verilog_filepath)
    list_designs.append(design)

  pas = []
  num_jobs = 8
  





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


