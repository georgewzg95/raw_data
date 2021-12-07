//////////////////////////////////////////////////////////////////////////////////
// Company:         
// Engineer:        IK
// 
// Create Date:     11:35:01 03/21/2013 
// Design Name:     
// Module Name:     wb_uart_top
// Project Name:    
// Target Devices:  
// Tool versions:   
// Description:     
//                  
//                  
//                  WBS mem-map:
//                      
//                      
//                  
//                  
// Revision: 
// Revision 0.01 - File Created, 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module wb_uart_top #
(
    parameter p_FDEPTH  = 0,    // fifo-depth
    parameter p_FREQ    = 0,    // input clk-freq
    parameter p_BAUD    = 0     // uaart baud-rate
)
(
    // SYS_CON
    input   i_clk,
    input   i_srst,
    // WBS      [i_clk]
    input   [ 3:0]  iv_wbs_adr, // byte-addr
    input   [31:0]  iv_wbs_dat,
    input           i_wbs_we,
    input           i_wbs_stb,
    input   [ 3:0]  iv_wbs_sel, // NC, for now
    input           i_wbs_cyc,
    output  [31:0]  ov_wbs_dat,
    output          o_wbs_ack,
    // UART     [async]
    input           i_uart_rxd,
    output  reg     o_uart_txd
);
//////////////////////////////////////////////////////////////////////////////////
    // ctrl
    wire            s_ctrl_utx_start;
    wire    [ 7:0]  s_ctrl_utx_data;
    wire            s_ctrl_rfifo_rd;
    // sts
    wire            s_sts_utx_busy;
    wire            s_sts_rfifo_ef;
    wire    [ 7:0]  sv_sts_rfifo_data;
    // U_RX-if
    wire            s_urx_ready;
    wire    [ 7:0]  sv_urx_data;
    // U_TX
    wire            s_uart_txd;
    
//////////////////////////////////////////////////////////////////////////////////
//
// WBS
//
wb_uart_slv         U_WBS
(
// SYS_CON
.i_clk              (i_clk),
.i_srst             (i_srst),
// WBS
.iv_wbs_adr         (iv_wbs_adr), // byte-addr
.iv_wbs_dat         (iv_wbs_dat),
.i_wbs_we           (i_wbs_we),
.i_wbs_stb          (i_wbs_stb),
.iv_wbs_sel         (iv_wbs_sel),
.i_wbs_cyc          (i_wbs_cyc),
.ov_wbs_dat         (ov_wbs_dat),
.o_wbs_ack          (o_wbs_ack),
// out-ctrl
.o_ctrl_utx_start   (s_ctrl_utx_start),
.o_ctrl_utx_data    (s_ctrl_utx_data),
.o_ctrl_rfifo_rd    (s_ctrl_rfifo_rd),
// in-sts
.i_sts_utx_busy     (s_sts_utx_busy),
.i_sts_rfifo_ef     (s_sts_rfifo_ef),
.iv_sts_rfifo_data  (sv_sts_rfifo_data)
);
//////////////////////////////////////////////////////////////////////////////////
//
// RX-FIFO
//
wb_uart_mscfifo     #(8, $clog2(p_FDEPTH)) //  p_DW, p_AW
                    U_RFIFO
(
// SYS_CON
.i_clk              (i_clk),
.i_arst             (i_srst),
// DIN
.i_wr               (s_urx_ready),
.iv_data            (sv_urx_data),
// DOUT
.i_rd               (s_ctrl_rfifo_rd),
.ov_data            (sv_sts_rfifo_data),
// STS-OUT
.ov_count           (),
.o_full             (),
.o_empty            (s_sts_rfifo_ef)
);
//////////////////////////////////////////////////////////////////////////////////
//
// UART modules
//
async_transmitter   #(p_FREQ, p_BAUD) // ClkFrequency, Baud
                    U_TX
(
// SYS_CON
.clk                (i_clk),
// if
.TxD_start          (s_ctrl_utx_start),
.TxD_data           (s_ctrl_utx_data),
.TxD_busy           (s_sts_utx_busy),
// out
.TxD                (s_uart_txd) // output == LUT-out
);
always @(posedge i_clk) // top-output == REG-out
    o_uart_txd <= s_uart_txd;

async_receiver      #(p_FREQ, p_BAUD) // ClkFrequency, Baud
                    U_RX
(
// SYS_CON
.clk                (i_clk),
// if
.RxD_data_ready     (s_urx_ready),
.RxD_data           (sv_urx_data),
// in
.RxD                (i_uart_rxd),
// nc
.RxD_idle           (),
.RxD_endofpacket    ()
);
//////////////////////////////////////////////////////////////////////////////////
endmodule
