//////////////////////////////////////////////////////////////////////////////////
// Company:         
// Engineer:        IK
// 
// Create Date:     11:35:01 03/21/2013 
// Design Name:     
// Module Name:     mblite_soc
// Project Name:    
// Target Devices:  
// Tool versions:   
// Description:     
//                  
//                  SoC mem-map:
//                      pu-internal: below 64KB 
//                      pu-external: above 64KB 
//                  
//                  pu-external details:
//                      0x010000 - PIO / 4KB
//                      0x010FFF
//                      
//                      0x011000 - UART / 4KB
//                      0x011FFF
//                      
//                  
// Revision: 
// Revision 0.01 - File Created, 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module mblite_soc
(
    // SYS_CON
    input   i_clk_50, // 50MHz 
    input   i_arst,
    // UART     [async]
    input           i_uart_rxd,
    output          o_uart_txd,
    // GPIO     [async]
    input   [ 7:0]  iv_gpio,    // BUTTON
    output  [ 7:0]  ov_gpio     // LED
);
//////////////////////////////////////////////////////////////////////////////////
// qnty of wbs
localparam  lp_NWBS =   2;

//////////////////////////////////////////////////////////////////////////////////
    // SYS_CON
    wire    s_sys_rst;
    // U_MBLITE.WBM
    wire    [31:0]  sv_wbm_adr_o;
    wire    [31:0]  sv_wbm_dat_o;
    wire            s_wbm_we_o;
    wire            s_wbm_stb_o;
    wire    [ 3:0]  sv_wbm_sel_o;
    wire            s_wbm_cyc_o;
    wire    [ 3:0]  s_mwb_sel_o;
    
    wire    [31:0]  sv_wbm_dat_i;
    wire            s_wbm_ack_i;
    // WB-Slaves
    wire    [16:0]          sv_wbs_iadr[lp_NWBS];
    wire    [31:0]          sv_wbs_idat[lp_NWBS];
    wire    [lp_NWBS-1:0]   sv_wbs_iwe;
    wire    [lp_NWBS-1:0]   sv_wbs_istb;
    wire    [ 3:0]          sv_wbs_isel[lp_NWBS];
    wire    [lp_NWBS-1:0]   sv_wbs_icyc;
    wire    [31:0]          sv_wbs_odat[lp_NWBS];
    wire    [lp_NWBS-1:0]   sv_wbs_oack;
    // WB-Cross
    wire    [lp_NWBS-1:0]   sv_wbc_cs;
    
//////////////////////////////////////////////////////////////////////////////////
//
// RST_SYNC
//
rst_sync    U_SRST
(
// SYS_CON
.i_clk      (i_clk_50),
// iRST
.i_arst     (i_arst),
// oRST
.o_srst     (s_sys_rst)
);
//////////////////////////////////////////////////////////////////////////////////
//
// WBS[0]: PIO
//
wb_pio_top  #(8) // p_DW
            U_PIO
(
// SYS_CON
.i_clk      (i_clk_50),
.i_srst     (s_sys_rst),
// PIO
.iv_pio     (iv_gpio),
.ov_pio     (ov_gpio),
// WBS
.iv_wbs_adr (sv_wbs_iadr[0][3:0]), // byte-addr
.iv_wbs_dat (sv_wbs_idat[0]),
.i_wbs_we   (sv_wbs_iwe[0]),
.i_wbs_stb  (sv_wbs_istb[0]),
.iv_wbs_sel (sv_wbs_isel[0]),
.i_wbs_cyc  (sv_wbs_icyc[0]),
.ov_wbs_dat (sv_wbs_odat[0]),
.o_wbs_ack  (sv_wbs_oack[0])
);
//////////////////////////////////////////////////////////////////////////////////
//
// WBS[1]: UART
//
wb_uart_top #(64, 50_000_000, 115_200) // p_FDEPTH, p_FREQ, p_BAUD
            U_UART
(
// SYS_CON
.i_clk      (i_clk_50),
.i_srst     (s_sys_rst),
// WBS      [i_clk]
.iv_wbs_adr (sv_wbs_iadr[1][3:0]), // byte-addr
.iv_wbs_dat (sv_wbs_idat[1]),
.i_wbs_we   (sv_wbs_iwe[1]),
.i_wbs_stb  (sv_wbs_istb[1]),
.i_wbs_cyc  (sv_wbs_icyc[1]),
.iv_wbs_sel (sv_wbs_isel[1]),
.ov_wbs_dat (sv_wbs_odat[1]),
.o_wbs_ack  (sv_wbs_oack[1]),
// UART     [async]
.i_uart_rxd (i_uart_rxd),
.o_uart_txd (o_uart_txd)
);
//////////////////////////////////////////////////////////////////////////////////
//
// WBM: MB-Lite unit
//  => pu + imem + dmem
//
mblite_unit U_MBLITE
(
// SYS_CON
.sys_clk_i  (i_clk_50),
.sys_rst_i  (s_sys_rst),
// IRQ
.sys_int_i  (1'b0),         // interrupt input
// WB-master inputs from the wb-slaves
.wbm_dat_i  (sv_wbm_dat_i), // databus input
.wbm_ack_i  (s_wbm_ack_i),  // buscycle acknowledge input
// WB-master outputs to the wb-slaves
.wbm_adr_o  (sv_wbm_adr_o), // address bits
.wbm_dat_o  (sv_wbm_dat_o), // databus output
.wbm_we_o   (s_wbm_we_o),   // write enable output
.wbm_stb_o  (s_wbm_stb_o),  // strobe signals
.wbm_sel_o  (sv_wbm_sel_o), // select output array
.wbm_cyc_o  (s_wbm_cyc_o)   // valid BUS cycle output
);
//////////////////////////////////////////////////////////////////////////////////
//
// WB-Cross
//  simple: {1 WB-Master} + {N WB-Slave}
//
assign sv_wbc_cs[0] = sv_wbm_adr_o[16:12] == 5'h10; // 0x010000
assign sv_wbc_cs[1] = sv_wbm_adr_o[16:12] == 5'h11; // 0x011000

assign  sv_wbs_iwe[0]   =   s_wbm_we_o;
assign  sv_wbs_iadr[0]  =   sv_wbm_adr_o;
assign  sv_wbs_idat[0]  =   sv_wbm_dat_o;
assign  sv_wbs_istb[0]  =   s_wbm_stb_o;
assign  sv_wbs_isel[0]  =   sv_wbm_sel_o;
assign  sv_wbs_icyc[0]  =   s_wbm_cyc_o & sv_wbc_cs[0];

assign  sv_wbs_iwe[1]   =   s_wbm_we_o;
assign  sv_wbs_iadr[1]  =   sv_wbm_adr_o;
assign  sv_wbs_idat[1]  =   sv_wbm_dat_o;
assign  sv_wbs_istb[1]  =   s_wbm_stb_o;
assign  sv_wbs_isel[1]  =   sv_wbm_sel_o;
assign  sv_wbs_icyc[1]  =   s_wbm_cyc_o & sv_wbc_cs[1];


assign  sv_wbm_dat_i    =   (sv_wbc_cs[0])? sv_wbs_odat[0] : 
                                            sv_wbs_odat[1] ; 
assign  s_wbm_ack_i     =   (sv_wbc_cs[0])? sv_wbs_oack[0] : 
                                            sv_wbs_oack[1] ;
//////////////////////////////////////////////////////////////////////////////////
endmodule
