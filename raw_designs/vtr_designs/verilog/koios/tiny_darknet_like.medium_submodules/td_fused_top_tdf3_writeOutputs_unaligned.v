`define EXPONENT 5
`define MANTISSA 10
`define ACTUAL_MANTISSA 11
`define EXPONENT_LSB 10
`define EXPONENT_MSB 14
`define MANTISSA_LSB 0
`define MANTISSA_MSB 9
`define MANTISSA_MUL_SPLIT_LSB 3
`define MANTISSA_MUL_SPLIT_MSB 9
`define SIGN 1
`define SIGN_LOC 15
`define DWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define IEEE_COMPLIANCE 1

module td_fused_top_tdf3_writeOutputs_unaligned (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_continue,
        ap_idle,
        ap_ready,
        indices_01_dout,
        indices_01_empty_n,
        indices_01_read,
        indices_12_dout,
        indices_12_empty_n,
        indices_12_read,
        p_read,
        out_data_address1,
        out_data_ce1,
        out_data_we1,
        out_data_d1
);

parameter    ap_ST_fsm_state1 = 3'd1;
parameter    ap_ST_fsm_state2 = 3'd2;
parameter    ap_ST_fsm_state3 = 3'd4;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
input   ap_continue;
output   ap_idle;
output   ap_ready;
input  [5:0] indices_01_dout;
input   indices_01_empty_n;
output   indices_01_read;
input  [11:0] indices_12_dout;
input   indices_12_empty_n;
output   indices_12_read;
input  [15:0] p_read;
output  [13:0] out_data_address1;
output   out_data_ce1;
output   out_data_we1;
output  [63:0] out_data_d1;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg indices_01_read;
reg indices_12_read;
reg out_data_ce1;
reg out_data_we1;

reg    ap_done_reg;
  reg   [2:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg   [15:0] outputCount_2;
reg   [15:0] outputChanIdx_2;
reg   [15:0] outputRow_4_0;
reg   [15:0] outputRow_4_1;
reg   [15:0] outputRow_4_2;
reg   [15:0] outputRow_4_3;
reg    indices_01_blk_n;
reg    indices_12_blk_n;
reg   [5:0] indices_01_read_reg_309;
reg   [11:0] indices_12_read_reg_315;
wire   [13:0] shl_ln89_fu_160_p2;
reg   [13:0] shl_ln89_reg_320;
wire    ap_CS_fsm_state2;
wire   [15:0] add_ln87_fu_198_p2;
wire   [0:0] icmp_ln88_fu_204_p2;
reg   [0:0] icmp_ln88_reg_333;
reg   [15:0] ap_phi_mux_empty_phi_fu_112_p4;
reg   [15:0] empty_reg_109;
wire    ap_CS_fsm_state3;
wire   [63:0] zext_ln94_8_fu_231_p1;
wire   [15:0] select_ln97_fu_289_p3;
wire   [1:0] trunc_ln86_fu_170_p1;
reg    ap_block_state1;
wire   [11:0] tmp_fu_119_p3;
wire   [8:0] tmp_s_fu_130_p3;
wire   [12:0] zext_ln94_fu_126_p1;
wire   [12:0] zext_ln94_5_fu_137_p1;
wire   [12:0] sub_ln94_fu_141_p2;
wire   [13:0] sub_ln94_cast13_fu_147_p1;
wire   [13:0] zext_ln94_6_fu_151_p1;
wire   [13:0] add_ln94_fu_154_p2;
wire   [3:0] trunc_ln94_fu_218_p1;
wire   [13:0] zext_ln94_7_fu_222_p1;
wire   [13:0] add_ln94_3_fu_226_p2;
wire   [15:0] bitcast_ln94_9_fu_260_p1;
wire   [15:0] bitcast_ln94_8_fu_252_p1;
wire   [15:0] bitcast_ln94_7_fu_244_p1;
wire   [15:0] bitcast_ln94_fu_236_p1;
wire   [15:0] add_ln96_fu_277_p2;
wire   [0:0] icmp_ln97_fu_283_p2;
reg   [2:0] ap_NS_fsm;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_done_reg = 1'b0;
#0 ap_CS_fsm = 3'd1;
#0 outputCount_2 = 16'd0;
#0 outputChanIdx_2 = 16'd0;
#0 outputRow_4_0 = 16'd0;
#0 outputRow_4_1 = 16'd0;
#0 outputRow_4_2 = 16'd0;
#0 outputRow_4_3 = 16'd0;
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if ((1'b1 == ap_CS_fsm_state3)) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln88_reg_333 == 1'd1) & (1'b1 == ap_CS_fsm_state3))) begin
        empty_reg_109 <= 16'd0;
    end else if (((icmp_ln88_fu_204_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
        empty_reg_109 <= add_ln87_fu_198_p2;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state2)) begin
        icmp_ln88_reg_333 <= icmp_ln88_fu_204_p2;
        shl_ln89_reg_320[13 : 2] <= shl_ln89_fu_160_p2[13 : 2];
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state1)) begin
        indices_01_read_reg_309 <= indices_01_dout;
        indices_12_read_reg_315 <= indices_12_dout;
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln88_reg_333 == 1'd1) & (1'b1 == ap_CS_fsm_state3))) begin
        outputChanIdx_2 <= select_ln97_fu_289_p3;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state3)) begin
        outputCount_2 <= ap_phi_mux_empty_phi_fu_112_p4;
    end
end

