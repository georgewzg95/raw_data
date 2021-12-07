`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:28:18 08/24/2011 
// Design Name: 
// Module Name:    q15_add 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module qadd(
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
    );
//sign+16.15

	//Parameterized values
	parameter Q = 15;
	parameter N = 32;

reg [N-1:0] res;

assign c = res;

always @(a,b)
begin
	//both negative
	if(a[N-1] == 1 && b[N-1] == 1) begin
		//sign
		res[N-1] = 1;
		//whole
		res[N-2:0] = a[N-2:0] + b[N-2:0];
	end
	//both positive
	else if(a[N-1] == 0 && b[N-1] == 0) begin
		//sign
		res[N-1] = 0;
		//whole
		res[N-2:0] = a[N-2:0] + b[N-2:0];
	end
	//subtract a-b
	else if(a[N-1] == 0 && b[N-1] == 1) begin
		//sign
		if(a[N-2:0] > b[N-2:0])
			res[N-1] = 1;
		else
			res[N-1] = 0;
		//whole
		res[N-2:0] = a[N-2:0] - b[N-2:0];
	end
	//subtract b-a
	else begin
		//sign
		if(a[N-2:0] < b[N-2:0])
			res[N-1] = 1;
		else
			res[N-1] = 0;
		//whole
		res[N-2:0] = b[N-2:0] - a[N-2:0];
	end
end

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:39:14 08/24/2011 
// Design Name: 
// Module Name:    divider 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
 
module qdiv(
	input [N-1:0] dividend,
	input [N-1:0] divisor,
	input start,
	input clk,
	output [N-1:0] quotient_out,
	output complete
	);
 
	//Parameterized values
	parameter Q = 15;
	parameter N = 32;
 
	reg [N-1:0] quotient;
	reg [N-1:0] dividend_copy;
	reg [2*(N-1)-1:0] divider_copy;
 
	reg [5:0] bit; 
	reg done;
 
	initial done = 1;
 
	assign quotient_out = quotient;
	assign complete = done;
 
	always @( posedge clk ) 
	begin
		if( done && start ) begin
 
			done <= 1'b0;
			bit <= N+Q-2;
			quotient <= 0;
			dividend_copy <= {1'b0,dividend[N-2:0]};
 
			divider_copy[2*(N-1)-1] <= 0;
			divider_copy[2*(N-1)-2:N-2] <= divisor[N-2:0];
			divider_copy[N-3:0] <= 0;
 
			//set sign bit
			if((dividend[N-1] == 1 && divisor[N-1] == 0) || (dividend[N-1] == 0 && divisor[N-1] == 1))
				quotient[N-1] <= 1;
			else
				quotient[N-1] <= 0;
		end 
		else if(!done) begin
			//compare divisor/dividend
			if(dividend_copy >= divider_copy) begin
				//subtract
				dividend_copy <= dividend_copy - divider_copy;
				//set quotient
				quotient[bit] <= 1'b1;
			end
 
			//reduce divisor
			divider_copy <= divider_copy >> 1;
  
			//stop condition
			if(bit == 0)
				done <= 1'b1;
				
			//reduce bit counter
			bit <= bit - 1;	
		end
	end
endmodule`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:21:14 08/24/2011 
// Design Name: 
// Module Name:    q15_mult 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module qmult(
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
    );
	 
	wire [2*N-1:0] a_ext;
	wire [2*N-1:0] b_ext;
	wire [2*N-1:0] r_ext;
	
	reg [2*N-1:0] a_mult;
	reg [2*N-1:0] b_mult;
	reg [2*N-1:0] result;
	reg [N-1:0] retVal;
	
	//Parameterized values
	parameter Q = 15;
	parameter N = 32;

	qtwosComp #(Q,N) comp_a (a[30:0], a_ext);

	qtwosComp #(Q,N) comp_b (b[30:0], b_ext);
	
	qtwosComp #(Q,N) comp_r (result[N-2+Q:Q], r_ext);
	
	assign c = retVal;
	
	always @(a_ext,b_ext)
	begin
		if(a[N-1] == 1)
			a_mult <= a_ext;
		else
			a_mult <= a;
			
		if(b[N-1] == 1)
			b_mult <= b_ext;
		else
			b_mult <= b;		
	end 
	
	always @(a_mult,b_mult)
	begin
		result <= a_mult * b_mult;
	end;
	
	always @(result,r_ext)
	begin		
		//sign
		if((a[N-1] == 1 && b[N-1] == 0) || (a[N-1] == 0 && b[N-1] == 1)) begin
			retVal[N-1] <= 1;
			retVal[N-2:0] <= r_ext[N-2:0];
		end
		else begin
			retVal[N-1] <= 0;
			retVal[N-2:0] <= result[N-2+Q:Q];
		end
	end

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:44:20 08/24/2011 
// Design Name: 
// Module Name:    twosComp 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module qtwosComp(
    input [N-2:0] a,
    output [2*N-1:0] b
    );
	reg [2*N-1:0] data;
	reg [2*N-1:0] flip;
	reg [2*N-1:0] out;
	
	//Parameterized values
	parameter Q = 15;
	parameter N = 32;
	
	assign b = out;
	
	always @(a)
	begin
		data <= a;		//if you dont put the value into a 64b register, when you flip the bits it wont work right
	end
	
	always @(data)
	begin
		flip <= ~a;
	end
	
	always @(flip)
	begin
		out <= flip + 1;
	end

endmodule
