`define SIMULATION_MEMORY

module weight_buffer_18_9_42_1_2688Wixr_real_half_0 (
	input clk,
	output [17:0] q_0_0,
	output [17:0] q_0_1,
	output [17:0] q_0_2,
	output [17:0] q_0_3,
	output [17:0] q_0_4,
	output [17:0] q_0_5,
	output [17:0] q_0_6,
	output [17:0] q_0_7,
	output [17:0] q_0_8,
	input [11:0] index
);

wire [161:0] packed_result_0;
reg [11:0] addrs_0;
reg [11:0] addrs_base_0;

always @ (posedge clk) begin
	addrs_base_0 <= 0;
	addrs_0 <= index + addrs_base_0;
end

wire rom_we;
assign rom_we = 1'b0;

`ifdef SIMULATION_MEMORY
defparam ram_inst_0.DATA_WIDTH = 162;
defparam ram_inst_0.ADDR_WIDTH = 12;
`endif
single_port_ram ram_inst_0 (
	.we(rom_we),
	.addr(addrs_0),
	.data(162'd0),
	.out(packed_result_0),
	.clk(clk)
);

// Unpack result
assign q_0_0 = packed_result_0[17:0];
assign q_0_1 = packed_result_0[35:18];
assign q_0_2 = packed_result_0[53:36];
assign q_0_3 = packed_result_0[71:54];
assign q_0_4 = packed_result_0[89:72];
assign q_0_5 = packed_result_0[107:90];
assign q_0_6 = packed_result_0[125:108];
assign q_0_7 = packed_result_0[143:126];
assign q_0_8 = packed_result_0[161:144];

endmodule

module single_port_ram(
clk,
addr,
data,
we,
out
);

parameter DATA_WIDTH = 288;
parameter ADDR_WIDTH = 6;
input clk;
input [ADDR_WIDTH-1:0] addr;
input [DATA_WIDTH-1:0] data;
input we;
output reg [DATA_WIDTH-1:0] out;

reg [DATA_WIDTH-1:0] ram[ADDR_WIDTH-1:0];

always @(posedge clk) begin
  if (we) begin
    ram[addr] <= data;
  end
  else begin
    out <= ram[addr];
  end
end

endmodule



