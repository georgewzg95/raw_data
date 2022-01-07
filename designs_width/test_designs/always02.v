module uut_always02(clock, reset, count);

input clock, reset;
output [1:0] count;
reg [1:0] count;

always @(posedge clock) begin
	count <= count + 1'b1;
	if (reset)
		count <= 0;
end

endmodule
