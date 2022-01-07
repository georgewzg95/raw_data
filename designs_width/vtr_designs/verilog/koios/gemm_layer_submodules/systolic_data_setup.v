`define BFLOAT16 
`define EXPONENT 8
`define MANTISSA 7
`define EXPONENT 5
`define MANTISSA 10
`define SIGN 1
`define DWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define AWIDTH 8
`define MEM_SIZE 256
`define MAT_MUL_SIZE 20
`define MASK_WIDTH 20
`define LOG2_MAT_MUL_SIZE 4 
`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3
`define MEM_ACCESS_LATENCY 1
`define ADDR_STRIDE_WIDTH 8

module systolic_data_setup(
clk,
reset,
start_mat_mul,
a_addr,
b_addr,
address_mat_a,
address_mat_b,
address_stride_a,
address_stride_b,
a_data,
b_data,
clk_cnt,
a0_data,
b0_data,
a1_data_delayed_1,
b1_data_delayed_1,
a2_data_delayed_2,
b2_data_delayed_2,
a3_data_delayed_3,
b3_data_delayed_3,
a4_data_delayed_4,
b4_data_delayed_4,
a5_data_delayed_5,
b5_data_delayed_5,
a6_data_delayed_6,
b6_data_delayed_6,
a7_data_delayed_7,
b7_data_delayed_7,
a8_data_delayed_8,
b8_data_delayed_8,
a9_data_delayed_9,
b9_data_delayed_9,
a10_data_delayed_10,
b10_data_delayed_10,
a11_data_delayed_11,
b11_data_delayed_11,
a12_data_delayed_12,
b12_data_delayed_12,
a13_data_delayed_13,
b13_data_delayed_13,
a14_data_delayed_14,
b14_data_delayed_14,
a15_data_delayed_15,
b15_data_delayed_15,
a16_data_delayed_16,
b16_data_delayed_16,
a17_data_delayed_17,
b17_data_delayed_17,
a18_data_delayed_18,
b18_data_delayed_18,
a19_data_delayed_19,
b19_data_delayed_19,

validity_mask_a_rows,
validity_mask_a_cols,
validity_mask_b_rows,
validity_mask_b_cols,

a_loc,
b_loc
);

input clk;
input reset;
input start_mat_mul;
output [`AWIDTH-1:0] a_addr;
output [`AWIDTH-1:0] b_addr;
input [`AWIDTH-1:0] address_mat_a;
input [`AWIDTH-1:0] address_mat_b;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data;
input [7:0] clk_cnt;
output [`DWIDTH-1:0] a0_data;
output [`DWIDTH-1:0] b0_data;
output [`DWIDTH-1:0] a1_data_delayed_1;
output [`DWIDTH-1:0] b1_data_delayed_1;
output [`DWIDTH-1:0] a2_data_delayed_2;
output [`DWIDTH-1:0] b2_data_delayed_2;
output [`DWIDTH-1:0] a3_data_delayed_3;
output [`DWIDTH-1:0] b3_data_delayed_3;
output [`DWIDTH-1:0] a4_data_delayed_4;
output [`DWIDTH-1:0] b4_data_delayed_4;
output [`DWIDTH-1:0] a5_data_delayed_5;
output [`DWIDTH-1:0] b5_data_delayed_5;
output [`DWIDTH-1:0] a6_data_delayed_6;
output [`DWIDTH-1:0] b6_data_delayed_6;
output [`DWIDTH-1:0] a7_data_delayed_7;
output [`DWIDTH-1:0] b7_data_delayed_7;
output [`DWIDTH-1:0] a8_data_delayed_8;
output [`DWIDTH-1:0] b8_data_delayed_8;
output [`DWIDTH-1:0] a9_data_delayed_9;
output [`DWIDTH-1:0] b9_data_delayed_9;
output [`DWIDTH-1:0] a10_data_delayed_10;
output [`DWIDTH-1:0] b10_data_delayed_10;
output [`DWIDTH-1:0] a11_data_delayed_11;
output [`DWIDTH-1:0] b11_data_delayed_11;
output [`DWIDTH-1:0] a12_data_delayed_12;
output [`DWIDTH-1:0] b12_data_delayed_12;
output [`DWIDTH-1:0] a13_data_delayed_13;
output [`DWIDTH-1:0] b13_data_delayed_13;
output [`DWIDTH-1:0] a14_data_delayed_14;
output [`DWIDTH-1:0] b14_data_delayed_14;
output [`DWIDTH-1:0] a15_data_delayed_15;
output [`DWIDTH-1:0] b15_data_delayed_15;
output [`DWIDTH-1:0] a16_data_delayed_16;
output [`DWIDTH-1:0] b16_data_delayed_16;
output [`DWIDTH-1:0] a17_data_delayed_17;
output [`DWIDTH-1:0] b17_data_delayed_17;
output [`DWIDTH-1:0] a18_data_delayed_18;
output [`DWIDTH-1:0] b18_data_delayed_18;
output [`DWIDTH-1:0] a19_data_delayed_19;
output [`DWIDTH-1:0] b19_data_delayed_19;

input [`MASK_WIDTH-1:0] validity_mask_a_rows;
input [`MASK_WIDTH-1:0] validity_mask_a_cols;
input [`MASK_WIDTH-1:0] validity_mask_b_rows;
input [`MASK_WIDTH-1:0] validity_mask_b_cols;

input [7:0] a_loc;
input [7:0] b_loc;
wire [`DWIDTH-1:0] a0_data;
wire [`DWIDTH-1:0] a1_data;
wire [`DWIDTH-1:0] a2_data;
wire [`DWIDTH-1:0] a3_data;
wire [`DWIDTH-1:0] a4_data;
wire [`DWIDTH-1:0] a5_data;
wire [`DWIDTH-1:0] a6_data;
wire [`DWIDTH-1:0] a7_data;
wire [`DWIDTH-1:0] a8_data;
wire [`DWIDTH-1:0] a9_data;
wire [`DWIDTH-1:0] a10_data;
wire [`DWIDTH-1:0] a11_data;
wire [`DWIDTH-1:0] a12_data;
wire [`DWIDTH-1:0] a13_data;
wire [`DWIDTH-1:0] a14_data;
wire [`DWIDTH-1:0] a15_data;
wire [`DWIDTH-1:0] a16_data;
wire [`DWIDTH-1:0] a17_data;
wire [`DWIDTH-1:0] a18_data;
wire [`DWIDTH-1:0] a19_data;
wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;
wire [`DWIDTH-1:0] b4_data;
wire [`DWIDTH-1:0] b5_data;
wire [`DWIDTH-1:0] b6_data;
wire [`DWIDTH-1:0] b7_data;
wire [`DWIDTH-1:0] b8_data;
wire [`DWIDTH-1:0] b9_data;
wire [`DWIDTH-1:0] b10_data;
wire [`DWIDTH-1:0] b11_data;
wire [`DWIDTH-1:0] b12_data;
wire [`DWIDTH-1:0] b13_data;
wire [`DWIDTH-1:0] b14_data;
wire [`DWIDTH-1:0] b15_data;
wire [`DWIDTH-1:0] b16_data;
wire [`DWIDTH-1:0] b17_data;
wire [`DWIDTH-1:0] b18_data;
wire [`DWIDTH-1:0] b19_data;

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM A
//////////////////////////////////////////////////////////////////////////
reg [`AWIDTH-1:0] a_addr;
reg a_mem_access; //flag that tells whether the matmul is trying to access memory or not

always @(posedge clk) begin
  //(clk_cnt >= a_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:

  if (reset || ~start_mat_mul || (clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)+20)) begin
  
      a_addr <= address_mat_a-address_stride_a;
  
    a_mem_access <= 0;
  end
  //else if ((clk_cnt >= a_loc*`MAT_MUL_SIZE) && (clk_cnt < a_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:

  else if ((clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (a_loc<<`LOG2_MAT_MUL_SIZE)+20)) begin
  
      a_addr <= a_addr + address_stride_a;
  
    a_mem_access <= 1;
  end
end

//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM A
//////////////////////////////////////////////////////////////////////////
reg [7:0] a_mem_access_counter;
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    a_mem_access_counter <= 0;
  end
  else if (a_mem_access == 1) begin
    a_mem_access_counter <= a_mem_access_counter + 1;  
  end
  else begin
    a_mem_access_counter <= 0;
  end
end

wire a_data_valid; //flag that tells whether the data from memory is valid
assign a_data_valid = 
     ((validity_mask_a_cols[0]==1'b0 && a_mem_access_counter==1) ||
      (validity_mask_a_cols[1]==1'b0 && a_mem_access_counter==2) ||
      (validity_mask_a_cols[2]==1'b0 && a_mem_access_counter==3) ||
      (validity_mask_a_cols[3]==1'b0 && a_mem_access_counter==4) ||
      (validity_mask_a_cols[4]==1'b0 && a_mem_access_counter==5) ||
      (validity_mask_a_cols[5]==1'b0 && a_mem_access_counter==6) ||
      (validity_mask_a_cols[6]==1'b0 && a_mem_access_counter==7) ||
      (validity_mask_a_cols[7]==1'b0 && a_mem_access_counter==8) ||
      (validity_mask_a_cols[8]==1'b0 && a_mem_access_counter==9) ||
      (validity_mask_a_cols[9]==1'b0 && a_mem_access_counter==10) ||
      (validity_mask_a_cols[10]==1'b0 && a_mem_access_counter==11) ||
      (validity_mask_a_cols[11]==1'b0 && a_mem_access_counter==12) ||
      (validity_mask_a_cols[12]==1'b0 && a_mem_access_counter==13) ||
      (validity_mask_a_cols[13]==1'b0 && a_mem_access_counter==14) ||
      (validity_mask_a_cols[14]==1'b0 && a_mem_access_counter==15) ||
      (validity_mask_a_cols[15]==1'b0 && a_mem_access_counter==16) ||
      (validity_mask_a_cols[16]==1'b0 && a_mem_access_counter==17) ||
      (validity_mask_a_cols[17]==1'b0 && a_mem_access_counter==18) ||
      (validity_mask_a_cols[18]==1'b0 && a_mem_access_counter==19) ||
      (validity_mask_a_cols[19]==1'b0 && a_mem_access_counter==20)) ?
    
    1'b0 : (a_mem_access_counter >= `MEM_ACCESS_LATENCY);

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM A (systolic data setup)
//////////////////////////////////////////////////////////////////////////
assign a0_data = a_data[1*`DWIDTH-1:0*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[0]}};
assign a1_data = a_data[2*`DWIDTH-1:1*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[1]}};
assign a2_data = a_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[2]}};
assign a3_data = a_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[3]}};
assign a4_data = a_data[5*`DWIDTH-1:4*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[4]}};
assign a5_data = a_data[6*`DWIDTH-1:5*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[5]}};
assign a6_data = a_data[7*`DWIDTH-1:6*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[6]}};
assign a7_data = a_data[8*`DWIDTH-1:7*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[7]}};
assign a8_data = a_data[9*`DWIDTH-1:8*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[8]}};
assign a9_data = a_data[10*`DWIDTH-1:9*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[9]}};
assign a10_data = a_data[11*`DWIDTH-1:10*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[10]}};
assign a11_data = a_data[12*`DWIDTH-1:11*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[11]}};
assign a12_data = a_data[13*`DWIDTH-1:12*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[12]}};
assign a13_data = a_data[14*`DWIDTH-1:13*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[13]}};
assign a14_data = a_data[15*`DWIDTH-1:14*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[14]}};
assign a15_data = a_data[16*`DWIDTH-1:15*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[15]}};
assign a16_data = a_data[17*`DWIDTH-1:16*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[16]}};
assign a17_data = a_data[18*`DWIDTH-1:17*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[17]}};
assign a18_data = a_data[19*`DWIDTH-1:18*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[18]}};
assign a19_data = a_data[20*`DWIDTH-1:19*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[19]}};

