//////////////////////////////////////////////////////////////////////////////////
// Company:         
// Engineer:        IK
// 
// Create Date:     
// Design Name:     
// Module Name:     wb_uart_mscfifo
// Project Name:    
// Target Devices:  
// Tool versions:   
// Description:     
//                  
//                  single clock FWFT FIFO
//                  
//                  
//                  
// Revision: 
// Revision 0.01 - File Created, 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module wb_uart_mscfifo #(parameter p_DW = 0, p_AW = 0)
(
    // SYS_CON
    input   i_clk,
    input   i_arst,
    // DIN
    input               i_wr,
    input   [p_DW-1:0]  iv_data,
    // DOUT
    input               i_rd,
    output  [p_DW-1:0]  ov_data,
    // STS-OUT
    output  [p_AW-1:0]  ov_count,
    output              o_full,
    output  reg         o_empty
);
//////////////////////////////////////////////////////////////////////////////////
    // LEN
    reg     [p_AW-1:0]  sv_length;
    wire                s_last_data;
    // ADDR
    reg     [p_AW-1:0]  sv_raddr;
    reg     [p_AW-1:0]  sv_waddr;
    wire                s_rd;
    reg                 s_1st_wr;
    // FWFT
    reg                 s_fwft_flag;
    reg     [p_DW-1:0]  sv_fwft_data;
    // BRAM
    wire    [p_DW-1:0]  sv_data_bram;
    
//////////////////////////////////////////////////////////////////////////////////
    // LAST-DATA flag
    assign  s_last_data =   (sv_length == 1);
    // inner-RD 
    assign  s_rd        =   s_1st_wr | (i_rd & ((!s_last_data & !o_empty) | i_wr));
    //
    // DOUT
    assign  ov_data     =   (s_fwft_flag)? sv_fwft_data : sv_data_bram;
    // FF
    assign  o_full      =   (sv_length == {p_AW{1'b1}});
    // CNT
    assign  ov_count    =   sv_length;
    
//////////////////////////////////////////////////////////////////////////////////
//
// Construct FIFO-CTRL logic
//
always @ (posedge i_clk or posedge i_arst)
begin   :   FIFO_CTRL_LOGIC
    if (i_arst)
        begin   :   RST
            sv_length <= 0;
            s_1st_wr <= 0;
            sv_raddr <= 0;
            sv_waddr <= 0;
            s_fwft_flag <= 0;
            sv_fwft_data <= 0;
        end
    else
        begin   :   WRK
            // FIFO-LEN
            if (i_wr & !i_rd & !o_full)
                sv_length <= sv_length + 1'b1;
            else if (!i_wr & i_rd & !o_empty)
                sv_length <= sv_length - 1'b1;
            // 1st-wr flag (in empty fifo)
            s_1st_wr <= i_wr & (sv_length == 0);
            // rd-addr
            if (s_rd)
                sv_raddr <= sv_raddr + 1'b1;
            // wr-addr
            if (i_wr)
                sv_waddr <= sv_waddr + 1'b1;
            // fwft-flag
            if (i_rd & !i_wr)
                s_fwft_flag <= 0;
            else if (i_rd & i_wr & s_last_data)
                s_fwft_flag <= 1;
            // fwft-data
            if (i_rd & i_wr & s_last_data)
                sv_fwft_data <= iv_data;
        end
end
//////////////////////////////////////////////////////////////////////////////////
//
// Construct EF
//
always @ (posedge i_clk or posedge i_arst)
begin   :   EF_LOGIC
    if (i_arst)
        begin   :   RST
            o_empty <= 1;
        end
    else
        begin   :   WRK
            if (s_1st_wr)
                o_empty <= 0;
            else if (i_rd & !i_wr & s_last_data)
                o_empty <= 1;
        end
end
//////////////////////////////////////////////////////////////////////////////////
//
// Instantiate BRAM
//
sdpram      #(p_DW, p_AW) // p_DW, p_AW
            U_SDPRAM
(
// SYS_CON
.i_clk      (i_clk),
// IN / port-a
.i_we_a     (i_wr),
.iv_addr_a  (sv_waddr),
.iv_data_a  (iv_data),
// OUT / port-b
.i_rd_b     (s_rd),
.iv_addr_b  (sv_raddr),
.ov_data_b  (sv_data_bram)
);
//////////////////////////////////////////////////////////////////////////////////
endmodule
