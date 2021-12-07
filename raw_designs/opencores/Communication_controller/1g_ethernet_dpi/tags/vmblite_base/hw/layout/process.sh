#!/bin/bash

# USAGE: ./process.sh
# ARGs:
#    <none>
#    -o
#    -clr
#    -asm
#    -gsim

# gui-open
if [ "$1" == "-o" ]; then
 cd process
 vivado ./project_n1.xpr 
 exit 0
fi

# gate-sim
if [ "$1" == "-gsim" ]; then
 cd process
 vivado -mode batch -source ../tcl/vgsim.tcl 
 exit 0
fi

# clr
rm -rf .Xil
rm -rf process
rm -rf *.jou
rm -rf *.log
rm -rf ../src/rtl/mblite/std/*.mem
if [ "$1" == "-clr" ]; then
 exit 0
fi

# prep
mkdir process
cd process
if [ ! -d ../../../sw/test_main/_bmm ]; then
 cmd="make -C ../../../sw/test_main"
 $cmd &> mbl-main.log || {
    echo "test_main MAKE failed"
    exit 1
 }
fi
cp -f ../../../sw/test_main/_bmm/*.mem ../../src/rtl/mblite/std

# prj-cre
vivado -mode batch -source ../tcl/vsetup.tcl 
if [ "$1" == "-asm" ]; then
 exit 0
fi

# prj-asm
vivado -mode batch -source ../tcl/vrun.tcl 

# Final
exit 0
