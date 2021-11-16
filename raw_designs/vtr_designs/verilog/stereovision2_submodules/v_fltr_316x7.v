	`define WIDTH_4B 4'b1000
`define COEF0_b  29
	`define COEF1_b  101
//	`define COEF2_b  -15
//	`define COEF3_b  -235
//	`define COEF4_b  -15
	`define COEF2_b  15
	`define COEF3_b  235
	`define COEF4_b  15
	`define COEF5_b  101
	`define COEF6_b  29
	`define WIDTH_5B 5'b10000
	`define COEF0_c  4
	`define COEF1_c  42
	`define COEF2_c  163
	`define COEF3_c  255
	`define COEF4_c  163
	`define COEF5_c  42
	`define COEF6_c  4
//	`define COEF0_d  -12
//	`define COEF1_d  -77
//	`define COEF2_d  -148
	`define COEF0_d  12
	`define COEF1_d  77
	`define COEF2_d  148
	`define COEF3_d  0
	`define COEF4_d  148
	`define COEF5_d  77
	`define COEF6_d  12
	`define COEF0_1  15
//`define COEF0_1  -15
	`define COEF1_1  25
	`define COEF2_1  193
	`define COEF3_1  0
//	`define COEF4_1  -193
//	`define COEF5_1  -25
	`define COEF4_1  193
	`define COEF5_1  25
	`define COEF6_1  15
	`define COEF0_2  4
	`define COEF1_2  42
	`define COEF2_2  163
	`define COEF3_2  255
	`define COEF4_2  163
	`define COEF5_2  42
	`define COEF6_2  4
//	`define COEF0_3  -9
//	`define COEF1_3  -56
//	`define COEF2_3  -109
	`define COEF0_3  9
	`define COEF1_3  56
	`define COEF2_3  109
	`define COEF3_3  0
	`define COEF4_3  109
	`define COEF5_3  56
	`define COEF6_3  9
//	`define COEF0_4  -9
//	`define COEF1_4  -56
//	`define COEF2_4  -109
	`define COEF0_4  9
	`define COEF1_4  56
	`define COEF2_4  109
	`define COEF3_4  0
	`define COEF4_4  109
	`define COEF5_4  56
	`define COEF6_4  9

module v_fltr_316x7 (tm3_clk_v0, vidin_new_data, vidin_in, vidin_out_f1, vidin_out_f2, vidin_out_f3, vidin_out_h1, vidin_out_h2, vidin_out_h3, vidin_out_h4); // PAJ var never used, vidin_out_or);

   parameter horiz_length  = 9'b100111100;
   parameter vert_length  = 3'b111; // PAJ constant for all

   input tm3_clk_v0; 
   input vidin_new_data; 
   input[7:0] vidin_in; 
   output[15:0] vidin_out_f1; 
   wire[15:0] vidin_out_f1;
   output[15:0] vidin_out_f2; 
   wire[15:0] vidin_out_f2;
   output[15:0] vidin_out_f3; 
   wire[15:0] vidin_out_f3;
   output[15:0] vidin_out_h1; 
   wire[15:0] vidin_out_h1;
   output[15:0] vidin_out_h2; 
   wire[15:0] vidin_out_h2;
   output[15:0] vidin_out_h3; 
   wire[15:0] vidin_out_h3;
   output[15:0] vidin_out_h4; 
   wire[15:0] vidin_out_h4;
//   output[7:0] vidin_out_or; 
//   reg[7:0] vidin_out_or;

   wire[7:0] buff_out0; 
   wire[7:0] buff_out1; 
   wire[7:0] buff_out2; 
   wire[7:0] buff_out3; 
   wire[7:0] buff_out4; 
   wire[7:0] buff_out5; 
   wire[7:0] buff_out6; 
   wire[7:0] buff_out7; 

 	fifo316 fifo0(tm3_clk_v0, vidin_new_data, buff_out0, buff_out1);
 	fifo316 fifo1(tm3_clk_v0, vidin_new_data, buff_out1, buff_out2);
 	fifo316 fifo2(tm3_clk_v0, vidin_new_data, buff_out2, buff_out3);
 	fifo316 fifo3(tm3_clk_v0, vidin_new_data, buff_out3, buff_out4);
 	fifo316 fifo4(tm3_clk_v0, vidin_new_data, buff_out4, buff_out5);
 	fifo316 fifo5(tm3_clk_v0, vidin_new_data, buff_out5, buff_out6);
 	fifo316 fifo6(tm3_clk_v0, vidin_new_data, buff_out6, buff_out7);

   fltr_compute_f1 inst_fltr_compute_f1 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_f1);	
   fltr_compute_f2 inst_fltr_compute_f2 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_f2);	
   fltr_compute_f3 inst_fltr_compute_f3 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_f3);	
   fltr_compute_h1 inst_fltr_compute_h1 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_h1);	
   fltr_compute_h2 inst_fltr_compute_h2 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_h2);	
   fltr_compute_h3 inst_fltr_compute_h3 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_h3);	
   fltr_compute_h4 inst_fltr_compute_h4 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_h4);	

         assign buff_out0 = vidin_in ; 
/*
   always @(posedge tm3_clk_v0)
   begin
         buff_out0 <= vidin_in ; 
         //vidin_out_or <= buff_out6; 
   end 
*/
endmodule
module fifo316 (clk, wen, din, dout);

//	parameter `WIDTH = 4'b1000;

    input clk; 
    input wen; 
    input[`WIDTH_4B - 1:0] din; 
    output[`WIDTH_4B - 1:0] dout; 
    reg[`WIDTH_4B - 1:0] dout;

    reg[`WIDTH_4B-1:0]buff1; 
    reg[`WIDTH_4B-1:0]buff2; 

    always @(posedge clk)
    begin
		if (wen == 1'b1)
		begin
			buff1 <= din;
			buff2 <= buff1;
			dout <= buff2;
		end
	end
endmodule
