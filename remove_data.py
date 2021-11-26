fin = open("effective_data", "rt")
fout = open("out_data", "wt")
my_list = []

for line in fin:
  data = line.split(',')
  if len(my_list) == 0:
    fout.write(line)
    my_list.append(data[2:])
    continue

  if data[2:] in my_list:
    continue
  else:
    my_list.append(data[2:])
    fout.write(line)
    continue

fin.close()
fout.close()
