`define BITS 32         // Bit width of the operands
`define NumPath 34     

module fpu_mul( 
clk, 
//rmode, 
opa, opb, out, 
control
/*
inf, snan, qnan, ine, overflow, underflow, zero, div_by_zero
*/
);
input		clk;
//input	[1:0]	rmode;
input	[31:0]	opa, opb;
output	[31:0]	out;
output  [7:0] control;
/*
output		inf, snan, qnan;
output		ine;
output		overflow, underflow;
output		zero;
output		div_by_zero;
*/



////////////////////////////////////////////////////////////////////////
//
// Local Wires
//
reg [2:0] fpu_op;
reg		zero;
reg	[31:0]	opa_r, opb_r;		// Input operand registers
reg	[31:0]	out;			// Output register
reg		div_by_zero;		// Divide by zero output register
wire		signa, signb;		// alias to opX sign
wire		sign_fasu;		// sign output
wire	[26:0]	fracta, fractb;		// Fraction Outputs from EQU block
wire	[7:0]	exp_fasu;		// Exponent output from EQU block
reg	[7:0]	exp_r;			// Exponent output (registerd)
wire	[26:0]	fract_out_d;		// fraction output
wire		co;			// carry output
reg	[27:0]	fract_out_q;		// fraction output (registerd)
wire	[30:0]	out_d;			// Intermediate final result output
wire		overflow_d, underflow_d;// Overflow/Underflow Indicators
reg		overflow, underflow;	// Output registers for Overflow & Underflow
reg		inf, snan, qnan;	// Output Registers for INF, SNAN and QNAN
reg		ine;			// Output Registers for INE
reg	[1:0]	rmode_r1, rmode_r2, 	// Pipeline registers for rounding mode
		rmode_r3;
reg	[2:0]	fpu_op_r1, fpu_op_r2,	// Pipeline registers for fp opration
		fpu_op_r3;
wire		mul_inf, div_inf;
wire		mul_00, div_00;
/*
parameter	INF  = 31'h7f800000;
parameter	QNAN = 31'h7fc00001;
parameter	 SNAN = 31'h7f800001;

*/
wire	[1:0]	rmode;
assign rmode = 2'b00;

wire [30:0]	INF;
assign INF = 31'h7f800000;
wire [30:0]	QNAN; 
assign QNAN = 31'h7fc00001;
wire [30:0] SNAN;
assign SNAN = 31'h7f800001;

// start output_reg
reg [31:0]  out_o1;
reg     inf_o1, snan_o1, qnan_o1;
reg     ine_o1;
reg     overflow_o1, underflow_o1;
reg     zero_o1;
reg     div_by_zero_o1;
// end output_reg

wire [7:0] contorl;
assign control = {inf, snan, qnan, ine, overflow, underflow, zero, div_by_zero};

////////////////////////////////////////////////////////////////////////
//
// Input Registers
//

always @(posedge clk)  begin
 fpu_op[2:0] <= 3'b010;
end

always @(posedge clk)
	opa_r <= opa;

always @(posedge clk)
	opb_r <= opb;

always @(posedge clk)
	rmode_r1 <= rmode;

always @(posedge clk)
	rmode_r2 <= rmode_r1;

always @(posedge clk)
	rmode_r3 <= rmode_r2;

always @(posedge clk)
	fpu_op_r1 <= fpu_op;

always @(posedge clk)
	fpu_op_r2 <= fpu_op_r1;

always @(posedge clk)
	fpu_op_r3 <= fpu_op_r2;

////////////////////////////////////////////////////////////////////////
//
// Exceptions block
//
wire		inf_d, ind_d, qnan_d, snan_d, opa_nan, opb_nan;
wire		opa_00, opb_00;
wire		opa_inf, opb_inf;
wire		opa_dn, opb_dn;

except u0(	.clk(clk),
		.opa(opa_r[30:0]), .opb(opb_r[30:0]),
		.inf(inf_d), .ind(ind_d),
		.qnan(qnan_d), .snan(snan_d),
		.opa_nan(opa_nan), .opb_nan(opb_nan),
		.opa_00(opa_00), .opb_00(opb_00),
		.opa_inf(opa_inf), .opb_inf(opb_inf),
		.opa_dn(opa_dn), .opb_dn(opb_dn)
		);

