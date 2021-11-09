
`define DATA_WIDTH 16

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
