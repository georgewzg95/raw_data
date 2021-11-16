import os
import csv
import argparse
import re
from collections import defaultdict

class tree_node():
  def __init__(self):
    self.value = None
    self.children = None


class gen_submod():
  def __init__(self):
    self.start_path = None
    self.yosys_path = None
    self.hier_filepath = None
    self.subdir = None
    self.filename = None

    #filepath to the verilog file
    self.filepath = None

    #filepath to the hierarchy file
    self.hier_filepath = None

    #path to the directory containing hierarchy file
    self.hier_dir = None

    self.dict = defaultdict(list)
    self.parse_arges()
    self.iteration_main()

  def iteration_main(self):
    for subdir, dirs, files in os.walk(self.start_path):
      for filename in files:
        if filename.endswith(".v"):
          self.subdir = subdir
          self.filename = filename
          self.filepath = subdir + os.sep + filename
          self.gen_ys()
          if self.create_hier() == True:
            continue
          self.read_hier()
          self.write_submod()

  def write_submod(self):
    for i in range(len(self.dict) - 1, 0, -1):
      for t_mod in self.dict[i]:
        self.generate(t_mod)
        self.append_mod(t_mod)

  def append_mod(self, t_mod):
    if t_mod.children == None:
      return
    t_mod_path = self.hier_dir + os.sep + t_mod.value + ".v"
    for module in t_mod.children:
      module_path = self.hier_dir + os.sep + module.value + ".v"
      os.system("cat " + module_path + " >> " + t_mod_path)

  def generate(self, t_mod):
    fin = open(self.filepath, "rt")
    t_mod_path = self.hier_dir + os.sep + t_mod.value + ".v"
    if os.path.exists(t_mod_path) == True:
      os.system("rm " + t_mod_path)
    fout = open(t_mod_path, "wt")
    start_parse = False

    for line in fin:
      # find the target module
      if line.find("module") >= 0:
        x = line.split()
        if x[0] == "module":
          k = x[1].split('(')
          if k[0] == t_mod.value:
            start_parse = True
            fout.write(line)
            continue

      #start to copy
      if start_parse == True:
        fout.write(line)
        if line.find("endmodule") >=0:
          break
    fin.close()
    fout.close()

  def parse_arges(self):
    parser = argparse.ArgumentParser()
    parser.add_argument(  "-d",
                          "--directory",
                          default = "raw_designs/test_designs",
                          type = str,
                          help = "directory path to pwd to generate designs from")
    parser.add_argument(  "-y",
                          "--yosys_path",
                          default = "/home/zhigang/FeatEx/",
                          type = str,
                          help = "ABSOLUTE path for yosys")

    args = parser.parse_args()
    if args.directory.startswith("/"):
      self.start_path = args.directory
    else:
      self.start_path = os.getcwd() + os.sep + args.directory

    self.yosys_path = args.yosys_path

  def gen_ys(self):
    fin = open("template_submod.ys", "rt")
    fout = open("out.ys", "wt")
    for line in fin:
      line = line.replace('[DESIGN]', self.filepath)
      fout.write(line)
    fin.close()
    fout.close()

  def create_hier(self):
    dir_name = self.filename[:-2] + "_submodules"
    dir_path = self.subdir + os.sep + dir_name
    self.hier_dir = dir_path
    self.hier_filepath = dir_path + os.sep + self.filename[:-2] + '.hier'
    try:
      os.mkdir(dir_path)
    except OSError as error:
      print(error)

    if os.path.exists(self.hier_filepath) == False:
      os.system(self.yosys_path + 'yosys -q -l ' + self.hier_filepath + ' out.ys')
    else:
      print("hierarchy file already exists, skip the generation: " + self.hier_filepath)
      return True

    return False

  def read_hier(self):
    #clean the hierarchy first
    self.dict = defaultdict(list)

    start_parse = False
    last_node = None
    fin = open(self.hier_filepath, "rt")
    for line in fin:
      if line.find("2.3. Analyzing design hierarchy") >= 0:
        start_parse = True
        continue
      if start_parse:
        if line.find("Top module:") >= 0:
          root = tree_node()
          x = line.split("\\")
          root.value = x[1].strip()
          self.dict[0].append(root)
          continue
        if line.find("Used module:") < 0:
          break
        
        cur_node = tree_node()
        x = line.split('\\')
        cur_node.value = x[1].strip()
        lev = 0
        for i in range(12, len(line)):
          if line[i] == ' ':
            lev += 1
          else:
            break
        lev = (lev - 1)//4
        last_node = self.dict[lev - 1][-1]
        self.dict[lev].append(cur_node)
        if last_node.children == None:
          last_node.children = []
        last_node.children.append(cur_node)
    fin.close()

    # for i in range(len(self.dict)):
    #   for modules in self.dict[i]:
    #     print("the level is", str(i), modules.value, sep = " ")
    #     print("children is:")
    #     if modules.children != None:
    #       for children in modules.children:
    #         print(children.value, end=",")
    #     print("")


if __name__ == "__main__":
  gen_submod()