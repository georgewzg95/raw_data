`define SIMULATION_MEMORY

module elementwise_mult_core_18_18_10_16_1 (
	input clk,
	input reset,
	input i_valid,
	input i_ready,
	input [17:0] i_A_0,
	input [17:0] i_B_0,
	output [17:0] o_C_0,
	input [17:0] i_A_1,
	input [17:0] i_B_1,
	output [17:0] o_C_1,
	input [17:0] i_A_2,
	input [17:0] i_B_2,
	output [17:0] o_C_2,
	input [17:0] i_A_3,
	input [17:0] i_B_3,
	output [17:0] o_C_3,
	input [17:0] i_A_4,
	input [17:0] i_B_4,
	output [17:0] o_C_4,
	input [17:0] i_A_5,
	input [17:0] i_B_5,
	output [17:0] o_C_5,
	input [17:0] i_A_6,
	input [17:0] i_B_6,
	output [17:0] o_C_6,
	input [17:0] i_A_7,
	input [17:0] i_B_7,
	output [17:0] o_C_7,
	input [17:0] i_A_8,
	input [17:0] i_B_8,
	output [17:0] o_C_8,
	input [17:0] i_A_9,
	input [17:0] i_B_9,
	output [17:0] o_C_9,
	input [17:0] i_A_10,
	input [17:0] i_B_10,
	output [17:0] o_C_10,
	input [17:0] i_A_11,
	input [17:0] i_B_11,
	output [17:0] o_C_11,
	input [17:0] i_A_12,
	input [17:0] i_B_12,
	output [17:0] o_C_12,
	input [17:0] i_A_13,
	input [17:0] i_B_13,
	output [17:0] o_C_13,
	input [17:0] i_A_14,
	input [17:0] i_B_14,
	output [17:0] o_C_14,
	input [17:0] i_A_15,
	input [17:0] i_B_15,
	output [17:0] o_C_15,
	output o_valid,
	output o_ready
);

// Store inputs and outputs in registers
reg [17:0] reg_A_0;
reg [17:0] reg_B_0;
wire [17:0] reg_C_0;
reg [17:0] reg_A_1;
reg [17:0] reg_B_1;
wire [17:0] reg_C_1;
reg [17:0] reg_A_2;
reg [17:0] reg_B_2;
wire [17:0] reg_C_2;
reg [17:0] reg_A_3;
reg [17:0] reg_B_3;
wire [17:0] reg_C_3;
reg [17:0] reg_A_4;
reg [17:0] reg_B_4;
wire [17:0] reg_C_4;
reg [17:0] reg_A_5;
reg [17:0] reg_B_5;
wire [17:0] reg_C_5;
reg [17:0] reg_A_6;
reg [17:0] reg_B_6;
wire [17:0] reg_C_6;
reg [17:0] reg_A_7;
reg [17:0] reg_B_7;
wire [17:0] reg_C_7;
reg [17:0] reg_A_8;
reg [17:0] reg_B_8;
wire [17:0] reg_C_8;
reg [17:0] reg_A_9;
reg [17:0] reg_B_9;
wire [17:0] reg_C_9;
reg [17:0] reg_A_10;
reg [17:0] reg_B_10;
wire [17:0] reg_C_10;
reg [17:0] reg_A_11;
reg [17:0] reg_B_11;
wire [17:0] reg_C_11;
reg [17:0] reg_A_12;
reg [17:0] reg_B_12;
wire [17:0] reg_C_12;
reg [17:0] reg_A_13;
reg [17:0] reg_B_13;
wire [17:0] reg_C_13;
reg [17:0] reg_A_14;
reg [17:0] reg_B_14;
wire [17:0] reg_C_14;
reg [17:0] reg_A_15;
reg [17:0] reg_B_15;
wire [17:0] reg_C_15;

reg valid_A_B;
wire valid_C;
wire enable;
assign enable = i_ready;

wire mult_valid_0;
wire round_valid_0;
wire [36:0] mult_C_0;
wire [36:0] rounded_C_0;
wire mult_valid_1;
wire round_valid_1;
wire [36:0] mult_C_1;
wire [36:0] rounded_C_1;
wire mult_valid_2;
wire round_valid_2;
wire [36:0] mult_C_2;
wire [36:0] rounded_C_2;
wire mult_valid_3;
wire round_valid_3;
wire [36:0] mult_C_3;
wire [36:0] rounded_C_3;
wire mult_valid_4;
wire round_valid_4;
wire [36:0] mult_C_4;
wire [36:0] rounded_C_4;
wire mult_valid_5;
wire round_valid_5;
wire [36:0] mult_C_5;
wire [36:0] rounded_C_5;
wire mult_valid_6;
wire round_valid_6;
wire [36:0] mult_C_6;
wire [36:0] rounded_C_6;
wire mult_valid_7;
wire round_valid_7;
wire [36:0] mult_C_7;
wire [36:0] rounded_C_7;
wire mult_valid_8;
wire round_valid_8;
wire [36:0] mult_C_8;
wire [36:0] rounded_C_8;
wire mult_valid_9;
wire round_valid_9;
wire [36:0] mult_C_9;
wire [36:0] rounded_C_9;
wire mult_valid_10;
wire round_valid_10;
wire [36:0] mult_C_10;
wire [36:0] rounded_C_10;
wire mult_valid_11;
wire round_valid_11;
wire [36:0] mult_C_11;
wire [36:0] rounded_C_11;
wire mult_valid_12;
wire round_valid_12;
wire [36:0] mult_C_12;
wire [36:0] rounded_C_12;
wire mult_valid_13;
wire round_valid_13;
wire [36:0] mult_C_13;
wire [36:0] rounded_C_13;
wire mult_valid_14;
wire round_valid_14;
wire [36:0] mult_C_14;
wire [36:0] rounded_C_14;
wire mult_valid_15;
wire round_valid_15;
wire [36:0] mult_C_15;
wire [36:0] rounded_C_15;

dsp_signed_mult_18x18_unit_18_18_1 dsp_signed_mult_18x18_unit_18_18_1_inst0 (
	.clk(clk),
	.reset(reset),
	.ena(enable),
	.i_valid(valid_A_B),
	.ax(reg_A_0),
	.ay(reg_B_0),
	.bx(reg_A_1),
	.by(reg_B_1),
	.o_valid(mult_valid_0),
	.resulta(mult_C_0),
	.resultb(mult_C_1)
);
assign mult_valid_1 = mult_valid_0;
dsp_signed_mult_18x18_unit_18_18_1 dsp_signed_mult_18x18_unit_18_18_1_inst2 (
	.clk(clk),
	.reset(reset),
	.ena(enable),
	.i_valid(valid_A_B),
	.ax(reg_A_2),
	.ay(reg_B_2),
	.bx(reg_A_3),
	.by(reg_B_3),
	.o_valid(mult_valid_2),
	.resulta(mult_C_2),
	.resultb(mult_C_3)
);
assign mult_valid_3 = mult_valid_2;
dsp_signed_mult_18x18_unit_18_18_1 dsp_signed_mult_18x18_unit_18_18_1_inst4 (
	.clk(clk),
	.reset(reset),
	.ena(enable),
	.i_valid(valid_A_B),
	.ax(reg_A_4),
	.ay(reg_B_4),
	.bx(reg_A_5),
	.by(reg_B_5),
	.o_valid(mult_valid_4),
	.resulta(mult_C_4),
	.resultb(mult_C_5)
);
assign mult_valid_5 = mult_valid_4;
dsp_signed_mult_18x18_unit_18_18_1 dsp_signed_mult_18x18_unit_18_18_1_inst6 (
	.clk(clk),
	.reset(reset),
	.ena(enable),
	.i_valid(valid_A_B),
	.ax(reg_A_6),
	.ay(reg_B_6),
	.bx(reg_A_7),
	.by(reg_B_7),
	.o_valid(mult_valid_6),
	.resulta(mult_C_6),
	.resultb(mult_C_7)
);
assign mult_valid_7 = mult_valid_6;
dsp_signed_mult_18x18_unit_18_18_1 dsp_signed_mult_18x18_unit_18_18_1_inst8 (
	.clk(clk),
	.reset(reset),
	.ena(enable),
	.i_valid(valid_A_B),
	.ax(reg_A_8),
	.ay(reg_B_8),
	.bx(reg_A_9),
	.by(reg_B_9),
	.o_valid(mult_valid_8),
	.resulta(mult_C_8),
	.resultb(mult_C_9)
);
assign mult_valid_9 = mult_valid_8;
dsp_signed_mult_18x18_unit_18_18_1 dsp_signed_mult_18x18_unit_18_18_1_inst10 (
	.clk(clk),
	.reset(reset),
	.ena(enable),
	.i_valid(valid_A_B),
	.ax(reg_A_10),
	.ay(reg_B_10),
	.bx(reg_A_11),
	.by(reg_B_11),
	.o_valid(mult_valid_10),
	.resulta(mult_C_10),
	.resultb(mult_C_11)
);
assign mult_valid_11 = mult_valid_10;
dsp_signed_mult_18x18_unit_18_18_1 dsp_signed_mult_18x18_unit_18_18_1_inst12 (
	.clk(clk),
	.reset(reset),
	.ena(enable),
	.i_valid(valid_A_B),
	.ax(reg_A_12),
	.ay(reg_B_12),
	.bx(reg_A_13),
	.by(reg_B_13),
	.o_valid(mult_valid_12),
	.resulta(mult_C_12),
	.resultb(mult_C_13)
);
assign mult_valid_13 = mult_valid_12;
dsp_signed_mult_18x18_unit_18_18_1 dsp_signed_mult_18x18_unit_18_18_1_inst14 (
	.clk(clk),
	.reset(reset),
	.ena(enable),
	.i_valid(valid_A_B),
	.ax(reg_A_14),
	.ay(reg_B_14),
	.bx(reg_A_15),
	.by(reg_B_15),
	.o_valid(mult_valid_14),
	.resulta(mult_C_14),
	.resultb(mult_C_15)
);
assign mult_valid_15 = mult_valid_14;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst0 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_0),
	.in(mult_C_0),
	.o_valid(round_valid_0),
	.out(rounded_C_0)
);
assign reg_C_0 = rounded_C_0;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst1 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_1),
	.in(mult_C_1),
	.o_valid(round_valid_1),
	.out(rounded_C_1)
);
assign reg_C_1 = rounded_C_1;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst2 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_2),
	.in(mult_C_2),
	.o_valid(round_valid_2),
	.out(rounded_C_2)
);
assign reg_C_2 = rounded_C_2;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst3 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_3),
	.in(mult_C_3),
	.o_valid(round_valid_3),
	.out(rounded_C_3)
);
assign reg_C_3 = rounded_C_3;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst4 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_4),
	.in(mult_C_4),
	.o_valid(round_valid_4),
	.out(rounded_C_4)
);
assign reg_C_4 = rounded_C_4;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst5 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_5),
	.in(mult_C_5),
	.o_valid(round_valid_5),
	.out(rounded_C_5)
);
assign reg_C_5 = rounded_C_5;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst6 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_6),
	.in(mult_C_6),
	.o_valid(round_valid_6),
	.out(rounded_C_6)
);
assign reg_C_6 = rounded_C_6;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst7 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_7),
	.in(mult_C_7),
	.o_valid(round_valid_7),
	.out(rounded_C_7)
);
assign reg_C_7 = rounded_C_7;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst8 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_8),
	.in(mult_C_8),
	.o_valid(round_valid_8),
	.out(rounded_C_8)
);
assign reg_C_8 = rounded_C_8;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst9 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_9),
	.in(mult_C_9),
	.o_valid(round_valid_9),
	.out(rounded_C_9)
);
assign reg_C_9 = rounded_C_9;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst10 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_10),
	.in(mult_C_10),
	.o_valid(round_valid_10),
	.out(rounded_C_10)
);
assign reg_C_10 = rounded_C_10;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst11 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_11),
	.in(mult_C_11),
	.o_valid(round_valid_11),
	.out(rounded_C_11)
);
assign reg_C_11 = rounded_C_11;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst12 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_12),
	.in(mult_C_12),
	.o_valid(round_valid_12),
	.out(rounded_C_12)
);
assign reg_C_12 = rounded_C_12;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst13 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_13),
	.in(mult_C_13),
	.o_valid(round_valid_13),
	.out(rounded_C_13)
);
assign reg_C_13 = rounded_C_13;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst14 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_14),
	.in(mult_C_14),
	.o_valid(round_valid_14),
	.out(rounded_C_14)
);
assign reg_C_14 = rounded_C_14;
fp_rounding_unit_1_37_10 fp_rounding_unit_1_37_10_inst15 (
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.i_valid(mult_valid_15),
	.in(mult_C_15),
	.o_valid(round_valid_15),
	.out(rounded_C_15)
);
assign reg_C_15 = rounded_C_15;
always @ (posedge clk) begin
	if (reset) begin
		valid_A_B <= 1'b0;
		reg_A_0 <= 0;
		reg_B_0 <= 0;
		reg_A_1 <= 0;
		reg_B_1 <= 0;
		reg_A_2 <= 0;
		reg_B_2 <= 0;
		reg_A_3 <= 0;
		reg_B_3 <= 0;
		reg_A_4 <= 0;
		reg_B_4 <= 0;
		reg_A_5 <= 0;
		reg_B_5 <= 0;
		reg_A_6 <= 0;
		reg_B_6 <= 0;
		reg_A_7 <= 0;
		reg_B_7 <= 0;
		reg_A_8 <= 0;
		reg_B_8 <= 0;
		reg_A_9 <= 0;
		reg_B_9 <= 0;
		reg_A_10 <= 0;
		reg_B_10 <= 0;
		reg_A_11 <= 0;
		reg_B_11 <= 0;
		reg_A_12 <= 0;
		reg_B_12 <= 0;
		reg_A_13 <= 0;
		reg_B_13 <= 0;
		reg_A_14 <= 0;
		reg_B_14 <= 0;
		reg_A_15 <= 0;
		reg_B_15 <= 0;
	end else if (enable) begin
		reg_A_0 <= i_A_0;
		reg_B_0 <= i_B_0;
		reg_A_1 <= i_A_1;
		reg_B_1 <= i_B_1;
		reg_A_2 <= i_A_2;
		reg_B_2 <= i_B_2;
		reg_A_3 <= i_A_3;
		reg_B_3 <= i_B_3;
		reg_A_4 <= i_A_4;
		reg_B_4 <= i_B_4;
		reg_A_5 <= i_A_5;
		reg_B_5 <= i_B_5;
		reg_A_6 <= i_A_6;
		reg_B_6 <= i_B_6;
		reg_A_7 <= i_A_7;
		reg_B_7 <= i_B_7;
		reg_A_8 <= i_A_8;
		reg_B_8 <= i_B_8;
		reg_A_9 <= i_A_9;
		reg_B_9 <= i_B_9;
		reg_A_10 <= i_A_10;
		reg_B_10 <= i_B_10;
		reg_A_11 <= i_A_11;
		reg_B_11 <= i_B_11;
		reg_A_12 <= i_A_12;
		reg_B_12 <= i_B_12;
		reg_A_13 <= i_A_13;
		reg_B_13 <= i_B_13;
		reg_A_14 <= i_A_14;
		reg_B_14 <= i_B_14;
		reg_A_15 <= i_A_15;
		reg_B_15 <= i_B_15;
		valid_A_B <= i_valid;
	end
end

assign o_C_0 = reg_C_0;
assign o_C_1 = reg_C_1;
assign o_C_2 = reg_C_2;
assign o_C_3 = reg_C_3;
assign o_C_4 = reg_C_4;
assign o_C_5 = reg_C_5;
assign o_C_6 = reg_C_6;
assign o_C_7 = reg_C_7;
assign o_C_8 = reg_C_8;
assign o_C_9 = reg_C_9;
assign o_C_10 = reg_C_10;
assign o_C_11 = reg_C_11;
assign o_C_12 = reg_C_12;
assign o_C_13 = reg_C_13;
assign o_C_14 = reg_C_14;
assign o_C_15 = reg_C_15;
assign valid_C = round_valid_0;
assign o_ready = i_ready;
assign o_valid = valid_C & i_ready;

endmodule

module dsp_signed_mult_18x18_unit_18_18_1 (
	input clk,
	input reset,
	input ena,
	input i_valid,
	input [17:0] ax,
	input [17:0] ay,
	input [17:0] bx,
	input [17:0] by,
	output o_valid,
	output [36:0] resulta,
	output [36:0] resultb 
);

reg [17:0] reg_ax, reg_ay, reg_bx, reg_by;
reg [36:0] reg_resa, reg_resb;
always @(posedge clk) begin
	if (reset) begin
		reg_ax <= 0;
		reg_ay <= 0;
		reg_bx <= 0;
		reg_by <= 0;
		reg_resa <= 0;
		reg_resb <= 0;
	end else if (ena) begin
		reg_ax <= ax;
		reg_ay <= ay;
		reg_bx <= bx;
		reg_by <= by;
		reg_resa <= reg_ax * reg_ay;
		reg_resb <= reg_bx * reg_by;
	end
end

assign resulta = reg_resa;
assign resultb = reg_resb;
reg input_valid, result_valid, output_valid;
always @ (posedge clk) begin
	if (reset) begin
		output_valid <= 1'b0;
		input_valid <= 1'b0;
		result_valid <= 1'b0;
	end else if (ena) begin
		input_valid <= i_valid;
		result_valid <= input_valid;
		output_valid <= result_valid;
	end
end
assign o_valid = output_valid;

endmodule

module fp_rounding_unit_1_37_10 (
	input clk,
	input reset,
	input enable,
	input i_valid,
	input [36:0] in,
	output [36:0] out,
	output o_valid
);

reg [36:0] rounded_result;
reg [36:0] floor;
reg [36:0] ceil;
reg is_ceil;
reg floor_ceil_valid;

always @ (*) begin
	if (is_ceil) begin
		rounded_result = ceil;
	end else begin
		rounded_result = floor;
	end
end

reg valid_reg;
reg [36:0] out_reg;
always @ (posedge clk) begin
	if (reset) begin
		is_ceil <= 1'b0;
		floor_ceil_valid <= 1'b0;
		valid_reg <= 1'b0;
		floor <= 0;
		ceil <= 0;
		out_reg <= 0;
	end else if (enable) begin
		is_ceil <= in[9];
		floor <= in >>> 10;
		ceil <= (in >>> 10) + 1;
		floor_ceil_valid <= i_valid;
		out_reg <= rounded_result;
		valid_reg <= floor_ceil_valid;
	end
end

assign o_valid = valid_reg;

assign out = out_reg;

endmodule






