# clk
create_clock -name sys_clk_pin -period "5.0" [get_ports "sys_diff_clock_clk_p"]
set_input_jitter sys_clk_pin 0.050
