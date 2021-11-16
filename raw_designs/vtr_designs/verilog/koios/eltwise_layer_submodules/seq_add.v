`define BFLOAT16 
`define VCS
`define EXPONENT 8
`define MANTISSA 7
`define EXPONENT 5
`define MANTISSA 10
`define SIGN 1
`define DWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define AWIDTH 10
`define MEM_SIZE 1024
`define DESIGN_SIZE 12
`define CU_SIZE 4
`define MASK_WIDTH 4
`define MEM_ACCESS_LATENCY 1
`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8
`define ITERATIONS_WIDTH 32
`define REG_STDN_ADDR 32'h4
`define REG_MATRIX_A_ADDR 32'he
`define REG_MATRIX_B_ADDR 32'h12
`define REG_MATRIX_C_ADDR 32'h16
`define REG_VALID_MASK_A_ADDR 32'h20
`define REG_VALID_MASK_B_ADDR 32'h5c
`define REG_ITERATIONS_ADDR 32'h40
`define PE_PIPELINE_DEPTH 5
`define IDLE     2'b00
`define W_ENABLE  2'b01
`define R_ENABLE  2'b10

module seq_add(a, b, out, reset, clk);
input [`DWIDTH-1:0] a;
input [`DWIDTH-1:0] b;
input reset;
input clk;
output [`DWIDTH-1:0] out;

reg [`DWIDTH-1:0] a_flopped;
reg [`DWIDTH-1:0] b_flopped;

wire [`DWIDTH-1:0] sum_out_temp;
reg [`DWIDTH-1:0] sum_out_temp_reg;

always @(posedge clk) begin
  if (reset) begin
    a_flopped <= 0;
    b_flopped <= 0;
  end else begin
    a_flopped <= a;
    b_flopped <= b;
  end
end

//assign sum_out_temp = a + b;
`ifdef complex_dsp
adder_fp_clk add_u1(.clk(clk), .a(a_flopped), .b(b_flopped), .out(sum_out_temp));
`else
FPAddSub u_FPAddSub (.clk(clk), .rst(1'b0), .a(a_flopped), .b(b_flopped), .operation(1'b0), .result(sum_out_temp), .flags());
`endif

always @(posedge clk) begin
  if (reset) begin
    sum_out_temp_reg <= 0;
  end else begin
    sum_out_temp_reg <= sum_out_temp;
  end
end

assign out = sum_out_temp_reg;

endmodule