always @ (posedge ap_clk) begin
    if (((trunc_ln86_fu_170_p1 == 2'd0) & (1'b1 == ap_CS_fsm_state2))) begin
        outputRow_4_0 <= p_read;
    end
end

always @ (posedge ap_clk) begin
    if (((trunc_ln86_fu_170_p1 == 2'd1) & (1'b1 == ap_CS_fsm_state2))) begin
        outputRow_4_1 <= p_read;
    end
end

always @ (posedge ap_clk) begin
    if (((trunc_ln86_fu_170_p1 == 2'd2) & (1'b1 == ap_CS_fsm_state2))) begin
        outputRow_4_2 <= p_read;
    end
end

always @ (posedge ap_clk) begin
    if (((trunc_ln86_fu_170_p1 == 2'd3) & (1'b1 == ap_CS_fsm_state2))) begin
        outputRow_4_3 <= p_read;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state3)) begin
        ap_done = 1'b1;
    end else begin
        ap_done = ap_done_reg;
    end
end

always @ (*) begin
    if (((ap_start == 1'b0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln88_reg_333 == 1'd1) & (1'b1 == ap_CS_fsm_state3))) begin
        ap_phi_mux_empty_phi_fu_112_p4 = 16'd0;
    end else begin
        ap_phi_mux_empty_phi_fu_112_p4 = empty_reg_109;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state3)) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        indices_01_blk_n = indices_01_empty_n;
    end else begin
        indices_01_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (indices_12_empty_n == 1'b0) | (indices_01_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        indices_01_read = 1'b1;
    end else begin
        indices_01_read = 1'b0;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        indices_12_blk_n = indices_12_empty_n;
    end else begin
        indices_12_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((~((ap_start == 1'b0) | (indices_12_empty_n == 1'b0) | (indices_01_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        indices_12_read = 1'b1;
    end else begin
        indices_12_read = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state3)) begin
        out_data_ce1 = 1'b1;
    end else begin
        out_data_ce1 = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln88_reg_333 == 1'd1) & (1'b1 == ap_CS_fsm_state3))) begin
        out_data_we1 = 1'b1;
    end else begin
        out_data_we1 = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if ((~((ap_start == 1'b0) | (indices_12_empty_n == 1'b0) | (indices_01_empty_n == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_state2 : begin
            ap_NS_fsm = ap_ST_fsm_state3;
        end
        ap_ST_fsm_state3 : begin
            ap_NS_fsm = ap_ST_fsm_state1;
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln87_fu_198_p2 = (outputCount_2 + 16'd1);

assign add_ln94_3_fu_226_p2 = (shl_ln89_reg_320 + zext_ln94_7_fu_222_p1);

assign add_ln94_fu_154_p2 = (sub_ln94_cast13_fu_147_p1 + zext_ln94_6_fu_151_p1);

assign add_ln96_fu_277_p2 = (outputChanIdx_2 + 16'd1);

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state2 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_state3 = ap_CS_fsm[32'd2];

always @ (*) begin
    ap_block_state1 = ((ap_start == 1'b0) | (indices_12_empty_n == 1'b0) | (indices_01_empty_n == 1'b0) | (ap_done_reg == 1'b1));
end

assign bitcast_ln94_7_fu_244_p1 = outputRow_4_1;

assign bitcast_ln94_8_fu_252_p1 = outputRow_4_2;

assign bitcast_ln94_9_fu_260_p1 = outputRow_4_3;

assign bitcast_ln94_fu_236_p1 = outputRow_4_0;

assign icmp_ln88_fu_204_p2 = ((add_ln87_fu_198_p2 == 16'd4) ? 1'b1 : 1'b0);

assign icmp_ln97_fu_283_p2 = ((add_ln96_fu_277_p2 == 16'd4) ? 1'b1 : 1'b0);

assign out_data_address1 = zext_ln94_8_fu_231_p1;

assign out_data_d1 = {{{{bitcast_ln94_9_fu_260_p1}, {bitcast_ln94_8_fu_252_p1}}, {bitcast_ln94_7_fu_244_p1}}, {bitcast_ln94_fu_236_p1}};

assign select_ln97_fu_289_p3 = ((icmp_ln97_fu_283_p2[0:0] == 1'b1) ? 16'd0 : add_ln96_fu_277_p2);

assign shl_ln89_fu_160_p2 = add_ln94_fu_154_p2 << 14'd2;

assign sub_ln94_cast13_fu_147_p1 = sub_ln94_fu_141_p2;

assign sub_ln94_fu_141_p2 = (zext_ln94_fu_126_p1 - zext_ln94_5_fu_137_p1);

assign tmp_fu_119_p3 = {{indices_01_read_reg_309}, {6'd0}};

assign tmp_s_fu_130_p3 = {{indices_01_read_reg_309}, {3'd0}};

assign trunc_ln86_fu_170_p1 = outputCount_2[1:0];

assign trunc_ln94_fu_218_p1 = outputChanIdx_2[3:0];

assign zext_ln94_5_fu_137_p1 = tmp_s_fu_130_p3;

assign zext_ln94_6_fu_151_p1 = indices_12_read_reg_315;

assign zext_ln94_7_fu_222_p1 = trunc_ln94_fu_218_p1;

assign zext_ln94_8_fu_231_p1 = add_ln94_3_fu_226_p2;

assign zext_ln94_fu_126_p1 = tmp_fu_119_p3;

always @ (posedge ap_clk) begin
    shl_ln89_reg_320[1:0] <= 2'b00;
end

endmodule //td_fused_top_tdf3_writeOutputs_unaligned
