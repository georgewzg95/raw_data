`define SIMULATION_MEMORY

module idft_16_top_18 (
	input clk,
	input reset,
	input next,
	input [17:0] X0,
	output [17:0] Y0,
	input [17:0] X1,
	output [17:0] Y1,
	input [17:0] X2,
	output [17:0] Y2,
	input [17:0] X3,
	output [17:0] Y3,
	input [17:0] X4,
	output [17:0] Y4,
	input [17:0] X5,
	output [17:0] Y5,
	input [17:0] X6,
	output [17:0] Y6,
	input [17:0] X7,
	output [17:0] Y7,
	input [17:0] X8,
	output [17:0] Y8,
	input [17:0] X9,
	output [17:0] Y9,
	input [17:0] X10,
	output [17:0] Y10,
	input [17:0] X11,
	output [17:0] Y11,
	input [17:0] X12,
	output [17:0] Y12,
	input [17:0] X13,
	output [17:0] Y13,
	input [17:0] X14,
	output [17:0] Y14,
	input [17:0] X15,
	output [17:0] Y15,
	input [17:0] X16,
	output [17:0] Y16,
	input [17:0] X17,
	output [17:0] Y17,
	input [17:0] X18,
	output [17:0] Y18,
	input [17:0] X19,
	output [17:0] Y19,
	input [17:0] X20,
	output [17:0] Y20,
	input [17:0] X21,
	output [17:0] Y21,
	input [17:0] X22,
	output [17:0] Y22,
	input [17:0] X23,
	output [17:0] Y23,
	input [17:0] X24,
	output [17:0] Y24,
	input [17:0] X25,
	output [17:0] Y25,
	input [17:0] X26,
	output [17:0] Y26,
	input [17:0] X27,
	output [17:0] Y27,
	input [17:0] X28,
	output [17:0] Y28,
	input [17:0] X29,
	output [17:0] Y29,
	input [17:0] X30,
	output [17:0] Y30,
	input [17:0] X31,
	output [17:0] Y31,
	output next_out
);
wire [17:0] t0_0;
wire [17:0] t0_1;
wire [17:0] t0_2;
wire [17:0] t0_3;
wire [17:0] t0_4;
wire [17:0] t0_5;
wire [17:0] t0_6;
wire [17:0] t0_7;
wire [17:0] t0_8;
wire [17:0] t0_9;
wire [17:0] t0_10;
wire [17:0] t0_11;
wire [17:0] t0_12;
wire [17:0] t0_13;
wire [17:0] t0_14;
wire [17:0] t0_15;
wire [17:0] t0_16;
wire [17:0] t0_17;
wire [17:0] t0_18;
wire [17:0] t0_19;
wire [17:0] t0_20;
wire [17:0] t0_21;
wire [17:0] t0_22;
wire [17:0] t0_23;
wire [17:0] t0_24;
wire [17:0] t0_25;
wire [17:0] t0_26;
wire [17:0] t0_27;
wire [17:0] t0_28;
wire [17:0] t0_29;
wire [17:0] t0_30;
wire [17:0] t0_31;
wire next_0;
wire [17:0] t1_0;
wire [17:0] t1_1;
wire [17:0] t1_2;
wire [17:0] t1_3;
wire [17:0] t1_4;
wire [17:0] t1_5;
wire [17:0] t1_6;
wire [17:0] t1_7;
wire [17:0] t1_8;
wire [17:0] t1_9;
wire [17:0] t1_10;
wire [17:0] t1_11;
wire [17:0] t1_12;
wire [17:0] t1_13;
wire [17:0] t1_14;
wire [17:0] t1_15;
wire [17:0] t1_16;
wire [17:0] t1_17;
wire [17:0] t1_18;
wire [17:0] t1_19;
wire [17:0] t1_20;
wire [17:0] t1_21;
wire [17:0] t1_22;
wire [17:0] t1_23;
wire [17:0] t1_24;
wire [17:0] t1_25;
wire [17:0] t1_26;
wire [17:0] t1_27;
wire [17:0] t1_28;
wire [17:0] t1_29;
wire [17:0] t1_30;
wire [17:0] t1_31;
wire next_1;
wire [17:0] t2_0;
wire [17:0] t2_1;
wire [17:0] t2_2;
wire [17:0] t2_3;
wire [17:0] t2_4;
wire [17:0] t2_5;
wire [17:0] t2_6;
wire [17:0] t2_7;
wire [17:0] t2_8;
wire [17:0] t2_9;
wire [17:0] t2_10;
wire [17:0] t2_11;
wire [17:0] t2_12;
wire [17:0] t2_13;
wire [17:0] t2_14;
wire [17:0] t2_15;
wire [17:0] t2_16;
wire [17:0] t2_17;
wire [17:0] t2_18;
wire [17:0] t2_19;
wire [17:0] t2_20;
wire [17:0] t2_21;
wire [17:0] t2_22;
wire [17:0] t2_23;
wire [17:0] t2_24;
wire [17:0] t2_25;
wire [17:0] t2_26;
wire [17:0] t2_27;
wire [17:0] t2_28;
wire [17:0] t2_29;
wire [17:0] t2_30;
wire [17:0] t2_31;
wire next_2;

assign t0_0 = X0;
assign Y0 = t2_0;
assign t0_1 = X1;
assign Y1 = t2_1;
assign t0_2 = X2;
assign Y2 = t2_2;
assign t0_3 = X3;
assign Y3 = t2_3;
assign t0_4 = X4;
assign Y4 = t2_4;
assign t0_5 = X5;
assign Y5 = t2_5;
assign t0_6 = X6;
assign Y6 = t2_6;
assign t0_7 = X7;
assign Y7 = t2_7;
assign t0_8 = X8;
assign Y8 = t2_8;
assign t0_9 = X9;
assign Y9 = t2_9;
assign t0_10 = X10;
assign Y10 = t2_10;
assign t0_11 = X11;
assign Y11 = t2_11;
assign t0_12 = X12;
assign Y12 = t2_12;
assign t0_13 = X13;
assign Y13 = t2_13;
assign t0_14 = X14;
assign Y14 = t2_14;
assign t0_15 = X15;
assign Y15 = t2_15;
assign t0_16 = X16;
assign Y16 = t2_16;
assign t0_17 = X17;
assign Y17 = t2_17;
assign t0_18 = X18;
assign Y18 = t2_18;
assign t0_19 = X19;
assign Y19 = t2_19;
assign t0_20 = X20;
assign Y20 = t2_20;
assign t0_21 = X21;
assign Y21 = t2_21;
assign t0_22 = X22;
assign Y22 = t2_22;
assign t0_23 = X23;
assign Y23 = t2_23;
assign t0_24 = X24;
assign Y24 = t2_24;
assign t0_25 = X25;
assign Y25 = t2_25;
assign t0_26 = X26;
assign Y26 = t2_26;
assign t0_27 = X27;
assign Y27 = t2_27;
assign t0_28 = X28;
assign Y28 = t2_28;
assign t0_29 = X29;
assign Y29 = t2_29;
assign t0_30 = X30;
assign Y30 = t2_30;
assign t0_31 = X31;
assign Y31 = t2_31;
assign next_0 = next;
assign next_out = next_2;
codeBlock98050_18 codeBlock98050_18_inst (
	.clk(clk),
	.reset(reset),
	.next_in(next_0),
	.X0_in(t0_0),
	.Y0(t1_0),
	.X1_in(t0_1),
	.Y1(t1_1),
	.X2_in(t0_2),
	.Y2(t1_2),
	.X3_in(t0_3),
	.Y3(t1_3),
	.X4_in(t0_4),
	.Y4(t1_4),
	.X5_in(t0_5),
	.Y5(t1_5),
	.X6_in(t0_6),
	.Y6(t1_6),
	.X7_in(t0_7),
	.Y7(t1_7),
	.X8_in(t0_8),
	.Y8(t1_8),
	.X9_in(t0_9),
	.Y9(t1_9),
	.X10_in(t0_10),
	.Y10(t1_10),
	.X11_in(t0_11),
	.Y11(t1_11),
	.X12_in(t0_12),
	.Y12(t1_12),
	.X13_in(t0_13),
	.Y13(t1_13),
	.X14_in(t0_14),
	.Y14(t1_14),
	.X15_in(t0_15),
	.Y15(t1_15),
	.X16_in(t0_16),
	.Y16(t1_16),
	.X17_in(t0_17),
	.Y17(t1_17),
	.X18_in(t0_18),
	.Y18(t1_18),
	.X19_in(t0_19),
	.Y19(t1_19),
	.X20_in(t0_20),
	.Y20(t1_20),
	.X21_in(t0_21),
	.Y21(t1_21),
	.X22_in(t0_22),
	.Y22(t1_22),
	.X23_in(t0_23),
	.Y23(t1_23),
	.X24_in(t0_24),
	.Y24(t1_24),
	.X25_in(t0_25),
	.Y25(t1_25),
	.X26_in(t0_26),
	.Y26(t1_26),
	.X27_in(t0_27),
	.Y27(t1_27),
	.X28_in(t0_28),
	.Y28(t1_28),
	.X29_in(t0_29),
	.Y29(t1_29),
	.X30_in(t0_30),
	.Y30(t1_30),
	.X31_in(t0_31),
	.Y31(t1_31),
	.next_out(next_1)
);

codeBlock99168_18 codeBlock99168_18_inst (
	.clk(clk),
	.reset(reset),
	.next_in(next_1),
	.X0_in(t1_0),
	.Y0(t2_0),
	.X1_in(t1_1),
	.Y1(t2_1),
	.X2_in(t1_2),
	.Y2(t2_2),
	.X3_in(t1_3),
	.Y3(t2_3),
	.X4_in(t1_4),
	.Y4(t2_4),
	.X5_in(t1_5),
	.Y5(t2_5),
	.X6_in(t1_6),
	.Y6(t2_6),
	.X7_in(t1_7),
	.Y7(t2_7),
	.X8_in(t1_8),
	.Y8(t2_8),
	.X9_in(t1_9),
	.Y9(t2_9),
	.X10_in(t1_10),
	.Y10(t2_10),
	.X11_in(t1_11),
	.Y11(t2_11),
	.X12_in(t1_12),
	.Y12(t2_12),
	.X13_in(t1_13),
	.Y13(t2_13),
	.X14_in(t1_14),
	.Y14(t2_14),
	.X15_in(t1_15),
	.Y15(t2_15),
	.X16_in(t1_16),
	.Y16(t2_16),
	.X17_in(t1_17),
	.Y17(t2_17),
	.X18_in(t1_18),
	.Y18(t2_18),
	.X19_in(t1_19),
	.Y19(t2_19),
	.X20_in(t1_20),
	.Y20(t2_20),
	.X21_in(t1_21),
	.Y21(t2_21),
	.X22_in(t1_22),
	.Y22(t2_22),
	.X23_in(t1_23),
	.Y23(t2_23),
	.X24_in(t1_24),
	.Y24(t2_24),
	.X25_in(t1_25),
	.Y25(t2_25),
	.X26_in(t1_26),
	.Y26(t2_26),
	.X27_in(t1_27),
	.Y27(t2_27),
	.X28_in(t1_28),
	.Y28(t2_28),
	.X29_in(t1_29),
	.Y29(t2_29),
	.X30_in(t1_30),
	.Y30(t2_30),
	.X31_in(t1_31),
	.Y31(t2_31),
	.next_out(next_2)
);

endmodule
module codeBlock99168_18 (
	input clk,
	input reset,
	input next_in,
	input [17:0] X0_in,
	output [17:0] Y0,
	input [17:0] X1_in,
	output [17:0] Y1,
	input [17:0] X2_in,
	output [17:0] Y2,
	input [17:0] X3_in,
	output [17:0] Y3,
	input [17:0] X4_in,
	output [17:0] Y4,
	input [17:0] X5_in,
	output [17:0] Y5,
	input [17:0] X6_in,
	output [17:0] Y6,
	input [17:0] X7_in,
	output [17:0] Y7,
	input [17:0] X8_in,
	output [17:0] Y8,
	input [17:0] X9_in,
	output [17:0] Y9,
	input [17:0] X10_in,
	output [17:0] Y10,
	input [17:0] X11_in,
	output [17:0] Y11,
	input [17:0] X12_in,
	output [17:0] Y12,
	input [17:0] X13_in,
	output [17:0] Y13,
	input [17:0] X14_in,
	output [17:0] Y14,
	input [17:0] X15_in,
	output [17:0] Y15,
	input [17:0] X16_in,
	output [17:0] Y16,
	input [17:0] X17_in,
	output [17:0] Y17,
	input [17:0] X18_in,
	output [17:0] Y18,
	input [17:0] X19_in,
	output [17:0] Y19,
	input [17:0] X20_in,
	output [17:0] Y20,
	input [17:0] X21_in,
	output [17:0] Y21,
	input [17:0] X22_in,
	output [17:0] Y22,
	input [17:0] X23_in,
	output [17:0] Y23,
	input [17:0] X24_in,
	output [17:0] Y24,
	input [17:0] X25_in,
	output [17:0] Y25,
	input [17:0] X26_in,
	output [17:0] Y26,
	input [17:0] X27_in,
	output [17:0] Y27,
	input [17:0] X28_in,
	output [17:0] Y28,
	input [17:0] X29_in,
	output [17:0] Y29,
	input [17:0] X30_in,
	output [17:0] Y30,
	input [17:0] X31_in,
	output [17:0] Y31,
	output next_out
);

reg next;
reg [17:0] X0;
reg [17:0] X1;
reg [17:0] X2;
reg [17:0] X3;
reg [17:0] X4;
reg [17:0] X5;
reg [17:0] X6;
reg [17:0] X7;
reg [17:0] X8;
reg [17:0] X9;
reg [17:0] X10;
reg [17:0] X11;
reg [17:0] X12;
reg [17:0] X13;
reg [17:0] X14;
reg [17:0] X15;
reg [17:0] X16;
reg [17:0] X17;
reg [17:0] X18;
reg [17:0] X19;
reg [17:0] X20;
reg [17:0] X21;
reg [17:0] X22;
reg [17:0] X23;
reg [17:0] X24;
reg [17:0] X25;
reg [17:0] X26;
reg [17:0] X27;
reg [17:0] X28;
reg [17:0] X29;
reg [17:0] X30;
reg [17:0] X31;
shiftRegFIFO_2_1 shiftRegFIFO_2_1_inst (
	.X(next),
	.Y(next_out),
	.reset(reset),
	.clk(clk)
);
wire  [17:0] a65;
 		wire  [17:0] a66;
 		wire  [17:0] a67;
 		wire  [17:0] a68;
 		wire  [17:0] a73;
 		wire  [17:0] a74;
 		wire  [17:0] a75;
 		wire  [17:0] a76;
 		wire  [17:0] a81;
 		wire  [17:0] a82;
 		wire  [17:0] a83;
 		wire  [17:0] a84;
 		wire  [17:0] a89;
 		wire  [17:0] a90;
 		wire  [17:0] a91;
 		wire  [17:0] a92;
 		wire  [17:0] a97;
 		wire  [17:0] a98;
 		wire  [17:0] a99;
 		wire  [17:0] a100;
 		wire  [17:0] a105;
 		wire  [17:0] a106;
 		wire  [17:0] a107;
 		wire  [17:0] a108;
 		wire  [17:0] a113;
 		wire  [17:0] a114;
 		wire  [17:0] a115;
 		wire  [17:0] a116;
 		wire  [17:0] a121;
 		wire  [17:0] a122;
 		wire  [17:0] a123;
 		wire  [17:0] a124;
 		wire  [17:0] t402;
 		wire  [17:0] t403;
 		wire  [17:0] t404;
 		wire  [17:0] t405;
 		wire  [17:0] t406;
 		wire  [17:0] t407;
 		wire  [17:0] t408;
 		wire  [17:0] t409;
 		wire  [17:0] t418;
 		wire  [17:0] t419;
 		wire  [17:0] t420;
 		wire  [17:0] t421;
 		wire  [17:0] t422;
 		wire  [17:0] t423;
 		wire  [17:0] t424;
 		wire  [17:0] t425;
 		wire  [17:0] t434;
 		wire  [17:0] t435;
 		wire  [17:0] t436;
 		wire  [17:0] t437;
 		wire  [17:0] t438;
 		wire  [17:0] t439;
 		wire  [17:0] t440;
 		wire  [17:0] t441;
 		wire  [17:0] t450;
 		wire  [17:0] t451;
 		wire  [17:0] t452;
 		wire  [17:0] t453;
 		wire  [17:0] t454;
 		wire  [17:0] t455;
 		wire  [17:0] t456;
 		wire  [17:0] t457;
 		wire  [17:0] t410;
 		wire  [17:0] t411;
 		wire  [17:0] t412;
 		wire  [17:0] t413;
 		wire  [17:0] t414;
 		wire  [17:0] t415;
 		wire  [17:0] t416;
 		wire  [17:0] t417;
 		wire  [17:0] t426;
 		wire  [17:0] t427;
 		wire  [17:0] t428;
 		wire  [17:0] t429;
 		wire  [17:0] t430;
 		wire  [17:0] t431;
 		wire  [17:0] t432;
 		wire  [17:0] t433;
 		wire  [17:0] t442;
 		wire  [17:0] t443;
 		wire  [17:0] t444;
 		wire  [17:0] t445;
 		wire  [17:0] t446;
 		wire  [17:0] t447;
 		wire  [17:0] t448;
 		wire  [17:0] t449;
 		wire  [17:0] t458;
 		wire  [17:0] t459;
 		wire  [17:0] t460;
 		wire  [17:0] t461;
 		wire  [17:0] t462;
 		wire  [17:0] t463;
 		wire  [17:0] t464;
 		wire  [17:0] t465;

assign a65 = X0;
 		assign a66 = X16;
 		assign a67 = X1;
 		assign a68 = X17;
 		assign a73 = X8;
 		assign a74 = X24;
 		assign a75 = X9;
 		assign a76 = X25;
 		assign a81 = X2;
 		assign a82 = X18;
 		assign a83 = X3;
 		assign a84 = X19;
 		assign a89 = X10;
 		assign a90 = X26;
 		assign a91 = X11;
 		assign a92 = X27;
 		assign a97 = X4;
 		assign a98 = X20;
 		assign a99 = X5;
 		assign a100 = X21;
 		assign a105 = X12;
 		assign a106 = X28;
 		assign a107 = X13;
 		assign a108 = X29;
 		assign a113 = X6;
 		assign a114 = X22;
 		assign a115 = X7;
 		assign a116 = X23;
 		assign a121 = X14;
 		assign a122 = X30;
 		assign a123 = X15;
 		assign a124 = X31;
 		assign Y0 = t410;
 		assign Y1 = t411;
 		assign Y16 = t412;
 		assign Y17 = t413;
 		assign Y8 = t414;
 		assign Y9 = t415;
 		assign Y24 = t416;
 		assign Y25 = t417;
 		assign Y2 = t426;
 		assign Y3 = t427;
 		assign Y18 = t428;
 		assign Y19 = t429;
 		assign Y10 = t430;
 		assign Y11 = t431;
 		assign Y26 = t432;
 		assign Y27 = t433;
 		assign Y4 = t442;
 		assign Y5 = t443;
 		assign Y20 = t444;
 		assign Y21 = t445;
 		assign Y12 = t446;
 		assign Y13 = t447;
 		assign Y28 = t448;
 		assign Y29 = t449;
 		assign Y6 = t458;
 		assign Y7 = t459;
 		assign Y22 = t460;
 		assign Y23 = t461;
 		assign Y14 = t462;
 		assign Y15 = t463;
 		assign Y30 = t464;
 		assign Y31 = t465;

addfxp_18_1 add99180(.a(a65), .b(a66), .clk(clk), .q(t402));
 		addfxp_18_1 add99195(.a(a67), .b(a68), .clk(clk), .q(t403));
 		subfxp_18_1 sub99210(.a(a65), .b(a66), .clk(clk), .q(t404));
 		subfxp_18_1 sub99225(.a(a67), .b(a68), .clk(clk), .q(t405));
 		addfxp_18_1 add99240(.a(a73), .b(a74), .clk(clk), .q(t406));
 		addfxp_18_1 add99255(.a(a75), .b(a76), .clk(clk), .q(t407));
 		subfxp_18_1 sub99270(.a(a73), .b(a74), .clk(clk), .q(t408));
 		subfxp_18_1 sub99285(.a(a75), .b(a76), .clk(clk), .q(t409));
 		addfxp_18_1 add99388(.a(a81), .b(a82), .clk(clk), .q(t418));
 		addfxp_18_1 add99403(.a(a83), .b(a84), .clk(clk), .q(t419));
 		subfxp_18_1 sub99418(.a(a81), .b(a82), .clk(clk), .q(t420));
 		subfxp_18_1 sub99433(.a(a83), .b(a84), .clk(clk), .q(t421));
 		addfxp_18_1 add99448(.a(a89), .b(a90), .clk(clk), .q(t422));
 		addfxp_18_1 add99463(.a(a91), .b(a92), .clk(clk), .q(t423));
 		subfxp_18_1 sub99478(.a(a89), .b(a90), .clk(clk), .q(t424));
 		subfxp_18_1 sub99493(.a(a91), .b(a92), .clk(clk), .q(t425));
 		addfxp_18_1 add99596(.a(a97), .b(a98), .clk(clk), .q(t434));
 		addfxp_18_1 add99611(.a(a99), .b(a100), .clk(clk), .q(t435));
 		subfxp_18_1 sub99626(.a(a97), .b(a98), .clk(clk), .q(t436));
 		subfxp_18_1 sub99641(.a(a99), .b(a100), .clk(clk), .q(t437));
 		addfxp_18_1 add99656(.a(a105), .b(a106), .clk(clk), .q(t438));
 		addfxp_18_1 add99671(.a(a107), .b(a108), .clk(clk), .q(t439));
 		subfxp_18_1 sub99686(.a(a105), .b(a106), .clk(clk), .q(t440));
 		subfxp_18_1 sub99701(.a(a107), .b(a108), .clk(clk), .q(t441));
 		addfxp_18_1 add99804(.a(a113), .b(a114), .clk(clk), .q(t450));
 		addfxp_18_1 add99819(.a(a115), .b(a116), .clk(clk), .q(t451));
 		subfxp_18_1 sub99834(.a(a113), .b(a114), .clk(clk), .q(t452));
 		subfxp_18_1 sub99849(.a(a115), .b(a116), .clk(clk), .q(t453));
 		addfxp_18_1 add99864(.a(a121), .b(a122), .clk(clk), .q(t454));
 		addfxp_18_1 add99879(.a(a123), .b(a124), .clk(clk), .q(t455));
 		subfxp_18_1 sub99894(.a(a121), .b(a122), .clk(clk), .q(t456));
 		subfxp_18_1 sub99909(.a(a123), .b(a124), .clk(clk), .q(t457));
 		addfxp_18_1 add99292(.a(t402), .b(t406), .clk(clk), .q(t410));
 		addfxp_18_1 add99299(.a(t403), .b(t407), .clk(clk), .q(t411));
 		subfxp_18_1 sub99306(.a(t402), .b(t406), .clk(clk), .q(t412));
 		subfxp_18_1 sub99313(.a(t403), .b(t407), .clk(clk), .q(t413));
 		subfxp_18_1 sub99336(.a(t404), .b(t409), .clk(clk), .q(t414));
 		addfxp_18_1 add99343(.a(t405), .b(t408), .clk(clk), .q(t415));
 		addfxp_18_1 add99350(.a(t404), .b(t409), .clk(clk), .q(t416));
 		subfxp_18_1 sub99357(.a(t405), .b(t408), .clk(clk), .q(t417));
 		addfxp_18_1 add99500(.a(t418), .b(t422), .clk(clk), .q(t426));
 		addfxp_18_1 add99507(.a(t419), .b(t423), .clk(clk), .q(t427));
 		subfxp_18_1 sub99514(.a(t418), .b(t422), .clk(clk), .q(t428));
 		subfxp_18_1 sub99521(.a(t419), .b(t423), .clk(clk), .q(t429));
 		subfxp_18_1 sub99544(.a(t420), .b(t425), .clk(clk), .q(t430));
 		addfxp_18_1 add99551(.a(t421), .b(t424), .clk(clk), .q(t431));
 		addfxp_18_1 add99558(.a(t420), .b(t425), .clk(clk), .q(t432));
 		subfxp_18_1 sub99565(.a(t421), .b(t424), .clk(clk), .q(t433));
 		addfxp_18_1 add99708(.a(t434), .b(t438), .clk(clk), .q(t442));
 		addfxp_18_1 add99715(.a(t435), .b(t439), .clk(clk), .q(t443));
 		subfxp_18_1 sub99722(.a(t434), .b(t438), .clk(clk), .q(t444));
 		subfxp_18_1 sub99729(.a(t435), .b(t439), .clk(clk), .q(t445));
 		subfxp_18_1 sub99752(.a(t436), .b(t441), .clk(clk), .q(t446));
 		addfxp_18_1 add99759(.a(t437), .b(t440), .clk(clk), .q(t447));
 		addfxp_18_1 add99766(.a(t436), .b(t441), .clk(clk), .q(t448));
 		subfxp_18_1 sub99773(.a(t437), .b(t440), .clk(clk), .q(t449));
 		addfxp_18_1 add99916(.a(t450), .b(t454), .clk(clk), .q(t458));
 		addfxp_18_1 add99923(.a(t451), .b(t455), .clk(clk), .q(t459));
 		subfxp_18_1 sub99930(.a(t450), .b(t454), .clk(clk), .q(t460));
 		subfxp_18_1 sub99937(.a(t451), .b(t455), .clk(clk), .q(t461));
 		subfxp_18_1 sub99960(.a(t452), .b(t457), .clk(clk), .q(t462));
 		addfxp_18_1 add99967(.a(t453), .b(t456), .clk(clk), .q(t463));
 		addfxp_18_1 add99974(.a(t452), .b(t457), .clk(clk), .q(t464));
 		subfxp_18_1 sub99981(.a(t453), .b(t456), .clk(clk), .q(t465));

always @(posedge clk) begin
	if (reset == 1) begin
		next <= 1'b0;
	end else begin
		X0 <= X0_in;
		X1 <= X1_in;
		X2 <= X2_in;
		X3 <= X3_in;
		X4 <= X4_in;
		X5 <= X5_in;
		X6 <= X6_in;
		X7 <= X7_in;
		X8 <= X8_in;
		X9 <= X9_in;
		X10 <= X10_in;
		X11 <= X11_in;
		X12 <= X12_in;
		X13 <= X13_in;
		X14 <= X14_in;
		X15 <= X15_in;
		X16 <= X16_in;
		X17 <= X17_in;
		X18 <= X18_in;
		X19 <= X19_in;
		X20 <= X20_in;
		X21 <= X21_in;
		X22 <= X22_in;
		X23 <= X23_in;
		X24 <= X24_in;
		X25 <= X25_in;
		X26 <= X26_in;
		X27 <= X27_in;
		X28 <= X28_in;
		X29 <= X29_in;
		X30 <= X30_in;
		X31 <= X31_in;
		next <= next_in;
	end
end

endmodule
module subfxp_18_1 (
	input [17:0] a,
	input [17:0] b,
	input clk,
	output [17:0] q
);

reg [17:0] res_0;
assign q = res_0;

always @(posedge clk) begin
	res_0 <= a + b;
end

endmodule
module addfxp_18_1 (
	input [17:0] a,
	input [17:0] b,
	input clk,
	output [17:0] q
);

reg [17:0] res_0;
assign q = res_0;

always @(posedge clk) begin
	res_0 <= a + b;
end

endmodule
module shiftRegFIFO_2_1 (
	input [0:0] X,
	output [0:0] Y,
	input reset,
	input clk
);

reg [0:0] mem_0;
reg [0:0] mem_1;
assign Y = mem_1;

always @ (posedge clk) begin
	if (reset) begin
		mem_0 <= 0;
		mem_1 <= 0;
	end else begin
		mem_1 <= mem_0;
		mem_0 <= X;
	end
end

endmodule
module codeBlock98050_18 (
	input clk,
	input reset,
	input next_in,
	input [17:0] X0_in,
	output [17:0] Y0,
	input [17:0] X1_in,
	output [17:0] Y1,
	input [17:0] X2_in,
	output [17:0] Y2,
	input [17:0] X3_in,
	output [17:0] Y3,
	input [17:0] X4_in,
	output [17:0] Y4,
	input [17:0] X5_in,
	output [17:0] Y5,
	input [17:0] X6_in,
	output [17:0] Y6,
	input [17:0] X7_in,
	output [17:0] Y7,
	input [17:0] X8_in,
	output [17:0] Y8,
	input [17:0] X9_in,
	output [17:0] Y9,
	input [17:0] X10_in,
	output [17:0] Y10,
	input [17:0] X11_in,
	output [17:0] Y11,
	input [17:0] X12_in,
	output [17:0] Y12,
	input [17:0] X13_in,
	output [17:0] Y13,
	input [17:0] X14_in,
	output [17:0] Y14,
	input [17:0] X15_in,
	output [17:0] Y15,
	input [17:0] X16_in,
	output [17:0] Y16,
	input [17:0] X17_in,
	output [17:0] Y17,
	input [17:0] X18_in,
	output [17:0] Y18,
	input [17:0] X19_in,
	output [17:0] Y19,
	input [17:0] X20_in,
	output [17:0] Y20,
	input [17:0] X21_in,
	output [17:0] Y21,
	input [17:0] X22_in,
	output [17:0] Y22,
	input [17:0] X23_in,
	output [17:0] Y23,
	input [17:0] X24_in,
	output [17:0] Y24,
	input [17:0] X25_in,
	output [17:0] Y25,
	input [17:0] X26_in,
	output [17:0] Y26,
	input [17:0] X27_in,
	output [17:0] Y27,
	input [17:0] X28_in,
	output [17:0] Y28,
	input [17:0] X29_in,
	output [17:0] Y29,
	input [17:0] X30_in,
	output [17:0] Y30,
	input [17:0] X31_in,
	output [17:0] Y31,
	output next_out
);

reg next;
reg [17:0] X0;
reg [17:0] X1;
reg [17:0] X2;
reg [17:0] X3;
reg [17:0] X4;
reg [17:0] X5;
reg [17:0] X6;
reg [17:0] X7;
reg [17:0] X8;
reg [17:0] X9;
reg [17:0] X10;
reg [17:0] X11;
reg [17:0] X12;
reg [17:0] X13;
reg [17:0] X14;
reg [17:0] X15;
reg [17:0] X16;
reg [17:0] X17;
reg [17:0] X18;
reg [17:0] X19;
reg [17:0] X20;
reg [17:0] X21;
reg [17:0] X22;
reg [17:0] X23;
reg [17:0] X24;
reg [17:0] X25;
reg [17:0] X26;
reg [17:0] X27;
reg [17:0] X28;
reg [17:0] X29;
reg [17:0] X30;
reg [17:0] X31;
shiftRegFIFO_5_1 shiftRegFIFO_5_1_inst (
	.X(next),
	.Y(next_out),
	.reset(reset),
	.clk(clk)
);
wire  [17:0] a249;
 		wire  [17:0] a250;
 		wire  [17:0] a251;
 		wire  [17:0] a252;
 		wire  [17:0] a257;
 		wire  [17:0] a258;
 		wire  [17:0] a259;
 		wire  [17:0] a260;
 		wire  [17:0] a265;
 		wire  [17:0] a266;
 		wire  [17:0] a267;
 		wire  [17:0] a268;
 		wire  [17:0] a273;
 		wire  [17:0] a274;
 		wire  [17:0] a275;
 		wire  [17:0] a276;
 		wire  [17:0] a281;
 		wire  [17:0] a282;
 		wire  [17:0] a283;
 		wire  [17:0] a284;
 		wire  [17:0] a289;
 		wire  [17:0] a290;
 		wire  [17:0] a291;
 		wire  [17:0] a292;
 		wire  [17:0] a297;
 		wire  [17:0] a298;
 		wire  [17:0] a299;
 		wire  [17:0] a300;
 		wire  [17:0] a305;
 		wire  [17:0] a306;
 		wire  [17:0] a307;
 		wire  [17:0] a308;
 		wire  [17:0] t914;
 		wire  [17:0] t915;
 		wire  [17:0] t916;
 		wire  [17:0] t917;
 		wire  [17:0] t918;
 		wire  [17:0] t919;
 		wire  [17:0] t920;
 		wire  [17:0] t921;
 		wire  [17:0] t930;
 		wire  [17:0] t931;
 		wire  [17:0] t932;
 		wire  [17:0] t933;
 		wire  [17:0] t934;
 		wire  [17:0] t935;
 		wire  [17:0] t936;
 		wire  [17:0] t937;
 		wire  [17:0] t952;
 		wire  [17:0] t953;
 		wire  [17:0] t954;
 		wire  [17:0] t955;
 		wire  [17:0] t956;
 		wire  [17:0] t957;
 		wire  [17:0] t958;
 		wire  [17:0] t959;
 		wire  [17:0] t972;
 		wire  [17:0] t973;
 		wire  [17:0] t974;
 		wire  [17:0] t975;
 		wire  [17:0] t976;
 		wire  [17:0] t977;
 		wire  [17:0] t978;
 		wire  [17:0] t979;
 		wire  [17:0] t922;
 		wire  [17:0] t923;
 		wire  [17:0] t924;
 		wire  [17:0] t925;
 		wire  [17:0] t926;
 		wire  [17:0] t927;
 		wire  [17:0] t928;
 		wire  [17:0] t929;
 		wire  [17:0] t938;
 		wire  [17:0] t939;
 		wire  [17:0] t940;
 		wire  [17:0] t941;
 		wire  [17:0] t944;
 		wire  [17:0] t945;
 		wire  [17:0] t946;
 		wire  [17:0] t947;
 		wire  [17:0] t960;
 		wire  [17:0] t961;
 		wire  [17:0] t962;
 		wire  [17:0] t963;
 		wire  [17:0] t964;
 		wire  [17:0] t965;
 		wire  [17:0] t966;
 		wire  [17:0] t967;
 		wire  [17:0] t980;
 		wire  [17:0] t981;
 		wire  [17:0] t982;
 		wire  [17:0] t983;
 		wire  [17:0] t986;
 		wire  [17:0] t987;
 		wire  [17:0] t988;
 		wire  [17:0] t989;
 		reg  [17:0] tm24;
 		reg  [17:0] tm27;
 		reg  [17:0] tm30;
 		reg  [17:0] tm33;
 		reg  [17:0] tm36;
 		reg  [17:0] tm39;
 		reg  [17:0] tm42;
 		reg  [17:0] tm45;
 		reg  [17:0] tm48;
 		reg  [17:0] tm51;
 		reg  [17:0] tm54;
 		reg  [17:0] tm57;
 		reg  [17:0] tm60;
 		reg  [17:0] tm63;
 		reg  [17:0] tm66;
 		reg  [17:0] tm69;
 		wire  [17:0] a225;
 		wire  [17:0] a226;
 		wire  [17:0] a227;
 		wire  [17:0] a228;
 		wire  [17:0] a229;
 		wire  [17:0] a230;
 		wire  [17:0] a231;
 		wire  [17:0] a232;
 		wire  [17:0] a233;
 		wire  [17:0] a234;
 		wire  [17:0] a235;
 		wire  [17:0] a236;
 		wire  [17:0] a237;
 		wire  [17:0] a238;
 		wire  [17:0] a239;
 		wire  [17:0] a240;
 		wire  [17:0] a241;
 		wire  [17:0] a242;
 		wire  [17:0] a243;
 		wire  [17:0] a244;
 		wire  [17:0] a245;
 		wire  [17:0] a246;
 		wire  [17:0] a247;
 		wire  [17:0] a248;
 		reg  [17:0] tm25;
 		reg  [17:0] tm28;
 		reg  [17:0] tm31;
 		reg  [17:0] tm34;
 		reg  [17:0] tm37;
 		reg  [17:0] tm40;
 		reg  [17:0] tm43;
 		reg  [17:0] tm46;
 		reg  [17:0] tm49;
 		reg  [17:0] tm52;
 		reg  [17:0] tm55;
 		reg  [17:0] tm58;
 		reg  [17:0] tm61;
 		reg  [17:0] tm64;
 		reg  [17:0] tm67;
 		reg  [17:0] tm70;
 		wire  [17:0] t942;
 		wire  [17:0] t943;
 		wire  [17:0] t948;
 		wire  [17:0] t949;
 		wire  [17:0] t950;
 		wire  [17:0] t951;
 		wire  [17:0] t968;
 		wire  [17:0] t969;
 		wire  [17:0] t970;
 		wire  [17:0] t971;
 		wire  [17:0] t984;
 		wire  [17:0] t985;
 		wire  [17:0] t990;
 		wire  [17:0] t991;
 		wire  [17:0] t992;
 		wire  [17:0] t993;
 		reg  [17:0] tm26;
 		reg  [17:0] tm29;
 		reg  [17:0] tm32;
 		reg  [17:0] tm35;
 		reg  [17:0] tm38;
 		reg  [17:0] tm41;
 		reg  [17:0] tm44;
 		reg  [17:0] tm47;
 		reg  [17:0] tm50;
 		reg  [17:0] tm53;
 		reg  [17:0] tm56;
 		reg  [17:0] tm59;
 		reg  [17:0] tm62;
 		reg  [17:0] tm65;
 		reg  [17:0] tm68;
 		reg  [17:0] tm71;

wire  [17:0] tm0;
assign tm0 = (18'hb505 >> (18-18));
wire  [17:0] tm2;
assign tm2 = (18'hec83 >> (18-18));
wire  [17:0] tm3;
assign tm3 = (18'h61f8 >> (18-18));

assign a249 = X0;
 		assign a250 = X16;
 		assign a251 = X1;
 		assign a252 = X17;
 		assign a257 = X8;
 		assign a258 = X24;
 		assign a259 = X9;
 		assign a260 = X25;
 		assign a265 = X2;
 		assign a266 = X18;
 		assign a267 = X3;
 		assign a268 = X19;
 		assign a273 = X10;
 		assign a274 = X26;
 		assign a275 = X11;
 		assign a276 = X27;
 		assign a281 = X4;
 		assign a282 = X20;
 		assign a283 = X5;
 		assign a284 = X21;
 		assign a289 = X12;
 		assign a290 = X28;
 		assign a291 = X13;
 		assign a292 = X29;
 		assign a297 = X6;
 		assign a298 = X22;
 		assign a299 = X7;
 		assign a300 = X23;
 		assign a305 = X14;
 		assign a306 = X30;
 		assign a307 = X15;
 		assign a308 = X31;
 		assign Y0 = tm26;
 		assign Y1 = tm29;
 		assign Y4 = tm32;
 		assign Y5 = tm35;
 		assign Y2 = tm38;
 		assign Y3 = tm41;
 		assign Y6 = tm44;
 		assign Y7 = tm47;
 		assign Y8 = tm50;
 		assign Y9 = tm53;
 		assign Y12 = t942;
 		assign Y13 = t943;
 		assign Y10 = t948;
 		assign Y11 = t949;
 		assign Y14 = t950;
 		assign Y15 = t951;
 		assign Y16 = tm56;
 		assign Y17 = tm59;
 		assign Y20 = tm62;
 		assign Y21 = tm65;
 		assign Y18 = t968;
 		assign Y19 = t969;
 		assign Y22 = (~(t970)+1);
 		assign Y23 = t971;
 		assign Y24 = tm68;
 		assign Y25 = tm71;
 		assign Y28 = (~(t984)+1);
 		assign Y29 = t985;
 		assign Y26 = t990;
 		assign Y27 = t991;
 		assign Y30 = t992;
 		assign Y31 = (~(t993)+1);

addfxp_18_1 add98062(.a(a249), .b(a250), .clk(clk), .q(t914));
 		addfxp_18_1 add98077(.a(a251), .b(a252), .clk(clk), .q(t915));
 		subfxp_18_1 sub98092(.a(a249), .b(a250), .clk(clk), .q(t916));
 		subfxp_18_1 sub98107(.a(a251), .b(a252), .clk(clk), .q(t917));
 		addfxp_18_1 add98122(.a(a257), .b(a258), .clk(clk), .q(t918));
 		addfxp_18_1 add98137(.a(a259), .b(a260), .clk(clk), .q(t919));
 		subfxp_18_1 sub98152(.a(a257), .b(a258), .clk(clk), .q(t920));
 		subfxp_18_1 sub98167(.a(a259), .b(a260), .clk(clk), .q(t921));
 		addfxp_18_1 add98270(.a(a265), .b(a266), .clk(clk), .q(t930));
 		addfxp_18_1 add98285(.a(a267), .b(a268), .clk(clk), .q(t931));
 		subfxp_18_1 sub98300(.a(a265), .b(a266), .clk(clk), .q(t932));
 		subfxp_18_1 sub98315(.a(a267), .b(a268), .clk(clk), .q(t933));
 		addfxp_18_1 add98330(.a(a273), .b(a274), .clk(clk), .q(t934));
 		addfxp_18_1 add98345(.a(a275), .b(a276), .clk(clk), .q(t935));
 		subfxp_18_1 sub98360(.a(a273), .b(a274), .clk(clk), .q(t936));
 		subfxp_18_1 sub98375(.a(a275), .b(a276), .clk(clk), .q(t937));
 		addfxp_18_1 add98590(.a(a281), .b(a282), .clk(clk), .q(t952));
 		addfxp_18_1 add98605(.a(a283), .b(a284), .clk(clk), .q(t953));
 		subfxp_18_1 sub98620(.a(a281), .b(a282), .clk(clk), .q(t954));
 		subfxp_18_1 sub98635(.a(a283), .b(a284), .clk(clk), .q(t955));
 		addfxp_18_1 add98650(.a(a289), .b(a290), .clk(clk), .q(t956));
 		addfxp_18_1 add98665(.a(a291), .b(a292), .clk(clk), .q(t957));
 		subfxp_18_1 sub98680(.a(a289), .b(a290), .clk(clk), .q(t958));
 		subfxp_18_1 sub98695(.a(a291), .b(a292), .clk(clk), .q(t959));
 		addfxp_18_1 add98856(.a(a297), .b(a298), .clk(clk), .q(t972));
 		addfxp_18_1 add98871(.a(a299), .b(a300), .clk(clk), .q(t973));
 		subfxp_18_1 sub98886(.a(a297), .b(a298), .clk(clk), .q(t974));
 		subfxp_18_1 sub98901(.a(a299), .b(a300), .clk(clk), .q(t975));
 		addfxp_18_1 add98916(.a(a305), .b(a306), .clk(clk), .q(t976));
 		addfxp_18_1 add98931(.a(a307), .b(a308), .clk(clk), .q(t977));
 		subfxp_18_1 sub98946(.a(a305), .b(a306), .clk(clk), .q(t978));
 		subfxp_18_1 sub98961(.a(a307), .b(a308), .clk(clk), .q(t979));
 		addfxp_18_1 add98174(.a(t914), .b(t918), .clk(clk), .q(t922));
 		addfxp_18_1 add98181(.a(t915), .b(t919), .clk(clk), .q(t923));
 		subfxp_18_1 sub98188(.a(t914), .b(t918), .clk(clk), .q(t924));
 		subfxp_18_1 sub98195(.a(t915), .b(t919), .clk(clk), .q(t925));
 		subfxp_18_1 sub98218(.a(t916), .b(t921), .clk(clk), .q(t926));
 		addfxp_18_1 add98225(.a(t917), .b(t920), .clk(clk), .q(t927));
 		addfxp_18_1 add98232(.a(t916), .b(t921), .clk(clk), .q(t928));
 		subfxp_18_1 sub98239(.a(t917), .b(t920), .clk(clk), .q(t929));
 		addfxp_18_1 add98382(.a(t930), .b(t934), .clk(clk), .q(t938));
 		addfxp_18_1 add98389(.a(t931), .b(t935), .clk(clk), .q(t939));
 		subfxp_18_1 sub98396(.a(t930), .b(t934), .clk(clk), .q(t940));
 		subfxp_18_1 sub98403(.a(t931), .b(t935), .clk(clk), .q(t941));
 		subfxp_18_1 sub98454(.a(t932), .b(t937), .clk(clk), .q(t944));
 		addfxp_18_1 add98461(.a(t933), .b(t936), .clk(clk), .q(t945));
 		addfxp_18_1 add98468(.a(t932), .b(t937), .clk(clk), .q(t946));
 		subfxp_18_1 sub98475(.a(t933), .b(t936), .clk(clk), .q(t947));
 		addfxp_18_1 add98702(.a(t952), .b(t956), .clk(clk), .q(t960));
 		addfxp_18_1 add98709(.a(t953), .b(t957), .clk(clk), .q(t961));
 		subfxp_18_1 sub98716(.a(t952), .b(t956), .clk(clk), .q(t962));
 		subfxp_18_1 sub98723(.a(t953), .b(t957), .clk(clk), .q(t963));
 		subfxp_18_1 sub98747(.a(t954), .b(t959), .clk(clk), .q(t964));
 		addfxp_18_1 add98754(.a(t955), .b(t958), .clk(clk), .q(t965));
 		addfxp_18_1 add98761(.a(t954), .b(t959), .clk(clk), .q(t966));
 		subfxp_18_1 sub98768(.a(t955), .b(t958), .clk(clk), .q(t967));
 		addfxp_18_1 add98968(.a(t972), .b(t976), .clk(clk), .q(t980));
 		addfxp_18_1 add98975(.a(t973), .b(t977), .clk(clk), .q(t981));
 		subfxp_18_1 sub98982(.a(t972), .b(t976), .clk(clk), .q(t982));
 		subfxp_18_1 sub98989(.a(t973), .b(t977), .clk(clk), .q(t983));
 		subfxp_18_1 sub99041(.a(t974), .b(t979), .clk(clk), .q(t986));
 		addfxp_18_1 add99048(.a(t975), .b(t978), .clk(clk), .q(t987));
 		addfxp_18_1 add99055(.a(t974), .b(t979), .clk(clk), .q(t988));
 		subfxp_18_1 sub99062(.a(t975), .b(t978), .clk(clk), .q(t989));

multfix_alt_dsp_18 m88566(.ax(tm0), .ay(t940), .bx(tm0), .by(t941), .clk(clk), .a_q_sc(a225), .a_q_unsc(), .b_q_sc(a226), .b_q_unsc(), .rst(reset));
 			multfix_alt_dsp_18 m88570(.ax(tm2), .ay(t944), .bx(tm3), .by(t945), .clk(clk), .a_q_sc(a227), .a_q_unsc(), .b_q_sc(a228), .b_q_unsc(), .rst(reset));
 			multfix_alt_dsp_18 m88572(.ax(tm3), .ay(t944), .bx(tm2), .by(t945), .clk(clk), .a_q_sc(a229), .a_q_unsc(), .b_q_sc(a230), .b_q_unsc(), .rst(reset));
 			multfix_alt_dsp_18 m88574(.ax(tm3), .ay(t946), .bx(tm2), .by(t947), .clk(clk), .a_q_sc(a231), .a_q_unsc(), .b_q_sc(a232), .b_q_unsc(), .rst(reset));
 			multfix_alt_dsp_18 m88576(.ax(tm2), .ay(t946), .bx(tm3), .by(t947), .clk(clk), .a_q_sc(a233), .a_q_unsc(), .b_q_sc(a234), .b_q_unsc(), .rst(reset));
 			multfix_alt_dsp_18 m88578(.ax(tm0), .ay(t964), .bx(tm0), .by(t965), .clk(clk), .a_q_sc(a235), .a_q_unsc(), .b_q_sc(a236), .b_q_unsc(), .rst(reset));
 			multfix_alt_dsp_18 m88580(.ax(tm0), .ay(t966), .bx(tm0), .by(t967), .clk(clk), .a_q_sc(a237), .a_q_unsc(), .b_q_sc(a238), .b_q_unsc(), .rst(reset));
 			multfix_alt_dsp_18 m88582(.ax(tm0), .ay(t982), .bx(tm0), .by(t983), .clk(clk), .a_q_sc(a239), .a_q_unsc(), .b_q_sc(a240), .b_q_unsc(), .rst(reset));
 			multfix_alt_dsp_18 m88584(.ax(tm3), .ay(t986), .bx(tm2), .by(t987), .clk(clk), .a_q_sc(a241), .a_q_unsc(), .b_q_sc(a242), .b_q_unsc(), .rst(reset));
 			multfix_alt_dsp_18 m88586(.ax(tm2), .ay(t986), .bx(tm3), .by(t987), .clk(clk), .a_q_sc(a243), .a_q_unsc(), .b_q_sc(a244), .b_q_unsc(), .rst(reset));
 			multfix_alt_dsp_18 m88588(.ax(tm3), .ay(t989), .bx(tm2), .by(t988), .clk(clk), .a_q_sc(a245), .a_q_unsc(), .b_q_sc(a246), .b_q_unsc(), .rst(reset));
 			multfix_alt_dsp_18 m88590(.ax(tm3), .ay(t988), .bx(tm2), .by(t989), .clk(clk), .a_q_sc(a247), .a_q_unsc(), .b_q_sc(a248), .b_q_unsc(), .rst(reset));

subfxp_18_1 sub98424(.a(a225), .b(a226), .clk(clk), .q(t942));
 		addfxp_18_1 add98431(.a(a225), .b(a226), .clk(clk), .q(t943));
 		subfxp_18_1 sub98496(.a(a227), .b(a228), .clk(clk), .q(t948));
 		addfxp_18_1 add98517(.a(a229), .b(a230), .clk(clk), .q(t949));
 		subfxp_18_1 sub98538(.a(a231), .b(a232), .clk(clk), .q(t950));
 		addfxp_18_1 add98559(.a(a233), .b(a234), .clk(clk), .q(t951));
 		subfxp_18_1 sub98789(.a(a235), .b(a236), .clk(clk), .q(t968));
 		addfxp_18_1 add98796(.a(a235), .b(a236), .clk(clk), .q(t969));
 		addfxp_18_1 add98817(.a(a237), .b(a238), .clk(clk), .q(t970));
 		subfxp_18_1 sub98824(.a(a237), .b(a238), .clk(clk), .q(t971));
 		addfxp_18_1 add99010(.a(a239), .b(a240), .clk(clk), .q(t984));
 		subfxp_18_1 sub99017(.a(a239), .b(a240), .clk(clk), .q(t985));
 		subfxp_18_1 sub99083(.a(a241), .b(a242), .clk(clk), .q(t990));
 		addfxp_18_1 add99104(.a(a243), .b(a244), .clk(clk), .q(t991));
 		subfxp_18_1 sub99125(.a(a245), .b(a246), .clk(clk), .q(t992));
 		addfxp_18_1 add99146(.a(a247), .b(a248), .clk(clk), .q(t993));

always @(posedge clk) begin
	if (reset == 1) begin
		next <= 1'b0;
	end else begin
		X0 <= X0_in;
		X1 <= X1_in;
		X2 <= X2_in;
		X3 <= X3_in;
		X4 <= X4_in;
		X5 <= X5_in;
		X6 <= X6_in;
		X7 <= X7_in;
		X8 <= X8_in;
		X9 <= X9_in;
		X10 <= X10_in;
		X11 <= X11_in;
		X12 <= X12_in;
		X13 <= X13_in;
		X14 <= X14_in;
		X15 <= X15_in;
		X16 <= X16_in;
		X17 <= X17_in;
		X18 <= X18_in;
		X19 <= X19_in;
		X20 <= X20_in;
		X21 <= X21_in;
		X22 <= X22_in;
		X23 <= X23_in;
		X24 <= X24_in;
		X25 <= X25_in;
		X26 <= X26_in;
		X27 <= X27_in;
		X28 <= X28_in;
		X29 <= X29_in;
		X30 <= X30_in;
		X31 <= X31_in;
		next <= next_in;
		tm24 <= t922;
		tm27 <= t923;
		tm30 <= t924;
		tm33 <= t925;
		tm36 <= t926;
		tm39 <= t927;
		tm42 <= t928;
		tm45 <= t929;
		tm48 <= t938;
		tm51 <= t939;
		tm54 <= t960;
		tm57 <= t961;
		tm60 <= (~(t963)+1);
		tm63 <= t962;
		tm66 <= t980;
		tm69 <= t981;
		tm25 <= tm24;
		tm28 <= tm27;
		tm31 <= tm30;
		tm34 <= tm33;
		tm37 <= tm36;
		tm40 <= tm39;
		tm43 <= tm42;
		tm46 <= tm45;
		tm49 <= tm48;
		tm52 <= tm51;
		tm55 <= tm54;
		tm58 <= tm57;
		tm61 <= tm60;
		tm64 <= tm63;
		tm67 <= tm66;
		tm70 <= tm69;
		tm26 <= tm25;
		tm29 <= tm28;
		tm32 <= tm31;
		tm35 <= tm34;
		tm38 <= tm37;
		tm41 <= tm40;
		tm44 <= tm43;
		tm47 <= tm46;
		tm50 <= tm49;
		tm53 <= tm52;
		tm56 <= tm55;
		tm59 <= tm58;
		tm62 <= tm61;
		tm65 <= tm64;
		tm68 <= tm67;
		tm71 <= tm70;
	end
end

endmodule
module multfix_alt_dsp_18 (
	input [17:0] ax,
	input [17:0] ay,
	input [17:0] bx,
	input [17:0] by,
	input clk,
	output [17:0] a_q_sc,
	output [17:0] a_q_unsc,
	output [17:0] b_q_sc,
	output [17:0] b_q_unsc,
	input rst
);

wire [35:0] a_res;
wire [35:0] b_res;

assign a_q_unsc = a_res[17:0];
assign a_q_sc = {a_res[35-1], a_res[32			:16]};
assign b_q_unsc = b_res[17:0];
assign b_q_sc = {b_res[35-1], b_res[32			:16]};

dsp_signed_mult_18x18_unit_18_36_0 dsp_signed_mult_18x18_unit_18_36_0_inst (
	.clk(clk),
	.ena(1'b1),
	.reset(rst),
	.i_valid(),
	.o_valid(),
	.ax(ax),
	.ay(ay),
	.bx(bx),
	.by(by),
	.resulta(a_res),
	.resultb(b_res)
);

endmodule
module dsp_signed_mult_18x18_unit_18_36_0 (
	input clk,
	input reset,
	input ena,
	input i_valid,
	input [17:0] ax,
	input [17:0] ay,
	input [17:0] bx,
	input [17:0] by,
	output o_valid,
	output [35:0] resulta,
	output [35:0] resultb 
);

reg [35:0] reg_resa, reg_resb;
always @(posedge clk) begin
	reg_resa <= ax * ay;
	reg_resb <= bx * by;
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
module shiftRegFIFO_5_1 (
	input [0:0] X,
	output [0:0] Y,
	input reset,
	input clk
);

reg [0:0] mem_0;
reg [0:0] mem_1;
reg [0:0] mem_2;
reg [0:0] mem_3;
reg [0:0] mem_4;
assign Y = mem_4;

always @ (posedge clk) begin
	if (reset) begin
		mem_0 <= 0;
		mem_1 <= 0;
		mem_2 <= 0;
		mem_3 <= 0;
		mem_4 <= 0;
	end else begin
		mem_1 <= mem_0;
		mem_2 <= mem_1;
		mem_3 <= mem_2;
		mem_4 <= mem_3;
		mem_0 <= X;
	end
end

endmodule
