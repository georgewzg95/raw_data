
module fpu_sub( clk, rst, enable, opa, opb, fpu_op, sign, diff_2, exponent_2);
input		clk;
input		rst;
input		enable;
input	[63:0]	opa, opb;	  
input	[2:0]	fpu_op;
output		sign;
output	[55:0]	diff_2;
output	[10:0]	exponent_2;
		
reg [6:0] 	diff_shift;
reg [6:0] 	diff_shift_2;


reg   [10:0] exponent_a;
reg   [10:0] exponent_b;
reg   [51:0] mantissa_a;
reg   [51:0] mantissa_b;
reg   expa_gt_expb;
reg   expa_et_expb;
reg   mana_gtet_manb;
reg   a_gtet_b;
reg   sign;
reg   [10:0] exponent_small;
reg   [10:0] exponent_large;
reg   [51:0] mantissa_small;
reg   [51:0] mantissa_large;
reg   small_is_denorm;
reg   large_is_denorm;
reg   large_norm_small_denorm;
reg   small_is_nonzero;
reg   [10:0] exponent_diff;
reg   [54:0] minuend;
reg   [54:0] subtrahend;
reg   [54:0] subtra_shift;
wire   subtra_shift_nonzero = |subtra_shift[54:0];
wire   subtra_fraction_enable = small_is_nonzero & !subtra_shift_nonzero;
wire   [54:0] subtra_shift_2 = { 54'b0, 1'b1 };
reg   [54:0] subtra_shift_3;
reg   [54:0] diff;
reg   diffshift_gt_exponent;
reg   diffshift_et_55; // when the difference = 0
reg   [54:0] diff_1;
reg   [10:0] exponent;
reg   [10:0] exponent_2;
wire   in_norm_out_denorm = (exponent_large > 0) & (exponent== 0);
reg   [55:0] diff_2;
		

