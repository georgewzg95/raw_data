#!/bin/bash

# USAGE: ./process.sh
# ARGs:
#    <none>
#    -clr
#    -elf
#

ROOT_DIR=$PWD


function run_clr {
echo "CLR:"
make clean -C ./util 
make clean -C ./test_main
}

function run_elf {
echo "ELF:"
make all -C ./util 
make all -C ./test_main
}


echo "START: $(date)"
# proc NO-ARG
if [ "$1" == "" ]; then 
run_clr
run_elf
fi
# proc 1ST-ARG
if [ "$1" == "-clr" ]; then run_clr ; fi
if [ "$1" == "-elf" ]; then run_elf ; fi
# proc 2ND-ARG
if [ "$2" == "-elf" ]; then run_elf ; fi
echo "STOP : $(date)"

# Final
exit 0
