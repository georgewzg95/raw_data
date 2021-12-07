#!/bin/bash

# USAGE: ./process.sh
# ARGs:
#    <none>
#    -clr
#    -arch
#    -bit
#    -elf
#    -cp
#

ROOT_DIR=$PWD
CP_DIR=~/vbox_share/WORK/Xilinx/upld

function run_clr {
echo "CLR:"
cd $ROOT_DIR/hw/layout
./process.sh -clr &> /dev/null
cd $ROOT_DIR/hw/msim 
./process.sh -clr &> /dev/null
cd $ROOT_DIR/sw
./process.sh -clr &> /dev/null
}

function run_arch {
echo "ARCH:"
cd $ROOT_DIR/../
tar cfJ vmblite_base_$(date +"%Y-%m-%d_%H-%M-%S").tar.xz vmblite_base &> /dev/null
echo "=> done"
}

function run_bit {
echo "BIT:"
cd $ROOT_DIR/hw/layout
./process.sh
}

function run_cp {
echo "CP:"
}

echo "START: $(date)"
# proc NO-ARG
if [ "$1" == "" ]; then 
run_clr
run_bit
run_elf
fi
# proc 1ST-ARG
if [ "$1" == "-clr" ]; then run_clr ; fi
if [ "$1" == "-arch" ]; then run_arch ; fi
if [ "$1" == "-bit" ]; then run_bit ; fi
if [ "$1" == "-elf" ]; then run_elf ; fi
if [ "$1" == "-cp" ]; then run_cp ; fi
# proc 2ND-ARG
if [ "$2" == "-arch" ]; then run_arch ; fi
if [ "$2" == "-bit" ]; then run_bit ; fi
if [ "$2" == "-elf" ]; then run_elf ; fi
if [ "$2" == "-cp" ]; then run_cp ; fi
echo "STOP : $(date)"

# Final
exit 0
