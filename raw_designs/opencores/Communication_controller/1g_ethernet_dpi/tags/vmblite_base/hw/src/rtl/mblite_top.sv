//////////////////////////////////////////////////////////////////////////////////
// Company:         
// Engineer:        IK
// 
// Create Date:     
// Design Name:     
// Module Name:     mblite_top
// Project Name:    
// Target Devices:  
// Tool versions:   
// Description:     
//                  KC705 FPGA design
//                  
// Revision: 
// Revision 0.01 - File Created, 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module mblite_top
(
    //SYS_CON
    input           sys_diff_clock_clk_p, // 200MHz clock input from board
    input           sys_diff_clock_clk_n,
    // LEG
    output [ 7:0]   led_8bits_tri_o,
    // UART
    input           rs232_uart_rxd,
    output          rs232_uart_txd
);
//////////////////////////////////////////////////////////////////////////////////
    // reset
    wire    s_por;
    wire    s_rst;
    // clk_module
    wire    s_clk_200;
    wire    s_locked;
    
//////////////////////////////////////////////////////////////////////////////////
    // RST
    assign  s_rst   =   s_por | !s_locked;
    
//////////////////////////////////////////////////////////////////////////////////
//
// ??
//
IBUFDS      U_IBUFDS
(
.O          (s_clk_200),
.I          (sys_diff_clock_clk_p),
.IB         (sys_diff_clock_clk_n)
);
//////////////////////////////////////////////////////////////////////////////////
//
// POR
//
por_module  #(8) //  p_LEN
            U_POR
(
// SYS_CON
.i_clk      (s_clk_200),
// POR out
.o_por      (s_por)
);

//////////////////////////////////////////////////////////////////////////////////
//
// Clocking Block
//
clk_module  U_CB
(
// CLK-in
.i_clk_200  (s_clk_200),
// CLK-out
.o_clk_50   (s_clk_50),
// ??
.i_arst     (s_por),
.o_locked   (s_locked)
);
//////////////////////////////////////////////////////////////////////////////////
//
// 
//
mblite_soc  u0
(
// SYS_CON
.i_clk_50   (s_clk_50), // 50MHz 
.i_arst     (s_rst),
// UART     [async]
.i_uart_rxd (rs232_uart_rxd),
.o_uart_txd (rs232_uart_txd),
// GPIO     [async]
.iv_gpio    (8'b0),             // BUTTON
.ov_gpio    (led_8bits_tri_o)   // LED
);
//////////////////////////////////////////////////////////////////////////////////
endmodule

