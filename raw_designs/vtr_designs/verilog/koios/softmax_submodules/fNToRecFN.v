`define DEFINES_DONE
`define EXPONENT 5
`define MANTISSA 10
`define SIGN 1
`define DATAWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define IEEE_COMPLIANCE 1
`define NUM 8
`define ADDRSIZE 7
`define ADDRSIZE_FOR_TB 10
`define EXPONENT 5
`define MANTISSA 10
`define ACTUAL_MANTISSA 11
`define EXPONENT_LSB 10
`define EXPONENT_MSB 14
`define MANTISSA_LSB 0
`define MANTISSA_MSB 9
`define MANTISSA_MUL_SPLIT_LSB 3
`define MANTISSA_MUL_SPLIT_MSB 9
`define SIGN 1
`define SIGN_LOC 15
`define DWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define IEEE_COMPLIANCE 1
`define EXPONENT 5
`define MANTISSA 10
`define ACTUAL_MANTISSA 11
`define EXPONENT_LSB 10
`define EXPONENT_MSB 14
`define MANTISSA_LSB 0
`define MANTISSA_MSB 9
`define MANTISSA_MUL_SPLIT_LSB 3
`define MANTISSA_MUL_SPLIT_MSB 9
`define SIGN 1
`define SIGN_LOC 15
`define DWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define IEEE_COMPLIANCE 1
`define EXPONENT 5
`define MANTISSA 10
`define ACTUAL_MANTISSA 11
`define EXPONENT_LSB 10
`define EXPONENT_MSB 14
`define MANTISSA_LSB 0
`define MANTISSA_MSB 9
`define MANTISSA_MUL_SPLIT_LSB 3
`define MANTISSA_MUL_SPLIT_MSB 9
`define SIGN 1
`define SIGN_LOC 15
`define DWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define IEEE_COMPLIANCE 1

module fNToRecFN#(parameter expWidth = 3, parameter sigWidth = 3) (
        input [(expWidth + sigWidth - 1):0] in,
        output [(expWidth + sigWidth):0] out
    );

    //`include "HardFloat_localFuncs.vi"
    //localparam normDistWidth = clog2(sigWidth);
    localparam normDistWidth = 4; //Hardcoding for FP16

    wire sign;
    wire [(expWidth - 1):0] expIn;
    wire [(sigWidth - 2):0] fractIn;
    assign {sign, expIn, fractIn} = in;
    wire isZeroExpIn = (expIn == 0);
    wire isZeroFractIn = (fractIn == 0);
    
   
    wire [(normDistWidth - 1):0] normDist;
    //sigwidth = 11, normDistWidth=4
    countLeadingZerosfp16 #(sigWidth - 1, normDistWidth)  countLeadingZeros(.in(fractIn), .count(normDist)); 
    wire [(sigWidth - 2):0] subnormFract = (fractIn<<normDist)<<1;
    wire [expWidth:0] adjustedExp =
        (isZeroExpIn ? normDist ^ ((1<<(expWidth + 1)) - 1) : expIn)
            + ((1<<(expWidth - 1)) | (isZeroExpIn ? 2 : 1));
    wire isZero = isZeroExpIn && isZeroFractIn;
    wire isSpecial = (adjustedExp[expWidth:(expWidth - 1)] == 'b11);
    
   
    wire [expWidth:0] exp;
    assign exp[expWidth:(expWidth - 2)] =
        isSpecial ? {2'b11, !isZeroFractIn}
            : isZero ? 3'b000 : adjustedExp[expWidth:(expWidth - 2)];
    assign exp[(expWidth - 3):0] = adjustedExp;
    assign out = {sign, exp, isZeroExpIn ? subnormFract : fractIn};

endmodule
module countLeadingZerosfp16 #(parameter inWidth = 10, parameter countWidth = 4) (
    input [(inWidth - 1):0] in, output reg [(countWidth - 1):0] count
    );

  wire [(inWidth - 1):0] reverseIn;
  reverseFp16 reverse_in(in, reverseIn);
  wire [inWidth:0] oneLeastReverseIn =
      {1'b1, reverseIn} & ({1'b0, ~reverseIn} + 1);
		
  always@(*)
    begin
      if (oneLeastReverseIn[10] == 1)
        begin
          count = 4'd10;
        end
      else if (oneLeastReverseIn[9] == 1)
        begin
          count = 4'd9;
        end
      else if (oneLeastReverseIn[8] == 1)
        begin
          count= 4'd8;
        end
      else if (oneLeastReverseIn[7] == 1)
        begin
          count = 4'd7;
        end
      else if (oneLeastReverseIn[6] == 1)
        begin
          count = 4'd6;
        end
      else if (oneLeastReverseIn[5] == 1)
        begin
          count = 4'd5;
        end
      else if (oneLeastReverseIn[4] == 1)
        begin
          count = 4'd4;
        end
      else if (oneLeastReverseIn[3] == 1)
        begin
          count = 4'd3;
        end
      else if (oneLeastReverseIn[2] == 1)
        begin
          count = 4'd2;
        end
      else if (oneLeastReverseIn[1] == 1)
        begin
          count = 4'd1;
        end
      else
        begin
          count = 4'd0;
        end
      end

endmodule
module reverseFp16 (input [9:0] in, output [9:0] out);

   assign out[0] = in[9];
   assign out[1] = in[8];
   assign out[2] = in[7];
   assign out[3] = in[6];
   assign out[4] = in[5];
   assign out[5] = in[4];
   assign out[6] = in[3];
   assign out[7] = in[2];
   assign out[8] = in[1];
   assign out[9] = in[0];
   // genvar ix;
   // generate
   //     for (ix = 0; ix < width; ix = ix + 1) begin :Bit
   //         assign out[ix] = in[width - 1 - ix];
   //     end
   // endgenerate

endmodule