////////////////////////////////////////////////////////////////////////
//
// Pre-Normalize block
// - Adjusts the numbers to equal exponents and sorts them
// - determine result sign
// - determine actual operation to perform (add or sub)
//

wire		nan_sign_d, result_zero_sign_d;
reg		sign_fasu_r;
wire	[7:0]	exp_mul;
wire		sign_mul;
reg		sign_mul_r;
wire	[23:0]	fracta_mul, fractb_mul;
wire		inf_mul;
reg		inf_mul_r;
wire	[1:0]	exp_ovf;
reg	[1:0]	exp_ovf_r;
wire		sign_exe;
reg		sign_exe_r;
wire	[2:0]	underflow_fmul_d;

pre_norm_fmul u2(
		.clk(clk),
		.fpu_op(fpu_op_r1),
		.opa(opa_r), .opb(opb_r),
		.fracta(fracta_mul),
		.fractb(fractb_mul),
		.exp_out(exp_mul),	// FMUL exponent output (registered)
		.sign(sign_mul),	// FMUL sign output (registered)
		.sign_exe(sign_exe),	// FMUL exception sign output (registered)
		.inf(inf_mul),		// FMUL inf output (registered)
		.exp_ovf(exp_ovf),	// FMUL exponnent overflow output (registered)
		.underflow(underflow_fmul_d)
		);

always @(posedge clk)
	sign_mul_r <=  sign_mul;

always @(posedge clk)
	sign_exe_r <=  sign_exe;

always @(posedge clk)
	inf_mul_r <=  inf_mul;

always @(posedge clk)
	exp_ovf_r <=  exp_ovf;


////////////////////////////////////////////////////////////////////////
//
// Mul
//
wire	[47:0]	prod;

mul_r2 u5(.clk(clk), .opa(fracta_mul), .opb(fractb_mul), .prod(prod));


////////////////////////////////////////////////////////////////////////
//
// Normalize Result
//
wire		ine_d;
reg	[47:0]	fract_denorm;
wire	[47:0]	fract_div;
wire		sign_d;
reg		sign;
reg	[30:0]	opa_r1;
reg	[47:0]	fract_i2f;
reg		opas_r1, opas_r2;
wire		f2i_out_sign;

always @(posedge clk)			// Exponent must be once cycle delayed
	exp_r <=  exp_mul;

always @(posedge clk)
	opa_r1 <= opa_r[30:0];

//always @(fpu_op_r3 or prod)
always @(prod)
	fract_denorm = prod;

always @(posedge clk)
	opas_r1 <=  opa_r[31];

always @(posedge clk)
	opas_r2 <=  opas_r1;

assign sign_d =  sign_mul;