reg [`DWIDTH-1:0] a1_data_delayed_1;
reg [`DWIDTH-1:0] a2_data_delayed_1;
reg [`DWIDTH-1:0] a2_data_delayed_2;
reg [`DWIDTH-1:0] a3_data_delayed_1;
reg [`DWIDTH-1:0] a3_data_delayed_2;
reg [`DWIDTH-1:0] a3_data_delayed_3;
reg [`DWIDTH-1:0] a4_data_delayed_1;
reg [`DWIDTH-1:0] a4_data_delayed_2;
reg [`DWIDTH-1:0] a4_data_delayed_3;
reg [`DWIDTH-1:0] a4_data_delayed_4;
reg [`DWIDTH-1:0] a5_data_delayed_1;
reg [`DWIDTH-1:0] a5_data_delayed_2;
reg [`DWIDTH-1:0] a5_data_delayed_3;
reg [`DWIDTH-1:0] a5_data_delayed_4;
reg [`DWIDTH-1:0] a5_data_delayed_5;
reg [`DWIDTH-1:0] a6_data_delayed_1;
reg [`DWIDTH-1:0] a6_data_delayed_2;
reg [`DWIDTH-1:0] a6_data_delayed_3;
reg [`DWIDTH-1:0] a6_data_delayed_4;
reg [`DWIDTH-1:0] a6_data_delayed_5;
reg [`DWIDTH-1:0] a6_data_delayed_6;
reg [`DWIDTH-1:0] a7_data_delayed_1;
reg [`DWIDTH-1:0] a7_data_delayed_2;
reg [`DWIDTH-1:0] a7_data_delayed_3;
reg [`DWIDTH-1:0] a7_data_delayed_4;
reg [`DWIDTH-1:0] a7_data_delayed_5;
reg [`DWIDTH-1:0] a7_data_delayed_6;
reg [`DWIDTH-1:0] a7_data_delayed_7;
reg [`DWIDTH-1:0] a8_data_delayed_1;
reg [`DWIDTH-1:0] a8_data_delayed_2;
reg [`DWIDTH-1:0] a8_data_delayed_3;
reg [`DWIDTH-1:0] a8_data_delayed_4;
reg [`DWIDTH-1:0] a8_data_delayed_5;
reg [`DWIDTH-1:0] a8_data_delayed_6;
reg [`DWIDTH-1:0] a8_data_delayed_7;
reg [`DWIDTH-1:0] a8_data_delayed_8;
reg [`DWIDTH-1:0] a9_data_delayed_1;
reg [`DWIDTH-1:0] a9_data_delayed_2;
reg [`DWIDTH-1:0] a9_data_delayed_3;
reg [`DWIDTH-1:0] a9_data_delayed_4;
reg [`DWIDTH-1:0] a9_data_delayed_5;
reg [`DWIDTH-1:0] a9_data_delayed_6;
reg [`DWIDTH-1:0] a9_data_delayed_7;
reg [`DWIDTH-1:0] a9_data_delayed_8;
reg [`DWIDTH-1:0] a9_data_delayed_9;
reg [`DWIDTH-1:0] a10_data_delayed_1;
reg [`DWIDTH-1:0] a10_data_delayed_2;
reg [`DWIDTH-1:0] a10_data_delayed_3;
reg [`DWIDTH-1:0] a10_data_delayed_4;
reg [`DWIDTH-1:0] a10_data_delayed_5;
reg [`DWIDTH-1:0] a10_data_delayed_6;
reg [`DWIDTH-1:0] a10_data_delayed_7;
reg [`DWIDTH-1:0] a10_data_delayed_8;
reg [`DWIDTH-1:0] a10_data_delayed_9;
reg [`DWIDTH-1:0] a10_data_delayed_10;
reg [`DWIDTH-1:0] a11_data_delayed_1;
reg [`DWIDTH-1:0] a11_data_delayed_2;
reg [`DWIDTH-1:0] a11_data_delayed_3;
reg [`DWIDTH-1:0] a11_data_delayed_4;
reg [`DWIDTH-1:0] a11_data_delayed_5;
reg [`DWIDTH-1:0] a11_data_delayed_6;
reg [`DWIDTH-1:0] a11_data_delayed_7;
reg [`DWIDTH-1:0] a11_data_delayed_8;
reg [`DWIDTH-1:0] a11_data_delayed_9;
reg [`DWIDTH-1:0] a11_data_delayed_10;
reg [`DWIDTH-1:0] a11_data_delayed_11;
reg [`DWIDTH-1:0] a12_data_delayed_1;
reg [`DWIDTH-1:0] a12_data_delayed_2;
reg [`DWIDTH-1:0] a12_data_delayed_3;
reg [`DWIDTH-1:0] a12_data_delayed_4;
reg [`DWIDTH-1:0] a12_data_delayed_5;
reg [`DWIDTH-1:0] a12_data_delayed_6;
reg [`DWIDTH-1:0] a12_data_delayed_7;
reg [`DWIDTH-1:0] a12_data_delayed_8;
reg [`DWIDTH-1:0] a12_data_delayed_9;
reg [`DWIDTH-1:0] a12_data_delayed_10;
reg [`DWIDTH-1:0] a12_data_delayed_11;
reg [`DWIDTH-1:0] a12_data_delayed_12;
reg [`DWIDTH-1:0] a13_data_delayed_1;
reg [`DWIDTH-1:0] a13_data_delayed_2;
reg [`DWIDTH-1:0] a13_data_delayed_3;
reg [`DWIDTH-1:0] a13_data_delayed_4;
reg [`DWIDTH-1:0] a13_data_delayed_5;
reg [`DWIDTH-1:0] a13_data_delayed_6;
reg [`DWIDTH-1:0] a13_data_delayed_7;
reg [`DWIDTH-1:0] a13_data_delayed_8;
reg [`DWIDTH-1:0] a13_data_delayed_9;
reg [`DWIDTH-1:0] a13_data_delayed_10;
reg [`DWIDTH-1:0] a13_data_delayed_11;
reg [`DWIDTH-1:0] a13_data_delayed_12;
reg [`DWIDTH-1:0] a13_data_delayed_13;
reg [`DWIDTH-1:0] a14_data_delayed_1;
reg [`DWIDTH-1:0] a14_data_delayed_2;
reg [`DWIDTH-1:0] a14_data_delayed_3;
reg [`DWIDTH-1:0] a14_data_delayed_4;
reg [`DWIDTH-1:0] a14_data_delayed_5;
reg [`DWIDTH-1:0] a14_data_delayed_6;
reg [`DWIDTH-1:0] a14_data_delayed_7;
reg [`DWIDTH-1:0] a14_data_delayed_8;
reg [`DWIDTH-1:0] a14_data_delayed_9;
reg [`DWIDTH-1:0] a14_data_delayed_10;
reg [`DWIDTH-1:0] a14_data_delayed_11;
reg [`DWIDTH-1:0] a14_data_delayed_12;
reg [`DWIDTH-1:0] a14_data_delayed_13;
reg [`DWIDTH-1:0] a14_data_delayed_14;
reg [`DWIDTH-1:0] a15_data_delayed_1;
reg [`DWIDTH-1:0] a15_data_delayed_2;
reg [`DWIDTH-1:0] a15_data_delayed_3;
reg [`DWIDTH-1:0] a15_data_delayed_4;
reg [`DWIDTH-1:0] a15_data_delayed_5;
reg [`DWIDTH-1:0] a15_data_delayed_6;
reg [`DWIDTH-1:0] a15_data_delayed_7;
reg [`DWIDTH-1:0] a15_data_delayed_8;
reg [`DWIDTH-1:0] a15_data_delayed_9;
reg [`DWIDTH-1:0] a15_data_delayed_10;
reg [`DWIDTH-1:0] a15_data_delayed_11;
reg [`DWIDTH-1:0] a15_data_delayed_12;
reg [`DWIDTH-1:0] a15_data_delayed_13;
reg [`DWIDTH-1:0] a15_data_delayed_14;
reg [`DWIDTH-1:0] a15_data_delayed_15;
reg [`DWIDTH-1:0] a16_data_delayed_1;
reg [`DWIDTH-1:0] a16_data_delayed_2;
reg [`DWIDTH-1:0] a16_data_delayed_3;
reg [`DWIDTH-1:0] a16_data_delayed_4;
reg [`DWIDTH-1:0] a16_data_delayed_5;
reg [`DWIDTH-1:0] a16_data_delayed_6;
reg [`DWIDTH-1:0] a16_data_delayed_7;
reg [`DWIDTH-1:0] a16_data_delayed_8;
reg [`DWIDTH-1:0] a16_data_delayed_9;
reg [`DWIDTH-1:0] a16_data_delayed_10;
reg [`DWIDTH-1:0] a16_data_delayed_11;
reg [`DWIDTH-1:0] a16_data_delayed_12;
reg [`DWIDTH-1:0] a16_data_delayed_13;
reg [`DWIDTH-1:0] a16_data_delayed_14;
reg [`DWIDTH-1:0] a16_data_delayed_15;
reg [`DWIDTH-1:0] a16_data_delayed_16;
reg [`DWIDTH-1:0] a17_data_delayed_1;
reg [`DWIDTH-1:0] a17_data_delayed_2;
reg [`DWIDTH-1:0] a17_data_delayed_3;
reg [`DWIDTH-1:0] a17_data_delayed_4;
reg [`DWIDTH-1:0] a17_data_delayed_5;
reg [`DWIDTH-1:0] a17_data_delayed_6;
reg [`DWIDTH-1:0] a17_data_delayed_7;
reg [`DWIDTH-1:0] a17_data_delayed_8;
reg [`DWIDTH-1:0] a17_data_delayed_9;
reg [`DWIDTH-1:0] a17_data_delayed_10;
reg [`DWIDTH-1:0] a17_data_delayed_11;
reg [`DWIDTH-1:0] a17_data_delayed_12;
reg [`DWIDTH-1:0] a17_data_delayed_13;
reg [`DWIDTH-1:0] a17_data_delayed_14;
reg [`DWIDTH-1:0] a17_data_delayed_15;
reg [`DWIDTH-1:0] a17_data_delayed_16;
reg [`DWIDTH-1:0] a17_data_delayed_17;
reg [`DWIDTH-1:0] a18_data_delayed_1;
reg [`DWIDTH-1:0] a18_data_delayed_2;
reg [`DWIDTH-1:0] a18_data_delayed_3;
reg [`DWIDTH-1:0] a18_data_delayed_4;
reg [`DWIDTH-1:0] a18_data_delayed_5;
reg [`DWIDTH-1:0] a18_data_delayed_6;
reg [`DWIDTH-1:0] a18_data_delayed_7;
reg [`DWIDTH-1:0] a18_data_delayed_8;
reg [`DWIDTH-1:0] a18_data_delayed_9;
reg [`DWIDTH-1:0] a18_data_delayed_10;
reg [`DWIDTH-1:0] a18_data_delayed_11;
reg [`DWIDTH-1:0] a18_data_delayed_12;
reg [`DWIDTH-1:0] a18_data_delayed_13;
reg [`DWIDTH-1:0] a18_data_delayed_14;
reg [`DWIDTH-1:0] a18_data_delayed_15;
reg [`DWIDTH-1:0] a18_data_delayed_16;
reg [`DWIDTH-1:0] a18_data_delayed_17;
reg [`DWIDTH-1:0] a18_data_delayed_18;
reg [`DWIDTH-1:0] a19_data_delayed_1;
reg [`DWIDTH-1:0] a19_data_delayed_2;
reg [`DWIDTH-1:0] a19_data_delayed_3;
reg [`DWIDTH-1:0] a19_data_delayed_4;
reg [`DWIDTH-1:0] a19_data_delayed_5;
reg [`DWIDTH-1:0] a19_data_delayed_6;
reg [`DWIDTH-1:0] a19_data_delayed_7;
reg [`DWIDTH-1:0] a19_data_delayed_8;
reg [`DWIDTH-1:0] a19_data_delayed_9;
reg [`DWIDTH-1:0] a19_data_delayed_10;
reg [`DWIDTH-1:0] a19_data_delayed_11;
reg [`DWIDTH-1:0] a19_data_delayed_12;
reg [`DWIDTH-1:0] a19_data_delayed_13;
reg [`DWIDTH-1:0] a19_data_delayed_14;
reg [`DWIDTH-1:0] a19_data_delayed_15;
reg [`DWIDTH-1:0] a19_data_delayed_16;
reg [`DWIDTH-1:0] a19_data_delayed_17;
reg [`DWIDTH-1:0] a19_data_delayed_18;
reg [`DWIDTH-1:0] a19_data_delayed_19;


