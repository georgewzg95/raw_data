`define SIMULATION_MEMORY

module store_output (
	input clk,
	input i_valid,
	input i_reset,
	input [15:0] i_result_0,
	input [15:0] i_result_1,
	input [15:0] i_result_2,
	input [15:0] i_result_3,
	input [15:0] i_result_4,
	input [15:0] i_result_5,
	input [15:0] i_result_6,
	input [15:0] i_result_7,
	input [15:0] i_result_8,
	input [15:0] i_result_9,
	input [15:0] i_result_10,
	input [15:0] i_result_11,
	output [15:0] o_store_0_0,
	output [15:0] o_store_0_1,
	output [15:0] o_store_1_0,
	output [15:0] o_store_1_1,
	output [15:0] o_store_2_0,
	output [15:0] o_store_2_1,
	output [15:0] o_store_3_0,
	output [15:0] o_store_3_1,
	output [15:0] o_store_4_0,
	output [15:0] o_store_4_1,
	output [15:0] o_store_5_0,
	output [15:0] o_store_5_1,
	output o_wen_0,
	output o_wen_1,
	output o_wen_2,
	output o_wen_3,
	output o_wen_4,
	output o_wen_5,
	output [14:0] o_addr
);

reg wen_0;
reg wen_1;
reg wen_2;
reg wen_3;
reg wen_4;
reg wen_5;
reg [14:0] base_addr;
reg [14:0] offset;
reg [5:0] count;
reg [5:0] count_to_wvec;
reg [5:0] count_x;
reg [5:0] count_y;
reg valid;
reg [15:0] buffer_reg_0;
reg [15:0] buffer_reg_1;
reg [15:0] buffer_reg_2;
reg [15:0] buffer_reg_3;
reg [15:0] buffer_reg_4;
reg [15:0] buffer_reg_5;
reg [15:0] buffer_reg_6;
reg [15:0] buffer_reg_7;
reg [15:0] buffer_reg_8;
reg [15:0] buffer_reg_9;
reg [15:0] buffer_reg_10;
reg [15:0] buffer_reg_11;
reg [14:0] addr_reg;

wire [5:0] count_div_two;
assign count_div_two = count >> 1;
always @ (posedge clk) begin
	valid <= i_valid;
	buffer_reg_0 <= i_result_0;
	buffer_reg_1 <= i_result_1;
	buffer_reg_2 <= i_result_2;
	buffer_reg_3 <= i_result_3;
	buffer_reg_4 <= i_result_4;
	buffer_reg_5 <= i_result_5;
	buffer_reg_6 <= i_result_6;
	buffer_reg_7 <= i_result_7;
	buffer_reg_8 <= i_result_8;
	buffer_reg_9 <= i_result_9;
	buffer_reg_10 <= i_result_10;
	buffer_reg_11 <= i_result_11;
	addr_reg <= base_addr + offset;
	if (i_reset) begin
		count <= 0;
		count_to_wvec <= 0;
		base_addr <= 0;
		offset <= 0;
		count_x <= 0;
		count_y <= 0;
		wen_0 <= 1'b0;
		wen_1 <= 1'b0;
		wen_2 <= 1'b0;
		wen_3 <= 1'b0;
		wen_4 <= 1'b0;
		wen_5 <= 1'b0;
	end else if (i_valid) begin
		if (count_x == 5) begin
			if(count_y == 6)begin
				base_addr <= base_addr + 16;
				count_y <= 0;
				count_x <= 0;
				offset <= 0;
			end else begin
				if(count[0] == 1'b0) begin
					offset <= 8;
					count <= count + 1'b1;
					if(count_to_wvec == 5) begin
						count_to_wvec <= 0;
					end else begin
						count_to_wvec <= count_to_wvec + 1'b1;
					end
				end else if (count[1] == 1'b1) begin
					offset <= 0;
					base_addr <= base_addr + 16;
					count_x <= 0;
					count_y <= count_y + 2;
					count <= count + 1'b1;
					if(count_to_wvec == 5) begin
						count_to_wvec <= 0;
					end else begin
						count_to_wvec <= count_to_wvec + 1'b1;
					end
				end
			end
		end else if(count[0] == 1'b0) begin
			offset <= 8;
			count <= count + 1'b1;
			if(count_to_wvec == 5) begin
				count_to_wvec <= 0;
			end else begin
				count_to_wvec <= count_to_wvec + 1'b1;
			end
		end else if (count[0] == 1'b1) begin
			offset <= 0;
			count <= count + 1'b1;
			if(count_to_wvec == 5) begin
				count_to_wvec <= 0;
			end else begin
				count_to_wvec <= count_to_wvec + 1'b1;
			end
			count_x <= count_x + 1'b1;
		end
		if ((i_valid || valid) == 1'b1) begin
			if ((count_to_wvec == 0) && i_valid == 1) begin
				wen_0 <= 1'b1;
			end else begin
				wen_0 <= 1'b0;
			end
			if ((count_to_wvec == 1) && i_valid == 1) begin
				wen_1 <= 1'b1;
			end else begin
				wen_1 <= 1'b0;
			end
			if ((count_to_wvec == 2) && i_valid == 1) begin
				wen_2 <= 1'b1;
			end else begin
				wen_2 <= 1'b0;
			end
			if ((count_to_wvec == 3) && i_valid == 1) begin
				wen_3 <= 1'b1;
			end else begin
				wen_3 <= 1'b0;
			end
			if ((count_to_wvec == 4) && i_valid == 1) begin
				wen_4 <= 1'b1;
			end else begin
				wen_4 <= 1'b0;
			end
			if ((count_to_wvec == 5) && i_valid == 1) begin
				wen_5 <= 1'b1;
			end else begin
				wen_5 <= 1'b0;
			end
		end
	end
end

assign o_addr = addr_reg;
assign o_store_0_0 = buffer_reg_0;
assign o_store_1_0 = buffer_reg_2;
assign o_store_2_0 = buffer_reg_4;
assign o_store_3_0 = buffer_reg_6;
assign o_store_4_0 = buffer_reg_8;
assign o_store_5_0 = buffer_reg_10;
assign o_store_0_1 = buffer_reg_1;
assign o_store_1_1 = buffer_reg_3;
assign o_store_2_1 = buffer_reg_5;
assign o_store_3_1 = buffer_reg_7;
assign o_store_4_1 = buffer_reg_9;
assign o_store_5_1 = buffer_reg_11;

assign o_wen_0 = wen_0;
assign o_wen_1 = wen_1;
assign o_wen_2 = wen_2;
assign o_wen_3 = wen_3;
assign o_wen_4 = wen_4;
assign o_wen_5 = wen_5;

endmodule
