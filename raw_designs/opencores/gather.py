import os
import csv
import argparse
import re
from collections import defaultdict

start_path = "/home/zhigang/raw_data/raw_designs/opencores/Communication_controller"
output_path = "/home/zhigang/raw_data/raw_designs/opencores/communication_controller"

def retrieve_name(subdir):
  tokens = subdir.split("/")
  for index, token in enumerate(tokens):
    if token == "Communication_controller":
      return tokens(index + 1)


if __name__ == "__main__":
  print("start_path")
  for subdir, dirs, files in os.walk(start_path):
    for filename in files:
      if filename.endswith(".v"):
        verilog_name = retrieve_name(subdir)
        print(verilog_name)

# class gen_submod():
#   def __init__(self):
#     self.start_path = None
#     self.yosys_path = None
#     self.hier_filepath = None
#     self.subdir = None
#     self.filename = None
#     self.second_phase = None

#     #filepath to the verilog file
#     self.filepath = None

#     #filepath to the hierarchy file
#     self.hier_filepath = None

#     #path to the directory containing hierarchy file
#     self.hier_dir = None
#     self.dict = defaultdict(list)
#     #self.second_dict = []
#     self.parse_arges()

#     if self.second_phase == False:
#       self.iteration_main()
#     else:
#       self.iteration_second()

#   def iteration_second(self):
#     #check the hierarchy in .out files
#     for subdir, dirs, files in os.walk(self.start_path):
#       if subdir.endswith("submodules") == False:
#         continue
#       for filename in files:
#         if filename.endswith(".out"):
#           second_dict = self.check_second_phase(subdir + os.sep + filename)

#           if len(second_dict) == 0:
#             continue
          
#           target_module_path = subdir + os.sep + filename[:-4]
#           print(target_module_path)
#           print(second_dict)
#           print('\n')
#           for miss_module in second_dict:
#             miss_module_path = subdir + os.sep + miss_module + ".v"
#             print("miss module: " + miss_module_path)
#             self.append_second_phase(miss_module_path, target_module_path)

#           self.remove_redundant(target_module_path)

#   def remove_redundant(self, target_module_path):
#     module_list = []
#     with open(target_module_path, "r") as fr:
#       lines = fr.readlines()

#     delete = False
#     with open(target_module_path, "w") as fw:
#       for line in lines:
#         if line.find("module") >= 0:
#           x = line.split()
#           if x[0] == "module":
#             k = x[1].split('(')
#             cur_module = k[0].split('#')[0]
#             if cur_module in module_list:
#               delete = True
#               continue
#             else:
#               module_list.append(cur_module)
#               fw.write(line)
#               continue

#         if delete == True:
#           if line.find("endmodule") >= 0:
#             delete = False
#           continue

#         fw.write(line)

#   def append_second_phase(self, miss_module_path, target_module_path):
#     try:
#       fin = open(miss_module_path, "rt")
#     except IOError as error:
#       print(error)
#       return

#     fout = open(target_module_path, "a+")
#     for line in fin:
#       #skip the macros
#       if line.find('`define') >= 0:
#         continue
#       if target_module_path == "/home/zhigang/DATA/raw_designs/vtr_designs/verilog/koios/softmax_submodules/mode1_max_tree.v":
#         print(line)
#       fout.write(line)
#     fin.close()
#     fout.close()


#   def check_second_phase(self, filename):
#     second_dict = []
#     fin = open(filename, "rt")
#     hier_exs = False
#     fin.seek(0, 0)
#     st = False
#     for line in fin:
#       if line.find("design hierarchy") >= 0:
#         hier_exs = True
#       if hier_exs and line.find("Number of cells") >= 0:
#         st = True
#         continue
#       if st == True:
#         if line.find("$") < 0 and line.rstrip():
#           token = line.split()
#           second_dict.append(token[0])

#     fin.seek(0, 0)
#     st = False
#     for line in fin:
#       if hier_exs == False:
#         if line.find("Number of cells") >= 0:
#           st = True
#           continue
#         if st ==  True:
#           if line.find("$") < 0 and line.rstrip():
#             token = line.split()
#             second_dict.append(token[0])

#     return second_dict
#     # print(filename)
#     # print(second_dict)



#   def iteration_main(self):
#     for subdir, dirs, files in os.walk(self.start_path):
#       if subdir.endswith("submodules"):
#         print("submodules already exsits, skip the generation: " + subdir)
#         continue
#       for filename in files:
#         if filename.endswith(".v"):
#           self.subdir = subdir
#           self.filename = filename
#           self.filepath = subdir + os.sep + filename
#           self.gen_ys()
#           self.create_hier()
#           self.read_hier()
#           self.write_submod()
#           self.add_macro()