always @(posedge clk)
	sign <=  (rmode_r2==2'h3) ? !sign_d : sign_d;

wire or_result;
assign or_result = mul_00 | div_00;
post_norm u4(
//.clk(clk),			// System Clock
	.fpu_op(fpu_op_r3),		// Floating Point Operation
	.opas(opas_r2),			// OPA Sign
	.sign(sign),			// Sign of the result
	.rmode(rmode_r3),		// Rounding mode
	.fract_in(fract_denorm),	// Fraction Input
	.exp_in(exp_r),			// Exponent Input
	.exp_ovf(exp_ovf_r),		// Exponent Overflow
	.opa_dn(opa_dn),		// Operand A Denormalized
	.opb_dn(opb_dn),		// Operand A Denormalized
	.rem_00(1'b0),		// Diveide Remainder is zero
	.div_opa_ldz(5'b00000),	// Divide opa leading zeros count
//	.output_zero(mul_00 | div_00),	// Force output to Zero
	.output_zero(or_result),	// Force output to Zero
	.out(out_d),			// Normalized output (un-registered)
	.ine(ine_d),			// Result Inexact output (un-registered)
	.overflow(overflow_d),		// Overflow output (un-registered)
	.underflow(underflow_d),	// Underflow output (un-registered)
	.f2i_out_sign(f2i_out_sign)	// F2I Output Sign
	);

////////////////////////////////////////////////////////////////////////
//
// FPU Outputs
//
wire	[30:0]	out_fixed;
wire		output_zero_fasu;
wire		output_zero_fdiv;
wire		output_zero_fmul;
reg		inf_mul2;
wire		overflow_fasu;
wire		overflow_fmul;
wire		overflow_fdiv;
wire		inf_fmul;
wire		sign_mul_final;
wire		out_d_00;
wire		sign_div_final;
wire		ine_mul, ine_mula, ine_div, ine_fasu;
wire		underflow_fasu, underflow_fmul, underflow_fdiv;
wire		underflow_fmul1;
reg	[2:0]	underflow_fmul_r;
reg		opa_nan_r;



always @(posedge clk)
	inf_mul2 <=  exp_mul == 8'hff;


// Force pre-set values for non numerical output
assign mul_inf = (fpu_op_r3==3'b010) & (inf_mul_r | inf_mul2) & (rmode_r3==2'h0);
assign div_inf = (fpu_op_r3==3'b011) & (opb_00 | opa_inf);

assign mul_00 = (fpu_op_r3==3'b010) & (opa_00 | opb_00);
assign div_00 = (fpu_op_r3==3'b011) & (opa_00 | opb_inf);

assign out_fixed = 
	( (qnan_d | snan_d) | 
		(opa_inf & opb_00)|
		(opb_inf & opa_00 )
	)  ? QNAN : INF;

always @(posedge clk)
	out_o1[30:0] <=  (mul_inf | div_inf | inf_d | snan_d | qnan_d) ?  out_fixed : out_d;

assign out_d_00 = !(|out_d);

assign sign_mul_final = (sign_exe_r & ((opa_00 & opb_inf) | (opb_00 & opa_inf))) ? !sign_mul_r : sign_mul_r;

assign sign_div_final = (sign_exe_r & (opa_inf & opb_inf)) ? !sign_mul_r : sign_mul_r | (opa_00 & opb_00);

always @(posedge clk)
//	out_o1[31] <= 	 !(snan_d | qnan_d) ?	sign_mul_final : nan_sign_d ;
  out_o1[31] <= !(snan_d | qnan_d) & sign_mul_final;

// Exception Outputs
assign ine_mula = ((inf_mul_r |  inf_mul2 | opa_inf | opb_inf) & (rmode_r3==2'h1) & 
		!((opa_inf & opb_00) | (opb_inf & opa_00 )) & fpu_op_r3[1]);

assign ine_mul  = (ine_mula | ine_d | inf_fmul | out_d_00 | overflow_d | underflow_d) &
		  !opa_00 & !opb_00 & !(snan_d | qnan_d | inf_d);

always @(posedge  clk)
	ine_o1 <=  ine_mul;


assign overflow_fmul = !inf_d & (inf_mul_r | inf_mul2 | overflow_d) & !(snan_d | qnan_d);

always @(posedge clk)
	overflow_o1 <= 	 overflow_fmul;

always @(posedge clk)
	underflow_fmul_r <=  underflow_fmul_d;

wire out_d_compare1;
assign out_d_compare1 = (out_d[30:23]==8'b0);

wire out_d_compare2;
assign out_d_compare2 = (out_d[22:0]==23'b0);
/*
assign underflow_fmul1 = underflow_fmul_r[0] |
			(underflow_fmul_r[1] & underflow_d ) |
			((opa_dn | opb_dn) & out_d_00 & (prod!=0) & sign) |
			(underflow_fmul_r[2] & ((out_d[30:23]==8'b0) | (out_d[22:0]==23'b0)));
*/
assign underflow_fmul1 = underflow_fmul_r[0] |
			(underflow_fmul_r[1] & underflow_d ) |
			((opa_dn | opb_dn) & out_d_00 & (prod!=48'b0) & sign) |
			(underflow_fmul_r[2] & (out_d_compare1 | out_d_compare2));


assign underflow_fmul = underflow_fmul1 & !(snan_d | qnan_d | inf_mul_r);
/*
always @(posedge clk)
begin
	underflow_o1 <=  1'b0;
	snan_o1 <= 1'b0;
	qnan_o1 <= 1'b0;
	inf_fmul <= 1'b0;
	inf_o1 <= 1'b0;
	zero_o1 <= 1'b0;
	opa_nan_r <= 1'b0;
	div_by_zero_o1 <= 1'b0;
end
assign output_zero_fmul = 1'b0;
*/


always @(posedge clk)
	underflow_o1 <=   underflow_fmul;

always @(posedge clk)
	snan_o1 <=  snan_d;

// Status Outputs
always @(posedge clk)
	qnan_o1 <= 	 ( snan_d | qnan_d |
				(((opa_inf & opb_00) | (opb_inf & opa_00 )) & fpu_op_r3==3'b010)
					   );

assign inf_fmul = 	(((inf_mul_r | inf_mul2) & (rmode_r3==2'h0)) | opa_inf | opb_inf) & 
			!((opa_inf & opb_00) | (opb_inf & opa_00 )) &
			fpu_op_r3==3'b010;

always @(posedge clk)
/*
	inf_o1 <= 	fpu_op_r3[2] ? 1'b0 :
			(!(qnan_d | snan_d) & 
			( ((&out_d[30:23]) & !(|out_d[22:0]) & !(opb_00 & fpu_op_r3==3'b011)) | inf_fmul)
			);
*/
	inf_o1 <= !fpu_op_r3[2] & (!(qnan_d | snan_d) & 
			( ((&out_d[30:23]) & !(|out_d[22:0]) & !(opb_00 & fpu_op_r3==3'b011)) | inf_fmul)
			);

assign output_zero_fmul = (out_d_00 | opa_00 | opb_00) &
			  !(inf_mul_r | inf_mul2 | opa_inf | opb_inf | snan_d | qnan_d) &
			  !(opa_inf & opb_00) & !(opb_inf & opa_00);

always @(posedge clk)
	zero_o1 <=  output_zero_fmul;

always @(posedge clk)
	opa_nan_r <=  (!opa_nan) & (fpu_op_r2==3'b011) ;

always @(posedge clk)
	div_by_zero_o1 <=  opa_nan_r & !opa_00 & !opa_inf & opb_00;


// output register
always @(posedge clk)
begin
	qnan <=  qnan_o1;
	out <=  out_o1;
	inf <=  inf_o1;
	snan <=  snan_o1;
	//qnan <=  qnan_o1;
	ine <=  ine_o1;
	overflow <=  overflow_o1;
	underflow <=  underflow_o1;
	zero <=  zero_o1;
	div_by_zero <=  div_by_zero_o1;
end
endmodule
module mul_r2(clk, opa, opb, prod);
input		clk;
input	[23:0]	opa, opb;
output	[47:0]	prod;

reg	[47:0]	prod1, prod;

always @(posedge clk)
	prod1 <=   opa * opb;

always @(posedge clk)
	prod <=   prod1;

endmodule
module pre_norm_fmul(clk, fpu_op, opa, opb, fracta, fractb, exp_out, sign,
		sign_exe, inf, exp_ovf, underflow);
input		clk;
input	[2:0]	fpu_op;
input	[31:0]	opa, opb;
output	[23:0]	fracta, fractb;
output	[7:0]	exp_out;
output		sign, sign_exe;
output		inf;
output	[1:0]	exp_ovf;
output	[2:0]	underflow;

////////////////////////////////////////////////////////////////////////
//
// Local Wires and registers
//

reg	[7:0]	exp_out;
wire		signa, signb;
reg		sign, sign_d;
reg		sign_exe;
reg		inf;
wire	[1:0]	exp_ovf_d;
reg	[1:0]	exp_ovf;
wire	[7:0]	expa, expb;
wire	[7:0]	exp_tmp1, exp_tmp2;
wire		co1, co2;
wire		expa_dn, expb_dn;
wire	[7:0]	exp_out_a;
wire		opa_00, opb_00, fracta_00, fractb_00;
wire	[7:0]	exp_tmp3, exp_tmp4, exp_tmp5;
wire	[2:0]	underflow_d;
reg	[2:0]	underflow;
wire		op_div;
wire	[7:0]	exp_out_mul, exp_out_div;

assign op_div = (fpu_op == 3'b011);
////////////////////////////////////////////////////////////////////////
//
// Aliases
//
assign  signa = opa[31];
assign  signb = opb[31];
assign   expa = opa[30:23];
assign   expb = opb[30:23];

////////////////////////////////////////////////////////////////////////
//
// Calculate Exponenet
//

assign expa_dn   = !(|expa);
assign expb_dn   = !(|expb);
assign opa_00    = !(|opa[30:0]);
assign opb_00    = !(|opb[30:0]);
assign fracta_00 = !(|opa[22:0]);
assign fractb_00 = !(|opb[22:0]);

assign fracta[22:0] = opa[22:0];
assign fractb[22:0] = opb[22:0];
assign fracta[23:23] = !expa_dn;
assign fractb[23:23] = !expb_dn;
//assign fracta = {!expa_dn,opa[22:0]};	// Recover hidden bit
//assign fractb = {!expb_dn,opb[22:0]};	// Recover hidden bit

assign {co1,exp_tmp1} = op_div ? ({1'b0,expa[7:0]} - {1'b0,expb[7:0]}) : ({1'b0,expa[7:0]} + {1'b0,expb[7:0]});
assign {co2,exp_tmp2} = op_div ? ({co1,exp_tmp1} + 9'h07f) : ({co1,exp_tmp1} - 9'h07f);
assign exp_tmp3 = exp_tmp2 + 8'h01;
assign exp_tmp4 = 8'h7f - exp_tmp1;
assign exp_tmp5 = op_div ? (exp_tmp4+8'h01) : (exp_tmp4-8'h01);


always@(posedge clk)
	exp_out <= op_div ? exp_out_div : exp_out_mul;

assign exp_out_div = (expa_dn | expb_dn) ? (co2 ? exp_tmp5 : exp_tmp3 ) : co2 ? exp_tmp4 : exp_tmp2;
assign exp_out_mul = exp_ovf_d[1] ? exp_out_a : (expa_dn | expb_dn) ? exp_tmp3 : exp_tmp2;
assign exp_out_a   = (expa_dn | expb_dn) ? exp_tmp5 : exp_tmp4;
assign exp_ovf_d[0] = op_div ? (expa[7] & !expb[7]) : (co2 & expa[7] & expb[7]);
assign exp_ovf_d[1] = op_div ? co2                  : ((!expa[7] & !expb[7] & exp_tmp2[7]) | co2);

always @(posedge clk)
	exp_ovf <=   exp_ovf_d;

assign underflow_d[0] =	(exp_tmp1 < 8'h7f) & !co1 & !(opa_00 | opb_00 | expa_dn | expb_dn);
assign underflow_d[1] =	((expa[7] | expb[7]) & !opa_00 & !opb_00) |
			 (expa_dn & !fracta_00) | (expb_dn & !fractb_00);
assign underflow_d[2] =	 !opa_00 & !opb_00 & (exp_tmp1 == 8'h7f);

always @(posedge clk)
	underflow <= underflow_d;

always @(posedge clk)
	inf <= op_div ? (expb_dn & !expa[7]) : ({co1,exp_tmp1} > 9'h17e) ;


////////////////////////////////////////////////////////////////////////
//
// Determine sign for the output
//

// sign: 0=Posetive Number; 1=Negative Number
always @(signa or signb)
   case({signa, signb})		// synopsys full_case parallel_case
	2'b00: sign_d = 0;
	2'b01: sign_d = 1;
	2'b10: sign_d = 1;
	2'b11: sign_d = 0;
   endcase

always @(posedge clk)
	sign <= sign_d;

always @(posedge clk)
	sign_exe <= signa & signb;

endmodule