always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
    a1_data_delayed_1 <= 0;
    a2_data_delayed_1 <= 0;
    a2_data_delayed_2 <= 0;
    a3_data_delayed_1 <= 0;
    a3_data_delayed_2 <= 0;
    a3_data_delayed_3 <= 0;
    a4_data_delayed_1 <= 0;
    a4_data_delayed_2 <= 0;
    a4_data_delayed_3 <= 0;
    a4_data_delayed_4 <= 0;
    a5_data_delayed_1 <= 0;
    a5_data_delayed_2 <= 0;
    a5_data_delayed_3 <= 0;
    a5_data_delayed_4 <= 0;
    a5_data_delayed_5 <= 0;
    a6_data_delayed_1 <= 0;
    a6_data_delayed_2 <= 0;
    a6_data_delayed_3 <= 0;
    a6_data_delayed_4 <= 0;
    a6_data_delayed_5 <= 0;
    a6_data_delayed_6 <= 0;
    a7_data_delayed_1 <= 0;
    a7_data_delayed_2 <= 0;
    a7_data_delayed_3 <= 0;
    a7_data_delayed_4 <= 0;
    a7_data_delayed_5 <= 0;
    a7_data_delayed_6 <= 0;
    a7_data_delayed_7 <= 0;
    a8_data_delayed_1 <= 0;
    a8_data_delayed_2 <= 0;
    a8_data_delayed_3 <= 0;
    a8_data_delayed_4 <= 0;
    a8_data_delayed_5 <= 0;
    a8_data_delayed_6 <= 0;
    a8_data_delayed_7 <= 0;
    a8_data_delayed_8 <= 0;
    a9_data_delayed_1 <= 0;
    a9_data_delayed_2 <= 0;
    a9_data_delayed_3 <= 0;
    a9_data_delayed_4 <= 0;
    a9_data_delayed_5 <= 0;
    a9_data_delayed_6 <= 0;
    a9_data_delayed_7 <= 0;
    a9_data_delayed_8 <= 0;
    a9_data_delayed_9 <= 0;
    a10_data_delayed_1 <= 0;
    a10_data_delayed_2 <= 0;
    a10_data_delayed_3 <= 0;
    a10_data_delayed_4 <= 0;
    a10_data_delayed_5 <= 0;
    a10_data_delayed_6 <= 0;
    a10_data_delayed_7 <= 0;
    a10_data_delayed_8 <= 0;
    a10_data_delayed_9 <= 0;
    a10_data_delayed_10 <= 0;
    a11_data_delayed_1 <= 0;
    a11_data_delayed_2 <= 0;
    a11_data_delayed_3 <= 0;
    a11_data_delayed_4 <= 0;
    a11_data_delayed_5 <= 0;
    a11_data_delayed_6 <= 0;
    a11_data_delayed_7 <= 0;
    a11_data_delayed_8 <= 0;
    a11_data_delayed_9 <= 0;
    a11_data_delayed_10 <= 0;
    a11_data_delayed_11 <= 0;
    a12_data_delayed_1 <= 0;
    a12_data_delayed_2 <= 0;
    a12_data_delayed_3 <= 0;
    a12_data_delayed_4 <= 0;
    a12_data_delayed_5 <= 0;
    a12_data_delayed_6 <= 0;
    a12_data_delayed_7 <= 0;
    a12_data_delayed_8 <= 0;
    a12_data_delayed_9 <= 0;
    a12_data_delayed_10 <= 0;
    a12_data_delayed_11 <= 0;
    a12_data_delayed_12 <= 0;
    a13_data_delayed_1 <= 0;
    a13_data_delayed_2 <= 0;
    a13_data_delayed_3 <= 0;
    a13_data_delayed_4 <= 0;
    a13_data_delayed_5 <= 0;
    a13_data_delayed_6 <= 0;
    a13_data_delayed_7 <= 0;
    a13_data_delayed_8 <= 0;
    a13_data_delayed_9 <= 0;
    a13_data_delayed_10 <= 0;
    a13_data_delayed_11 <= 0;
    a13_data_delayed_12 <= 0;
    a13_data_delayed_13 <= 0;
    a14_data_delayed_1 <= 0;
    a14_data_delayed_2 <= 0;
    a14_data_delayed_3 <= 0;
    a14_data_delayed_4 <= 0;
    a14_data_delayed_5 <= 0;
    a14_data_delayed_6 <= 0;
    a14_data_delayed_7 <= 0;
    a14_data_delayed_8 <= 0;
    a14_data_delayed_9 <= 0;
    a14_data_delayed_10 <= 0;
    a14_data_delayed_11 <= 0;
    a14_data_delayed_12 <= 0;
    a14_data_delayed_13 <= 0;
    a14_data_delayed_14 <= 0;
    a15_data_delayed_1 <= 0;
    a15_data_delayed_2 <= 0;
    a15_data_delayed_3 <= 0;
    a15_data_delayed_4 <= 0;
    a15_data_delayed_5 <= 0;
    a15_data_delayed_6 <= 0;
    a15_data_delayed_7 <= 0;
    a15_data_delayed_8 <= 0;
    a15_data_delayed_9 <= 0;
    a15_data_delayed_10 <= 0;
    a15_data_delayed_11 <= 0;
    a15_data_delayed_12 <= 0;
    a15_data_delayed_13 <= 0;
    a15_data_delayed_14 <= 0;
    a15_data_delayed_15 <= 0;
    a16_data_delayed_1 <= 0;
    a16_data_delayed_2 <= 0;
    a16_data_delayed_3 <= 0;
    a16_data_delayed_4 <= 0;
    a16_data_delayed_5 <= 0;
    a16_data_delayed_6 <= 0;
    a16_data_delayed_7 <= 0;
    a16_data_delayed_8 <= 0;
    a16_data_delayed_9 <= 0;
    a16_data_delayed_10 <= 0;
    a16_data_delayed_11 <= 0;
    a16_data_delayed_12 <= 0;
    a16_data_delayed_13 <= 0;
    a16_data_delayed_14 <= 0;
    a16_data_delayed_15 <= 0;
    a16_data_delayed_16 <= 0;
    a17_data_delayed_1 <= 0;
    a17_data_delayed_2 <= 0;
    a17_data_delayed_3 <= 0;
    a17_data_delayed_4 <= 0;
    a17_data_delayed_5 <= 0;
    a17_data_delayed_6 <= 0;
    a17_data_delayed_7 <= 0;
    a17_data_delayed_8 <= 0;
    a17_data_delayed_9 <= 0;
    a17_data_delayed_10 <= 0;
    a17_data_delayed_11 <= 0;
    a17_data_delayed_12 <= 0;
    a17_data_delayed_13 <= 0;
    a17_data_delayed_14 <= 0;
    a17_data_delayed_15 <= 0;
    a17_data_delayed_16 <= 0;
    a17_data_delayed_17 <= 0;
    a18_data_delayed_1 <= 0;
    a18_data_delayed_2 <= 0;
    a18_data_delayed_3 <= 0;
    a18_data_delayed_4 <= 0;
    a18_data_delayed_5 <= 0;
    a18_data_delayed_6 <= 0;
    a18_data_delayed_7 <= 0;
    a18_data_delayed_8 <= 0;
    a18_data_delayed_9 <= 0;
    a18_data_delayed_10 <= 0;
    a18_data_delayed_11 <= 0;
    a18_data_delayed_12 <= 0;
    a18_data_delayed_13 <= 0;
    a18_data_delayed_14 <= 0;
    a18_data_delayed_15 <= 0;
    a18_data_delayed_16 <= 0;
    a18_data_delayed_17 <= 0;
    a18_data_delayed_18 <= 0;
    a19_data_delayed_1 <= 0;
    a19_data_delayed_2 <= 0;
    a19_data_delayed_3 <= 0;
    a19_data_delayed_4 <= 0;
    a19_data_delayed_5 <= 0;
    a19_data_delayed_6 <= 0;
    a19_data_delayed_7 <= 0;
    a19_data_delayed_8 <= 0;
    a19_data_delayed_9 <= 0;
    a19_data_delayed_10 <= 0;
    a19_data_delayed_11 <= 0;
    a19_data_delayed_12 <= 0;
    a19_data_delayed_13 <= 0;
    a19_data_delayed_14 <= 0;
    a19_data_delayed_15 <= 0;
    a19_data_delayed_16 <= 0;
    a19_data_delayed_17 <= 0;
    a19_data_delayed_18 <= 0;
    a19_data_delayed_19 <= 0;

  end
  else begin
  a1_data_delayed_1 <= a1_data;
  a2_data_delayed_1 <= a2_data;
  a3_data_delayed_1 <= a3_data;
  a4_data_delayed_1 <= a4_data;
  a5_data_delayed_1 <= a5_data;
  a6_data_delayed_1 <= a6_data;
  a7_data_delayed_1 <= a7_data;
  a8_data_delayed_1 <= a8_data;
  a9_data_delayed_1 <= a9_data;
  a10_data_delayed_1 <= a10_data;
  a11_data_delayed_1 <= a11_data;
  a12_data_delayed_1 <= a12_data;
  a13_data_delayed_1 <= a13_data;
  a14_data_delayed_1 <= a14_data;
  a15_data_delayed_1 <= a15_data;
  a16_data_delayed_1 <= a16_data;
  a17_data_delayed_1 <= a17_data;
  a18_data_delayed_1 <= a18_data;
  a19_data_delayed_1 <= a19_data;
  a2_data_delayed_2 <= a2_data_delayed_1;
  a3_data_delayed_2 <= a3_data_delayed_1;
  a3_data_delayed_3 <= a3_data_delayed_2;
  a4_data_delayed_2 <= a4_data_delayed_1;
  a4_data_delayed_3 <= a4_data_delayed_2;
  a4_data_delayed_4 <= a4_data_delayed_3;
  a5_data_delayed_2 <= a5_data_delayed_1;
  a5_data_delayed_3 <= a5_data_delayed_2;
  a5_data_delayed_4 <= a5_data_delayed_3;
  a5_data_delayed_5 <= a5_data_delayed_4;
  a6_data_delayed_2 <= a6_data_delayed_1;
  a6_data_delayed_3 <= a6_data_delayed_2;
  a6_data_delayed_4 <= a6_data_delayed_3;
  a6_data_delayed_5 <= a6_data_delayed_4;
  a6_data_delayed_6 <= a6_data_delayed_5;
  a7_data_delayed_2 <= a7_data_delayed_1;
  a7_data_delayed_3 <= a7_data_delayed_2;
  a7_data_delayed_4 <= a7_data_delayed_3;
  a7_data_delayed_5 <= a7_data_delayed_4;
  a7_data_delayed_6 <= a7_data_delayed_5;
  a7_data_delayed_7 <= a7_data_delayed_6;
  a8_data_delayed_2 <= a8_data_delayed_1;
  a8_data_delayed_3 <= a8_data_delayed_2;
  a8_data_delayed_4 <= a8_data_delayed_3;
  a8_data_delayed_5 <= a8_data_delayed_4;
  a8_data_delayed_6 <= a8_data_delayed_5;
  a8_data_delayed_7 <= a8_data_delayed_6;
  a8_data_delayed_8 <= a8_data_delayed_7;
  a9_data_delayed_2 <= a9_data_delayed_1;
  a9_data_delayed_3 <= a9_data_delayed_2;
  a9_data_delayed_4 <= a9_data_delayed_3;
  a9_data_delayed_5 <= a9_data_delayed_4;
  a9_data_delayed_6 <= a9_data_delayed_5;
  a9_data_delayed_7 <= a9_data_delayed_6;
  a9_data_delayed_8 <= a9_data_delayed_7;
  a9_data_delayed_9 <= a9_data_delayed_8;
  a10_data_delayed_2 <= a10_data_delayed_1;
  a10_data_delayed_3 <= a10_data_delayed_2;
  a10_data_delayed_4 <= a10_data_delayed_3;
  a10_data_delayed_5 <= a10_data_delayed_4;
  a10_data_delayed_6 <= a10_data_delayed_5;
  a10_data_delayed_7 <= a10_data_delayed_6;
  a10_data_delayed_8 <= a10_data_delayed_7;
  a10_data_delayed_9 <= a10_data_delayed_8;
  a10_data_delayed_10 <= a10_data_delayed_9;
  a11_data_delayed_2 <= a11_data_delayed_1;
  a11_data_delayed_3 <= a11_data_delayed_2;
  a11_data_delayed_4 <= a11_data_delayed_3;
  a11_data_delayed_5 <= a11_data_delayed_4;
  a11_data_delayed_6 <= a11_data_delayed_5;
  a11_data_delayed_7 <= a11_data_delayed_6;
  a11_data_delayed_8 <= a11_data_delayed_7;
  a11_data_delayed_9 <= a11_data_delayed_8;
  a11_data_delayed_10 <= a11_data_delayed_9;
  a11_data_delayed_11 <= a11_data_delayed_10;
  a12_data_delayed_2 <= a12_data_delayed_1;
  a12_data_delayed_3 <= a12_data_delayed_2;
  a12_data_delayed_4 <= a12_data_delayed_3;
  a12_data_delayed_5 <= a12_data_delayed_4;
  a12_data_delayed_6 <= a12_data_delayed_5;
  a12_data_delayed_7 <= a12_data_delayed_6;
  a12_data_delayed_8 <= a12_data_delayed_7;
  a12_data_delayed_9 <= a12_data_delayed_8;
  a12_data_delayed_10 <= a12_data_delayed_9;
  a12_data_delayed_11 <= a12_data_delayed_10;
  a12_data_delayed_12 <= a12_data_delayed_11;
  a13_data_delayed_2 <= a13_data_delayed_1;
  a13_data_delayed_3 <= a13_data_delayed_2;
  a13_data_delayed_4 <= a13_data_delayed_3;
  a13_data_delayed_5 <= a13_data_delayed_4;
  a13_data_delayed_6 <= a13_data_delayed_5;
  a13_data_delayed_7 <= a13_data_delayed_6;
  a13_data_delayed_8 <= a13_data_delayed_7;
  a13_data_delayed_9 <= a13_data_delayed_8;
  a13_data_delayed_10 <= a13_data_delayed_9;
  a13_data_delayed_11 <= a13_data_delayed_10;
  a13_data_delayed_12 <= a13_data_delayed_11;
  a13_data_delayed_13 <= a13_data_delayed_12;
  a14_data_delayed_2 <= a14_data_delayed_1;
  a14_data_delayed_3 <= a14_data_delayed_2;
  a14_data_delayed_4 <= a14_data_delayed_3;
  a14_data_delayed_5 <= a14_data_delayed_4;
  a14_data_delayed_6 <= a14_data_delayed_5;
  a14_data_delayed_7 <= a14_data_delayed_6;
  a14_data_delayed_8 <= a14_data_delayed_7;
  a14_data_delayed_9 <= a14_data_delayed_8;
  a14_data_delayed_10 <= a14_data_delayed_9;
  a14_data_delayed_11 <= a14_data_delayed_10;
  a14_data_delayed_12 <= a14_data_delayed_11;
  a14_data_delayed_13 <= a14_data_delayed_12;
  a14_data_delayed_14 <= a14_data_delayed_13;
  a15_data_delayed_2 <= a15_data_delayed_1;
  a15_data_delayed_3 <= a15_data_delayed_2;
  a15_data_delayed_4 <= a15_data_delayed_3;
  a15_data_delayed_5 <= a15_data_delayed_4;
  a15_data_delayed_6 <= a15_data_delayed_5;
  a15_data_delayed_7 <= a15_data_delayed_6;
  a15_data_delayed_8 <= a15_data_delayed_7;
  a15_data_delayed_9 <= a15_data_delayed_8;
  a15_data_delayed_10 <= a15_data_delayed_9;
  a15_data_delayed_11 <= a15_data_delayed_10;
  a15_data_delayed_12 <= a15_data_delayed_11;
  a15_data_delayed_13 <= a15_data_delayed_12;
  a15_data_delayed_14 <= a15_data_delayed_13;
  a15_data_delayed_15 <= a15_data_delayed_14;
  a16_data_delayed_2 <= a16_data_delayed_1;
  a16_data_delayed_3 <= a16_data_delayed_2;
  a16_data_delayed_4 <= a16_data_delayed_3;
  a16_data_delayed_5 <= a16_data_delayed_4;
  a16_data_delayed_6 <= a16_data_delayed_5;
  a16_data_delayed_7 <= a16_data_delayed_6;
  a16_data_delayed_8 <= a16_data_delayed_7;
  a16_data_delayed_9 <= a16_data_delayed_8;
  a16_data_delayed_10 <= a16_data_delayed_9;
  a16_data_delayed_11 <= a16_data_delayed_10;
  a16_data_delayed_12 <= a16_data_delayed_11;
  a16_data_delayed_13 <= a16_data_delayed_12;
  a16_data_delayed_14 <= a16_data_delayed_13;
  a16_data_delayed_15 <= a16_data_delayed_14;
  a16_data_delayed_16 <= a16_data_delayed_15;
  a17_data_delayed_2 <= a17_data_delayed_1;
  a17_data_delayed_3 <= a17_data_delayed_2;
  a17_data_delayed_4 <= a17_data_delayed_3;
  a17_data_delayed_5 <= a17_data_delayed_4;
  a17_data_delayed_6 <= a17_data_delayed_5;
  a17_data_delayed_7 <= a17_data_delayed_6;
  a17_data_delayed_8 <= a17_data_delayed_7;
  a17_data_delayed_9 <= a17_data_delayed_8;
  a17_data_delayed_10 <= a17_data_delayed_9;
  a17_data_delayed_11 <= a17_data_delayed_10;
  a17_data_delayed_12 <= a17_data_delayed_11;
  a17_data_delayed_13 <= a17_data_delayed_12;
  a17_data_delayed_14 <= a17_data_delayed_13;
  a17_data_delayed_15 <= a17_data_delayed_14;
  a17_data_delayed_16 <= a17_data_delayed_15;
  a17_data_delayed_17 <= a17_data_delayed_16;
  a18_data_delayed_2 <= a18_data_delayed_1;
  a18_data_delayed_3 <= a18_data_delayed_2;
  a18_data_delayed_4 <= a18_data_delayed_3;
  a18_data_delayed_5 <= a18_data_delayed_4;
  a18_data_delayed_6 <= a18_data_delayed_5;
  a18_data_delayed_7 <= a18_data_delayed_6;
  a18_data_delayed_8 <= a18_data_delayed_7;
  a18_data_delayed_9 <= a18_data_delayed_8;
  a18_data_delayed_10 <= a18_data_delayed_9;
  a18_data_delayed_11 <= a18_data_delayed_10;
  a18_data_delayed_12 <= a18_data_delayed_11;
  a18_data_delayed_13 <= a18_data_delayed_12;
  a18_data_delayed_14 <= a18_data_delayed_13;
  a18_data_delayed_15 <= a18_data_delayed_14;
  a18_data_delayed_16 <= a18_data_delayed_15;
  a18_data_delayed_17 <= a18_data_delayed_16;
  a18_data_delayed_18 <= a18_data_delayed_17;
  a19_data_delayed_2 <= a19_data_delayed_1;
  a19_data_delayed_3 <= a19_data_delayed_2;
  a19_data_delayed_4 <= a19_data_delayed_3;
  a19_data_delayed_5 <= a19_data_delayed_4;
  a19_data_delayed_6 <= a19_data_delayed_5;
  a19_data_delayed_7 <= a19_data_delayed_6;
  a19_data_delayed_8 <= a19_data_delayed_7;
  a19_data_delayed_9 <= a19_data_delayed_8;
  a19_data_delayed_10 <= a19_data_delayed_9;
  a19_data_delayed_11 <= a19_data_delayed_10;
  a19_data_delayed_12 <= a19_data_delayed_11;
  a19_data_delayed_13 <= a19_data_delayed_12;
  a19_data_delayed_14 <= a19_data_delayed_13;
  a19_data_delayed_15 <= a19_data_delayed_14;
  a19_data_delayed_16 <= a19_data_delayed_15;
  a19_data_delayed_17 <= a19_data_delayed_16;
  a19_data_delayed_18 <= a19_data_delayed_17;
  a19_data_delayed_19 <= a19_data_delayed_18;
 
  end
