import os

# root_path = os.getcwd()
# #start_path = root_path + "/raw_designs/test_designs"
# start_path = root_path + "/raw_designs/opencores/arithmetic"

def parse_arges():
  parser = argparse.ArgumentParser()
  parser.add_argument(  "-d",
                        "--directory",
                        required = True,
                        type = str,
                        help = "synthesize all the designs under the declared diectory")
  parser.add_argument(  "-y",
                        "--yosys_path",
                        default = "/home/zhigang/FeatEx/",
                        type = str,
                        help = "ABSOLUTE path for yosys")
  args = parser.parse_args()
  return args

def replace_template(filepath):
  fin = open("template.ys", "rt")
  fout = open("out.ys", "wt")
  for line in fin:
    line = line.replace('[DESIGN]', filepath)
    line = line.replace('[OUTPUT]', filepath + ".out")
    fout.write(line)
  fin.close()
  fout.close()

if __name__ == "__main__":
  args = parse_args()
  start_path = os.path.abspath(args.directory)
  yosys_path = args.yosys_path
  for subdir, dirs, files in os.walk(start_path):
    for filename in files:
      filepath = subdir + os.sep + filename
      
      if filepath.endswith(".sv") or filepath.endswith(".v"):
        #relative_path = os.path.relpath(filepath, start_path)
        replace_template(filepath)
        os.system(yosys_path + 'yosys -q -l ' + filepath + '.log out.ys') 
