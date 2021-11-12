import os
import csv

root_path = os.getcwd()
start_path = root_path + "/raw_designs/vtr_designs"
yosys_path = "/home/zhigang/FeatEx/"

my_dict = {}
remove = {}

def create_folder(filepath, filename):
  dir_name = filename[:-2] + "_submodules"
  dir_path = filepath + os.sep + dir_name
  try:
    os.mkdir(dir_path)
  except OSError as error:
    print(error)
  return dir_path

def gen_ys(filepath):
  fin = open("template_submod.ys", "rt")
  fout = open("out.ys", "wt")
  for line in fin:
    line = line.replace('[DESIGN]', filepath)
    fout.write(line)
  fin.close()
  fout.close()

for subdir, dirs, files in os.walk(start_path):
  for filename in files:
    filepath = subdir + os.sep + filename
    if filename.endswith(".v"):
      submod_path = create_folder(filepath, filename)
      gen_ys(filepath)
      os.system(yosys_path + 'yosys -q -l ' + submod_path + os.sep + filename + '.hier out.ys') 


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