end

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM B
//////////////////////////////////////////////////////////////////////////
reg [`AWIDTH-1:0] b_addr;
reg b_mem_access; //flag that tells whether the matmul is trying to access memory or not
always @(posedge clk) begin
  //else if (clk_cnt >= b_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:

  if ((reset || ~start_mat_mul) || (clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)+20)) begin

      b_addr <= address_mat_b - address_stride_b;
  
    b_mem_access <= 0;
  end
  //else if ((clk_cnt >= b_loc*`MAT_MUL_SIZE) && (clk_cnt < b_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:

  else if ((clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (b_loc<<`LOG2_MAT_MUL_SIZE)+20)) begin

      b_addr <= b_addr + address_stride_b;
  
    b_mem_access <= 1;
  end
end 

//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM B
//////////////////////////////////////////////////////////////////////////
reg [7:0] b_mem_access_counter;
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    b_mem_access_counter <= 0;
  end
  else if (b_mem_access == 1) begin
    b_mem_access_counter <= b_mem_access_counter + 1;  
  end
  else begin
    b_mem_access_counter <= 0;
  end
end

wire b_data_valid; //flag that tells whether the data from memory is valid
assign b_data_valid = 
     ((validity_mask_b_rows[0]==1'b0 && b_mem_access_counter==1) ||
      (validity_mask_b_rows[1]==1'b0 && b_mem_access_counter==2) ||
      (validity_mask_b_rows[2]==1'b0 && b_mem_access_counter==3) ||
      (validity_mask_b_rows[3]==1'b0 && b_mem_access_counter==4) ||
      (validity_mask_b_rows[4]==1'b0 && b_mem_access_counter==5) ||
      (validity_mask_b_rows[5]==1'b0 && b_mem_access_counter==6) ||
      (validity_mask_b_rows[6]==1'b0 && b_mem_access_counter==7) ||
      (validity_mask_b_rows[7]==1'b0 && b_mem_access_counter==8) ||
      (validity_mask_b_rows[8]==1'b0 && b_mem_access_counter==9) ||
      (validity_mask_b_rows[9]==1'b0 && b_mem_access_counter==10) ||
      (validity_mask_b_rows[10]==1'b0 && b_mem_access_counter==11) ||
      (validity_mask_b_rows[11]==1'b0 && b_mem_access_counter==12) ||
      (validity_mask_b_rows[12]==1'b0 && b_mem_access_counter==13) ||
      (validity_mask_b_rows[13]==1'b0 && b_mem_access_counter==14) ||
      (validity_mask_b_rows[14]==1'b0 && b_mem_access_counter==15) ||
      (validity_mask_b_rows[15]==1'b0 && b_mem_access_counter==16) ||
      (validity_mask_b_rows[16]==1'b0 && b_mem_access_counter==17) ||
      (validity_mask_b_rows[17]==1'b0 && b_mem_access_counter==18) ||
      (validity_mask_b_rows[18]==1'b0 && b_mem_access_counter==19) ||
      (validity_mask_b_rows[19]==1'b0 && b_mem_access_counter==20)) ?
    
        1'b0 : (b_mem_access_counter >= `MEM_ACCESS_LATENCY);

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM B (systolic data setup)
//////////////////////////////////////////////////////////////////////////
assign b0_data = b_data[1*`DWIDTH-1:0*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[0]}};
assign b1_data = b_data[2*`DWIDTH-1:1*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[1]}};
assign b2_data = b_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[2]}};
assign b3_data = b_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[3]}};
assign b4_data = b_data[5*`DWIDTH-1:4*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[4]}};
assign b5_data = b_data[6*`DWIDTH-1:5*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[5]}};
assign b6_data = b_data[7*`DWIDTH-1:6*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[6]}};
assign b7_data = b_data[8*`DWIDTH-1:7*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[7]}};
assign b8_data = b_data[9*`DWIDTH-1:8*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[8]}};
assign b9_data = b_data[10*`DWIDTH-1:9*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[9]}};
assign b10_data = b_data[11*`DWIDTH-1:10*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[10]}};
assign b11_data = b_data[12*`DWIDTH-1:11*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[11]}};
assign b12_data = b_data[13*`DWIDTH-1:12*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[12]}};
assign b13_data = b_data[14*`DWIDTH-1:13*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[13]}};
assign b14_data = b_data[15*`DWIDTH-1:14*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[14]}};
assign b15_data = b_data[16*`DWIDTH-1:15*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[15]}};
assign b16_data = b_data[17*`DWIDTH-1:16*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[16]}};
assign b17_data = b_data[18*`DWIDTH-1:17*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[17]}};
assign b18_data = b_data[19*`DWIDTH-1:18*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[18]}};
assign b19_data = b_data[20*`DWIDTH-1:19*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[19]}};

