import os

root_path = os.getcwd()
#start_path = root_path + "/raw_designs/test_designs"
start_path = root_path + "/raw_designs/vtr_designs"
yosys_path = "/home/zhigang/FeatEx/"

def replace_template(filepath):
  fin = open("template.ys", "rt")
  fout = open("out.ys", "wt")
  for line in fin:
    line = line.replace('[DESIGN]', filepath)
    line = line.replace('[OUTPUT]', filepath + ".out")
    fout.write(line)
  fin.close()
  fout.close()

for subdir, dirs, files in os.walk(start_path):
  for filename in files:
    filepath = subdir + os.sep + filename
    
    if filepath.endswith(".sv") or filepath.endswith(".v"):
      #relative_path = os.path.relpath(filepath, start_path)
      replace_template(filepath)
      os.system(yosys_path + 'yosys -q -l ' + filepath + '.log out.ys') 