#   def line_prepender(self, macro):
#     for i in range(len(self.dict) - 1, 0, -1):
#       for t_mod in self.dict[i]:
#         filename = self.hier_dir + os.sep + t_mod.value + ".v"
#         with open(filename, 'r+') as f:
#           content = f.read()
#           f.seek(0, 0)
#           f.write(macro + '\n' + content)

#   def add_macro(self):
#     macro = ""
#     fin = open(self.filepath, "rt")
#     for line in fin:
#       if line.find("`define") >= 0:
#         macro += line

#     self.line_prepender(macro)

#   def write_submod(self):
#     for i in range(len(self.dict) - 1, 0, -1):
#       for t_mod in self.dict[i]:
#         self.generate(t_mod)
#         self.append_mod(t_mod)

#   def append_mod(self, t_mod):
#     if t_mod.children == None:
#       return
#     t_mod_path = self.hier_dir + os.sep + t_mod.value + ".v"
#     for module in t_mod.children:
#       module_path = self.hier_dir + os.sep + module.value + ".v"
#       os.system("cat " + module_path + " >> " + t_mod_path)

#   def generate(self, t_mod):
#     fin = open(self.filepath, "rt")
#     t_mod_path = self.hier_dir + os.sep + t_mod.value + ".v"
#     if os.path.exists(t_mod_path) == True:
#       os.system("rm " + t_mod_path)
#     fout = open(t_mod_path, "wt")
#     start_parse = False

#     for line in fin:
#       # find the target module
#       if line.find("module") >= 0:
#         x = line.split()
#         if x[0] == "module":
#           k = x[1].split('(')
#           k = k[0].split('#')
#           if k[0] == t_mod.value:
#             start_parse = True
#             fout.write(line)
#             continue

#       #start to copy
#       if start_parse == True:
#         fout.write(line)
#         if line.find("endmodule") >=0:
#           break
#     fin.close()
#     fout.close()

#   def parse_arges(self):
#     parser = argparse.ArgumentParser()
#     parser.add_argument(  "-d",
#                           "--directory",
#                           default = "raw_designs/test_designs",
#                           type = str,
#                           help = "directory path to pwd to generate designs from")
#     parser.add_argument(  "-y",
#                           "--yosys_path",
#                           default = "/home/zhigang/FeatEx/",
#                           type = str,
#                           help = "ABSOLUTE path for yosys")
#     parser.add_argument('--second_phase', dest='second_phase', action='store_true')
#     parser.add_argument('-s', dest='second_phase', action='store_true')
#     parser.set_defaults(second_phase=False)

#     args = parser.parse_args()
#     if args.directory.startswith("/"):
#       self.start_path = args.directory
#     else:
#       self.start_path = os.getcwd() + os.sep + args.directory

#     self.yosys_path = args.yosys_path
#     self.second_phase = args.second_phase

#   def gen_ys(self):
#     fin = open("template_submod.ys", "rt")
#     fout = open("out.ys", "wt")
#     for line in fin:
#       line = line.replace('[DESIGN]', self.filepath)
#       fout.write(line)
#     fin.close()
#     fout.close()

#   def create_hier(self):
#     dir_name = self.filename[:-2] + "_submodules"
#     dir_path = self.subdir + os.sep + dir_name
#     self.hier_dir = dir_path
#     self.hier_filepath = dir_path + os.sep + self.filename[:-2] + '.hier'
#     try:
#       os.mkdir(dir_path)
#     except OSError as error:
#       print(error)

#     if os.path.exists(self.hier_filepath) == False:
#       os.system(self.yosys_path + 'yosys -q -l ' + self.hier_filepath + ' out.ys')

#   def read_hier(self):
#     #clean the hierarchy first
#     self.dict = defaultdict(list)

#     start_parse = False
#     last_node = None
#     fin = open(self.hier_filepath, "rt")
#     for line in fin:
#       if line.find("2.2. Analyzing design hierarchy") >= 0:
#         start_parse = True
#         continue
#       if start_parse:
#         if line.find("Top module:") >= 0:
#           root = tree_node()
#           x = line.split("\\")
#           root.value = x[1].strip()
#           self.dict[0].append(root)
#           continue
#         if line.find("Used module:") < 0:
#           break
        
#         cur_node = tree_node()
#         x = line.split('\\')
#         cur_node.value = x[1].strip()
#         lev = 0
#         for i in range(12, len(line)):
#           if line[i] == ' ':
#             lev += 1
#           else:
#             break
#         lev = (lev - 1)//4
#         last_node = self.dict[lev - 1][-1]
#         self.dict[lev].append(cur_node)
#         if last_node.children == None:
#           last_node.children = []
#         last_node.children.append(cur_node)
#     fin.close()

    # for i in range(len(self.dict)):
    #   for modules in self.dict[i]:
    #     print("the level is", str(i), modules.value, sep = " ")
    #     print("children is:")
    #     if modules.children != None:
    #       for children in modules.children:
    #         print(children.value, end=",")
    #     print("")

