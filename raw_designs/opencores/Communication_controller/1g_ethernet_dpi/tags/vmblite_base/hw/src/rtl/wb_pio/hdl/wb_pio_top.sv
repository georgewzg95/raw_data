//////////////////////////////////////////////////////////////////////////////////
// Company:         
// Engineer:        IK
// 
// Create Date:     11:35:01 03/21/2013 
// Design Name:     
// Module Name:     wb_pio_top
// Project Name:    
// Target Devices:  
// Tool versions:   
// Description:     
//                  simple pio-in/out, with DW-read/write
//                  
//                  WBS mem-map:
//                      0:     [in]
//                      4:     [out]
//                  
//                  
// Revision: 
// Revision 0.01 - File Created, 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module wb_pio_top #(parameter p_DW = 0)
(
    // SYS_CON
    input   i_clk,
    input   i_srst,
    // PIO
    input       [p_DW-1:0]  iv_pio,
    output  reg [p_DW-1:0]  ov_pio,
    // WBS
    input       [ 3:0]  iv_wbs_adr, // byte-addr
    input       [31:0]  iv_wbs_dat,
    input               i_wbs_we,
    input               i_wbs_stb,
    input       [ 3:0]  iv_wbs_sel, // NC, for now
    input               i_wbs_cyc,
    output  reg [31:0]  ov_wbs_dat,
    output  reg         o_wbs_ack
);
//////////////////////////////////////////////////////////////////////////////////
// mem-map def
localparam  lp_IN_ADDR  =   0*4; // byte-addr
localparam  lp_OUT_ADDR =   1*4; // ..

//////////////////////////////////////////////////////////////////////////////////
    // chip-select
    wire    s_wbs_ce;
    // ireg
    reg     [p_DW-1:0]  sv_pio_i;
    
//////////////////////////////////////////////////////////////////////////////////
    // chip-select flag
    assign  s_wbs_ce    =   i_wbs_stb & i_wbs_cyc;
    
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
            
            ov_pio <= 0;
        end
    else
        begin   :   WRK
            // wb-write
            if (s_wbs_ce & i_wbs_we & (iv_wbs_adr == lp_OUT_ADDR))
                ov_pio <= iv_wbs_dat;
            // wb-read
            case(iv_wbs_adr)
                lp_IN_ADDR  :   ov_wbs_dat <= sv_pio_i;
                lp_OUT_ADDR :   ov_wbs_dat <= ov_pio;
                default     :   ov_wbs_dat <= 0;
            endcase
            // wb-ask
            o_wbs_ack <=    (s_wbs_ce)? !o_wbs_ack :
                                        1'b0       ;
        end
end
//////////////////////////////////////////////////////////////////////////////////
//
// In-REG
//
always @(posedge i_clk)
begin   :   IREG_LOGIC
    sv_pio_i <= iv_pio;
end
//////////////////////////////////////////////////////////////////////////////////
endmodule
