#!/bin/bash
#
# USAGE: ./process.sh
# ARGs:
#    <none>
#    -clr
#    -reasm
#    -fast


GATE_SIM=0
#GATE_SIM=1
#GATE_SIM=2
ROOT_DIR=$PWD

#
# view
if [ "$1" == "-view" ]; then
 vsim -view vsim.wlf -do wave.do
 exit 0
fi

#
# clr
rm -rf work
rm -rf mblite
rm -rf *.h
rm -rf *.tr
rm -rf *wlf*
rm -rf *.hex
rm -rf *.mem
rm -rf *.ver
rm -rf *.so
rm -rf *.log
rm -rf *.pcap
rm -rf *.vstf
rm -rf *.ini
rm -rf *.v
rm -rf *.sdf
rm -rf *transcript*
if [ "$1" == "-clr" ]; then
 exit 0
fi

# deal with GATE-LEVEL sim
if [ ! -d ../../sw/test_main/_bmm ] || [ "$1" == "-reasm" ]; then
 cmd="make -C ../../sw/test_main/"
 $cmd &> mbl-main.log || {
    echo "test_main MAKE failed"
    exit 1
 }
fi
if [ $GATE_SIM == 0 ]; then
 cp -f ../../sw/test_main/_bmm/*.mem ./
fi

#
if [ $GATE_SIM != 0 ]; then
 cd $ROOT_DIR/../layout
 if [ ! -d ./process ]; then
  ./process.sh &> /dev/null
 fi
 ./process.sh -gsim &> /dev/null
 cd $ROOT_DIR
 mv -f ../layout/process/*.sdf ./
 mv -f ../layout/process/*.v ./
fi


# start
export GATE_SIM=$GATE_SIM
if [ "$1" == "-fast" ] || [ "$2" == "-fast" ] 
then
 export FAST_SIM=1
 vsim -c -do start_sim.tcl
else
 export FAST_SIM=0
 vsim -do start_sim.tcl
fi

#
#Final
exit 0