reg [`DWIDTH-1:0] b1_data_delayed_1;
reg [`DWIDTH-1:0] b2_data_delayed_1;
reg [`DWIDTH-1:0] b2_data_delayed_2;
reg [`DWIDTH-1:0] b3_data_delayed_1;
reg [`DWIDTH-1:0] b3_data_delayed_2;
reg [`DWIDTH-1:0] b3_data_delayed_3;
reg [`DWIDTH-1:0] b4_data_delayed_1;
reg [`DWIDTH-1:0] b4_data_delayed_2;
reg [`DWIDTH-1:0] b4_data_delayed_3;
reg [`DWIDTH-1:0] b4_data_delayed_4;
reg [`DWIDTH-1:0] b5_data_delayed_1;
reg [`DWIDTH-1:0] b5_data_delayed_2;
reg [`DWIDTH-1:0] b5_data_delayed_3;
reg [`DWIDTH-1:0] b5_data_delayed_4;
reg [`DWIDTH-1:0] b5_data_delayed_5;
reg [`DWIDTH-1:0] b6_data_delayed_1;
reg [`DWIDTH-1:0] b6_data_delayed_2;
reg [`DWIDTH-1:0] b6_data_delayed_3;
reg [`DWIDTH-1:0] b6_data_delayed_4;
reg [`DWIDTH-1:0] b6_data_delayed_5;
reg [`DWIDTH-1:0] b6_data_delayed_6;
reg [`DWIDTH-1:0] b7_data_delayed_1;
reg [`DWIDTH-1:0] b7_data_delayed_2;
reg [`DWIDTH-1:0] b7_data_delayed_3;
reg [`DWIDTH-1:0] b7_data_delayed_4;
reg [`DWIDTH-1:0] b7_data_delayed_5;
reg [`DWIDTH-1:0] b7_data_delayed_6;
reg [`DWIDTH-1:0] b7_data_delayed_7;
reg [`DWIDTH-1:0] b8_data_delayed_1;
reg [`DWIDTH-1:0] b8_data_delayed_2;
reg [`DWIDTH-1:0] b8_data_delayed_3;
reg [`DWIDTH-1:0] b8_data_delayed_4;
reg [`DWIDTH-1:0] b8_data_delayed_5;
reg [`DWIDTH-1:0] b8_data_delayed_6;
reg [`DWIDTH-1:0] b8_data_delayed_7;
reg [`DWIDTH-1:0] b8_data_delayed_8;
reg [`DWIDTH-1:0] b9_data_delayed_1;
reg [`DWIDTH-1:0] b9_data_delayed_2;
reg [`DWIDTH-1:0] b9_data_delayed_3;
reg [`DWIDTH-1:0] b9_data_delayed_4;
reg [`DWIDTH-1:0] b9_data_delayed_5;
reg [`DWIDTH-1:0] b9_data_delayed_6;
reg [`DWIDTH-1:0] b9_data_delayed_7;
reg [`DWIDTH-1:0] b9_data_delayed_8;
reg [`DWIDTH-1:0] b9_data_delayed_9;
reg [`DWIDTH-1:0] b10_data_delayed_1;
reg [`DWIDTH-1:0] b10_data_delayed_2;
reg [`DWIDTH-1:0] b10_data_delayed_3;
reg [`DWIDTH-1:0] b10_data_delayed_4;
reg [`DWIDTH-1:0] b10_data_delayed_5;
reg [`DWIDTH-1:0] b10_data_delayed_6;
reg [`DWIDTH-1:0] b10_data_delayed_7;
reg [`DWIDTH-1:0] b10_data_delayed_8;
reg [`DWIDTH-1:0] b10_data_delayed_9;
reg [`DWIDTH-1:0] b10_data_delayed_10;
reg [`DWIDTH-1:0] b11_data_delayed_1;
reg [`DWIDTH-1:0] b11_data_delayed_2;
reg [`DWIDTH-1:0] b11_data_delayed_3;
reg [`DWIDTH-1:0] b11_data_delayed_4;
reg [`DWIDTH-1:0] b11_data_delayed_5;
reg [`DWIDTH-1:0] b11_data_delayed_6;
reg [`DWIDTH-1:0] b11_data_delayed_7;
reg [`DWIDTH-1:0] b11_data_delayed_8;
reg [`DWIDTH-1:0] b11_data_delayed_9;
reg [`DWIDTH-1:0] b11_data_delayed_10;
reg [`DWIDTH-1:0] b11_data_delayed_11;
reg [`DWIDTH-1:0] b12_data_delayed_1;
reg [`DWIDTH-1:0] b12_data_delayed_2;
reg [`DWIDTH-1:0] b12_data_delayed_3;
reg [`DWIDTH-1:0] b12_data_delayed_4;
reg [`DWIDTH-1:0] b12_data_delayed_5;
reg [`DWIDTH-1:0] b12_data_delayed_6;
reg [`DWIDTH-1:0] b12_data_delayed_7;
reg [`DWIDTH-1:0] b12_data_delayed_8;
reg [`DWIDTH-1:0] b12_data_delayed_9;
reg [`DWIDTH-1:0] b12_data_delayed_10;
reg [`DWIDTH-1:0] b12_data_delayed_11;
reg [`DWIDTH-1:0] b12_data_delayed_12;
reg [`DWIDTH-1:0] b13_data_delayed_1;
reg [`DWIDTH-1:0] b13_data_delayed_2;
reg [`DWIDTH-1:0] b13_data_delayed_3;
reg [`DWIDTH-1:0] b13_data_delayed_4;
reg [`DWIDTH-1:0] b13_data_delayed_5;
reg [`DWIDTH-1:0] b13_data_delayed_6;
reg [`DWIDTH-1:0] b13_data_delayed_7;
reg [`DWIDTH-1:0] b13_data_delayed_8;
reg [`DWIDTH-1:0] b13_data_delayed_9;
reg [`DWIDTH-1:0] b13_data_delayed_10;
reg [`DWIDTH-1:0] b13_data_delayed_11;
reg [`DWIDTH-1:0] b13_data_delayed_12;
reg [`DWIDTH-1:0] b13_data_delayed_13;
reg [`DWIDTH-1:0] b14_data_delayed_1;
reg [`DWIDTH-1:0] b14_data_delayed_2;
reg [`DWIDTH-1:0] b14_data_delayed_3;
reg [`DWIDTH-1:0] b14_data_delayed_4;
reg [`DWIDTH-1:0] b14_data_delayed_5;
reg [`DWIDTH-1:0] b14_data_delayed_6;
reg [`DWIDTH-1:0] b14_data_delayed_7;
reg [`DWIDTH-1:0] b14_data_delayed_8;
reg [`DWIDTH-1:0] b14_data_delayed_9;
reg [`DWIDTH-1:0] b14_data_delayed_10;
reg [`DWIDTH-1:0] b14_data_delayed_11;
reg [`DWIDTH-1:0] b14_data_delayed_12;
reg [`DWIDTH-1:0] b14_data_delayed_13;
reg [`DWIDTH-1:0] b14_data_delayed_14;
reg [`DWIDTH-1:0] b15_data_delayed_1;
reg [`DWIDTH-1:0] b15_data_delayed_2;
reg [`DWIDTH-1:0] b15_data_delayed_3;
reg [`DWIDTH-1:0] b15_data_delayed_4;
reg [`DWIDTH-1:0] b15_data_delayed_5;
reg [`DWIDTH-1:0] b15_data_delayed_6;
reg [`DWIDTH-1:0] b15_data_delayed_7;
reg [`DWIDTH-1:0] b15_data_delayed_8;
reg [`DWIDTH-1:0] b15_data_delayed_9;
reg [`DWIDTH-1:0] b15_data_delayed_10;
reg [`DWIDTH-1:0] b15_data_delayed_11;
reg [`DWIDTH-1:0] b15_data_delayed_12;
reg [`DWIDTH-1:0] b15_data_delayed_13;
reg [`DWIDTH-1:0] b15_data_delayed_14;
reg [`DWIDTH-1:0] b15_data_delayed_15;
reg [`DWIDTH-1:0] b16_data_delayed_1;
reg [`DWIDTH-1:0] b16_data_delayed_2;
reg [`DWIDTH-1:0] b16_data_delayed_3;
reg [`DWIDTH-1:0] b16_data_delayed_4;
reg [`DWIDTH-1:0] b16_data_delayed_5;
reg [`DWIDTH-1:0] b16_data_delayed_6;
reg [`DWIDTH-1:0] b16_data_delayed_7;
reg [`DWIDTH-1:0] b16_data_delayed_8;
reg [`DWIDTH-1:0] b16_data_delayed_9;
reg [`DWIDTH-1:0] b16_data_delayed_10;
reg [`DWIDTH-1:0] b16_data_delayed_11;
reg [`DWIDTH-1:0] b16_data_delayed_12;
reg [`DWIDTH-1:0] b16_data_delayed_13;
reg [`DWIDTH-1:0] b16_data_delayed_14;
reg [`DWIDTH-1:0] b16_data_delayed_15;
reg [`DWIDTH-1:0] b16_data_delayed_16;
reg [`DWIDTH-1:0] b17_data_delayed_1;
reg [`DWIDTH-1:0] b17_data_delayed_2;
reg [`DWIDTH-1:0] b17_data_delayed_3;
reg [`DWIDTH-1:0] b17_data_delayed_4;
reg [`DWIDTH-1:0] b17_data_delayed_5;
reg [`DWIDTH-1:0] b17_data_delayed_6;
reg [`DWIDTH-1:0] b17_data_delayed_7;
reg [`DWIDTH-1:0] b17_data_delayed_8;
reg [`DWIDTH-1:0] b17_data_delayed_9;
reg [`DWIDTH-1:0] b17_data_delayed_10;
reg [`DWIDTH-1:0] b17_data_delayed_11;
reg [`DWIDTH-1:0] b17_data_delayed_12;
reg [`DWIDTH-1:0] b17_data_delayed_13;
reg [`DWIDTH-1:0] b17_data_delayed_14;
reg [`DWIDTH-1:0] b17_data_delayed_15;
reg [`DWIDTH-1:0] b17_data_delayed_16;
reg [`DWIDTH-1:0] b17_data_delayed_17;
reg [`DWIDTH-1:0] b18_data_delayed_1;
reg [`DWIDTH-1:0] b18_data_delayed_2;
reg [`DWIDTH-1:0] b18_data_delayed_3;
reg [`DWIDTH-1:0] b18_data_delayed_4;
reg [`DWIDTH-1:0] b18_data_delayed_5;
reg [`DWIDTH-1:0] b18_data_delayed_6;
reg [`DWIDTH-1:0] b18_data_delayed_7;
reg [`DWIDTH-1:0] b18_data_delayed_8;
reg [`DWIDTH-1:0] b18_data_delayed_9;
reg [`DWIDTH-1:0] b18_data_delayed_10;
reg [`DWIDTH-1:0] b18_data_delayed_11;
reg [`DWIDTH-1:0] b18_data_delayed_12;
reg [`DWIDTH-1:0] b18_data_delayed_13;
reg [`DWIDTH-1:0] b18_data_delayed_14;
reg [`DWIDTH-1:0] b18_data_delayed_15;
reg [`DWIDTH-1:0] b18_data_delayed_16;
reg [`DWIDTH-1:0] b18_data_delayed_17;
reg [`DWIDTH-1:0] b18_data_delayed_18;
reg [`DWIDTH-1:0] b19_data_delayed_1;
reg [`DWIDTH-1:0] b19_data_delayed_2;
reg [`DWIDTH-1:0] b19_data_delayed_3;
reg [`DWIDTH-1:0] b19_data_delayed_4;
reg [`DWIDTH-1:0] b19_data_delayed_5;
reg [`DWIDTH-1:0] b19_data_delayed_6;
reg [`DWIDTH-1:0] b19_data_delayed_7;
reg [`DWIDTH-1:0] b19_data_delayed_8;
reg [`DWIDTH-1:0] b19_data_delayed_9;
reg [`DWIDTH-1:0] b19_data_delayed_10;
reg [`DWIDTH-1:0] b19_data_delayed_11;
reg [`DWIDTH-1:0] b19_data_delayed_12;
reg [`DWIDTH-1:0] b19_data_delayed_13;
reg [`DWIDTH-1:0] b19_data_delayed_14;
reg [`DWIDTH-1:0] b19_data_delayed_15;
reg [`DWIDTH-1:0] b19_data_delayed_16;
reg [`DWIDTH-1:0] b19_data_delayed_17;
reg [`DWIDTH-1:0] b19_data_delayed_18;
reg [`DWIDTH-1:0] b19_data_delayed_19;


