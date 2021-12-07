//////////////////////////////////////////////////////////////////////////////////
// Company:         
// Engineer:        IK
// 
// Create Date:     11:35:01 03/21/2013 
// Design Name:     
// Module Name:     sdpram
// Project Name:    
// Target Devices:  
// Tool versions:   
// Description:     
//                  
//                  MEM for FIFO
//                  
//                  USE "ram_style" for XILINX
//                  USE "ramstyle" for ALTERA
//                  
//                  Because FIFO-VOLUME quite small (8 is enought)
//                      -> no reasons for wasting BRAM on this [use LUTs]
//                  
//                  [
//                      q2 synth anyway will implement this mem on LUTs,
//                      becasue of small volume, 
//                      but attr present for any case
//                  ]
//                  
// Revision: 
// Revision 0.01 - File Created, 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module sdpram #(parameter p_DW = 0, parameter p_AW = 0)
(
    // SYS_CON
    input   i_clk,
    // IN / port-a
    input                   i_we_a,
    input       [p_AW-1:0]  iv_addr_a,
    input       [p_DW-1:0]  iv_data_a,
    // OUT / port-b
    input                   i_rd_b,
    input       [p_AW-1:0]  iv_addr_b,
    output  reg [p_DW-1:0]  ov_data_b
);
//////////////////////////////////////////////////////////////////////////////////
    
    //synthesis attribute ram_style of sv_mem is distributed
    reg     [p_DW-1:0]  sv_mem [2**p_AW-1:0] /* synthesis ramstyle = "logic" */; 
    
//////////////////////////////////////////////////////////////////////////////////
//
// Construct "Simple Dual Port RAM" logic
//
always @ (posedge i_clk)
begin   :   RAM_LOGIC
    // IN / port-a
    if (i_we_a)
        sv_mem[iv_addr_a] <= iv_data_a;
    // OUT / port-b
    if (i_rd_b)
        ov_data_b <= sv_mem[iv_addr_b];
end
//////////////////////////////////////////////////////////////////////////////////
endmodule
