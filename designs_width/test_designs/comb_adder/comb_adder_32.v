`define WIDTH 32

module adder(A, B, C);

input [`WIDTH-1:0] A;
input [`WIDTH-1:0] B;
output [`WIDTH-1:0] C;

assign C = A + B;

endmodule
