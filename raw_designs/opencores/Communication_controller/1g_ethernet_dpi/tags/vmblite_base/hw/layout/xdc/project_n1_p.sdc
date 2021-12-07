# clk
set_property LOC AD12 [ get_ports sys_diff_clock_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [ get_ports sys_diff_clock_clk_p]
# ext-rst
#set_property LOC AB7 [ get_ports glbl_rst]
#set_property IOSTANDARD LVCMOS15 [ get_ports glbl_rst]
# led
set_property LOC AB8 [ get_ports led_8bits_tri_o[0]]
set_property IOSTANDARD LVCMOS15 [ get_ports led_8bits_tri_o[0]]

set_property LOC AA8 [ get_ports led_8bits_tri_o[1]]
set_property IOSTANDARD LVCMOS15 [ get_ports led_8bits_tri_o[1]]

set_property LOC AC9 [ get_ports led_8bits_tri_o[2]]
set_property IOSTANDARD LVCMOS15 [ get_ports led_8bits_tri_o[2]]

set_property LOC AB9 [ get_ports led_8bits_tri_o[3]]
set_property IOSTANDARD LVCMOS15 [ get_ports led_8bits_tri_o[3]]

set_property LOC AE26 [ get_ports led_8bits_tri_o[4]]
set_property IOSTANDARD LVCMOS25 [ get_ports led_8bits_tri_o[4]]

set_property LOC G19 [ get_ports led_8bits_tri_o[5]]
set_property IOSTANDARD LVCMOS25 [ get_ports led_8bits_tri_o[5]]

set_property LOC E18 [ get_ports led_8bits_tri_o[6]]
set_property IOSTANDARD LVCMOS25 [ get_ports led_8bits_tri_o[6]]

set_property LOC F16 [ get_ports led_8bits_tri_o[7]]
set_property IOSTANDARD LVCMOS25 [ get_ports led_8bits_tri_o[7]]
# uart
set_property LOC M19 [ get_ports rs232_uart_rxd]
set_property IOSTANDARD LVCMOS25 [ get_ports rs232_uart_rxd]

set_property LOC K24 [ get_ports rs232_uart_txd]
set_property IOSTANDARD LVCMOS25 [ get_ports rs232_uart_txd]
