import os
import csv

# root_path = os.getcwd()
# #start_path = root_path + "/raw_designs/vtr_designs/verilog/stereovision0_submodules/scl_v_fltr.v.out"
# #start_path = root_path + "/raw_designs/test_designs/"
# #start_path = root_path + "/raw_designs/vtr_designs/verilog/koios"
# start_path = root_path + "/raw_designs/vtr_designs/"
# #start_path = root_path + "/raw_designs/opencores/arithmetic"
# cur_path = root_path

field_name = ['Name',
              'Number of wires',
              'Number of wire bits',
              'Number of public wires',
              'Number of public wire bits',
              'Number of memories',
              'Number of memory bits',
              'Number of processes',
              'Number of cells']

cell_name = [ '$not',  '$pos', '$neg', 
              '$reduce_and', '$reduce_or', '$reduce_xor', '$reduce_xor', '$reduce_xnor', '$reduce_bool',
              '$logic_not', '$slice', '$lut', '$sop',

              '$and', '$or', '$xor', '$xnor',
              '$shl', '$shr', '$sshl', '$sshr', '$shift', '$shiftx',
              '$lt', '$le', '$eq', '$ne', '$eqx', '$nex', '$ge', '$gt',
              '$add', '$sub', '$mul', '$div', '$mod', '$divfloor', '$modfloor', '$pow',
              '$logic_and', '$logic_or', '$concat', '$macc',

              '$mux', '$pmux',

              '$lcu', '$alu','$fa',

              '$sr', '$ff', '$dff', '$dffe', '$dffsr', '$dffsre',
              '$adff', '$adffe', '$aldff', '$aldffe', '$sdff', '$sdffe',
              '$sdffce', '$dlatch', '$adlatch', '$dlatchsr',

              '$memrd', '$memrd_v2', '$memwr', '$memwr_v2', '$meminit',
              '$meminit_v2', '$mem', '$mem_v2', '$fsm']

my_dict = {}
remove = {}

def retrieve_info(filepath):
  #relative_path = os.path.relpath(filepath, cur_path)
  relative_path = filepath
  fin = open(filepath, "rt")
  if relative_path not in my_dict:
    my_dict[relative_path] = []

  hierarchy = False
  bb = False
  for line in fin:
    if line.find("design hierarchy") >= 0:
      hierarchy = True
    if hierarchy and line.find("Number of cells") >= 0:
      bb = True
      continue
    if bb:
      if line.find('$') < 0 and line.strip():
        print(relative_path)
        print(line)
        remove[relative_path] = []

  fin.seek(0, 0)
  if not hierarchy:
    for line in fin:
      if line.find("Number of cells") >= 0:
        bb = True
        continue
      if bb:
        if line.find('$') < 0 and line.strip():
          print(relative_path)
          print(line)
          remove[relative_path] = []

  fin.seek(0, 0)
  cell_dict = {}
  if hierarchy:
    start_parse = False
    start_cell = False
    for line in fin:
      if line.find("design hierarchy") > 0:
        start_parse = True

      if start_cell == True and line.rstrip():
        if line.split()[0] not in cell_dict:
          cell_dict[line.split()[0]] = line.split()[1]

      if start_parse:
        if line.find('Number of cells:') >= 0:
          start_cell = True
        for f_name in field_name:
          if line.find(f_name) > 0:
            for token in line.split(): 
              if token.isdigit():
                my_dict[relative_path].append(token)
      

  else:
    start_cell = False
    for line in fin:
      if start_cell == True and line.rstrip():
        if line.split()[0] not in cell_dict:
          cell_dict[line.split()[0]] = line.split()[1]

      if line.find('Number of cells:') >= 0:
        start_cell = True
      for f_name in field_name:
        if line.find(f_name) > 0:
          for token in line.split():
            if token.isdigit():
              my_dict[relative_path].append(token)

  for cell in cell_name:
    if cell not in cell_dict:
      my_dict[relative_path].append('0')
    else:
      my_dict[relative_path].append(cell_dict[cell])


def parse_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('-d',
                     '--directory',
                     required = True,
                     type = str,
                     help = 'the directory to collect all .out file from')

  parser.add_argument('-o',
                     '--output',
                     required = True,
                     type = str,
                     help = 'the output file consisting all features')

  parser.add_argument('-c',
                     '--clean_file',
                     required = True,
                     type = str,
                     help = 'the output file consisting features after removing redundent designs')

  args = parser.parse_args()
  return args

if __name__ == "__main__":

  with open('features.csv', 'wt') as f:
    for ele in field_name:
      f.write(','+ele)
    for ele in cell_name:
      f.write(','+ele)



  for subdir, dirs, files in os.walk(args.directory):
    for filename in files:
      filepath = subdir + os.sep + filename
      if filepath.endswith(".out"):
          retrieve_info(filepath)

  with open(args.output, 'w') as csv_file:
    csv_writer = csv.writer(csv_file, delimiter=',')
    num = 0
    for key in sorted(my_dict):
      if key in remove:
        continue

      row = my_dict[key]
      if row == []:
        remove[key] = []
        continue
      dump_data = True
      for e in row:
        if e != '0':
          dump_data = False

      if dump_data:
        remove[key] = row
      else:
        row.insert(0, key)
        row.insert(0, num)
        csv_writer.writerow(row)
        num = num + 1
    print("effecitive data points: {num}".format(num = num))

  with open("removed_data.csv", 'w') as csv_file:
    csv_writer = csv.writer(csv_file, delimiter = ',')
    for key in sorted(remove):
      row = remove[key]
      row.insert(0, key)
      csv_writer.writerow(row)

  fin = open(args.output, "rt")
  fout = open(args.clean_file, "wt")
  removed_file = open("removed_data.csv", "a+")
  my_list = []
  for line in fin:
    data = line.split(',')
    # if len(my_list) == 0:
    #   fout.write(line)
    #   my_list.append(data[2:])
    #   continue

    if data[2:] in my_list:
      removed_file.write(line)
      continue
    else:
      my_list.append(data[2:])
      fout.write(line)
      continue

  fin.close()
  fout.close()
  removed_file.close()