import subprocess
import time
import os
import argparse

def parse_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('-i',
                     '--input',
                     required = True,
                     type = str,
                     help = 'files to collect data from, should be clean designs')

  parser.add_argument('-o',
                     '--output',
                     required = True,
                     type = str,
                     help = 'the output filename containing report results (power and utilization)')

  parser.add_argument('-f',
                     '--feature_file',
                     required = True,
                     type = str,
                     help = 'the input file clean.feat containing feature information (generated from collect.py)')

  args = parser.parse_args()
  return args

def retrieve_info(lines, section, target):
  st = False
  skip = False
  for line in lines:
    if line.find(section) >= 0 and skip == False:
      skip = True
      continue
    if line.find(section) >= 0 and skip == True:
      st = True
      continue
    if st == True and line.find(target) >= 0:
      #print(line.split('|'))
      return line.split('|')[-2].rstrip()

def retrieve_utilization(file):
  with open(file, 'r') as f:
    lines = f.readlines()

  data_list = []
  data_list.append(retrieve_info(lines, '2. Slice Logic Distribution', 'Slice'))
  data_list.append(retrieve_info(lines, '2. Slice Logic Distribution', 'LUT as Logic'))
  data_list.append(retrieve_info(lines, '2. Slice Logic Distribution', 'LUT as Memory'))
  data_list.append(retrieve_info(lines, '2. Slice Logic Distribution', 'LUT Flip Flop Pairs'))

  data_list.append(retrieve_info(lines, '3. Memory', 'Block RAM Tile'))

  data_list.append(retrieve_info(lines, '4. DSP', 'DSPs'))

  data_list.append(retrieve_info(lines, '5. IO and GT Specific', 'Bonded IOB'))

  return data_list

def retrieve_power(file):
  with open(file, 'r') as f:
    lines = f.readlines()

  for line in lines:
    if line.find("Total On-Chip Power (W)") >= 0:
      return line.split('|')[-2].rstrip().split('(')[0].rstrip()

def retrieve_feature(file):
  my_dict = {}
  with open(file, 'r') as f:
    feature_lines = f.readlines()

  for line in feature_lines:
    design_name = line.split(',')[1][:-4]
    data = line.split(',')[2:]
    data_str = ','.join(data)
    my_dict[design_name] = data_str

  return my_dict

if __name__ == "__main__":

  rpt_dir_list = []
  feature_dir_list = []
  args = parse_args()
  with open(args.input, 'r') as f:
    lines = f.readlines()
  for line in lines:
    rpt_dir_list.append(line.split(',')[0].strip())
    feature_dir_list.append(line.split(',')[1])

  output_file = open(args.output + '.rpt', 'w')
  for directory in rpt_dir_list:
    rpt_util_filename = directory + os.sep + 'post_route_util.rpt'
    rpt_power_filename = directory + os.sep + 'post_route_power.rpt'
    data_list = retrieve_utilization(rpt_util_filename)
    data_list.append(retrieve_power(rpt_power_filename))
    output_file.write(directory.rstrip())
    for data in data_list:
      if data.find('<0.01') >= 0:
        data = '0'
      output_file.write(',' + data.strip())
    output_file.write('\n')
  output_file.close()

  output_feature_file = open(args.output + '.feat', 'w')
  feature_dict = retrieve_feature(args.feature_file)
  for directory in feature_dir_list:
    output_feature_file.write(directory + ',' + my_dict[directory])
  output_feature_file.close()

