/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FPU                                                        ////
////  Floating Point Unit (Double precision)                     ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

module fpu_add( clk, rst, enable, opa, opb, sign, sum_2, exponent_2);
input		clk;
input		rst;
input		enable;
input	[63:0]	opa, opb;
output		sign;
output  [55:0]	sum_2;
output	[10:0]	exponent_2;

reg   sign;
reg   [10:0] exponent_a;
reg   [10:0] exponent_b;
reg   [51:0] mantissa_a;
reg   [51:0] mantissa_b;
reg   expa_gt_expb;
reg   [10:0] exponent_small;
reg   [10:0] exponent_large;
reg   [51:0] mantissa_small;
reg   [51:0] mantissa_large;
reg   small_is_denorm;
reg   large_is_denorm;
reg   large_norm_small_denorm;
reg   [10:0] exponent_diff;
reg   [55:0] large_add;
reg   [55:0] small_add;
reg   [55:0] small_shift;
wire   small_shift_nonzero = |small_shift[55:0];
wire	small_is_nonzero = (exponent_small > 0) | |mantissa_small[51:0]; 
wire   small_fraction_enable = small_is_nonzero & !small_shift_nonzero;
wire   [55:0] small_shift_2 = { 55'b0, 1'b1 };
reg   [55:0] small_shift_3;
reg   [55:0] sum;
wire   sum_overflow = sum[55]; // sum[55] will be 0 if there was no carry from adding the 2 numbers
reg   [55:0] sum_2;
reg   [10:0] exponent;
wire   sum_leading_one = sum_2[54]; // this is where the leading one resides, unless denorm
reg   denorm_to_norm;
reg   [10:0] exponent_2;

always @(posedge clk) 
	begin
		if (rst) begin
			sign <= 0;
			exponent_a <= 0;
			exponent_b <= 0;
			mantissa_a <= 0;
			mantissa_b <= 0;
			expa_gt_expb <= 0;
			exponent_small  <= 0;
			exponent_large  <= 0;
			mantissa_small  <= 0;
			mantissa_large  <= 0;
			small_is_denorm <= 0;
			large_is_denorm <= 0;
			large_norm_small_denorm <= 0;
			exponent_diff <= 0;
			large_add <= 0;
			small_add <= 0;
			small_shift <= 0;
			small_shift_3 <= 0;
			sum <= 0;
			sum_2 <= 0;
			exponent <= 0;
			denorm_to_norm <= 0;
			exponent_2 <= 0;
		end
		else if (enable) begin
			sign <= opa[63];
			exponent_a <= opa[62:52];
			exponent_b <= opb[62:52];
			mantissa_a <= opa[51:0];
			mantissa_b <= opb[51:0];
			expa_gt_expb <= exponent_a > exponent_b;
			exponent_small  <= expa_gt_expb ? exponent_b : exponent_a;
			exponent_large  <= expa_gt_expb ? exponent_a : exponent_b;
			mantissa_small  <= expa_gt_expb ? mantissa_b : mantissa_a;
			mantissa_large  <= expa_gt_expb ? mantissa_a : mantissa_b;
			small_is_denorm <= !(exponent_small > 0);
			large_is_denorm <= !(exponent_large > 0);
			large_norm_small_denorm <= (small_is_denorm && !large_is_denorm);
			exponent_diff <= exponent_large - exponent_small - large_norm_small_denorm;
			large_add <= { 1'b0, !large_is_denorm, mantissa_large, 2'b0 };
			small_add <= { 1'b0, !small_is_denorm, mantissa_small, 2'b0 };
			small_shift <= small_add >> exponent_diff;
			small_shift_3 <= small_fraction_enable ? small_shift_2 : small_shift;
			sum <= large_add + small_shift_3;
			sum_2 <= sum_overflow ? sum >> 1 : sum;
			exponent <= sum_overflow ? exponent_large + 1: exponent_large;
			denorm_to_norm <= sum_leading_one & large_is_denorm;
			exponent_2 <= denorm_to_norm ? exponent + 1 : exponent;
		end
	end

endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FPU                                                        ////
////  Floating Point Unit (Double precision)                     ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1ns / 100ps

module fpu_div( clk, rst, enable, opa, opb, sign, mantissa_7,
exponent_out);
input		clk;
input		rst;
input		enable;
input	[63:0]	opa;
input	[63:0]	opb;
output		sign;
output	[55:0] mantissa_7;
output  [11:0] exponent_out;

parameter	preset  = 53;

reg [53:0] dividend_reg;
reg [53:0] divisor_reg;
reg enable_reg;
reg enable_reg_2;
reg enable_reg_a;
reg enable_reg_b;
reg enable_reg_c;
reg enable_reg_d;
reg enable_reg_e;
reg [5:0] 	dividend_shift;
reg [5:0] 	dividend_shift_2;
reg [5:0] 	divisor_shift;
reg [5:0] 	divisor_shift_2;
reg [5:0] 	count_out;
reg [11:0]  exponent_out;


