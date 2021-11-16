`define SIMULATION_MEMORY
//`define SIMULATION_addfp
`define VECTOR_DEPTH 64 //Q,K,V vector size
`define DATA_WIDTH 16
`define VECTOR_BITS 1024 // 16 bit each (16x64)
`define NUM_WORDS 32   //num of words in the sentence
`define BUF_AWIDTH 4 //16 entries in each buffer ram
`define BUF_LOC_SIZE 4 //4 words in each addr location
`define OUT_RAM_DEPTH 512 //512 entries in output bram
//`define EXPONENT 8
//`define MANTISSA 7
`define EXPONENT 5
`define MANTISSA 10
`define SIGN 1
`define DWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define DEFINES_DONE
`define DATAWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define IEEE_COMPLIANCE 1
`define NUM 4
`define ADDRSIZE 4

module mode2_sub(
  a_inp0,
  a_inp1,
  a_inp2,
  a_inp3,
  outp0,
  outp1,
  outp2,
  outp3,
  b_inp
);

  input  [`DATAWIDTH-1 : 0] a_inp0;
  input  [`DATAWIDTH-1 : 0] a_inp1;
  input  [`DATAWIDTH-1 : 0] a_inp2;
  input  [`DATAWIDTH-1 : 0] a_inp3;
  output  [`DATAWIDTH-1 : 0] outp0;
  output  [`DATAWIDTH-1 : 0] outp1;
  output  [`DATAWIDTH-1 : 0] outp2;
  output  [`DATAWIDTH-1 : 0] outp3;
  input  [`DATAWIDTH-1 : 0] b_inp;


  wire clk_NC;
  wire rst_NC;
  wire [4:0] flags_NC0, flags_NC1, flags_NC2, flags_NC3;

  // 0 add, 1 sub
  fixed_point_addsub sub0(.clk(clk_NC), .rst(rst_NC), .a(a_inp0),	.b(b_inp), .operation(1'b1),	.result(outp0), .flags(flags_NC0));
  fixed_point_addsub sub1(.clk(clk_NC), .rst(rst_NC), .a(a_inp1),	.b(b_inp), .operation(1'b1),	.result(outp1), .flags(flags_NC1));
  fixed_point_addsub sub2(.clk(clk_NC), .rst(rst_NC), .a(a_inp2),	.b(b_inp), .operation(1'b1),	.result(outp2), .flags(flags_NC2));
  fixed_point_addsub sub3(.clk(clk_NC), .rst(rst_NC), .a(a_inp3),	.b(b_inp), .operation(1'b1),	.result(outp3), .flags(flags_NC3));

//  DW_fp_sub #(`MANTISSA, `EXPONENT, `IEEE_COMPLIANCE) sub0(.a(a_inp0), .b(b_inp), .z(outp0), .rnd(3'b000), .status());
//  DW_fp_sub #(`MANTISSA, `EXPONENT, `IEEE_COMPLIANCE) sub1(.a(a_inp1), .b(b_inp), .z(outp1), .rnd(3'b000), .status());
//  DW_fp_sub #(`MANTISSA, `EXPONENT, `IEEE_COMPLIANCE) sub2(.a(a_inp2), .b(b_inp), .z(outp2), .rnd(3'b000), .status());
//  DW_fp_sub #(`MANTISSA, `EXPONENT, `IEEE_COMPLIANCE) sub3(.a(a_inp3), .b(b_inp), .z(outp3), .rnd(3'b000), .status());
endmodule
