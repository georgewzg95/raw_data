
open_project ./project_n1.xpr

config_webtalk -user off

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

open_run impl_1
write_verilog -force -mode timesim -sdf_anno true -sdf_file project_n1.sdf project_n1_impl_timing.v
#write_verilog -force -mode timesim -sdf_file project_n1.sdf project_n1_impl_timing.v
write_sdf project_n1.sdf

close_project
