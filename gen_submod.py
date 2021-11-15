import os
import csv
import argparse

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
    self.filepath = None
    self.hier_filepath = None
    self.hier_dir = None
    self.dict = {}
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
          self.create_hier()
          self.read_hier()

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
    print(self.filename[:-2] + " hierarchy files creation finished")

  def read_hier(self):
    print("reading hierarchy file " + self.hier_filepath)
    start_parse = False
    last_node = None
    fin = open(self.hier_filepath, "rt")
    for line in fin:
      if line.find("2.3. Analyzing design hierarchy") >= 0:
        start_parse = True
        continue
      if start_parse:
        print("searching submodules")
        print(line)
        if line.find("Top module:") >= 0:
          print("top module found")
          root = tree_node()
          x = line.split("\\")
          root.value = x[1].strip()
          self.dict[0] = []
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
        print("the lev is " + str(lev))
        lev = (lev - 1)//4
        print("the lev is " + str(lev))
        last_node = self.dict[lev - 1][-1]
        print(self.dict[lev])
        if self.dict[lev] == None:
          self.dict[lev] = []
        self.dict[lev].append(cur_node)
        if last_node.children == None:
          last_node.children = []
        last_node.children.append(cur_node)
    fin.close()

if __name__ == "__main__":
  gen_submod()



my_dict = {}
remove = {}


# def retrieve_info(filepath):
#   relative_path = os.path.relpath(filepath, cur_path)
  
#   fin = open(filepath, "rt")
#   if relative_path not in my_dict:
#     my_dict[relative_path] = []

#   hierarchy = False
#   bb = False
#   for line in fin:
#     if line.find("design hierarchy") > 0:
#       hierarchy = True
#     if hierarchy and line.find("Number of cells") > 0:
#       bb = True
#       continue
#     if bb:
#       if line.find('$') < 0 and line.strip():
#         print(relative_path)
#         print(line)

#   fin.seek(0, 0)
#   if hierarchy:
#     start_parse = False
#     for line in fin:
#       if line.find("design hierarchy") > 0:
#         start_parse = True
#       if start_parse:
#         for f_name in field_name:
#           if line.find(f_name) > 0:
#             for token in line.split(): 
#               if token.isdigit():
#                 my_dict[relative_path].append(token)
#   else:
#     for line in fin:
#       for f_name in field_name:
#         if line.find(f_name) > 0:
#           for token in line.split():
#             if token.isdigit():
#               my_dict[relative_path].append(token)

# for subdir, dirs, files in os.walk(start_path):
#   for filename in files:
#     filepath = subdir + os.sep + filename
    
#     if filepath.endswith(".out"):
#         retrieve_info(filepath)

# with open('effective_data.csv', 'w') as csv_file:
#   csv_writer = csv.writer(csv_file, delimiter=',')
#   num = 0
#   for key in sorted(my_dict):
#     row = my_dict[key]
#     if row == []:
#       remove[key] = []
#       continue
#     dump_data = True
#     for e in row:
#       if e != '0':
#         dump_data = False

#     if dump_data:
#       remove[key] = row
#     else:
#       row.insert(0, key)
#       row.insert(0, num)
#       csv_writer.writerow(row)
#       num = num + 1
#   print("effecitive data points: {num}".format(num = num))

# with open('remove_data.csv', 'w') as csv_file:
#   csv_writer = csv.writer(csv_file, delimiter = ',')
#   for key in sorted(remove):
#     row = remove[key]
#     row.insert(0, key)
#     csv_writer.writerow(row)