always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
    b1_data_delayed_1 <= 0;
    b2_data_delayed_1 <= 0;
    b2_data_delayed_2 <= 0;
    b3_data_delayed_1 <= 0;
    b3_data_delayed_2 <= 0;
    b3_data_delayed_3 <= 0;
    b4_data_delayed_1 <= 0;
    b4_data_delayed_2 <= 0;
    b4_data_delayed_3 <= 0;
    b4_data_delayed_4 <= 0;
    b5_data_delayed_1 <= 0;
    b5_data_delayed_2 <= 0;
    b5_data_delayed_3 <= 0;
    b5_data_delayed_4 <= 0;
    b5_data_delayed_5 <= 0;
    b6_data_delayed_1 <= 0;
    b6_data_delayed_2 <= 0;
    b6_data_delayed_3 <= 0;
    b6_data_delayed_4 <= 0;
    b6_data_delayed_5 <= 0;
    b6_data_delayed_6 <= 0;
    b7_data_delayed_1 <= 0;
    b7_data_delayed_2 <= 0;
    b7_data_delayed_3 <= 0;
    b7_data_delayed_4 <= 0;
    b7_data_delayed_5 <= 0;
    b7_data_delayed_6 <= 0;
    b7_data_delayed_7 <= 0;
    b8_data_delayed_1 <= 0;
    b8_data_delayed_2 <= 0;
    b8_data_delayed_3 <= 0;
    b8_data_delayed_4 <= 0;
    b8_data_delayed_5 <= 0;
    b8_data_delayed_6 <= 0;
    b8_data_delayed_7 <= 0;
    b8_data_delayed_8 <= 0;
    b9_data_delayed_1 <= 0;
    b9_data_delayed_2 <= 0;
    b9_data_delayed_3 <= 0;
    b9_data_delayed_4 <= 0;
    b9_data_delayed_5 <= 0;
    b9_data_delayed_6 <= 0;
    b9_data_delayed_7 <= 0;
    b9_data_delayed_8 <= 0;
    b9_data_delayed_9 <= 0;
    b10_data_delayed_1 <= 0;
    b10_data_delayed_2 <= 0;
    b10_data_delayed_3 <= 0;
    b10_data_delayed_4 <= 0;
    b10_data_delayed_5 <= 0;
    b10_data_delayed_6 <= 0;
    b10_data_delayed_7 <= 0;
    b10_data_delayed_8 <= 0;
    b10_data_delayed_9 <= 0;
    b10_data_delayed_10 <= 0;
    b11_data_delayed_1 <= 0;
    b11_data_delayed_2 <= 0;
    b11_data_delayed_3 <= 0;
    b11_data_delayed_4 <= 0;
    b11_data_delayed_5 <= 0;
    b11_data_delayed_6 <= 0;
    b11_data_delayed_7 <= 0;
    b11_data_delayed_8 <= 0;
    b11_data_delayed_9 <= 0;
    b11_data_delayed_10 <= 0;
    b11_data_delayed_11 <= 0;
    b12_data_delayed_1 <= 0;
    b12_data_delayed_2 <= 0;
    b12_data_delayed_3 <= 0;
    b12_data_delayed_4 <= 0;
    b12_data_delayed_5 <= 0;
    b12_data_delayed_6 <= 0;
    b12_data_delayed_7 <= 0;
    b12_data_delayed_8 <= 0;
    b12_data_delayed_9 <= 0;
    b12_data_delayed_10 <= 0;
    b12_data_delayed_11 <= 0;
    b12_data_delayed_12 <= 0;
    b13_data_delayed_1 <= 0;
    b13_data_delayed_2 <= 0;
    b13_data_delayed_3 <= 0;
    b13_data_delayed_4 <= 0;
    b13_data_delayed_5 <= 0;
    b13_data_delayed_6 <= 0;
    b13_data_delayed_7 <= 0;
    b13_data_delayed_8 <= 0;
    b13_data_delayed_9 <= 0;
    b13_data_delayed_10 <= 0;
    b13_data_delayed_11 <= 0;
    b13_data_delayed_12 <= 0;
    b13_data_delayed_13 <= 0;
    b14_data_delayed_1 <= 0;
    b14_data_delayed_2 <= 0;
    b14_data_delayed_3 <= 0;
    b14_data_delayed_4 <= 0;
    b14_data_delayed_5 <= 0;
    b14_data_delayed_6 <= 0;
    b14_data_delayed_7 <= 0;
    b14_data_delayed_8 <= 0;
    b14_data_delayed_9 <= 0;
    b14_data_delayed_10 <= 0;
    b14_data_delayed_11 <= 0;
    b14_data_delayed_12 <= 0;
    b14_data_delayed_13 <= 0;
    b14_data_delayed_14 <= 0;
    b15_data_delayed_1 <= 0;
    b15_data_delayed_2 <= 0;
    b15_data_delayed_3 <= 0;
    b15_data_delayed_4 <= 0;
    b15_data_delayed_5 <= 0;
    b15_data_delayed_6 <= 0;
    b15_data_delayed_7 <= 0;
    b15_data_delayed_8 <= 0;
    b15_data_delayed_9 <= 0;
    b15_data_delayed_10 <= 0;
    b15_data_delayed_11 <= 0;
    b15_data_delayed_12 <= 0;
    b15_data_delayed_13 <= 0;
    b15_data_delayed_14 <= 0;
    b15_data_delayed_15 <= 0;
    b16_data_delayed_1 <= 0;
    b16_data_delayed_2 <= 0;
    b16_data_delayed_3 <= 0;
    b16_data_delayed_4 <= 0;
    b16_data_delayed_5 <= 0;
    b16_data_delayed_6 <= 0;
    b16_data_delayed_7 <= 0;
    b16_data_delayed_8 <= 0;
    b16_data_delayed_9 <= 0;
    b16_data_delayed_10 <= 0;
    b16_data_delayed_11 <= 0;
    b16_data_delayed_12 <= 0;
    b16_data_delayed_13 <= 0;
    b16_data_delayed_14 <= 0;
    b16_data_delayed_15 <= 0;
    b16_data_delayed_16 <= 0;
    b17_data_delayed_1 <= 0;
    b17_data_delayed_2 <= 0;
    b17_data_delayed_3 <= 0;
    b17_data_delayed_4 <= 0;
    b17_data_delayed_5 <= 0;
    b17_data_delayed_6 <= 0;
    b17_data_delayed_7 <= 0;
    b17_data_delayed_8 <= 0;
    b17_data_delayed_9 <= 0;
    b17_data_delayed_10 <= 0;
    b17_data_delayed_11 <= 0;
    b17_data_delayed_12 <= 0;
    b17_data_delayed_13 <= 0;
    b17_data_delayed_14 <= 0;
    b17_data_delayed_15 <= 0;
    b17_data_delayed_16 <= 0;
    b17_data_delayed_17 <= 0;
    b18_data_delayed_1 <= 0;
    b18_data_delayed_2 <= 0;
    b18_data_delayed_3 <= 0;
    b18_data_delayed_4 <= 0;
    b18_data_delayed_5 <= 0;
    b18_data_delayed_6 <= 0;
    b18_data_delayed_7 <= 0;
    b18_data_delayed_8 <= 0;
    b18_data_delayed_9 <= 0;
    b18_data_delayed_10 <= 0;
    b18_data_delayed_11 <= 0;
    b18_data_delayed_12 <= 0;
    b18_data_delayed_13 <= 0;
    b18_data_delayed_14 <= 0;
    b18_data_delayed_15 <= 0;
    b18_data_delayed_16 <= 0;
    b18_data_delayed_17 <= 0;
    b18_data_delayed_18 <= 0;
    b19_data_delayed_1 <= 0;
    b19_data_delayed_2 <= 0;
    b19_data_delayed_3 <= 0;
    b19_data_delayed_4 <= 0;
    b19_data_delayed_5 <= 0;
    b19_data_delayed_6 <= 0;
    b19_data_delayed_7 <= 0;
    b19_data_delayed_8 <= 0;
    b19_data_delayed_9 <= 0;
    b19_data_delayed_10 <= 0;
    b19_data_delayed_11 <= 0;
    b19_data_delayed_12 <= 0;
    b19_data_delayed_13 <= 0;
    b19_data_delayed_14 <= 0;
    b19_data_delayed_15 <= 0;
    b19_data_delayed_16 <= 0;
    b19_data_delayed_17 <= 0;
    b19_data_delayed_18 <= 0;
    b19_data_delayed_19 <= 0;

  end
  else begin
  b1_data_delayed_1 <= b1_data;
  b2_data_delayed_1 <= b2_data;
  b3_data_delayed_1 <= b3_data;
  b4_data_delayed_1 <= b4_data;
  b5_data_delayed_1 <= b5_data;
  b6_data_delayed_1 <= b6_data;
  b7_data_delayed_1 <= b7_data;
  b8_data_delayed_1 <= b8_data;
  b9_data_delayed_1 <= b9_data;
  b10_data_delayed_1 <= b10_data;
  b11_data_delayed_1 <= b11_data;
  b12_data_delayed_1 <= b12_data;
  b13_data_delayed_1 <= b13_data;
  b14_data_delayed_1 <= b14_data;
  b15_data_delayed_1 <= b15_data;
  b16_data_delayed_1 <= b16_data;
  b17_data_delayed_1 <= b17_data;
  b18_data_delayed_1 <= b18_data;
  b19_data_delayed_1 <= b19_data;
  b2_data_delayed_2 <= b2_data_delayed_1;
  b3_data_delayed_2 <= b3_data_delayed_1;
  b3_data_delayed_3 <= b3_data_delayed_2;
  b4_data_delayed_2 <= b4_data_delayed_1;
  b4_data_delayed_3 <= b4_data_delayed_2;
  b4_data_delayed_4 <= b4_data_delayed_3;
  b5_data_delayed_2 <= b5_data_delayed_1;
  b5_data_delayed_3 <= b5_data_delayed_2;
  b5_data_delayed_4 <= b5_data_delayed_3;
  b5_data_delayed_5 <= b5_data_delayed_4;
  b6_data_delayed_2 <= b6_data_delayed_1;
  b6_data_delayed_3 <= b6_data_delayed_2;
  b6_data_delayed_4 <= b6_data_delayed_3;
  b6_data_delayed_5 <= b6_data_delayed_4;
  b6_data_delayed_6 <= b6_data_delayed_5;
  b7_data_delayed_2 <= b7_data_delayed_1;
  b7_data_delayed_3 <= b7_data_delayed_2;
  b7_data_delayed_4 <= b7_data_delayed_3;
  b7_data_delayed_5 <= b7_data_delayed_4;
  b7_data_delayed_6 <= b7_data_delayed_5;
  b7_data_delayed_7 <= b7_data_delayed_6;
  b8_data_delayed_2 <= b8_data_delayed_1;
  b8_data_delayed_3 <= b8_data_delayed_2;
  b8_data_delayed_4 <= b8_data_delayed_3;
  b8_data_delayed_5 <= b8_data_delayed_4;
  b8_data_delayed_6 <= b8_data_delayed_5;
  b8_data_delayed_7 <= b8_data_delayed_6;
  b8_data_delayed_8 <= b8_data_delayed_7;
  b9_data_delayed_2 <= b9_data_delayed_1;
  b9_data_delayed_3 <= b9_data_delayed_2;
  b9_data_delayed_4 <= b9_data_delayed_3;
  b9_data_delayed_5 <= b9_data_delayed_4;
  b9_data_delayed_6 <= b9_data_delayed_5;
  b9_data_delayed_7 <= b9_data_delayed_6;
  b9_data_delayed_8 <= b9_data_delayed_7;
  b9_data_delayed_9 <= b9_data_delayed_8;
  b10_data_delayed_2 <= b10_data_delayed_1;
  b10_data_delayed_3 <= b10_data_delayed_2;
  b10_data_delayed_4 <= b10_data_delayed_3;
  b10_data_delayed_5 <= b10_data_delayed_4;
  b10_data_delayed_6 <= b10_data_delayed_5;
  b10_data_delayed_7 <= b10_data_delayed_6;
  b10_data_delayed_8 <= b10_data_delayed_7;
  b10_data_delayed_9 <= b10_data_delayed_8;
  b10_data_delayed_10 <= b10_data_delayed_9;
  b11_data_delayed_2 <= b11_data_delayed_1;
  b11_data_delayed_3 <= b11_data_delayed_2;
  b11_data_delayed_4 <= b11_data_delayed_3;
  b11_data_delayed_5 <= b11_data_delayed_4;
  b11_data_delayed_6 <= b11_data_delayed_5;
  b11_data_delayed_7 <= b11_data_delayed_6;
  b11_data_delayed_8 <= b11_data_delayed_7;
  b11_data_delayed_9 <= b11_data_delayed_8;
  b11_data_delayed_10 <= b11_data_delayed_9;
  b11_data_delayed_11 <= b11_data_delayed_10;
  b12_data_delayed_2 <= b12_data_delayed_1;
  b12_data_delayed_3 <= b12_data_delayed_2;
  b12_data_delayed_4 <= b12_data_delayed_3;
  b12_data_delayed_5 <= b12_data_delayed_4;
  b12_data_delayed_6 <= b12_data_delayed_5;
  b12_data_delayed_7 <= b12_data_delayed_6;
  b12_data_delayed_8 <= b12_data_delayed_7;
  b12_data_delayed_9 <= b12_data_delayed_8;
  b12_data_delayed_10 <= b12_data_delayed_9;
  b12_data_delayed_11 <= b12_data_delayed_10;
  b12_data_delayed_12 <= b12_data_delayed_11;
  b13_data_delayed_2 <= b13_data_delayed_1;
  b13_data_delayed_3 <= b13_data_delayed_2;
  b13_data_delayed_4 <= b13_data_delayed_3;
  b13_data_delayed_5 <= b13_data_delayed_4;
  b13_data_delayed_6 <= b13_data_delayed_5;
  b13_data_delayed_7 <= b13_data_delayed_6;
  b13_data_delayed_8 <= b13_data_delayed_7;
  b13_data_delayed_9 <= b13_data_delayed_8;
  b13_data_delayed_10 <= b13_data_delayed_9;
  b13_data_delayed_11 <= b13_data_delayed_10;
  b13_data_delayed_12 <= b13_data_delayed_11;
  b13_data_delayed_13 <= b13_data_delayed_12;
  b14_data_delayed_2 <= b14_data_delayed_1;
  b14_data_delayed_3 <= b14_data_delayed_2;
  b14_data_delayed_4 <= b14_data_delayed_3;
  b14_data_delayed_5 <= b14_data_delayed_4;
  b14_data_delayed_6 <= b14_data_delayed_5;
  b14_data_delayed_7 <= b14_data_delayed_6;
  b14_data_delayed_8 <= b14_data_delayed_7;
  b14_data_delayed_9 <= b14_data_delayed_8;
  b14_data_delayed_10 <= b14_data_delayed_9;
  b14_data_delayed_11 <= b14_data_delayed_10;
  b14_data_delayed_12 <= b14_data_delayed_11;
  b14_data_delayed_13 <= b14_data_delayed_12;
  b14_data_delayed_14 <= b14_data_delayed_13;
  b15_data_delayed_2 <= b15_data_delayed_1;
  b15_data_delayed_3 <= b15_data_delayed_2;
  b15_data_delayed_4 <= b15_data_delayed_3;
  b15_data_delayed_5 <= b15_data_delayed_4;
  b15_data_delayed_6 <= b15_data_delayed_5;
  b15_data_delayed_7 <= b15_data_delayed_6;
  b15_data_delayed_8 <= b15_data_delayed_7;
  b15_data_delayed_9 <= b15_data_delayed_8;
  b15_data_delayed_10 <= b15_data_delayed_9;
  b15_data_delayed_11 <= b15_data_delayed_10;
  b15_data_delayed_12 <= b15_data_delayed_11;
  b15_data_delayed_13 <= b15_data_delayed_12;
  b15_data_delayed_14 <= b15_data_delayed_13;
  b15_data_delayed_15 <= b15_data_delayed_14;
  b16_data_delayed_2 <= b16_data_delayed_1;
  b16_data_delayed_3 <= b16_data_delayed_2;
  b16_data_delayed_4 <= b16_data_delayed_3;
  b16_data_delayed_5 <= b16_data_delayed_4;
  b16_data_delayed_6 <= b16_data_delayed_5;
  b16_data_delayed_7 <= b16_data_delayed_6;
  b16_data_delayed_8 <= b16_data_delayed_7;
  b16_data_delayed_9 <= b16_data_delayed_8;
  b16_data_delayed_10 <= b16_data_delayed_9;
  b16_data_delayed_11 <= b16_data_delayed_10;
  b16_data_delayed_12 <= b16_data_delayed_11;
  b16_data_delayed_13 <= b16_data_delayed_12;
  b16_data_delayed_14 <= b16_data_delayed_13;
  b16_data_delayed_15 <= b16_data_delayed_14;
  b16_data_delayed_16 <= b16_data_delayed_15;
  b17_data_delayed_2 <= b17_data_delayed_1;
  b17_data_delayed_3 <= b17_data_delayed_2;
  b17_data_delayed_4 <= b17_data_delayed_3;
  b17_data_delayed_5 <= b17_data_delayed_4;
  b17_data_delayed_6 <= b17_data_delayed_5;
  b17_data_delayed_7 <= b17_data_delayed_6;
  b17_data_delayed_8 <= b17_data_delayed_7;
  b17_data_delayed_9 <= b17_data_delayed_8;
  b17_data_delayed_10 <= b17_data_delayed_9;
  b17_data_delayed_11 <= b17_data_delayed_10;
  b17_data_delayed_12 <= b17_data_delayed_11;
  b17_data_delayed_13 <= b17_data_delayed_12;
  b17_data_delayed_14 <= b17_data_delayed_13;
  b17_data_delayed_15 <= b17_data_delayed_14;
  b17_data_delayed_16 <= b17_data_delayed_15;
  b17_data_delayed_17 <= b17_data_delayed_16;
  b18_data_delayed_2 <= b18_data_delayed_1;
  b18_data_delayed_3 <= b18_data_delayed_2;
  b18_data_delayed_4 <= b18_data_delayed_3;
  b18_data_delayed_5 <= b18_data_delayed_4;
  b18_data_delayed_6 <= b18_data_delayed_5;
  b18_data_delayed_7 <= b18_data_delayed_6;
  b18_data_delayed_8 <= b18_data_delayed_7;
  b18_data_delayed_9 <= b18_data_delayed_8;
  b18_data_delayed_10 <= b18_data_delayed_9;
  b18_data_delayed_11 <= b18_data_delayed_10;
  b18_data_delayed_12 <= b18_data_delayed_11;
  b18_data_delayed_13 <= b18_data_delayed_12;
  b18_data_delayed_14 <= b18_data_delayed_13;
  b18_data_delayed_15 <= b18_data_delayed_14;
  b18_data_delayed_16 <= b18_data_delayed_15;
  b18_data_delayed_17 <= b18_data_delayed_16;
  b18_data_delayed_18 <= b18_data_delayed_17;
  b19_data_delayed_2 <= b19_data_delayed_1;
  b19_data_delayed_3 <= b19_data_delayed_2;
  b19_data_delayed_4 <= b19_data_delayed_3;
  b19_data_delayed_5 <= b19_data_delayed_4;
  b19_data_delayed_6 <= b19_data_delayed_5;
  b19_data_delayed_7 <= b19_data_delayed_6;
  b19_data_delayed_8 <= b19_data_delayed_7;
  b19_data_delayed_9 <= b19_data_delayed_8;
  b19_data_delayed_10 <= b19_data_delayed_9;
  b19_data_delayed_11 <= b19_data_delayed_10;
  b19_data_delayed_12 <= b19_data_delayed_11;
  b19_data_delayed_13 <= b19_data_delayed_12;
  b19_data_delayed_14 <= b19_data_delayed_13;
  b19_data_delayed_15 <= b19_data_delayed_14;
  b19_data_delayed_16 <= b19_data_delayed_15;
  b19_data_delayed_17 <= b19_data_delayed_16;
  b19_data_delayed_18 <= b19_data_delayed_17;
  b19_data_delayed_19 <= b19_data_delayed_18;
 
  end
end
endmodule
