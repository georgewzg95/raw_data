#
quit -sim

#
quietly set SYS_PATH "~/Xilinx/Vivado/2015.4/data/verilog/src"

# cfg-env
quietly set FAST_SIM $::env(FAST_SIM)
quietly set GATE_SIM $::env(GATE_SIM)

#
if { [file exists "work"] } { file delete -force "work" }
vlib work
if { [file exists "mblite"] } { file delete -force "mblite" }
vlib mblite

#
if { $GATE_SIM > 0 } {
 vlog -quiet *.v
} else {
 vlog -quiet -work work $SYS_PATH/glbl.v 

 vcom -quiet     -work mblite -f vcom_synth.f
 vlog -quiet -sv -work work   -f vlog_synth.f
}
#
if { $GATE_SIM > 0 } {
 vlog -quiet -sv -work work +define+GATE_LEVEL=1 -f vlog_sim.f
} else {
 vlog -quiet -sv -work work -f vlog_sim.f
}

# sim
if { $GATE_SIM == 1 } {
 vsim -t ps -L secureip -L simprims_ver work.testcase work.glbl
 log -r /*
 do wave.do
} elseif { $GATE_SIM == 2 } {
 vsim -novopt +sdf_verbose -t 1ps +transport_int_delays +pulse_r/0 +pulse_int_r/0 -L simprims_ver -L secureip -L mblite work.testcase work.glbl
 log -r /*
 do wave.do
} else {
 if { $FAST_SIM == 1 } {
  vsim -quiet  -t ps -L unisims_ver -L mblite work.testcase work.glbl
 } else {
  vsim -novopt -t ps -L unisims_ver -L mblite work.testcase work.glbl

  log -r /*
  do wave.do
 }
}
quietly set StdArithNoWarnings 1
quietly set NumericStdNoWarnings 1

run -all
