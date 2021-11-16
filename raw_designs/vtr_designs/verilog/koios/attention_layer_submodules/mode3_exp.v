`define SIMULATION_MEMORY
//`define SIMULATION_addfp
`define VECTOR_DEPTH 64 //Q,K,V vector size
`define DATA_WIDTH 16
`define VECTOR_BITS 1024 // 16 bit each (16x64)
`define NUM_WORDS 32   //num of words in the sentence
`define BUF_AWIDTH 4 //16 entries in each buffer ram
`define BUF_LOC_SIZE 4 //4 words in each addr location
`define OUT_RAM_DEPTH 512 //512 entries in output bram
`define EXPONENT 8
`define MANTISSA 7
`define EXPONENT 5
`define MANTISSA 10
`define SIGN 1
`define DWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define DEFINES_DONE
`define DATAWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define IEEE_COMPLIANCE 1
`define NUM 4
`define ADDRSIZE 4

module mode3_exp(
  inp0, 
  inp1, 
  inp2, 
  inp3, 

  clk,
  reset,
  stage_run,
  stage_run2,
  
  outp0, 
  outp1, 
  outp2, 
  outp3
);

  input  [`DATAWIDTH-1 : 0] inp0;
  input  [`DATAWIDTH-1 : 0] inp1;
  input  [`DATAWIDTH-1 : 0] inp2;
  input  [`DATAWIDTH-1 : 0] inp3;

  input  clk;
  input  reset;
  input  stage_run;
  input  stage_run2;

  output  [`DATAWIDTH-1 : 0] outp0;
  output  [`DATAWIDTH-1 : 0] outp1;
  output  [`DATAWIDTH-1 : 0] outp2;
  output  [`DATAWIDTH-1 : 0] outp3;
  expunit exp0(.a(inp0), .z(outp0), .status(), .stage_run(stage_run), .stage_run2(stage_run2), .clk(clk), .reset(reset));
  expunit exp1(.a(inp1), .z(outp1), .status(), .stage_run(stage_run), .stage_run2(stage_run2), .clk(clk), .reset(reset));
  expunit exp2(.a(inp2), .z(outp2), .status(), .stage_run(stage_run), .stage_run2(stage_run2), .clk(clk), .reset(reset));
  expunit exp3(.a(inp3), .z(outp3), .status(), .stage_run(stage_run), .stage_run2(stage_run2), .clk(clk), .reset(reset));
