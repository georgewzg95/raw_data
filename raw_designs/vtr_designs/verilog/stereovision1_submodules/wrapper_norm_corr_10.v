
module wrapper_norm_corr_10 (clk, wen, d_l_1, d_l_2, d_r_1, d_r_2, corr_out_0, corr_out_1, corr_out_2, corr_out_3, corr_out_4, corr_out_5, corr_out_6, corr_out_7, corr_out_8, corr_out_9, corr_out_10);

   parameter sh_reg_w  = 4'b1000;
   input clk; 
   input wen; 
   input[15:0] d_l_1; 
   input[15:0] d_l_2; 
   input[15:0] d_r_1; 
   input[15:0] d_r_2; 
   output[2 * sh_reg_w - 1:0] corr_out_0; 
   wire[2 * sh_reg_w - 1:0] corr_out_0;
   output[2 * sh_reg_w - 1:0] corr_out_1; 
   wire[2 * sh_reg_w - 1:0] corr_out_1;
   output[2 * sh_reg_w - 1:0] corr_out_2; 
   wire[2 * sh_reg_w - 1:0] corr_out_2;
   output[2 * sh_reg_w - 1:0] corr_out_3; 
   wire[2 * sh_reg_w - 1:0] corr_out_3;
   output[2 * sh_reg_w - 1:0] corr_out_4; 
   wire[2 * sh_reg_w - 1:0] corr_out_4;
   output[2 * sh_reg_w - 1:0] corr_out_5; 
   wire[2 * sh_reg_w - 1:0] corr_out_5;
   output[2 * sh_reg_w - 1:0] corr_out_6; 
   wire[2 * sh_reg_w - 1:0] corr_out_6;
   output[2 * sh_reg_w - 1:0] corr_out_7; 
   wire[2 * sh_reg_w - 1:0] corr_out_7;
   output[2 * sh_reg_w - 1:0] corr_out_8; 
   wire[2 * sh_reg_w - 1:0] corr_out_8;
   output[2 * sh_reg_w - 1:0] corr_out_9; 
   wire[2 * sh_reg_w - 1:0] corr_out_9;
   output[2 * sh_reg_w - 1:0] corr_out_10; 
   wire[2 * sh_reg_w - 1:0] corr_out_10;

   wire[sh_reg_w - 1:0] d_l_1_nrm; 
   wire[sh_reg_w - 1:0] d_l_2_nrm; 
   wire[sh_reg_w - 1:0] d_r_1_nrm; 
   wire[sh_reg_w - 1:0] d_r_2_nrm; 

   wrapper_norm  norm_inst_left(.clk(clk), .nd(wen), .din_1(d_l_1), .din_2(d_l_2), .dout_1(d_l_1_nrm), .dout_2(d_l_2_nrm)); 
   wrapper_norm  norm_inst_right(.clk(clk), .nd(wen), .din_1(d_r_1), .din_2(d_r_2), .dout_1(d_r_1_nrm), .dout_2(d_r_2_nrm)); 
   wrapper_corr_10  corr_5_inst(.clk(clk), .wen(wen), .d_l_1(d_l_1_nrm), .d_l_2(d_l_2_nrm), .d_r_1(d_r_1_nrm), .d_r_2(d_r_2_nrm), .corr_out_0(corr_out_0), .corr_out_1(corr_out_1), .corr_out_2(corr_out_2), .corr_out_3(corr_out_3), .corr_out_4(corr_out_4), .corr_out_5(corr_out_5), .corr_out_6(corr_out_6), .corr_out_7(corr_out_7), .corr_out_8(corr_out_8), .corr_out_9(corr_out_9), .corr_out_10(corr_out_10));
