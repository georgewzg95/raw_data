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

module divideby8
(
  input [`DATA_WIDTH-1:0] data,
  output reg [`DATA_WIDTH-1:0] out
 );

 reg [`DATA_WIDTH-1:0] mask; 

 always@(*) begin
	 if (data[`DATA_WIDTH-1] == 1) 
		mask = 16'b1110000000000000;
	 else
		mask = 0;
	
	 out = mask|(data>>3);
  end
 
endmodule
