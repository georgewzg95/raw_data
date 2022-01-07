`define WIDTH 64

module adder(clock, count);

input clock;
output [`WIDTH-1:0] count;
reg [`WIDTH-1:0] count;

always @(posedge clock) begin
	count <= count + 1'b1;
end

endmodule