always @(posedge clk) 
	begin
		if (rst) begin
		exponent_a <= 0;
		exponent_b <= 0;
		mantissa_a <= 0;
		mantissa_b <= 0;
		expa_gt_expb <= 0;
		expa_et_expb <= 0;
		mana_gtet_manb <= 0;
   		a_gtet_b <= 0;
   		sign <= 0;
   		exponent_small  <= 0;
   		exponent_large  <= 0;
  		mantissa_small  <= 0;
   		mantissa_large  <= 0;
   		small_is_denorm <= 0;
   		large_is_denorm <= 0;
   		large_norm_small_denorm <= 0;
   		small_is_nonzero <= 0;
		exponent_diff <= 0;
		minuend <= 0;
		subtrahend <= 0;
		subtra_shift <= 0;
		subtra_shift_3 <= 0;
		diff_shift_2 <= 0;
		diff <= 0;
		diffshift_gt_exponent <= 0;
		diffshift_et_55 <= 0;
		diff_1 <= 0;
		exponent <= 0;
		exponent_2 <= 0;
		diff_2 <= 0;
		end
		else if (enable) begin
		exponent_a <= opa[62:52];
		exponent_b <= opb[62:52];
		mantissa_a <= opa[51:0];
		mantissa_b <= opb[51:0];
		expa_gt_expb <= exponent_a > exponent_b;
		expa_et_expb <= exponent_a == exponent_b;
		mana_gtet_manb <= mantissa_a >= mantissa_b;
   		a_gtet_b <= expa_gt_expb | (expa_et_expb & mana_gtet_manb);
   		sign <= a_gtet_b ? opa[63] :!opb[63] ^ (fpu_op == 3'b000);
   		exponent_small  <= a_gtet_b ? exponent_b : exponent_a;
   		exponent_large  <= a_gtet_b ? exponent_a : exponent_b;
  		mantissa_small  <= a_gtet_b ? mantissa_b : mantissa_a;
   		mantissa_large  <= a_gtet_b ? mantissa_a : mantissa_b;
   		small_is_denorm <= !(exponent_small > 0);
   		large_is_denorm <= !(exponent_large > 0);
   		large_norm_small_denorm <= (small_is_denorm == 1 && large_is_denorm == 0);
   		small_is_nonzero <= (exponent_small > 0) | |mantissa_small[51:0];
		exponent_diff <= exponent_large - exponent_small - large_norm_small_denorm;
		minuend <= { !large_is_denorm, mantissa_large, 2'b00 };
		subtrahend <= { !small_is_denorm, mantissa_small, 2'b00 };
		subtra_shift <= subtrahend >> exponent_diff;
		subtra_shift_3 <= subtra_fraction_enable ? subtra_shift_2 : subtra_shift;
		diff_shift_2 <= diff_shift;
		diff <= minuend - subtra_shift_3;
		diffshift_gt_exponent <= diff_shift_2 > exponent_large;
		diffshift_et_55 <= diff_shift_2 == 55; 
		diff_1 <= diffshift_gt_exponent ? diff << exponent_large : diff << diff_shift_2;
		exponent <= diffshift_gt_exponent ? 0 : (exponent_large - diff_shift_2);
		exponent_2 <= diffshift_et_55 ? 0 : exponent;
		diff_2 <= in_norm_out_denorm ? { 1'b0, diff_1 >> 1} : {1'b0, diff_1};
		
		end
	end

	
always @(diff)
   casex(diff)	
    55'b1??????????????????????????????????????????????????????: diff_shift <=  0;
	55'b01?????????????????????????????????????????????????????: diff_shift <=  1;
	55'b001????????????????????????????????????????????????????: diff_shift <=  2;
	55'b0001???????????????????????????????????????????????????: diff_shift <=  3;
	55'b00001??????????????????????????????????????????????????: diff_shift <=  4;
	55'b000001?????????????????????????????????????????????????: diff_shift <=  5;
	55'b0000001????????????????????????????????????????????????: diff_shift <=  6;
	55'b00000001???????????????????????????????????????????????: diff_shift <=  7;
	55'b000000001??????????????????????????????????????????????: diff_shift <=  8;
	55'b0000000001?????????????????????????????????????????????: diff_shift <=  9;
	55'b00000000001????????????????????????????????????????????: diff_shift <=  10;
	55'b000000000001???????????????????????????????????????????: diff_shift <=  11;
	55'b0000000000001??????????????????????????????????????????: diff_shift <=  12;
	55'b00000000000001?????????????????????????????????????????: diff_shift <=  13;
	55'b000000000000001????????????????????????????????????????: diff_shift <=  14;
	55'b0000000000000001???????????????????????????????????????: diff_shift <=  15;
	55'b00000000000000001??????????????????????????????????????: diff_shift <=  16;
	55'b000000000000000001?????????????????????????????????????: diff_shift <=  17;
	55'b0000000000000000001????????????????????????????????????: diff_shift <=  18;
	55'b00000000000000000001???????????????????????????????????: diff_shift <=  19;
	55'b000000000000000000001??????????????????????????????????: diff_shift <=  20;
	55'b0000000000000000000001?????????????????????????????????: diff_shift <=  21;
	55'b00000000000000000000001????????????????????????????????: diff_shift <=  22;
	55'b000000000000000000000001???????????????????????????????: diff_shift <=  23;
	55'b0000000000000000000000001??????????????????????????????: diff_shift <=  24;
	55'b00000000000000000000000001?????????????????????????????: diff_shift <=  25;
	55'b000000000000000000000000001????????????????????????????: diff_shift <=  26;
	55'b0000000000000000000000000001???????????????????????????: diff_shift <=  27;
	55'b00000000000000000000000000001??????????????????????????: diff_shift <=  28;
	55'b000000000000000000000000000001?????????????????????????: diff_shift <=  29;
	55'b0000000000000000000000000000001????????????????????????: diff_shift <=  30;
	55'b00000000000000000000000000000001???????????????????????: diff_shift <=  31;
	55'b000000000000000000000000000000001??????????????????????: diff_shift <=  32;
	55'b0000000000000000000000000000000001?????????????????????: diff_shift <=  33;
	55'b00000000000000000000000000000000001????????????????????: diff_shift <=  34;
	55'b000000000000000000000000000000000001???????????????????: diff_shift <=  35;
	55'b0000000000000000000000000000000000001??????????????????: diff_shift <=  36;
	55'b00000000000000000000000000000000000001?????????????????: diff_shift <=  37;
	55'b000000000000000000000000000000000000001????????????????: diff_shift <=  38;
	55'b0000000000000000000000000000000000000001???????????????: diff_shift <=  39;
	55'b00000000000000000000000000000000000000001??????????????: diff_shift <=  40;
	55'b000000000000000000000000000000000000000001?????????????: diff_shift <=  41;
	55'b0000000000000000000000000000000000000000001????????????: diff_shift <=  42;
	55'b00000000000000000000000000000000000000000001???????????: diff_shift <=  43;
	55'b000000000000000000000000000000000000000000001??????????: diff_shift <=  44;
	55'b0000000000000000000000000000000000000000000001?????????: diff_shift <=  45;
	55'b00000000000000000000000000000000000000000000001????????: diff_shift <=  46;
	55'b000000000000000000000000000000000000000000000001???????: diff_shift <=  47;
	55'b0000000000000000000000000000000000000000000000001??????: diff_shift <=  48;
    55'b00000000000000000000000000000000000000000000000001?????: diff_shift <=  49;
	55'b000000000000000000000000000000000000000000000000001????: diff_shift <=  50;
	55'b0000000000000000000000000000000000000000000000000001???: diff_shift <=  51;
	55'b00000000000000000000000000000000000000000000000000001??: diff_shift <=  52;
	55'b000000000000000000000000000000000000000000000000000001?: diff_shift <=  53;
	55'b0000000000000000000000000000000000000000000000000000001: diff_shift <=  54;
	55'b0000000000000000000000000000000000000000000000000000000: diff_shift <=  55;
	endcase	

	
	

endmodule
