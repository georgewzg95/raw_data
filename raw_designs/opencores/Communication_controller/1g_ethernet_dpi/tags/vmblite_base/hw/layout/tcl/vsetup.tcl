
create_project project_n1 ./ -part xc7k325tffg900-2

set obj [get_projects project_n1]

set_property "board_part" "xilinx.com:kc705:part0:1.2" $obj
set_property "default_lib" "mblite" $obj
set_property "sim.ip.auto_export_scripts" "1" $obj
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "Verilog" $obj
set_property "target_simulator" "ModelSim" $obj

add_files -norecurse ../xdc/project_n1_b.sdc 
add_files -norecurse ../xdc/project_n1_p.sdc 
add_files -norecurse ../xdc/project_n1_t.sdc 

add_files -norecurse ../../src/rtl/mblite_top.sv
add_files -norecurse ../../src/rtl/mblite_soc.sv 
add_files -norecurse ../../src/rtl/misc/clk_module.sv 
add_files -norecurse ../../src/rtl/misc/por_module.sv 
add_files -norecurse ../../src/rtl/misc/rst_sync.sv 
add_files -norecurse ../../src/rtl/wb_pio/hdl/wb_pio_top.sv 
add_files -norecurse ../../src/rtl/wb_uart/hdl/async.v 
add_files -norecurse ../../src/rtl/wb_uart/hdl/wb_uart_mscfifo.v 
add_files -norecurse ../../src/rtl/wb_uart/hdl/wb_uart_sdpram.v 
add_files -norecurse ../../src/rtl/wb_uart/hdl/wb_uart_slv.sv 
add_files -norecurse ../../src/rtl/wb_uart/hdl/wb_uart_top.sv 
add_files -norecurse ../../src/rtl/mblite/config_Pkg.vhd 
add_files -norecurse ../../src/rtl/mblite/std/std_Pkg.vhd 
add_files -norecurse ../../src/rtl/mblite/std/dsram.vhd 
add_files -norecurse ../../src/rtl/mblite/std/sram.vhd 
add_files -norecurse ../../src/rtl/mblite/std/sram_4en.vhd 
add_files -norecurse ../../src/rtl/mblite/core/core_Pkg.vhd 
add_files -norecurse ../../src/rtl/mblite/core/core.vhd 
add_files -norecurse ../../src/rtl/mblite/core/core_address_decoder.vhd 
add_files -norecurse ../../src/rtl/mblite/core/core_wb_adapter.vhd 
add_files -norecurse ../../src/rtl/mblite/core/decode.vhd 
add_files -norecurse ../../src/rtl/mblite/core/execute.vhd 
add_files -norecurse ../../src/rtl/mblite/core/fetch.vhd 
add_files -norecurse ../../src/rtl/mblite/core/gprf.vhd 
add_files -norecurse ../../src/rtl/mblite/core/mem.vhd 
add_files -norecurse ../../src/rtl/mblite/mblite_unit.vhd 

set obj [get_filesets sources_1]
set_property "top" "mblite_top" $obj

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

close_project
