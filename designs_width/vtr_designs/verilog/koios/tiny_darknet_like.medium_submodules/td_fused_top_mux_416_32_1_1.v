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

module td_fused_top_mux_416_32_1_1 #(
parameter
    ID                = 0,
    NUM_STAGE         = 1,
    din0_WIDTH       = 32,
    din1_WIDTH       = 32,
    din2_WIDTH       = 32,
    din3_WIDTH       = 32,
    din4_WIDTH         = 32,
    dout_WIDTH            = 32
)(
    input  [31 : 0]     din0,
    input  [31 : 0]     din1,
    input  [31 : 0]     din2,
    input  [31 : 0]     din3,
    input  [15 : 0]    din4,
    output [31 : 0]   dout);

// puts internal signals
wire [15 : 0]     sel;
// level 1 signals
wire [31 : 0]         mux_1_0;
wire [31 : 0]         mux_1_1;
// level 2 signals
wire [31 : 0]         mux_2_0;
// level 3 signals
wire [31 : 0]         mux_3_0;
// level 4 signals
wire [31 : 0]         mux_4_0;
// level 5 signals
wire [31 : 0]         mux_5_0;
// level 6 signals
wire [31 : 0]         mux_6_0;
// level 7 signals
wire [31 : 0]         mux_7_0;
// level 8 signals
wire [31 : 0]         mux_8_0;
// level 9 signals
wire [31 : 0]         mux_9_0;
// level 10 signals
wire [31 : 0]         mux_10_0;
// level 11 signals
wire [31 : 0]         mux_11_0;
// level 12 signals
wire [31 : 0]         mux_12_0;
// level 13 signals
wire [31 : 0]         mux_13_0;
// level 14 signals
wire [31 : 0]         mux_14_0;
// level 15 signals
wire [31 : 0]         mux_15_0;
// level 16 signals
wire [31 : 0]         mux_16_0;

assign sel = din4;

// Generate level 1 logic
assign mux_1_0 = (sel[0] == 0)? din0 : din1;
assign mux_1_1 = (sel[0] == 0)? din2 : din3;

// Generate level 2 logic
assign mux_2_0 = (sel[1] == 0)? mux_1_0 : mux_1_1;

// Generate level 3 logic
assign mux_3_0 = mux_2_0;

// Generate level 4 logic
assign mux_4_0 = mux_3_0;

// Generate level 5 logic
assign mux_5_0 = mux_4_0;

// Generate level 6 logic
assign mux_6_0 = mux_5_0;

// Generate level 7 logic
assign mux_7_0 = mux_6_0;

// Generate level 8 logic
assign mux_8_0 = mux_7_0;

// Generate level 9 logic
assign mux_9_0 = mux_8_0;

// Generate level 10 logic
assign mux_10_0 = mux_9_0;

// Generate level 11 logic
assign mux_11_0 = mux_10_0;

// Generate level 12 logic
assign mux_12_0 = mux_11_0;

// Generate level 13 logic
assign mux_13_0 = mux_12_0;

// Generate level 14 logic
assign mux_14_0 = mux_13_0;

// Generate level 15 logic
assign mux_15_0 = mux_14_0;

// Generate level 16 logic
assign mux_16_0 = mux_15_0;

// output logic
assign dout = mux_16_0;

endmodule