endmodule
//[second_phase_finishes]
module expunit (a, z, status, stage_run, stage_run2, clk, reset);

	input [15:0] a;
    input stage_run;
	input stage_run2;
    input clk;
    input reset;
    output reg [15:0] z;
    output [7:0] status;
	
    reg  [31:0] LUTout_reg;
	reg  [31:0] LUTout_reg2;
    reg  [15:0] a_reg;
	reg  [15:0] a_reg2;
	reg  [15:0] a_comp_reg;
	reg  [31:0] Mult_out_reg;
    wire [31:0] LUTout;
    wire [31:0] Mult_out;
    wire [15:0] a_comp;
    wire [15:0] z_out;
  	
    
	always @(posedge clk) begin
    if(reset) begin
      LUTout_reg2 <= 0;
	  a_reg2 <= 0;
	  a_comp_reg <= 0;
    end 
	else if(stage_run2) begin
      LUTout_reg2 <= LUTout;
	  a_reg2 <= a;
	  a_comp_reg <= a_comp;
    end
    end
	
	always @(posedge clk) begin
    if(reset) begin
      Mult_out_reg <= 0;
      LUTout_reg <= 0;
	  a_reg <= 0;
    end 
	else if(stage_run) begin
      Mult_out_reg <= Mult_out;
      LUTout_reg <= LUTout_reg2;
	  a_reg <= a_reg2;
    end
    end

    assign a_comp = ~a + 1'b1;
    ExpLUT lut(.addr(a_comp[14:8]), .exp(LUTout)); 
    assign Mult_out = ~(a_comp_reg*LUTout_reg2[31:16])+1;
    assign z_out = Mult_out_reg[27:12] + LUTout_reg[15:0];

    always@(z_out or a_reg) begin
      if (a_reg[15:12] == 4'b1000) begin
        z = 12'b1;
      end
      else
        z = z_out;
    end
  
endmodule
module ExpLUT(addr, exp);
    input [6:0] addr;
    output reg [31:0] exp;

    always @(addr) begin
        case (addr)
	     7'b0000000            : exp =  32'b00001111100000100001000000000000;
	     7'b0000001            : exp =  32'b00001110100100100000111111110000;
	     7'b0000010            : exp =  32'b00001101101100000000111111010100;
	     7'b0000011            : exp =  32'b00001100110110110000111110101100;
	     7'b0000100            : exp =  32'b00001100000101000000111101111011;
	     7'b0000101            : exp =  32'b00001011010110000000111101000000;
	     7'b0000110            : exp =  32'b00001010101010000000111011111110;
	     7'b0000111            : exp =  32'b00001010000000110000111010110110;
	     7'b0001000            : exp =  32'b00001001011010000000111001101000;
	     7'b0001001            : exp =  32'b00001000110101100000111000010110;
	     7'b0001010            : exp =  32'b00001000010011010000110111000000;
	     7'b0001011            : exp =  32'b00000111110011000000110101101000;
	     7'b0001100            : exp =  32'b00000111010100110000110100001101;
	     7'b0001101            : exp =  32'b00000110111000010000110010110001;
	     7'b0001110            : exp =  32'b00000110011101110000110001010011;
	     7'b0001111            : exp =  32'b00000110000100100000101111110101;
	     7'b0010000            : exp =  32'b00000101101101000000101110010111;
	     7'b0010001            : exp =  32'b00000101010111000000101100111001;
	     7'b0010010            : exp =  32'b00000101000010010000101011011011;
	     7'b0010011            : exp =  32'b00000100101110100000101001111111;
	     7'b0010100            : exp =  32'b00000100011100010000101000100011;
	     7'b0010101            : exp =  32'b00000100001011000000100111001001;
	     7'b0010110            : exp =  32'b00000011111010110000100101110000;
	     7'b0010111            : exp =  32'b00000011101011110000100100011000;
	     7'b0011000            : exp =  32'b00000011011101010000100011000010;
	     7'b0011001            : exp =  32'b00000011010000000000100001101111;
	     7'b0011010            : exp =  32'b00000011000011010000100000011101;
	     7'b0011011            : exp =  32'b00000010110111100000011111001101;
	     7'b0011100            : exp =  32'b00000010101100010000011101111111;
	     7'b0011101            : exp =  32'b00000010100010000000011100110011;
	     7'b0011110            : exp =  32'b00000010011000000000011011101001;
	     7'b0011111            : exp =  32'b00000010001111000000011010100010;
	     7'b0100000            : exp =  32'b00000010000110010000011001011101;
	     7'b0100001            : exp =  32'b00000001111110000000011000011001;
	     7'b0100010            : exp =  32'b00000001110110100000010111011000;
	     7'b0100011            : exp =  32'b00000001101111010000010110011010;
	     7'b0100100            : exp =  32'b00000001101000100000010101011101;
	     7'b0100101            : exp =  32'b00000001100010010000010100100010;
	     7'b0100110            : exp =  32'b00000001011100010000010011101010;
	     7'b0100111            : exp =  32'b00000001010110100000010010110011;
	     7'b0101000            : exp =  32'b00000001010001010000010001111111;
	     7'b0101001            : exp =  32'b00000001001100100000010001001100;
	     7'b0101010            : exp =  32'b00000001000111110000010000011011;
	     7'b0101011            : exp =  32'b00000001000011100000001111101100;
	     7'b0101100            : exp =  32'b00000000111111010000001110111111;
	     7'b0101101            : exp =  32'b00000000111011100000001110010100;
	     7'b0101110            : exp =  32'b00000000111000000000001101101011;
	     7'b0101111            : exp =  32'b00000000110100100000001101000011;
	     7'b0110000            : exp =  32'b00000000110001010000001100011100;
	     7'b0110001            : exp =  32'b00000000101110010000001011111000;
	     7'b0110010            : exp =  32'b00000000101011100000001011010101;
	     7'b0110011            : exp =  32'b00000000101000110000001010110011;
	     7'b0110100            : exp =  32'b00000000100110010000001010010011;
	     7'b0110101            : exp =  32'b00000000100100000000001001110100;
	     7'b0110110            : exp =  32'b00000000100001110000001001010110;
	     7'b0110111            : exp =  32'b00000000011111110000001000111010;
	     7'b0111000            : exp =  32'b00000000011101110000001000011111;
	     7'b0111001            : exp =  32'b00000000011100000000001000000101;
	     7'b0111010            : exp =  32'b00000000011010010000000111101100;
	     7'b0111011            : exp =  32'b00000000011000110000000111010101;
	     7'b0111100            : exp =  32'b00000000010111010000000110111110;
	     7'b0111101            : exp =  32'b00000000010101110000000110101000;
	     7'b0111110            : exp =  32'b00000000010100100000000110010100;
	     7'b0111111            : exp =  32'b00000000010011010000000110000000;
	     7'b1000000            : exp =  32'b00000000010010000000000101101101;
	     7'b1000001            : exp =  32'b00000000010001000000000101011100;
	     7'b1000010            : exp =  32'b00000000010000000000000101001010;
	     7'b1000011            : exp =  32'b00000000001111000000000100111010;
	     7'b1000100            : exp =  32'b00000000001110000000000100101011;
	     7'b1000101            : exp =  32'b00000000001101010000000100011100;
	     7'b1000110            : exp =  32'b00000000001100010000000100001110;
	     7'b1000111            : exp =  32'b00000000001011100000000100000000;
	     7'b1001000            : exp =  32'b00000000001011000000000011110011;
	     7'b1001001            : exp =  32'b00000000001010010000000011100111;
	     7'b1001010            : exp =  32'b00000000001001100000000011011100;
	     7'b1001011            : exp =  32'b00000000001001000000000011010001;
	     7'b1001100            : exp =  32'b00000000001000100000000011000110;
	     7'b1001101            : exp =  32'b00000000001000000000000010111100;
	     7'b1001110            : exp =  32'b00000000000111100000000010110011;
	     7'b1001111            : exp =  32'b00000000000111000000000010101001;
	     7'b1010000            : exp =  32'b00000000000110100000000010100001;
	     7'b1010001            : exp =  32'b00000000000110010000000010011001;
	     7'b1010010            : exp =  32'b00000000000101110000000010010001;
	     7'b1010011            : exp =  32'b00000000000101100000000010001001;
	     7'b1010100            : exp =  32'b00000000000101000000000010000010;
	     7'b1010101            : exp =  32'b00000000000100110000000001111100;
	     7'b1010110            : exp =  32'b00000000000100100000000001110101;
	     7'b1010111            : exp =  32'b00000000000100010000000001101111;
	     7'b1011000            : exp =  32'b00000000000100000000000001101001;
	     7'b1011001            : exp =  32'b00000000000011110000000001100100;
	     7'b1011010            : exp =  32'b00000000000011100000000001011111;
	     7'b1011011            : exp =  32'b00000000000011010000000001011010;
	     7'b1011100            : exp =  32'b00000000000011000000000001010101;
	     7'b1011101            : exp =  32'b00000000000010110000000001010001;
	     7'b1011110            : exp =  32'b00000000000010110000000001001101;
	     7'b1011111            : exp =  32'b00000000000010100000000001001001;
	     7'b1100000            : exp =  32'b00000000000010010000000001000101;
	     7'b1100001            : exp =  32'b00000000000010010000000001000001;
	     7'b1100010            : exp =  32'b00000000000010000000000000111110;
	     7'b1100011            : exp =  32'b00000000000010000000000000111010;
	     7'b1100100            : exp =  32'b00000000000001110000000000110111;
	     7'b1100101            : exp =  32'b00000000000001110000000000110100;
	     7'b1100110            : exp =  32'b00000000000001100000000000110010;
	     7'b1100111            : exp =  32'b00000000000001100000000000101111;
	     7'b1101000            : exp =  32'b00000000000001010000000000101100;
	     7'b1101001            : exp =  32'b00000000000001010000000000101010;
	     7'b1101010            : exp =  32'b00000000000001010000000000101000;
	     7'b1101011            : exp =  32'b00000000000001000000000000100110;
	     7'b1101100            : exp =  32'b00000000000001000000000000100100;
	     7'b1101101            : exp =  32'b00000000000001000000000000100010;
	     7'b1101110            : exp =  32'b00000000000001000000000000100000;
	     7'b1101111            : exp =  32'b00000000000000110000000000011110;
	     7'b1110000            : exp =  32'b00000000000000110000000000011101;
	     7'b1110001            : exp =  32'b00000000000000110000000000011011;
	     7'b1110010            : exp =  32'b00000000000000110000000000011010;
	     7'b1110011            : exp =  32'b00000000000000110000000000011000;
	     7'b1110100            : exp =  32'b00000000000000100000000000010111;
	     7'b1110101            : exp =  32'b00000000000000100000000000010110;
	     7'b1110110            : exp =  32'b00000000000000100000000000010100;
	     7'b1110111            : exp =  32'b00000000000000100000000000010011;
	     7'b1111000            : exp =  32'b00000000000000100000000000010010;
	     7'b1111001            : exp =  32'b00000000000000100000000000010001;
	     7'b1111010            : exp =  32'b00000000000000010000000000010000;
	     7'b1111011            : exp =  32'b00000000000000010000000000001111;
	     7'b1111100            : exp =  32'b00000000000000010000000000001111;
	     7'b1111101            : exp =  32'b00000000000000010000000000001110;
	     7'b1111110            : exp =  32'b00000000000000010000000000001101;
	     7'b1111111            : exp =  32'b00000000000000010000000000001100;
        endcase
    end
endmodule
