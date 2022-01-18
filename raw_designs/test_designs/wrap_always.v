
module top(clock, count);
input clock;
output count;
wire reset;
assign reset = 1'b1;

always_module(.clock(clock), .reset(reset), .count(count));

endmodule

module always_module(clock, reset, count);

input clock, reset;
output [1:0] count;
reg [1:0] count;

always @(posedge clock) begin
	count <= count + 1'b1;
	if (reset)
		count <= 0;
end

endmodule
