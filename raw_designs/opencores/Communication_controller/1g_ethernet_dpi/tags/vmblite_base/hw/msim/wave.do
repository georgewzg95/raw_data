onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testcase/tb/dut/s_clk_200
add wave -noupdate /testcase/tb/dut/s_clk_50
add wave -noupdate /testcase/tb/dut/U_POR/o_por
add wave -noupdate /testcase/tb/dut/u0/i_clk_50
add wave -noupdate /testcase/tb/dut/u0/i_arst
add wave -noupdate -expand -group dut.IO /testcase/tb/dut/led_8bits_tri_o
add wave -noupdate -expand -group dut.IO /testcase/tb/dut/rs232_uart_rxd
add wave -noupdate -expand -group dut.IO /testcase/tb/dut/rs232_uart_txd
add wave -noupdate -divider {New Divider}
add wave -noupdate -group dut.soc.pu.MBL-WBM.IF /testcase/tb/dut/u0/U_MBLITE/wbm_dat_i
add wave -noupdate -group dut.soc.pu.MBL-WBM.IF /testcase/tb/dut/u0/U_MBLITE/wbm_ack_i
add wave -noupdate -group dut.soc.pu.MBL-WBM.IF /testcase/tb/dut/u0/U_MBLITE/wbm_adr_o
add wave -noupdate -group dut.soc.pu.MBL-WBM.IF /testcase/tb/dut/u0/U_MBLITE/wbm_dat_o
add wave -noupdate -group dut.soc.pu.MBL-WBM.IF /testcase/tb/dut/u0/U_MBLITE/wbm_we_o
add wave -noupdate -group dut.soc.pu.MBL-WBM.IF /testcase/tb/dut/u0/U_MBLITE/wbm_stb_o
add wave -noupdate -group dut.soc.pu.MBL-WBM.IF /testcase/tb/dut/u0/U_MBLITE/wbm_sel_o
add wave -noupdate -group dut.soc.pu.MBL-WBM.IF /testcase/tb/dut/u0/U_MBLITE/wbm_cyc_o
add wave -noupdate -group dut.soc.pu.imem.IF /testcase/tb/dut/u0/U_MBLITE/imem/dat_o
add wave -noupdate -group dut.soc.pu.imem.IF /testcase/tb/dut/u0/U_MBLITE/imem/dat_i
add wave -noupdate -group dut.soc.pu.imem.IF /testcase/tb/dut/u0/U_MBLITE/imem/adr_i
add wave -noupdate -group dut.soc.pu.imem.IF /testcase/tb/dut/u0/U_MBLITE/imem/wre_i
add wave -noupdate -group dut.soc.pu.imem.IF /testcase/tb/dut/u0/U_MBLITE/imem/ena_i
add wave -noupdate -group dut.soc.pu.imem.IF /testcase/tb/dut/u0/U_MBLITE/imem/clk_i
add wave -noupdate -group dut.soc.pu.dmem.IF /testcase/tb/dut/u0/U_MBLITE/dmem/dat_o
add wave -noupdate -group dut.soc.pu.dmem.IF /testcase/tb/dut/u0/U_MBLITE/dmem/dat_i
add wave -noupdate -group dut.soc.pu.dmem.IF /testcase/tb/dut/u0/U_MBLITE/dmem/adr_i
add wave -noupdate -group dut.soc.pu.dmem.IF /testcase/tb/dut/u0/U_MBLITE/dmem/wre_i
add wave -noupdate -group dut.soc.pu.dmem.IF /testcase/tb/dut/u0/U_MBLITE/dmem/ena_i
add wave -noupdate -group dut.soc.pu.dmem.IF /testcase/tb/dut/u0/U_MBLITE/dmem/clk_i
add wave -noupdate -group dut.soc.PIO.WBS /testcase/tb/dut/u0/U_PIO/iv_wbs_adr
add wave -noupdate -group dut.soc.PIO.WBS /testcase/tb/dut/u0/U_PIO/iv_wbs_dat
add wave -noupdate -group dut.soc.PIO.WBS /testcase/tb/dut/u0/U_PIO/i_wbs_we
add wave -noupdate -group dut.soc.PIO.WBS /testcase/tb/dut/u0/U_PIO/i_wbs_stb
add wave -noupdate -group dut.soc.PIO.WBS /testcase/tb/dut/u0/U_PIO/iv_wbs_sel
add wave -noupdate -group dut.soc.PIO.WBS /testcase/tb/dut/u0/U_PIO/i_wbs_cyc
add wave -noupdate -group dut.soc.PIO.WBS /testcase/tb/dut/u0/U_PIO/ov_wbs_dat
add wave -noupdate -group dut.soc.PIO.WBS /testcase/tb/dut/u0/U_PIO/o_wbs_ack
add wave -noupdate -expand -group dut.soc.UART.WBS /testcase/tb/dut/u0/U_UART/iv_wbs_adr
add wave -noupdate -expand -group dut.soc.UART.WBS /testcase/tb/dut/u0/U_UART/iv_wbs_dat
add wave -noupdate -expand -group dut.soc.UART.WBS /testcase/tb/dut/u0/U_UART/i_wbs_we
add wave -noupdate -expand -group dut.soc.UART.WBS /testcase/tb/dut/u0/U_UART/i_wbs_stb
add wave -noupdate -expand -group dut.soc.UART.WBS /testcase/tb/dut/u0/U_UART/iv_wbs_sel
add wave -noupdate -expand -group dut.soc.UART.WBS /testcase/tb/dut/u0/U_UART/i_wbs_cyc
add wave -noupdate -expand -group dut.soc.UART.WBS /testcase/tb/dut/u0/U_UART/ov_wbs_dat
add wave -noupdate -expand -group dut.soc.UART.WBS /testcase/tb/dut/u0/U_UART/o_wbs_ack
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {641014064 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 324
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {871613675 ps} {5474257175 ps}
