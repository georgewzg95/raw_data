import subprocess
import time
import os

class design:
  def __init__(self, cmd, report_dir, filepath):
    self.cmd = cmd
    self.name = filepath.split('/')[-1][:-6]
    self.report_dir = report_dir
    self.filepath = filepath
    self.create_directory()

  def create_directory(self):
    directory = self.report_dir + os.sep + self.name
    if os.exists(directory) == True:
      print(self.name)
      print(self.filepath)
      return
    os.mkdir(directory)
 
if __name__ == "__main__":
  file_list = open('out_data.csv', 'rt')
  for line in file_list:
    filepath = line.split(',')[1]


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