endmodule
module wrapper_corr_10 (clk, wen, d_l_1, d_l_2, d_r_1, d_r_2, corr_out_0, corr_out_1, corr_out_2, corr_out_3, corr_out_4, corr_out_5, corr_out_6, corr_out_7, corr_out_8, corr_out_9, corr_out_10);

   parameter sh_reg_w  = 4'b1000;
   input clk; 
   input wen; 
   input[7:0] d_l_1; 
   input[7:0] d_l_2; 
   input[7:0] d_r_1; 
   input[7:0] d_r_2; 
   output[2 * sh_reg_w - 1:0] corr_out_0; 
   reg[2 * sh_reg_w - 1:0] corr_out_0;
   output[2 * sh_reg_w - 1:0] corr_out_1; 
   reg[2 * sh_reg_w - 1:0] corr_out_1;
   output[2 * sh_reg_w - 1:0] corr_out_2; 
   reg[2 * sh_reg_w - 1:0] corr_out_2;
   output[2 * sh_reg_w - 1:0] corr_out_3; 
   reg[2 * sh_reg_w - 1:0] corr_out_3;
   output[2 * sh_reg_w - 1:0] corr_out_4; 
   reg[2 * sh_reg_w - 1:0] corr_out_4;
   output[2 * sh_reg_w - 1:0] corr_out_5; 
   reg[2 * sh_reg_w - 1:0] corr_out_5;
   output[2 * sh_reg_w - 1:0] corr_out_6; 
   reg[2 * sh_reg_w - 1:0] corr_out_6;
   output[2 * sh_reg_w - 1:0] corr_out_7; 
   reg[2 * sh_reg_w - 1:0] corr_out_7;
   output[2 * sh_reg_w - 1:0] corr_out_8; 
   reg[2 * sh_reg_w - 1:0] corr_out_8;
   output[2 * sh_reg_w - 1:0] corr_out_9; 
   reg[2 * sh_reg_w - 1:0] corr_out_9;
   output[2 * sh_reg_w - 1:0] corr_out_10; 
   reg[2 * sh_reg_w - 1:0] corr_out_10;

   wire[sh_reg_w - 1:0] out_r1; 
   wire[sh_reg_w - 1:0] out_01; 
   wire[sh_reg_w - 1:0] out_11; 
   wire[sh_reg_w - 1:0] out_21; 
   wire[sh_reg_w - 1:0] out_31; 
   wire[sh_reg_w - 1:0] out_41; 
   wire[sh_reg_w - 1:0] out_51; 
   wire[sh_reg_w - 1:0] out_61; 
   wire[sh_reg_w - 1:0] out_71; 
   wire[sh_reg_w - 1:0] out_81; 
   wire[sh_reg_w - 1:0] out_91; 
   wire[sh_reg_w - 1:0] out_101; 
   wire[sh_reg_w - 1:0] out_r2; 
   wire[sh_reg_w - 1:0] out_02; 
   wire[sh_reg_w - 1:0] out_12; 
   wire[sh_reg_w - 1:0] out_22; 
   wire[sh_reg_w - 1:0] out_32; 
   wire[sh_reg_w - 1:0] out_42; 
   wire[sh_reg_w - 1:0] out_52; 
   wire[sh_reg_w - 1:0] out_62; 
   wire[sh_reg_w - 1:0] out_72; 
   wire[sh_reg_w - 1:0] out_82; 
   wire[sh_reg_w - 1:0] out_92; 

   wire[sh_reg_w - 1:0] out_102; 
   wire[2 * sh_reg_w - 1:0] corr_out_0_tmp; 
   wire[2 * sh_reg_w - 1:0] corr_out_1_tmp; 
   wire[2 * sh_reg_w - 1:0] corr_out_2_tmp; 
   wire[2 * sh_reg_w - 1:0] corr_out_3_tmp; 
   wire[2 * sh_reg_w - 1:0] corr_out_4_tmp; 
   wire[2 * sh_reg_w - 1:0] corr_out_5_tmp; 
   wire[2 * sh_reg_w - 1:0] corr_out_6_tmp; 
   wire[2 * sh_reg_w - 1:0] corr_out_7_tmp; 
   wire[2 * sh_reg_w - 1:0] corr_out_8_tmp; 
   wire[2 * sh_reg_w - 1:0] corr_out_9_tmp; 
   wire[2 * sh_reg_w - 1:0] corr_out_10_tmp; 

   sh_reg  inst_sh_reg_r_1(clk, wen, d_r_1, d_r_2, out_r1, out_r2); 

   sh_reg  inst_sh_reg_0(clk, wen, d_l_1, d_l_2, out_01, out_02); 

   sh_reg  inst_sh_reg_1(clk, wen, out_01, out_02, out_11, out_12); 

   sh_reg  inst_sh_reg_2(clk, wen, out_11, out_12, out_21, out_22); 

   sh_reg  inst_sh_reg_3(clk, wen, out_21, out_22, out_31, out_32); 

   sh_reg  inst_sh_reg_4(clk, wen, out_31, out_32, out_41, out_42); 

   sh_reg  inst_sh_reg_5(clk, wen, out_41, out_42, out_51, out_52); 

   sh_reg  inst_sh_reg_6(clk, wen, out_51, out_52, out_61, out_62); 

   sh_reg  inst_sh_reg_7(clk, wen, out_61, out_62, out_71, out_72); 

   sh_reg  inst_sh_reg_8(clk, wen, out_71, out_72, out_81, out_82); 

   sh_reg  inst_sh_reg_9(clk, wen, out_81, out_82, out_91, out_92); 

   sh_reg  inst_sh_reg_10(clk, wen, out_91, out_92, out_101, out_102); 

   corr  inst_corr_0(clk, wen, out_01, out_02, out_r1, out_r2, corr_out_0_tmp); 

   corr  inst_corr_1(clk, wen, out_11, out_12, out_r1, out_r2, corr_out_1_tmp); 

   corr  inst_corr_2(clk, wen, out_21, out_22, out_r1, out_r2, corr_out_2_tmp); 

   corr  inst_corr_3(clk, wen, out_31, out_32, out_r1, out_r2, corr_out_3_tmp); 

   corr  inst_corr_4(clk, wen, out_41, out_42, out_r1, out_r2, corr_out_4_tmp); 

   corr  inst_corr_5(clk, wen, out_51, out_52, out_r1, out_r2, corr_out_5_tmp); 

   corr  inst_corr_6(clk, wen, out_61, out_62, out_r1, out_r2, corr_out_6_tmp); 

   corr  inst_corr_7(clk, wen, out_71, out_72, out_r1, out_r2, corr_out_7_tmp); 

   corr  inst_corr_8(clk, wen, out_81, out_82, out_r1, out_r2, corr_out_8_tmp); 

   corr  inst_corr_9(clk, wen, out_91, out_92, out_r1, out_r2, corr_out_9_tmp); 

   corr  inst_corr_10(clk, wen, out_101, out_102, out_r1, out_r2, corr_out_10_tmp); 

   always @(posedge clk)
   begin
         if (wen == 1'b1)
         begin
            corr_out_0 <= corr_out_0_tmp ; 
            corr_out_1 <= corr_out_1_tmp ; 
            corr_out_2 <= corr_out_2_tmp ; 
            corr_out_3 <= corr_out_3_tmp ; 
            corr_out_4 <= corr_out_4_tmp ; 
            corr_out_5 <= corr_out_5_tmp ; 
            corr_out_6 <= corr_out_6_tmp ; 
            corr_out_7 <= corr_out_7_tmp ; 
            corr_out_8 <= corr_out_8_tmp ; 
            corr_out_9 <= corr_out_9_tmp ; 
            corr_out_10 <= corr_out_10_tmp ; 
         end 
         else
         begin
            corr_out_0 <= corr_out_0; 
            corr_out_1 <= corr_out_1; 
            corr_out_2 <= corr_out_2; 
            corr_out_3 <= corr_out_3; 
            corr_out_4 <= corr_out_4; 
            corr_out_5 <= corr_out_5; 
            corr_out_6 <= corr_out_6; 
            corr_out_7 <= corr_out_7; 
            corr_out_8 <= corr_out_8; 
            corr_out_9 <= corr_out_9; 
            corr_out_10 <= corr_out_10; 
         end 

   end 
endmodule
module corr (clk, new_data, in_l_re, in_l_im, in_r_re, in_r_im, corr_out);

    parameter sh_reg_w  = 4'b1000;
    input clk; 
    input new_data; 
    input[sh_reg_w - 1:0] in_l_re; 
    input[sh_reg_w - 1:0] in_l_im; 
    input[sh_reg_w - 1:0] in_r_re; 
    input[sh_reg_w - 1:0] in_r_im; 
    output[2 * sh_reg_w - 1:0] corr_out; 
    reg[2 * sh_reg_w - 1:0] corr_out;
    wire[sh_reg_w - 1:0] in_l_re_reg; 
    wire[sh_reg_w - 1:0] in_l_im_reg; 
    wire[sh_reg_w - 1:0] in_r_re_reg; 
    wire[sh_reg_w - 1:0] in_r_im_reg; 
    reg[2 * sh_reg_w - 1:0] lrexrre_reg; 
    reg[2 * sh_reg_w - 1:0] limxrim_reg; 
    reg[2 * sh_reg_w - 1:0] corr_out_tmp; 

    always @(posedge clk)
    begin
			// PAJ - edf xilinx files converted to multiply 
			lrexrre_reg <= in_l_re * in_r_re;
			limxrim_reg <= in_l_im * in_r_im;

          if (new_data == 1'b1)
          begin
             corr_out <= corr_out_tmp ; 
          end 
          else
          begin
             corr_out <= corr_out; 
          end 
          corr_out_tmp <= lrexrre_reg + limxrim_reg ; 
    end 
 endmodule
module wrapper_norm (clk, nd, din_1, din_2, dout_1, dout_2);

   parameter sh_reg_w  = 4'b1000;
   input clk; 
   input nd; 
   input[15:0] din_1; 
   input[15:0] din_2; 
   output[sh_reg_w - 1:0] dout_1; 
   wire[sh_reg_w - 1:0] dout_1;
   output[sh_reg_w - 1:0] dout_2; 
   wire[sh_reg_w - 1:0] dout_2;

   reg[15:0] din_1_reg; 
   reg[15:0] din_2_reg; 
   reg[15:0] din_1_tmp1; 
   reg[15:0] din_2_tmp1; 
   reg[15:0] din_1_tmp2; 
   reg[15:0] din_2_tmp2; 
   reg[15:0] addin_1; 
   reg[15:0] addin_2; 
   reg[16:0] add_out; 

   my_wrapper_divider my_div_inst_1 (nd, clk, din_1_tmp2, add_out, dout_1); 
   my_wrapper_divider my_div_inst_2 (nd, clk, din_2_tmp2, add_out, dout_2); 

   always @(posedge clk)
   begin
         if (nd == 1'b1)
         begin
            din_1_reg <= din_1 ; 
            din_2_reg <= din_2 ; 
         end 
         else
         begin
            din_1_reg <= din_1_reg ; 
            din_2_reg <= din_2_reg; 
         end 
         din_1_tmp1 <= din_1_reg ; 
         din_1_tmp2 <= din_1_tmp1 ; 
         din_2_tmp1 <= din_2_reg ; 
         din_2_tmp2 <= din_2_tmp1 ; 
         if ((din_1_reg[15]) == 1'b0)
         begin
            addin_1 <= din_1_reg ; 
         end
         else
         begin
            addin_1 <= 16'b0000000000000000 - din_1_reg ; 
         end 
         if ((din_2_reg[15]) == 1'b0)
         begin
            addin_2 <= din_2_reg + 16'b0000000000000001 ; 
         end
         else
         begin
            addin_2 <= 16'b0000000000000001 - din_2_reg ; 
         end 
         add_out <= ({addin_1[15], addin_1}) + ({addin_2[15], addin_2}) ; 
   end 
endmodule