wire   sign = opa[63] ^ opb[63];
reg [51:0] mantissa_a;
reg [51:0] mantissa_b;
wire [10:0] expon_a = opa[62:52];
wire [10:0] expon_b = opb[62:52];
wire	a_is_norm = |expon_a;
wire	b_is_norm = |expon_b;
wire	a_is_zero = !(|opa[62:0]); 
wire [11:0] exponent_a = { 1'b0, expon_a};
wire [11:0] exponent_b = { 1'b0, expon_b};
reg [51:0] dividend_a;
reg [51:0] dividend_a_shifted;
wire [52:0] dividend_denorm = { dividend_a_shifted, 1'b0};
wire [53:0]	dividend_1 = a_is_norm ? { 2'b01, dividend_a } : { 1'b0, dividend_denorm};
reg [51:0] divisor_b;
reg [51:0] divisor_b_shifted;
wire [52:0] divisor_denorm = { divisor_b_shifted, 1'b0};
wire [53:0]	divisor_1 = b_is_norm ? { 2'b01, divisor_b } : { 1'b0, divisor_denorm};
wire [5:0] count_index = count_out;
wire count_nonzero = !(count_index == 0);
reg [53:0] quotient;
reg	[53:0] quotient_out;
reg [53:0] remainder;
reg [53:0] remainder_out;
reg remainder_msb;
reg count_nonzero_reg;
reg count_nonzero_reg_2;
reg [11:0] expon_term;
reg expon_uf_1;
reg [11:0] expon_uf_term_1;
reg [11:0] expon_final_1;
reg [11:0] expon_final_2;
reg [11:0] expon_shift_a;
reg [11:0] expon_shift_b;
reg expon_uf_2;
reg [11:0] expon_uf_term_2;
reg [11:0] expon_uf_term_3;
reg expon_uf_gt_maxshift;
reg [11:0] expon_uf_term_4;
reg [11:0] expon_final_3;
reg [11:0] expon_final_4;
wire quotient_msb = quotient_out[53];
reg expon_final_4_et0;
reg expon_final_4_term;
reg [11:0] expon_final_5;
reg [51:0] mantissa_1;
wire [51:0] mantissa_2 = quotient_out[52:1];
wire [51:0] mantissa_3 = quotient_out[51:0];
wire [51:0] mantissa_4 = quotient_msb ? mantissa_2 : mantissa_3;
wire [51:0] mantissa_5 = (expon_final_4 == 1) ? mantissa_2 : mantissa_4;
wire [51:0] mantissa_6 = expon_final_4_et0 ? mantissa_1 : mantissa_5;
wire [107:0] remainder_a = { quotient_out[53:0] , remainder_msb, remainder_out[52:0]};
reg [6:0] remainder_shift_term;
reg [107:0] remainder_b;
wire [55:0] remainder_1 = remainder_b[107:52];
wire [55:0] remainder_2 = { quotient_out[0] , remainder_msb, remainder_out[52:0], 1'b0 };
wire [55:0] remainder_3 = { remainder_msb , remainder_out[52:0], 2'b0 };
wire [55:0] remainder_4 = quotient_msb ? remainder_2 : remainder_3;
wire [55:0] remainder_5 = (expon_final_4 == 1) ? remainder_2 : remainder_4;
wire [55:0] remainder_6 = expon_final_4_et0 ? remainder_1 : remainder_5;
wire	m_norm = |expon_final_5;
wire	rem_lsb = |remainder_6[54:0];	
wire [55:0] mantissa_7 = { 1'b0, m_norm, mantissa_6, remainder_6[55], rem_lsb };

always @ (posedge clk)
begin
	if (rst)
		exponent_out <= 0;
	else 
		exponent_out <= a_is_zero ? 12'b0 : expon_final_5; 
end

always @ (posedge clk)
begin
	if (rst)
		count_out <= 0;
	else if (enable_reg) 
		count_out <= preset;
	else if (count_nonzero)
		count_out <= count_out - 1; 
end

always @ (posedge clk)
begin
	if (rst) begin
		quotient_out <= 0;
		remainder_out <= 0;
		end
	else begin
		quotient_out <= quotient;
		remainder_out <= remainder;
		end
end


always @ (posedge clk)
begin
	if (rst) 
		quotient <= 0;
	else if (count_nonzero_reg)
		quotient[count_index] <= !(divisor_reg > dividend_reg);  
end

always @ (posedge clk)
begin
	if (rst) begin
		remainder <= 0;
		remainder_msb <= 0;
		end  
	else if (!count_nonzero_reg & count_nonzero_reg_2) begin	  
	    remainder <= dividend_reg;
		remainder_msb <= (divisor_reg > dividend_reg) ? 0 : 1;
		end
end

always @ (posedge clk)
begin
	if (rst) begin
		dividend_reg <= 0;
		divisor_reg <= 0;
		end
	else if (enable_reg_e) begin
		dividend_reg <= dividend_1;
		divisor_reg <= divisor_1;
		end
	else if (count_nonzero_reg)
		dividend_reg <= (divisor_reg > dividend_reg) ? dividend_reg << 1 : 
						(dividend_reg - divisor_reg) << 1; 
		// divisor doesn't change for the divide
end

always @ (posedge clk)
begin
	if (rst) begin
		expon_term  <= 0;
 		expon_uf_1 <= 0;
        expon_uf_term_1 <= 0;
        expon_final_1 <= 0;
        expon_final_2 <= 0;
        expon_shift_a <= 0;
        expon_shift_b <= 0;
 		expon_uf_2 <= 0;
        expon_uf_term_2 <= 0;
        expon_uf_term_3 <= 0;
 		expon_uf_gt_maxshift <= 0;
        expon_uf_term_4 <= 0;
        expon_final_3 <= 0;
        expon_final_4 <= 0;
 		expon_final_4_et0 <= 0;
 		expon_final_4_term <= 0;
        expon_final_5 <= 0;
        mantissa_a <= 0;
		mantissa_b <= 0;
		dividend_a <= 0;
		divisor_b <= 0;
		dividend_shift_2 <= 0;
		divisor_shift_2 <= 0;
		remainder_shift_term <= 0;
		remainder_b <= 0;
		dividend_a_shifted <= 0;
		divisor_b_shifted <=  0;
		mantissa_1 <= 0;
		end
	else if (enable_reg_2) begin
		expon_term  <= exponent_a + 1023;
 		expon_uf_1 <= exponent_b > expon_term;
        expon_uf_term_1 <= expon_uf_1 ? (exponent_b - expon_term) : 0;
        expon_final_1 <= expon_term - exponent_b;
        expon_final_2 <= expon_uf_1 ? 0 : expon_final_1;
        expon_shift_a <= a_is_norm ? 0 : dividend_shift_2;
        expon_shift_b <= b_is_norm ? 0 : divisor_shift_2;
 		expon_uf_2 <= expon_shift_a > expon_final_2;
        expon_uf_term_2 <= expon_uf_2 ? (expon_shift_a - expon_final_2) : 0;
        expon_uf_term_3 <= expon_uf_term_2 + expon_uf_term_1;
 		expon_uf_gt_maxshift <= (expon_uf_term_3 > 51);
        expon_uf_term_4 <= expon_uf_gt_maxshift ? 52 : expon_uf_term_3;
        expon_final_3 <= expon_uf_2 ? 0 : (expon_final_2 - expon_shift_a);
        expon_final_4 <= expon_final_3 + expon_shift_b;
 		expon_final_4_et0 <= (expon_final_4 == 0);
 		expon_final_4_term <= expon_final_4_et0 ? 0 : 1;
        expon_final_5 <= quotient_msb ? expon_final_4 : expon_final_4 - expon_final_4_term;
		mantissa_a <= opa[51:0];
		mantissa_b <= opb[51:0];
		dividend_a <= mantissa_a;
		divisor_b <= mantissa_b;
		dividend_shift_2 <= dividend_shift;
		divisor_shift_2 <= divisor_shift;
		remainder_shift_term <= 52 - expon_uf_term_4;
		remainder_b <= remainder_a << remainder_shift_term;
		dividend_a_shifted <= dividend_a << dividend_shift_2;
		divisor_b_shifted <= divisor_b << divisor_shift_2;
		mantissa_1 <= quotient_out[53:2] >> expon_uf_term_4;
		end
end

always @ (posedge clk)
begin
	if (rst) begin
		count_nonzero_reg <= 0;	
		count_nonzero_reg_2 <= 0;
		enable_reg <= 0;
		enable_reg_a <= 0;
		enable_reg_b <= 0;
		enable_reg_c <= 0;
		enable_reg_d <= 0;
		enable_reg_e <= 0;
		end
	else begin
		count_nonzero_reg <= count_nonzero;	 
		count_nonzero_reg_2 <= count_nonzero_reg;
		enable_reg <= enable_reg_e;
		enable_reg_a <= enable;
		enable_reg_b <= enable_reg_a;
		enable_reg_c <= enable_reg_b;
		enable_reg_d <= enable_reg_c;
		enable_reg_e <= enable_reg_d;
		end
end

always @ (posedge clk)
begin
	if (rst) 
		enable_reg_2 <= 0;
	else if (enable)
		enable_reg_2 <= 1;
end


always @(dividend_a)
   casex(dividend_a)
    52'b1???????????????????????????????????????????????????: dividend_shift <= 0;
    52'b01??????????????????????????????????????????????????: dividend_shift <= 1;
    52'b001?????????????????????????????????????????????????: dividend_shift <= 2;
    52'b0001????????????????????????????????????????????????: dividend_shift <= 3;
    52'b00001???????????????????????????????????????????????: dividend_shift <= 4;
    52'b000001??????????????????????????????????????????????: dividend_shift <= 5;
    52'b0000001?????????????????????????????????????????????: dividend_shift <= 6;
    52'b00000001????????????????????????????????????????????: dividend_shift <= 7;
	52'b000000001???????????????????????????????????????????: dividend_shift <= 8;
    52'b0000000001??????????????????????????????????????????: dividend_shift <= 9;
    52'b00000000001?????????????????????????????????????????: dividend_shift <= 10;
    52'b000000000001????????????????????????????????????????: dividend_shift <= 11;
    52'b0000000000001???????????????????????????????????????: dividend_shift <= 12;
    52'b00000000000001??????????????????????????????????????: dividend_shift <= 13;
    52'b000000000000001?????????????????????????????????????: dividend_shift <= 14;
    52'b0000000000000001????????????????????????????????????: dividend_shift <= 15;
    52'b00000000000000001???????????????????????????????????: dividend_shift <= 16;
    52'b000000000000000001??????????????????????????????????: dividend_shift <= 17;
    52'b0000000000000000001?????????????????????????????????: dividend_shift <= 18;
    52'b00000000000000000001????????????????????????????????: dividend_shift <= 19;
    52'b000000000000000000001???????????????????????????????: dividend_shift <= 20;
    52'b0000000000000000000001??????????????????????????????: dividend_shift <= 21;
    52'b00000000000000000000001?????????????????????????????: dividend_shift <= 22;
    52'b000000000000000000000001????????????????????????????: dividend_shift <= 23;
    52'b0000000000000000000000001???????????????????????????: dividend_shift <= 24;
    52'b00000000000000000000000001??????????????????????????: dividend_shift <= 25;
    52'b000000000000000000000000001?????????????????????????: dividend_shift <= 26;
    52'b0000000000000000000000000001????????????????????????: dividend_shift <= 27;
    52'b00000000000000000000000000001???????????????????????: dividend_shift <= 28;
    52'b000000000000000000000000000001??????????????????????: dividend_shift <= 29;
    52'b0000000000000000000000000000001?????????????????????: dividend_shift <= 30;
    52'b00000000000000000000000000000001????????????????????: dividend_shift <= 31;
    52'b000000000000000000000000000000001???????????????????: dividend_shift <= 32;
    52'b0000000000000000000000000000000001??????????????????: dividend_shift <= 33;
    52'b00000000000000000000000000000000001?????????????????: dividend_shift <= 34;
    52'b000000000000000000000000000000000001????????????????: dividend_shift <= 35;
    52'b0000000000000000000000000000000000001???????????????: dividend_shift <= 36;
    52'b00000000000000000000000000000000000001??????????????: dividend_shift <= 37;
    52'b000000000000000000000000000000000000001?????????????: dividend_shift <= 38;
    52'b0000000000000000000000000000000000000001????????????: dividend_shift <= 39;
    52'b00000000000000000000000000000000000000001???????????: dividend_shift <= 40;
    52'b000000000000000000000000000000000000000001??????????: dividend_shift <= 41;
    52'b0000000000000000000000000000000000000000001?????????: dividend_shift <= 42;
    52'b00000000000000000000000000000000000000000001????????: dividend_shift <= 43;
    52'b000000000000000000000000000000000000000000001???????: dividend_shift <= 44;
    52'b0000000000000000000000000000000000000000000001??????: dividend_shift <= 45;
    52'b00000000000000000000000000000000000000000000001?????: dividend_shift <= 46;
    52'b000000000000000000000000000000000000000000000001????: dividend_shift <= 47;
    52'b0000000000000000000000000000000000000000000000001???: dividend_shift <= 48;
    52'b00000000000000000000000000000000000000000000000001??: dividend_shift <= 49;
    52'b000000000000000000000000000000000000000000000000001?: dividend_shift <= 50;
    52'b0000000000000000000000000000000000000000000000000001: dividend_shift <= 51;
    52'b0000000000000000000000000000000000000000000000000000: dividend_shift <= 52;
    
    endcase
    
always @(divisor_b)
   casex(divisor_b)
    52'b1???????????????????????????????????????????????????: divisor_shift <= 0;
    52'b01??????????????????????????????????????????????????: divisor_shift <= 1;
    52'b001?????????????????????????????????????????????????: divisor_shift <= 2;
    52'b0001????????????????????????????????????????????????: divisor_shift <= 3;
    52'b00001???????????????????????????????????????????????: divisor_shift <= 4;
    52'b000001??????????????????????????????????????????????: divisor_shift <= 5;
    52'b0000001?????????????????????????????????????????????: divisor_shift <= 6;
    52'b00000001????????????????????????????????????????????: divisor_shift <= 7;
	52'b000000001???????????????????????????????????????????: divisor_shift <= 8;
    52'b0000000001??????????????????????????????????????????: divisor_shift <= 9;
    52'b00000000001?????????????????????????????????????????: divisor_shift <= 10;
    52'b000000000001????????????????????????????????????????: divisor_shift <= 11;
    52'b0000000000001???????????????????????????????????????: divisor_shift <= 12;
    52'b00000000000001??????????????????????????????????????: divisor_shift <= 13;
    52'b000000000000001?????????????????????????????????????: divisor_shift <= 14;
    52'b0000000000000001????????????????????????????????????: divisor_shift <= 15;
    52'b00000000000000001???????????????????????????????????: divisor_shift <= 16;
    52'b000000000000000001??????????????????????????????????: divisor_shift <= 17;
    52'b0000000000000000001?????????????????????????????????: divisor_shift <= 18;
    52'b00000000000000000001????????????????????????????????: divisor_shift <= 19;
    52'b000000000000000000001???????????????????????????????: divisor_shift <= 20;
    52'b0000000000000000000001??????????????????????????????: divisor_shift <= 21;
    52'b00000000000000000000001?????????????????????????????: divisor_shift <= 22;
    52'b000000000000000000000001????????????????????????????: divisor_shift <= 23;
    52'b0000000000000000000000001???????????????????????????: divisor_shift <= 24;
    52'b00000000000000000000000001??????????????????????????: divisor_shift <= 25;
    52'b000000000000000000000000001?????????????????????????: divisor_shift <= 26;
    52'b0000000000000000000000000001????????????????????????: divisor_shift <= 27;
    52'b00000000000000000000000000001???????????????????????: divisor_shift <= 28;
    52'b000000000000000000000000000001??????????????????????: divisor_shift <= 29;
    52'b0000000000000000000000000000001?????????????????????: divisor_shift <= 30;
    52'b00000000000000000000000000000001????????????????????: divisor_shift <= 31;
    52'b000000000000000000000000000000001???????????????????: divisor_shift <= 32;
    52'b0000000000000000000000000000000001??????????????????: divisor_shift <= 33;
    52'b00000000000000000000000000000000001?????????????????: divisor_shift <= 34;
    52'b000000000000000000000000000000000001????????????????: divisor_shift <= 35;
    52'b0000000000000000000000000000000000001???????????????: divisor_shift <= 36;
    52'b00000000000000000000000000000000000001??????????????: divisor_shift <= 37;
    52'b000000000000000000000000000000000000001?????????????: divisor_shift <= 38;
    52'b0000000000000000000000000000000000000001????????????: divisor_shift <= 39;
    52'b00000000000000000000000000000000000000001???????????: divisor_shift <= 40;
    52'b000000000000000000000000000000000000000001??????????: divisor_shift <= 41;
    52'b0000000000000000000000000000000000000000001?????????: divisor_shift <= 42;
    52'b00000000000000000000000000000000000000000001????????: divisor_shift <= 43;
    52'b000000000000000000000000000000000000000000001???????: divisor_shift <= 44;
    52'b0000000000000000000000000000000000000000000001??????: divisor_shift <= 45;
    52'b00000000000000000000000000000000000000000000001?????: divisor_shift <= 46;
    52'b000000000000000000000000000000000000000000000001????: divisor_shift <= 47;
    52'b0000000000000000000000000000000000000000000000001???: divisor_shift <= 48;
    52'b00000000000000000000000000000000000000000000000001??: divisor_shift <= 49;
    52'b000000000000000000000000000000000000000000000000001?: divisor_shift <= 50;
    52'b0000000000000000000000000000000000000000000000000001: divisor_shift <= 51;
    52'b0000000000000000000000000000000000000000000000000000: divisor_shift <= 52;
    
    endcase
    
endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FPU                                                        ////
////  Floating Point Unit (Double precision)                     ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1ns / 100ps
/* FPU Operations (fpu_op):
========================
0 = add
1 = sub
2 = mul
3 = div

Rounding Modes (rmode):
=======================
0 = round_nearest_even
1 = round_to_zero
2 = round_up
3 = round_down  */

module fpu( clk, rst, enable, rmode, fpu_op, opa, opb, out, ready, underflow,
overflow, inexact, exception, invalid);
input		clk;
input		rst;
input		enable;
input	[1:0]	rmode;
input	[2:0]	fpu_op;
input	[63:0]	opa, opb;
output	[63:0]	out;
output		ready;
output		underflow;
output		overflow;
output		inexact;
output		exception;
output		invalid;
	
reg [63:0]	opa_reg;
reg [63:0]	opb_reg;
reg [2:0]	fpu_op_reg;
reg [1:0]	rmode_reg;
reg			enable_reg;
reg			enable_reg_1; // high for one clock cycle
reg			enable_reg_2; // high for one clock cycle		 
reg			enable_reg_3; // high for two clock cycles
reg			op_enable;	  
reg [63:0]	out;
reg [6:0] 	count_cycles;
reg [6:0]	count_ready;
wire		count_busy = (count_ready <= count_cycles);
reg			ready;
reg			ready_0;
reg			ready_1;
reg		underflow;
reg		overflow;
reg		inexact;
reg		exception;
reg		invalid;
wire		underflow_0;
wire		overflow_0;
wire		inexact_0;
wire		exception_0;
wire		invalid_0;

wire	add_enable_0 = (fpu_op_reg == 3'b000) & !(opa_reg[63] ^ opb_reg[63]);
wire	add_enable_1 = (fpu_op_reg == 3'b001) & (opa_reg[63] ^ opb_reg[63]);
reg		add_enable; 
wire	sub_enable_0 = (fpu_op_reg == 3'b000) & (opa_reg[63] ^ opb_reg[63]);
wire	sub_enable_1 = (fpu_op_reg == 3'b001) & !(opa_reg[63] ^ opb_reg[63]);
reg		sub_enable; 
reg		mul_enable; 
reg		div_enable; 
wire	[55:0]	sum_out;
wire	[55:0]	diff_out;
reg		[55:0]	addsub_out;
wire	[55:0]	mul_out;
wire	[55:0]	div_out;
reg		[55:0]	mantissa_round;
wire	[10:0] 	exp_add_out;
wire	[10:0] 	exp_sub_out;
wire	[11:0] 	exp_mul_out;
wire	[11:0] 	exp_div_out;
reg		[11:0] 	exponent_round;
reg		[11:0] 	exp_addsub;
wire	[11:0]	exponent_post_round;
wire	add_sign;
wire	sub_sign;
wire	mul_sign;
wire	div_sign;
reg		addsub_sign;
reg		sign_round;
wire	[63:0]	out_round;
wire	[63:0]	out_except;

fpu_add u1(
	.clk(clk),.rst(rst),.enable(add_enable),.opa(opa_reg),.opb(opb_reg),
	.sign(add_sign),.sum_2(sum_out),.exponent_2(exp_add_out));

fpu_sub u2(
	.clk(clk),.rst(rst),.enable(sub_enable),.opa(opa_reg),.opb(opb_reg),
	.fpu_op(fpu_op_reg),.sign(sub_sign),.diff_2(diff_out),
	.exponent_2(exp_sub_out));

fpu_mul u3(
	.clk(clk),.rst(rst),.enable(mul_enable),.opa(opa_reg),.opb(opb_reg),
	.sign(mul_sign),.product_7(mul_out),.exponent_5(exp_mul_out));	

fpu_div u4(
	.clk(clk),.rst(rst),.enable(div_enable),.opa(opa_reg),.opb(opb_reg),
	.sign(div_sign),.mantissa_7(div_out),.exponent_out(exp_div_out));	

fpu_round u5(.clk(clk),.rst(rst),.enable(op_enable),	.round_mode(rmode_reg),
	.sign_term(sign_round),.mantissa_term(mantissa_round), .exponent_term(exponent_round),
	.round_out(out_round),.exponent_final(exponent_post_round));		
	
fpu_exceptions u6(.clk(clk),.rst(rst),.enable(op_enable),.rmode(rmode_reg),
	.opa(opa_reg),.opb(opb_reg),
	.in_except(out_round), .exponent_in(exponent_post_round),
	.mantissa_in(mantissa_round[1:0]),.fpu_op(fpu_op_reg),.out(out_except),
	.ex_enable(except_enable),.underflow(underflow_0),.overflow(overflow_0),
	.inexact(inexact_0),.exception(exception_0),.invalid(invalid_0));
		
	
always @(posedge clk)
begin
	case (fpu_op_reg)
	3'b000:		mantissa_round <= addsub_out;
	3'b001:		mantissa_round <= addsub_out;
	3'b010:		mantissa_round <= mul_out;
	3'b011:		mantissa_round <= div_out;
	default:	mantissa_round <= 0;
	endcase
end

always @(posedge clk)
begin
	case (fpu_op_reg)
	3'b000:		exponent_round <= exp_addsub;
	3'b001:		exponent_round <= exp_addsub;
	3'b010:		exponent_round <= exp_mul_out;
	3'b011:		exponent_round <= exp_div_out;
	default:	exponent_round <= 0;
	endcase
end

always @(posedge clk)
begin
	case (fpu_op_reg)
	3'b000:		sign_round <= addsub_sign;
	3'b001:		sign_round <= addsub_sign;
	3'b010:		sign_round <= mul_sign;
	3'b011:		sign_round <= div_sign;
	default:	sign_round <= 0;
	endcase
end

always @(posedge clk)
begin
	case (fpu_op_reg)
	3'b000:		count_cycles <= 20;
	3'b001:		count_cycles <= 21;
	3'b010:		count_cycles <= 24;
	3'b011:		count_cycles <= 71; 
	default:	count_cycles <= 0;
	endcase
end

always @(posedge clk)
begin
	if (rst) begin
		add_enable <= 0;
		sub_enable <= 0;
		mul_enable <= 0;
		div_enable <= 0;
		addsub_out <= 0;
		addsub_sign <= 0;
		exp_addsub <= 0;
		end
	else begin
		add_enable <= (add_enable_0 | add_enable_1) & op_enable;
		sub_enable <= (sub_enable_0 | sub_enable_1) & op_enable;
		mul_enable <= (fpu_op_reg == 3'b010) & op_enable;
		div_enable <= (fpu_op_reg == 3'b011) & op_enable & enable_reg_3;
			// div_enable needs to be high for two clock cycles
		addsub_out <= add_enable ? sum_out : diff_out;
		addsub_sign <= add_enable ? add_sign : sub_sign;
		exp_addsub <= add_enable ? { 1'b0, exp_add_out} : { 1'b0, exp_sub_out};
		end
end 

always @ (posedge clk)
begin
	if (rst)
		count_ready <= 0;
	else if (enable_reg_1) 
		count_ready <= 0;
	else if (count_busy)
		count_ready <= count_ready + 1; 
end

always @(posedge clk)
begin
	if (rst) begin
		enable_reg <= 0;
		enable_reg_1 <= 0;
		enable_reg_2 <= 0;	   
		enable_reg_3 <= 0;
		end
	else begin
		enable_reg <= enable;
		enable_reg_1 <= enable & !enable_reg;
		enable_reg_2 <= enable_reg_1;  
		enable_reg_3 <= enable_reg_1 | enable_reg_2;
		end
end 
		
always @(posedge clk) 
begin
	if (rst) begin
		opa_reg <= 0;
		opb_reg <= 0;
		fpu_op_reg <= 0; 
		rmode_reg <= 0;
		op_enable <= 0;
		end
	else if (enable_reg_1) begin
		opa_reg <= opa;
		opb_reg <= opb;
		fpu_op_reg <= fpu_op; 
		rmode_reg <= rmode;
		op_enable <= 1;
		end
end

always @(posedge clk)
begin
	if (rst) begin
		ready_0 <= 0;
		ready_1 <= 0;
		ready <= 0;	   
		end
	else if (enable_reg_1) begin
		ready_0 <= 0;
		ready_1 <= 0;
		ready <= 0;	 
		end
	else begin
		ready_0 <= !count_busy;
		ready_1 <= ready_0;
		ready <= ready_1;  
		end
end 

always @(posedge clk)
begin
	if (rst) begin
		underflow <= 0;
		overflow <= 0;
		inexact <= 0;
		exception <= 0;
		invalid <= 0;	   	 
		out <= 0;
		end
	else if (ready_1) begin
		underflow <= underflow_0;
		overflow <= overflow_0;
		inexact <= inexact_0;
		exception <= exception_0;
		invalid <= invalid_0; 	
		out <= except_enable ? out_except : out_round;
		end
end 
endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FPU                                                        ////
////  Floating Point Unit (Double precision)                     ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1ns / 100ps

module fpu_exceptions( clk, rst, enable, rmode, opa, opb, in_except,
exponent_in, mantissa_in, fpu_op, out, ex_enable, underflow, overflow, 
inexact, exception, invalid);
input		clk;
input		rst;
input		enable;
input	[1:0]	rmode;
input	[63:0]	opa;
input	[63:0]	opb;
input	[63:0]	in_except;
input	[11:0]	exponent_in;
input	[1:0]	mantissa_in;
input	[2:0]	fpu_op;
output	[63:0]	out;
output		ex_enable;
output		underflow;
output		overflow;
output		inexact;
output		exception;
output		invalid;

reg		[63:0]	out;
reg		ex_enable;
reg		underflow;
reg		overflow;
reg		inexact;
reg		exception;
reg		invalid;

reg		in_et_zero;
reg		opa_et_zero;
reg		opb_et_zero;
reg		input_et_zero;
reg		add;
reg		subtract;
reg		multiply;
reg		divide;
reg		opa_QNaN;
reg		opb_QNaN;
reg		opa_SNaN;
reg		opb_SNaN;
reg		opa_pos_inf;
reg		opb_pos_inf;
reg		opa_neg_inf;
reg		opb_neg_inf;
reg		opa_inf;
reg		opb_inf;
reg		NaN_input;
reg		SNaN_input;
reg		a_NaN;
reg		div_by_0;
reg		div_0_by_0;
reg		div_inf_by_inf;
reg		div_by_inf;
reg		mul_0_by_inf;
reg		mul_inf;
reg		div_inf;
reg		add_inf;
reg		sub_inf;
reg		addsub_inf_invalid;
reg		addsub_inf;
reg		out_inf_trigger;
reg		out_pos_inf;
reg		out_neg_inf;
reg		round_nearest;
reg		round_to_zero;
reg		round_to_pos_inf;
reg		round_to_neg_inf;
reg		inf_round_down_trigger;
reg		mul_uf;
reg		div_uf;								
reg		underflow_trigger;			
reg		invalid_trigger;
reg		overflow_trigger;
reg		inexact_trigger;
reg	 	except_trigger;
reg		enable_trigger;
reg		NaN_out_trigger;
reg		SNaN_trigger;


wire	[10:0]  exp_2047 = 11'b11111111111;
wire	[10:0]  exp_2046 = 11'b11111111110;
reg		[62:0] NaN_output_0; 
reg		[62:0] NaN_output; 
wire	[51:0]  mantissa_max = 52'b1111111111111111111111111111111111111111111111111111;
reg		[62:0]	inf_round_down;
reg		[62:0]	out_inf;
reg		[63:0]	out_0;
reg		[63:0]	out_1;
reg		[63:0]	out_2;

always @(posedge clk)
begin
	if (rst) begin
		in_et_zero <=    0;
		opa_et_zero <=   0;
		opb_et_zero <=   0;
		input_et_zero <= 0;
		add 	<= 	0;
		subtract <= 0;
		multiply <= 0;
		divide 	<= 	0;
		opa_QNaN <= 0;
		opb_QNaN <= 0;
		opa_SNaN <= 0;
		opb_SNaN <= 0;
		opa_pos_inf <= 0;
		opb_pos_inf <= 0;
		opa_neg_inf <= 0;
		opb_neg_inf <= 0; 
		opa_inf <= 0;
		opb_inf <= 0;
		NaN_input <= 0; 
		SNaN_input <= 0;
		a_NaN <= 0;
		div_by_0 <= 0;
		div_0_by_0 <= 0;
		div_inf_by_inf <= 0;
		div_by_inf <= 0;
		mul_0_by_inf <= 0;
		mul_inf <= 0;
		div_inf <= 0;
		add_inf <= 0;
		sub_inf <= 0;
		addsub_inf_invalid <= 0;
		addsub_inf <= 0;
		out_inf_trigger <= 0;
		out_pos_inf <= 0;
		out_neg_inf <= 0;
		round_nearest <= 0;
		round_to_zero <= 0;
		round_to_pos_inf <= 0;
		round_to_neg_inf <= 0;
		inf_round_down_trigger <= 0;
		mul_uf <= 0;
		div_uf <= 0;															
		underflow_trigger <= 0;		
		invalid_trigger <= 0;
		overflow_trigger <= 0;
		inexact_trigger <= 0;
		except_trigger <= 0;
		enable_trigger <= 0;
		NaN_out_trigger <= 0;
		SNaN_trigger <= 0;
		NaN_output_0 <= 0;
		NaN_output <= 0;
		inf_round_down <= 0;
		out_inf <= 0;
		out_0 <= 0;
		out_1 <= 0;
		out_2 <= 0;
		end
	else if (enable) begin
		in_et_zero <= !(|in_except[62:0]);
		opa_et_zero <= !(|opa[62:0]);
		opb_et_zero <= !(|opb[62:0]);
		input_et_zero <= !(|in_except[62:0]);	
		add 	<= 	fpu_op == 3'b000;
		subtract <= 	fpu_op == 3'b001;
		multiply <= 	fpu_op == 3'b010;
		divide 	<= 	fpu_op == 3'b011;
		opa_QNaN <= (opa[62:52] == 2047) & |opa[51:0] & opa[51];
		opb_QNaN <= (opb[62:52] == 2047) & |opb[51:0] & opb[51];
		opa_SNaN <= (opa[62:52] == 2047) & |opa[51:0] & !opa[51];
		opb_SNaN <= (opb[62:52] == 2047) & |opb[51:0] & !opb[51];
		opa_pos_inf <= !opa[63] & (opa[62:52] == 2047) & !(|opa[51:0]);
		opb_pos_inf <= !opb[63] & (opb[62:52] == 2047) & !(|opb[51:0]);
		opa_neg_inf <= opa[63] & (opa[62:52] == 2047) & !(|opa[51:0]);
		opb_neg_inf <= opb[63] & (opb[62:52] == 2047) & !(|opb[51:0]);
		opa_inf <= (opa[62:52] == 2047) & !(|opa[51:0]);
		opb_inf <= (opb[62:52] == 2047) & !(|opb[51:0]);
		NaN_input <= opa_QNaN | opb_QNaN | opa_SNaN | opb_SNaN;
		SNaN_input <= opa_SNaN | opb_SNaN;
		a_NaN <= opa_QNaN | opa_SNaN;
		div_by_0 <= divide & opb_et_zero & !opa_et_zero;
		div_0_by_0 <= divide & opb_et_zero & opa_et_zero;
		div_inf_by_inf <= divide & opa_inf & opb_inf;
		div_by_inf <= divide & !opa_inf & opb_inf;
		mul_0_by_inf <= multiply & ((opa_inf & opb_et_zero) | (opa_et_zero & opb_inf));
		mul_inf <= multiply & (opa_inf | opb_inf) & !mul_0_by_inf;
		div_inf <= divide & opa_inf & !opb_inf;
		add_inf <= (add & (opa_inf | opb_inf));
		sub_inf <= (subtract & (opa_inf | opb_inf));
		addsub_inf_invalid <= (add & opa_pos_inf & opb_neg_inf) | (add & opa_neg_inf & opb_pos_inf) | 
					(subtract & opa_pos_inf & opb_pos_inf) | (subtract & opa_neg_inf & opb_neg_inf);
		addsub_inf <= (add_inf | sub_inf) & !addsub_inf_invalid;
		out_inf_trigger <= addsub_inf | mul_inf | div_inf | div_by_0 | (exponent_in > 2046);
		out_pos_inf <= out_inf_trigger & !in_except[63];
		out_neg_inf <= out_inf_trigger & in_except[63];
		round_nearest <= (rmode == 2'b00);
		round_to_zero <= (rmode == 2'b01);
		round_to_pos_inf <= (rmode == 2'b10);
		round_to_neg_inf <= (rmode == 2'b11);
		inf_round_down_trigger <= (out_pos_inf & round_to_neg_inf) | 
								(out_neg_inf & round_to_pos_inf) |
								(out_inf_trigger & round_to_zero);
		mul_uf <= multiply & !opa_et_zero & !opb_et_zero & in_et_zero;
		div_uf <= divide & !opa_et_zero & in_et_zero;																
		underflow_trigger <= div_by_inf | mul_uf | div_uf;								
		invalid_trigger <= SNaN_input | addsub_inf_invalid | mul_0_by_inf |
						div_0_by_0 | div_inf_by_inf;
		overflow_trigger <= out_inf_trigger & !NaN_input;
		inexact_trigger <= (|mantissa_in[1:0] | out_inf_trigger | underflow_trigger) &
						!NaN_input;
		except_trigger <= invalid_trigger | overflow_trigger | underflow_trigger |
						inexact_trigger;
		enable_trigger <= except_trigger | out_inf_trigger | NaN_input;	
		NaN_out_trigger <= NaN_input | invalid_trigger;
		SNaN_trigger <= invalid_trigger & !SNaN_input;
		NaN_output_0 <= a_NaN ? { exp_2047, 1'b1, opa[50:0]} : { exp_2047, 1'b1, opb[50:0]};
		NaN_output <= SNaN_trigger ? { exp_2047, 2'b01, opa[49:0]} : NaN_output_0;
		inf_round_down <= { exp_2046, mantissa_max };
		out_inf <= inf_round_down_trigger ? inf_round_down : { exp_2047, 52'b0 };
		out_0 <= underflow_trigger ? { in_except[63], 63'b0 } : in_except;
		out_1 <= out_inf_trigger ? { in_except[63], out_inf } : out_0;
		out_2 <= NaN_out_trigger ? { in_except[63], NaN_output} : out_1;
		end
end 

always @(posedge clk)
begin
	if (rst) begin
		ex_enable <= 0;
		underflow <= 0;
		overflow <= 0;	   
		inexact <= 0;
		exception <= 0;
		invalid <= 0;
		out <= 0;
		end
	else if (enable) begin
		ex_enable <= enable_trigger;
		underflow <= underflow_trigger;
		overflow <= overflow_trigger;	   
		inexact <= inexact_trigger;
		exception <= except_trigger;
		invalid <= invalid_trigger;
		out <= out_2;
		end
end 
    
endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FPU                                                        ////
////  Floating Point Unit (Double precision)                     ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1ns / 100ps

module fpu_mul( clk, rst, enable, opa, opb, sign, product_7, exponent_5);
input		clk;
input		rst;
input		enable;
input	[63:0]	opa, opb;
output		sign;
output  [55:0] product_7;
output  [11:0] exponent_5;

reg [5:0] 	product_shift;
reg [5:0] 	product_shift_2;


reg   sign;
reg   [51:0] mantissa_a;
reg   [51:0] mantissa_b;
reg   [10:0] exponent_a;
reg   [10:0] exponent_b;
reg		a_is_norm;
reg		b_is_norm;
reg		a_is_zero; 
reg		b_is_zero; 
reg		in_zero;
reg   [11:0] exponent_terms;
reg    exponent_gt_expoffset;
reg   [11:0] exponent_under;
reg   [11:0] exponent_1;
wire   [11:0] exponent = 0;
reg   [11:0] exponent_2;
reg   exponent_gt_prodshift;
reg   [11:0] exponent_3;
reg   [11:0] exponent_4;
reg  exponent_et_zero;
reg   [52:0] mul_a;
reg   [52:0] mul_b;
reg		[40:0] product_a;
reg		[40:0] product_b;
reg		[40:0] product_c;
reg		[25:0] product_d;
reg		[33:0] product_e;
reg		[33:0] product_f;
reg		[35:0] product_g;
reg		[28:0] product_h;
reg		[28:0] product_i;
reg		[30:0] product_j;
reg		[41:0] sum_0;
reg		[35:0] sum_1;
reg		[41:0] sum_2;
reg		[35:0] sum_3;
reg		[36:0] sum_4;
reg		[27:0] sum_5;
reg		[29:0] sum_6;
reg		[36:0] sum_7;
reg		[30:0] sum_8;
reg   [105:0] product;
reg   [105:0] product_1;
reg   [105:0] product_2;
reg   [105:0] product_3;
reg   [105:0] product_4; 
reg   [105:0] product_5;
reg   [105:0] product_6;
reg		product_lsb; // if there are any 1's in the remainder
wire  [55:0] product_7 =  { 1'b0, product_6[105:52], product_lsb }; 
reg  [11:0] exponent_5;		

always @(posedge clk) 
begin
	if (rst) begin
		sign <= 0;
		mantissa_a <= 0;
		mantissa_b <= 0;
		exponent_a <= 0;
		exponent_b <= 0;
		a_is_norm <= 0;
		b_is_norm <= 0;
		a_is_zero <= 0; 
		b_is_zero <= 0; 
		in_zero <= 0;
		exponent_terms <= 0;
		exponent_gt_expoffset <= 0;
		exponent_under <= 0;
		exponent_1 <= 0; 
		exponent_2 <= 0;
		exponent_gt_prodshift <= 0;
		exponent_3 <= 0;
		exponent_4 <= 0;
		exponent_et_zero <= 0;
		mul_a <= 0; 
		mul_b <= 0;
		product_a <= 0;
		product_b <= 0;
		product_c <= 0;
		product_d <= 0;
		product_e <= 0;
		product_f <= 0;
		product_g <= 0;
		product_h <= 0;
		product_i <= 0;
		product_j <= 0;
		sum_0 <= 0;
		sum_1 <= 0;
		sum_2 <= 0;
		sum_3 <= 0;
		sum_4 <= 0;
		sum_5 <= 0;
		sum_6 <= 0;
		sum_7 <= 0;
		sum_8 <= 0;
		product <= 0;
		product_1 <= 0;
		product_2 <= 0; 
		product_3 <= 0;
		product_4 <= 0;
		product_5 <= 0; 
		product_6 <= 0;
		product_lsb <= 0;
		exponent_5 <= 0;
		product_shift_2 <= 0;
	end
	else if (enable) begin
		sign <= opa[63] ^ opb[63];
		mantissa_a <= opa[51:0];
		mantissa_b <= opb[51:0];
		exponent_a <= opa[62:52];
		exponent_b <= opb[62:52];
		a_is_norm <= |exponent_a;
		b_is_norm <= |exponent_b;
		a_is_zero <= !(|opa[62:0]); 
		b_is_zero <= !(|opb[62:0]); 
		in_zero <= a_is_zero | b_is_zero;
		exponent_terms <= exponent_a + exponent_b + !a_is_norm + !b_is_norm;
		exponent_gt_expoffset <= exponent_terms > 1021;
		exponent_under <= 1022 - exponent_terms;
		exponent_1 <= exponent_terms - 1022; 
		exponent_2 <= exponent_gt_expoffset ? exponent_1 : exponent;
		exponent_gt_prodshift <= exponent_2 > product_shift_2;
		exponent_3 <= exponent_2 - product_shift;
		exponent_4 <= exponent_gt_prodshift ? exponent_3 : exponent;
		exponent_et_zero <= exponent_4 == 0;
		mul_a <= { a_is_norm, mantissa_a };
		mul_b <= { b_is_norm, mantissa_b };
		product_a <= mul_a[23:0] * mul_b[16:0];
		product_b <= mul_a[23:0] * mul_b[33:17];
		product_c <= mul_a[23:0] * mul_b[50:34];
		product_d <= mul_a[23:0] * mul_b[52:51];
		product_e <= mul_a[40:24] * mul_b[16:0];
		product_f <= mul_a[40:24] * mul_b[33:17];
		product_g <= mul_a[40:24] * mul_b[52:34];
		product_h <= mul_a[52:41] * mul_b[16:0];
		product_i <= mul_a[52:41] * mul_b[33:17];
		product_j <= mul_a[52:41] * mul_b[52:34];
		sum_0 <= product_a[40:17] + product_b;
		sum_1 <= sum_0[41:7] + product_e;
		sum_2 <= sum_1[35:10] + product_c;
		sum_3 <= sum_2[41:7] + product_h;
		sum_4 <= sum_3 + product_f;
		sum_5 <= sum_4[36:10] + product_d;
		sum_6 <= sum_5[27:7] + product_i;
		sum_7 <= sum_6 + product_g;
		sum_8 <= sum_7[36:17] + product_j;
		product <= { sum_8, sum_7[16:0], sum_5[6:0], sum_4[9:0], sum_2[6:0],
					sum_1[9:0], sum_0[6:0], product_a[16:0] };
		product_1 <= product >> exponent_under;
		product_2 <= exponent_gt_expoffset ? product : product_1; 
		product_3 <= product_2 << product_shift_2;
		product_4 <= product_2 << exponent_2;
		product_5 <= exponent_gt_prodshift ? product_3  : product_4;
		product_6 <= exponent_et_zero ? product_5 >> 1 : product_5;
		product_lsb <= |product_6[51:0];
		exponent_5 <= in_zero ? 12'b0 : exponent_4;
		product_shift_2 <= product_shift; // redundant register
			// reduces fanout on product_shift
	end
end

always @(product)
   casex(product)	
    106'b1?????????????????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  0;
	106'b01????????????????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  1;
	106'b001???????????????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  2;
	106'b0001??????????????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  3;
	106'b00001?????????????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  4;
	106'b000001????????????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  5;
	106'b0000001???????????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  6;
	106'b00000001??????????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  7;
	106'b000000001?????????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  8;
	106'b0000000001????????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  9;
	106'b00000000001???????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  10;
	106'b000000000001??????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  11;
	106'b0000000000001?????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  12;
	106'b00000000000001????????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  13;
	106'b000000000000001???????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  14;
	106'b0000000000000001??????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  15;
	106'b00000000000000001?????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  16;
	106'b000000000000000001????????????????????????????????????????????????????????????????????????????????????????: product_shift <=  17;
	106'b0000000000000000001???????????????????????????????????????????????????????????????????????????????????????: product_shift <=  18;
	106'b00000000000000000001??????????????????????????????????????????????????????????????????????????????????????: product_shift <=  19;
	106'b000000000000000000001?????????????????????????????????????????????????????????????????????????????????????: product_shift <=  20;
	106'b0000000000000000000001????????????????????????????????????????????????????????????????????????????????????: product_shift <=  21;
	106'b00000000000000000000001???????????????????????????????????????????????????????????????????????????????????: product_shift <=  22;
	106'b000000000000000000000001??????????????????????????????????????????????????????????????????????????????????: product_shift <=  23;
	106'b0000000000000000000000001?????????????????????????????????????????????????????????????????????????????????: product_shift <=  24;
	106'b00000000000000000000000001????????????????????????????????????????????????????????????????????????????????: product_shift <=  25;
	106'b000000000000000000000000001???????????????????????????????????????????????????????????????????????????????: product_shift <=  26;
	106'b0000000000000000000000000001??????????????????????????????????????????????????????????????????????????????: product_shift <=  27;
	106'b00000000000000000000000000001?????????????????????????????????????????????????????????????????????????????: product_shift <=  28;
	106'b000000000000000000000000000001????????????????????????????????????????????????????????????????????????????: product_shift <=  29;
	106'b0000000000000000000000000000001???????????????????????????????????????????????????????????????????????????: product_shift <=  30;
	106'b00000000000000000000000000000001??????????????????????????????????????????????????????????????????????????: product_shift <=  31;
	106'b000000000000000000000000000000001?????????????????????????????????????????????????????????????????????????: product_shift <=  32;
	106'b0000000000000000000000000000000001????????????????????????????????????????????????????????????????????????: product_shift <=  33;
	106'b00000000000000000000000000000000001???????????????????????????????????????????????????????????????????????: product_shift <=  34;
	106'b000000000000000000000000000000000001??????????????????????????????????????????????????????????????????????: product_shift <=  35;
	106'b0000000000000000000000000000000000001?????????????????????????????????????????????????????????????????????: product_shift <=  36;
	106'b00000000000000000000000000000000000001????????????????????????????????????????????????????????????????????: product_shift <=  37;
	106'b000000000000000000000000000000000000001???????????????????????????????????????????????????????????????????: product_shift <=  38;
	106'b0000000000000000000000000000000000000001??????????????????????????????????????????????????????????????????: product_shift <=  39;
	106'b00000000000000000000000000000000000000001?????????????????????????????????????????????????????????????????: product_shift <=  40;
	106'b000000000000000000000000000000000000000001????????????????????????????????????????????????????????????????: product_shift <=  41;
	106'b0000000000000000000000000000000000000000001???????????????????????????????????????????????????????????????: product_shift <=  42;
	106'b00000000000000000000000000000000000000000001??????????????????????????????????????????????????????????????: product_shift <=  43;
	106'b000000000000000000000000000000000000000000001?????????????????????????????????????????????????????????????: product_shift <=  44;
	106'b0000000000000000000000000000000000000000000001????????????????????????????????????????????????????????????: product_shift <=  45;
	106'b00000000000000000000000000000000000000000000001???????????????????????????????????????????????????????????: product_shift <=  46;
	106'b000000000000000000000000000000000000000000000001??????????????????????????????????????????????????????????: product_shift <=  47;
	106'b0000000000000000000000000000000000000000000000001?????????????????????????????????????????????????????????: product_shift <=  48;
    106'b00000000000000000000000000000000000000000000000001????????????????????????????????????????????????????????: product_shift <=  49;
	106'b000000000000000000000000000000000000000000000000001???????????????????????????????????????????????????????: product_shift <=  50;
	106'b0000000000000000000000000000000000000000000000000001??????????????????????????????????????????????????????: product_shift <=  51;
	106'b00000000000000000000000000000000000000000000000000001?????????????????????????????????????????????????????: product_shift <=  52;
	106'b000000000000000000000000000000000000000000000000000000????????????????????????????????????????????????????: product_shift <=  53;
	  // It's not necessary to go past 53, because you will only get more than 53 zeros
	  // when multiplying 2 denormalized numbers together, in which case you will underflow
	endcase	

endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FPU                                                        ////
////  Floating Point Unit (Double precision)                     ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1ns / 100ps

module fpu_round( clk, rst, enable, round_mode, sign_term, 
mantissa_term, exponent_term, round_out, exponent_final);
input		clk;
input		rst;
input		enable;
input	[1:0]	round_mode;
input		sign_term;
input	[55:0]	mantissa_term;
input	[11:0]	exponent_term;
output	[63:0]	round_out;
output	[11:0]	exponent_final;

wire	[55:0] rounding_amount = { 53'b0, 1'b1, 2'b0};
wire	round_nearest = (round_mode == 2'b00);
wire	round_to_zero = (round_mode == 2'b01);
wire	round_to_pos_inf = (round_mode == 2'b10);
wire	round_to_neg_inf = (round_mode == 2'b11);
wire 	round_nearest_trigger = round_nearest &  mantissa_term[1]; 
wire	round_to_pos_inf_trigger = !sign_term & |mantissa_term[1:0]; 
wire	round_to_neg_inf_trigger = sign_term & |mantissa_term[1:0];
wire 	round_trigger = ( round_nearest & round_nearest_trigger)
						| (round_to_pos_inf & round_to_pos_inf_trigger) 
						| (round_to_neg_inf & round_to_neg_inf_trigger);


reg	  [55:0] sum_round;
wire	sum_round_overflow = sum_round[55]; 
	// will be 0 if no carry, 1 if overflow from the rounding unit
	// overflow from rounding is extremely rare, but possible
reg	  [55:0] sum_round_2;
reg   [11:0] exponent_round;
reg	  [55:0] sum_final; 
reg   [11:0] exponent_final;
reg   [63:0] round_out;

always @(posedge clk) 
	begin
		if (rst) begin
			sum_round <= 0;
			sum_round_2 <= 0;
			exponent_round <= 0;
			sum_final <= 0; 
			exponent_final <= 0;
			round_out <= 0;
		end
		else begin
			sum_round <= rounding_amount + mantissa_term;
			sum_round_2 <= sum_round_overflow ? sum_round >> 1 : sum_round;
			exponent_round <= sum_round_overflow ? (exponent_term + 1) : exponent_term;
			sum_final <= round_trigger ? sum_round_2 : mantissa_term; 
			exponent_final <= round_trigger ? exponent_round : exponent_term;
			round_out <= { sign_term, exponent_final[10:0], sum_final[53:2] };
			end
	end
endmodule	/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FPU                                                        ////
////  Floating Point Unit (Double precision)                     ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1ns / 100ps


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
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FPU                                                        ////
////  Floating Point Unit (Double precision)                     ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

`timescale 1ps / 1ps

module fpu_tb;

reg clk;
reg rst;
reg enable;
reg [1:0]rmode;
reg [2:0]fpu_op;
reg [63:0]opa;
reg [63:0]opb;
wire [63:0]out;
wire ready;
wire underflow;
wire overflow;
wire inexact;
wire exception;
wire invalid;  

reg [6:0] count;


	fpu UUT (
		.clk(clk),
		.rst(rst),
		.enable(enable),
		.rmode(rmode),
		.fpu_op(fpu_op),
		.opa(opa),
		.opb(opb),
		.out(out),
		.ready(ready),
		.underflow(underflow),
		.overflow(overflow),
		.inexact(inexact),
		.exception(exception),
		.invalid(invalid));

  		  
initial
begin : STIMUL 
	#0			  
	count = 0;
	rst = 1'b1;
	#20000;
	rst = 1'b0;	   // paste after this
//inputA:1.6999999999e-314
//inputB:4.0000000000e-300
enable = 1'b1;
opa = 64'b0000000000000000000000000000000011001101000101110000011010100010;
opb = 64'b0000000111000101011011100001111111000010111110001111001101011001;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:4.249999999722977e-015
if (out==64'h3CF323EA98D06FB6)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.0000000000e-290
//inputB:3.0000000000e-021
enable = 1'b1;
opa = 64'b0000001111010010101101100000010001001001010000101111100001010101;
opb = 64'b0011101110101100010101011000111000001111000101011110100011110111;
fpu_op = 3'b010;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:9.000000000000022e-311
if (out==64'h000010914A4C025A)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.6500000000e+002
//inputB:6.5000000000e+001
enable = 1'b1;
opa = 64'b0100000001111101000100000000000000000000000000000000000000000000;
opb = 64'b0100000001010000010000000000000000000000000000000000000000000000;
fpu_op = 3'b001;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:4.000000000000000e+002
if (out==64'h4079000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.2700000000e-001
//inputB:3.4000000000e+001
enable = 1'b1;
opa = 64'b0011111111001101000011100101011000000100000110001001001101110101;
opb = 64'b0100000001000001000000000000000000000000000000000000000000000000;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:3.422700000000000e+001
if (out==64'h40411D0E56041894)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.2300000000e+002
//inputB:5.6000000000e+001
enable = 1'b1;
opa = 64'b0100000001101011111000000000000000000000000000000000000000000000;
opb = 64'b0100000001001100000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:3.982142857142857e+000
if (out==64'h400FDB6DB6DB6DB7)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-9.5000000000e+001
//inputB:2.0000000000e+002
enable = 1'b1;
opa = 64'b1100000001010111110000000000000000000000000000000000000000000000;
opb = 64'b0100000001101001000000000000000000000000000000000000000000000000;
fpu_op = 3'b010;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:-1.900000000000000e+004
if (out==64'hC0D28E0000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-4.5000000000e+001
//inputB:-3.2000000000e+001
enable = 1'b1;
opa = 64'b1100000001000110100000000000000000000000000000000000000000000000;
opb = 64'b1100000001000000000000000000000000000000000000000000000000000000;
fpu_op = 3'b001;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:-1.300000000000000e+001
if (out==64'hC02A000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-9.0300000000e+002
//inputB:2.1000000000e+001
enable = 1'b1;
opa = 64'b1100000010001100001110000000000000000000000000000000000000000000;
opb = 64'b0100000000110101000000000000000000000000000000000000000000000000;
fpu_op = 3'b000;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:-8.820000000000000e+002
if (out==64'hC08B900000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.5500000000e+002
//inputB:-4.5900000000e+002
enable = 1'b1;
opa = 64'b0100000001111100011100000000000000000000000000000000000000000000;
opb = 64'b1100000001111100101100000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:-9.912854030501089e-001
if (out==64'hBFEFB89C2A6346D5)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.3577000000e+002
//inputB:2.0000000000e-002
enable = 1'b1;
opa = 64'b0100000001101101011110001010001111010111000010100011110101110001;
opb = 64'b0011111110010100011110101110000101000111101011100001010001111011;
fpu_op = 3'b010;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:4.715400000000001e+000
if (out==64'h4012DC91D14E3BCE)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.0195000000e+002
//inputB:-3.3600000000e+001
enable = 1'b1;
opa = 64'b0100000001111001000111110011001100110011001100110011001100110011;
opb = 64'b1100000001000000110011001100110011001100110011001100110011001101;
fpu_op = 3'b001;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:4.355500000000000e+002
if (out==64'h407B38CCCCCCCCCC)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-1.0000000000e-309
//inputB:1.1000000000e-309
enable = 1'b1;
opa = 64'b1000000000000000101110000001010101110010011010001111110110101110;
opb = 64'b0000000000000000110010100111110111111101110110011110001111011001;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:9.999999999999969e-311
if (out==64'h000012688B70E62B)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.0000000000e-200
//inputB:2.0000000000e+002
enable = 1'b1;
opa = 64'b0001011010001000011111101001001000010101010011101111011110101100;
opb = 64'b0100000001101001000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:2.000000000000000e-202
if (out==64'h160F5A549627A36C)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.0000000000e+020
//inputB:2.0000000000e+002
enable = 1'b1;
opa = 64'b0100010000110101101011110001110101111000101101011000110001000000;
opb = 64'b0100000001101001000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:2.000000000000000e+018
if (out==64'h43BBC16D674EC800)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:5.0000000000e+000
//inputB:2.5000000000e+000
enable = 1'b1;
opa = 64'b0100000000010100000000000000000000000000000000000000000000000000;
opb = 64'b0100000000000100000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:2.000000000000000e+000
if (out==64'h4000000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:1.0000000000e-312
//inputB:1.0000000000e+000
enable = 1'b1;
opa = 64'b0000000000000000000000000010111100100000000111010100100111111011;
opb = 64'b0011111111110000000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:9.999999999984653e-313
if (out==64'h0000002F201D49FB)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.8999000000e+004
//inputB:2.3600000000e+001
enable = 1'b1;
opa = 64'b0100000011100111111011001110000000000000000000000000000000000000;
opb = 64'b0100000000110111100110011001100110011001100110011001100110011010;
fpu_op = 3'b001;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:4.897540000000000e+004
if (out==64'h40E7E9ECCCCCCCCD)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.0000000000e-200
//inputB:3.0000000000e+111
enable = 1'b1;
opa = 64'b0001011010001000011111101001001000010101010011101111011110101100;
opb = 64'b0101011100010011111101011000110101000011010010100010101110101110;
fpu_op = 3'b011;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:1.333333333333758e-311
if (out==64'h0000027456DBDA6D)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:7.0000000000e-310
//inputB:8.0000000000e-100
enable = 1'b1;
opa = 64'b0000000000000000100000001101101111010000000101100100101100101101;
opb = 64'b0010101101011011111111110010111011100100100011100000010100110000;
fpu_op = 3'b011;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:8.749999999999972e-211
if (out==64'h14526914EEBBD470)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:1.4000000000e-311
//inputB:2.5000000000e-310
enable = 1'b1;
opa = 64'b0000000000000000000000101001001111000001100110100000101110111110;
opb = 64'b0000000000000000001011100000010101011100100110100011111101101011;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:5.599999999999383e-002
if (out==64'h3FACAC083126E600)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-4.0600000000e+001
//inputB:-3.5700000000e+001
enable = 1'b1;
opa = 64'b1100000001000100010011001100110011001100110011001100110011001101;
opb = 64'b1100000001000001110110011001100110011001100110011001100110011010;
fpu_op = 3'b000;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:-7.630000000000001e+001
if (out==64'hC053133333333334)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.4500000000e+002
//inputB:-3.4400000000e+002
enable = 1'b1;
opa = 64'b0100000001110101100100000000000000000000000000000000000000000000;
opb = 64'b1100000001110101100000000000000000000000000000000000000000000000;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:1.000000000000000e+000
if (out==64'h3FF0000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.3770000000e+001
//inputB:-4.5000000000e+001
enable = 1'b1;
opa = 64'b0100000000110111110001010001111010111000010100011110101110000101;
opb = 64'b1100000001000110100000000000000000000000000000000000000000000000;
fpu_op = 3'b001;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:6.877000000000000e+001
if (out==64'h40513147AE147AE1)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-4.7700000000e+002
//inputB:4.8960000000e+002
enable = 1'b1;
opa = 64'b1100000001111101110100000000000000000000000000000000000000000000;
opb = 64'b0100000001111110100110011001100110011001100110011001100110011010;
fpu_op = 3'b010;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:-2.335392000000000e+005
if (out==64'hC10C82199999999A)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.0000000000e-311
//inputB:0.0000000000e+000
enable = 1'b1;
opa = 64'b0000000000000000000000111010111010000010010010011100011110100010;
opb = 64'b0000000000000000000000000000000000000000000000000000000000000000;
fpu_op = 3'b000;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:1.999999999999895e-311
if (out==64'h000003AE8249C7A2)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:0.0000000000e+000
//inputB:9.0000000000e+050
enable = 1'b1;
opa = 64'b0000000000000000000000000000000000000000000000000000000000000000;
opb = 64'b0100101010000011001111100111000010011110001011100011000100101101;
fpu_op = 3'b010;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:0.000000000000000e+000
if (out==64'h0000000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:5.4000000000e+001
//inputB:0.0000000000e+000
enable = 1'b1;
opa = 64'b0100000001001011000000000000000000000000000000000000000000000000;
opb = 64'b0000000000000000000000000000000000000000000000000000000000000000;
fpu_op = 3'b000;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:5.400000000000000e+001
if (out==64'h404B000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-6.7000000000e+001
//inputB:0.0000000000e+000
enable = 1'b1;
opa = 64'b1100000001010000110000000000000000000000000000000000000000000000;
opb = 64'b0000000000000000000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:-1.#INF00000000000e+000
if (out==64'hFFEFFFFFFFFFFFFF)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-4.5600000000e+001
//inputB:-6.9000000000e+001
enable = 1'b1;
opa = 64'b1100000001000110110011001100110011001100110011001100110011001101;
opb = 64'b1100000001010001010000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:6.608695652173914e-001
if (out==64'h3FE525D7EE30F953)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-5.9900000000e+002
//inputB:2.7000000000e-002
enable = 1'b1;
opa = 64'b1100000010000010101110000000000000000000000000000000000000000000;
opb = 64'b0011111110011011101001011110001101010011111101111100111011011001;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:-2.218518518518519e+004
if (out==64'hC0D5AA4BDA12F685)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.1000000000e-308
//inputB:2.0000000000e-308
enable = 1'b1;
opa = 64'b0000000000001111000110011100001001100010100111001100111101010011;
opb = 64'b0000000000001110011000011010110011110000001100111101000110100100;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:4.100000000000000e-308
if (out==64'h001D7B6F52D0A0F7)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:5.0000000000e-308
//inputB:2.0000000000e-312
enable = 1'b1;
opa = 64'b0000000000100001111110100001100000101100010000001100011000001101;
opb = 64'b0000000000000000000000000101111001000000001110101001001111110110;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:5.000199999999999e-308
if (out==64'h0021FA474C5E1008)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.9800000000e+000
//inputB:3.7700000000e+000
enable = 1'b1;
opa = 64'b0100000000001111110101110000101000111101011100001010001111010111;
opb = 64'b0100000000001110001010001111010111000010100011110101110000101001;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:7.750000000000000e+000
if (out==64'h401F000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.4000000000e+001
//inputB:7.9000000000e-002
enable = 1'b1;
opa = 64'b0100000001000110000000000000000000000000000000000000000000000000;
opb = 64'b0011111110110100001110010101100000010000011000100100110111010011;
fpu_op = 3'b000;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:4.407900000000000e+001
if (out==64'h40460A1CAC083127)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:5.0000000000e-311
//inputB:9.0000000000e+009
enable = 1'b1;
opa = 64'b0000000000000000000010010011010001000101101110000111001100010101;
opb = 64'b0100001000000000110000111000100011010000000000000000000000000000;
fpu_op = 3'b010;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:4.499999999999764e-301
if (out==64'h01934982FC467380)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-4.0000000000e-305
//inputB:2.0000000000e-008
enable = 1'b1;
opa = 64'b1000000010111100000101101100010111000101001001010011010101110101;
opb = 64'b0011111001010101011110011000111011100010001100001000110000111010;
fpu_op = 3'b010;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:-8.000000000007485e-313
if (out==64'h80000025B34AA196)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.0000000000e-308
//inputB:1.0000000000e-012
enable = 1'b1;
opa = 64'b0000000000010101100100101000001101101000010011011011101001110111;
opb = 64'b0011110101110001100101111001100110000001001011011110101000010001;
fpu_op = 3'b010;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:2.999966601548049e-320
if (out==64'h00000000000017B8)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:5.6999990000e+006
//inputB:5.6999989900e+006
enable = 1'b1;
opa = 64'b0100000101010101101111100110011111000000000000000000000000000000;
opb = 64'b0100000101010101101111100110011110111111010111000010100011110110;
fpu_op = 3'b001;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:9.999999776482582e-003
if (out==64'h3F847AE140000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-4.0000000000e+000
//inputB:9.0000000000e+000
enable = 1'b1;
opa = 64'b1100000000010000000000000000000000000000000000000000000000000000;
opb = 64'b0100000000100010000000000000000000000000000000000000000000000000;
fpu_op = 3'b001;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:-1.300000000000000e+001
if (out==64'hC02A000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.9700000000e+001
//inputB:2.5700000000e-002
enable = 1'b1;
opa = 64'b0100000001000011110110011001100110011001100110011001100110011010;
opb = 64'b0011111110011010010100010001100111001110000001110101111101110000;
fpu_op = 3'b001;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:3.967430000000001e+001
if (out==64'h4043D64F765FD8AF)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.3000000000e+000
//inputB:7.0000000000e-002
enable = 1'b1;
opa = 64'b0100000000000010011001100110011001100110011001100110011001100110;
opb = 64'b0011111110110001111010111000010100011110101110000101000111101100;
fpu_op = 3'b001;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:2.230000000000000e+000
if (out==64'h4001D70A3D70A3D7)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:1.9999999673e-316
//inputB:1.9999999673e-317
enable = 1'b1;
opa = 64'b0000000000000000000000000000000000000010011010011010111011000010;
opb = 64'b0000000000000000000000000000000000000000001111011100010010101101;
fpu_op = 3'b001;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:1.799999970587486e-316
if (out==64'h00000000022BEA15)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:1.9999999970e-315
//inputB:-1.9999999673e-316
enable = 1'b1;
opa = 64'b0000000000000000000000000000000000011000001000001101001110011010;
opb = 64'b1000000000000000000000000000000000000010011010011010111011000010;
fpu_op = 3'b001;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:2.199999993695311e-315
if (out==64'h000000001A8A825C)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.0000000000e+000
//inputB:1.0000000000e-025
enable = 1'b1;
opa = 64'b0100000000010000000000000000000000000000000000000000000000000000;
opb = 64'b0011101010111110111100101101000011110101110110100111110111011001;
fpu_op = 3'b001;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:4.000000000000000e+000
if (out==64'h4010000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.0000000000e-310
//inputB:4.0000000000e-304
enable = 1'b1;
opa = 64'b0000000000000000001101110011100110100010010100101011001010000001;
opb = 64'b0000000011110001100011100011101110011011001101110100000101101001;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:4.000003000000000e-304
if (out==64'h00F18E3C781DCAB4)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.5000000000e-313
//inputB:7.0000000000e+004
enable = 1'b1;
opa = 64'b0000000000000000000000000001000001111110011100001010011010110001;
opb = 64'b0100000011110001000101110000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:4.999998683134458e-318
if (out==64'h00000000000F712B)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-5.1000000000e-306
//inputB:2.0480000000e+003
enable = 1'b1;
opa = 64'b1000000010001100101001101001011010000110100001110011101110100101;
opb = 64'b0100000010100000000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:-2.490234375000003e-309
if (out==64'h8001CA69686873BB)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-1.5000000000e-305
//inputB:1.0240000000e+003
enable = 1'b1;
opa = 64'b1000000010100101000100010001010001010011110110111110100000011000;
opb = 64'b0100000010010000000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:-1.464843750000000e-308
if (out==64'h800A888A29EDF40C)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-3.4000000000e+056
//inputB:-4.0000000000e+199
enable = 1'b1;
opa = 64'b1100101110101011101110111000100000000000101110111001110000000101;
opb = 64'b1110100101100000101110001110000010101100101011000100111010101111;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:8.500000000000000e-144
if (out==64'h223A88ECC2AC8317)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:1.3559000000e-001
//inputB:2.3111240000e+003
enable = 1'b1;
opa = 64'b0011111111000001010110110000001101011011110101010001001011101100;
opb = 64'b0100000010100010000011100011111101111100111011011001000101101000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:5.866842281071894e-005
if (out==64'h3F0EC257A882625F)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);

// end of paste
$finish;
end 
	
always
begin : CLOCK_clk

	clk = 1'b0;
	#5000; 
	clk = 1'b1;
	#5000; 
end

endmodule
