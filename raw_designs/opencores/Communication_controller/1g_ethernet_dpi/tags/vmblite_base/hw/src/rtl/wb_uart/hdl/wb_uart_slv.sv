//////////////////////////////////////////////////////////////////////////////////
// Company:         
// Engineer:        IK
// 
// Create Date:     11:35:01 03/21/2013 
// Design Name:     
// Module Name:     wb_uart_slv
// Project Name:    
// Target Devices:  
// Tool versions:   
// Description:     
//                  
//                  
//                  
//                  
// Revision: 
// Revision 0.01 - File Created, 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module wb_uart_slv
(
    // SYS_CON
    input   i_clk,
    input   i_srst,
    // WBS
    input       [ 3:0]  iv_wbs_adr, // byte-addr
    input       [31:0]  iv_wbs_dat,
    input               i_wbs_we,
    input               i_wbs_stb,
    input       [ 3:0]  iv_wbs_sel, // NC, for now
    input               i_wbs_cyc,
    output  reg [31:0]  ov_wbs_dat,
    output  reg         o_wbs_ack,
    // out-ctrl
    output          o_ctrl_utx_start,
    output  [ 7:0]  o_ctrl_utx_data,
    output          o_ctrl_rfifo_rd,
    // in-sts
    input           i_sts_utx_busy,
    input           i_sts_rfifo_ef,
    input   [ 7:0]  iv_sts_rfifo_data
);
//////////////////////////////////////////////////////////////////////////////////
// mem-map:
localparam  lp_RXD_ADDR     =   0*4; // byte-addr
localparam  lp_TXD_ADDR     =   1*4;
localparam  lp_STS_ADDR     =   2*4;

//////////////////////////////////////////////////////////////////////////////////
    // csr
    logic   [31:0]  sv_reg_sts;
    // wb chip-select
    wire    s_wbs_ce;
    
//////////////////////////////////////////////////////////////////////////////////
    // chip-select flag
    assign  s_wbs_ce    =   i_wbs_stb & i_wbs_cyc;
    //
    // 
    assign  o_ctrl_utx_start    =   o_wbs_ack & (iv_wbs_adr == lp_TXD_ADDR);
    assign  o_ctrl_utx_data     =   iv_wbs_dat[7:0];
    assign  o_ctrl_rfifo_rd     =   o_wbs_ack & (iv_wbs_adr == lp_RXD_ADDR);
    
//////////////////////////////////////////////////////////////////////////////////
//
// WB-Slase
//
always @(posedge i_clk)
begin   :   WBS_LOGIC
    if (i_srst)
        begin   :   RST
            ov_wbs_dat <= 0;
            o_wbs_ack  <= 0;
        end
    else
        begin   :   WRK
            // wb-write
            
            // wb-read
            case(iv_wbs_adr)
                lp_RXD_ADDR     :   ov_wbs_dat <= iv_sts_rfifo_data;
                lp_STS_ADDR     :   ov_wbs_dat <= sv_reg_sts;
                default         :   ov_wbs_dat <= 0;
            endcase
            // wb-ask
            o_wbs_ack <=    (s_wbs_ce)? !o_wbs_ack :
                                        1'b0       ;
        end
end

always @(*)
begin   :   STATUS_LOGIC
    // status
    sv_reg_sts      <= 0;
    sv_reg_sts[0]   <= i_sts_utx_busy;
    sv_reg_sts[1]   <= i_sts_rfifo_ef;
    
end
//////////////////////////////////////////////////////////////////////////////////
endmodule
