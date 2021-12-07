import os
import csv
import argparse
import re
from collections import defaultdict


start_path = "./opencores/communication_controller"

def remove_redundant(target_module_path):
    module_list = []
    with open(target_module_path, "r") as fr:
      lines = fr.readlines()

    delete = False
    with open(target_module_path, "w") as fw:
      for line in lines:
        if line.find("module") >= 0:
          x = line.split()
          if x[0] == "module":
            k = x[1].split('(')
            cur_module = k[0].split('#')[0]
            if cur_module in module_list:
              delete = True
              continue
            else:
              module_list.append(cur_module)
              fw.write(line)
              continue

        if delete == True:
          if line.find("endmodule") >= 0:
            delete = False
          continue

        fw.write(line)

def move_defines(filename):
    macro = ""
    with open(filename, "rt") as fin:
      lines = fin.readlines()

    for line in lines:
      if line.find("`define") >= 0:
        macro += line
    
    with open(filename, "w") as fout:
      fout.write(macro + "\n")
      for line in lines:
        if line.find("`define") >= 0:
          continue
        fout.write(line)


if __name__ == "__main__":
  for subdir, dirs, files in os.walk(start_path):
    for filename in files:
      if filename.endswith(".v"):
        remove_redundant(subdir + os.sep + filename)
        move_defines(subdir + os.sep + filename)
