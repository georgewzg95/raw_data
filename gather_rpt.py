import subprocess
import time
import os
import argparse

report_dir = '/misc/scratch/zwei1/reports/'
root_dir = '/misc/scratch/zwei1/raw_data'

def parse_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('-i',
                     '--input',
                     required = True,
                     type = str,
                     help = 'files to collect data from, should be effective_design')

  parser.add_argument('-o',
                     '--output',
                     required = True,
                     type = str,
                     help = 'the collected output filename')

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
      return line.split('|')[-2].rstrip()

if __name__ == "__main__":

  dir_list = []
  args = parse_args()
  with open(args.input, 'r') as f:
    lines = f.readlines()
  for line in lines:
    dir_list.append(line.split(',')[0].rstrip())

  output_file = open(args.output, 'w')
  for directory in dir_list:
    rpt_util_filename = directory + os.sep + 'post_route_util.rpt'
    rpt_power_filename = directory + os.sep + 'post_route_power.rpt'
    data_list = retrieve_utilization(rpt_util_filename)
    data_list.append(retrieve_power(rpt_power_filename))
    output_file.write(directory.rstrip())
    for data in data_list:
      output_file.write(',' + data)
    output_file.write('\n')
  output_file.close()