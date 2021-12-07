//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
`switch (LFSR_LENGTH)
`case 2
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[2]"
`breaksw
`case 3
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[2]"
 `let LFSR_FB_REW="qi[1]^qi[3]"
`breaksw
`case 4
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[3]"
 `let LFSR_FB_REW="qi[1]^qi[4]"
`breaksw
`case 5
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[3]"
 `let LFSR_FB_REW="qi[1]^qi[4]"
`breaksw
`case 6
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[5]"
 `let LFSR_FB_REW="qi[1]^qi[6]"
`breaksw
`case 7
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[6]"
 `let LFSR_FB_REW="qi[1]^qi[7]"
`breaksw
`case 8
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[6]^qi[5]^qi[4]"
 `let LFSR_FB_REW="qi[1]^qi[7]^qi[6]^qi[5]"
`breaksw
`case 9
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[5]"
 `let LFSR_FB_REW="qi[1]^qi[6]"
`breaksw
`case 10
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[7]"
 `let LFSR_FB_REW="qi[1]^qi[8]"
`breaksw
`case 11
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[9]"
 `let LFSR_FB_REW="qi[1]^qi[10]"
`breaksw
`case 12
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[6]^qi[4]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[7]^qi[5]^qi[2]"
`breaksw
`case 13
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[4]^qi[3]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[5]^qi[4]^qi[2]"
`breaksw
`case 14
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[5]^qi[3]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[6]^qi[4]^qi[2]"
`breaksw
`case 15
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[14]"
 `let LFSR_FB_REW="qi[1]^qi[15]"
`breaksw
`case 16
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[15]^qi[13]^qi[4]"
 `let LFSR_FB_REW="qi[1]^qi[16]^qi[14]^qi[5]"
`breaksw
`case 17
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[14]"
 `let LFSR_FB_REW="qi[1]^qi[15]"
`breaksw
`case 18
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[11]"
 `let LFSR_FB_REW="qi[1]^qi[12]"
`breaksw
`case 19
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[6]^qi[2]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[7]^qi[3]^qi[2]"
`breaksw
`case 20
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[17]"
 `let LFSR_FB_REW="qi[1]^qi[18]"
`breaksw
`case 21
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[19]"
 `let LFSR_FB_REW="qi[1]^qi[20]"
`breaksw
`case 22
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[21]"
 `let LFSR_FB_REW="qi[1]^qi[22]"
`breaksw
`case 23
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[18]"
 `let LFSR_FB_REW="qi[1]^qi[19]"
`breaksw
`case 24
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[23]^qi[22]^qi[17]"
 `let LFSR_FB_REW="qi[1]^qi[24]^qi[23]^qi[18]"
`breaksw
`case 25
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[22]"
 `let LFSR_FB_REW="qi[1]^qi[23]"
`breaksw
`case 26
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[6]^qi[2]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[7]^qi[3]^qi[2]"
`breaksw
`case 27
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[5]^qi[2]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[6]^qi[3]^qi[2]"
`breaksw
`case 28
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[25]"
 `let LFSR_FB_REW="qi[1]^qi[26]"
`breaksw
`case 29
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[27]"
 `let LFSR_FB_REW="qi[1]^qi[28]"
`breaksw
`case 30
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[6]^qi[4]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[7]^qi[5]^qi[2]"
`breaksw
`case 31
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[28]"
 `let LFSR_FB_REW="qi[1]^qi[29]"
`breaksw
`case 32
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[22]^qi[2]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[23]^qi[3]^qi[2]"
`breaksw	      
`endswitch
// module name
`define CNT_MODULE_NAME vcnt

// counter type = [BINARY, GRAY, LFSR]
//`define CNT_TYPE_BINARY
`define CNT_TYPE_GRAY
//`define CNT_TYPE_LFSR

// q as output
`define CNT_Q
// for gray type counter optional binary output
`define CNT_Q_BIN

// up/down, forward/rewind
`define CNT_REW

// number of CNT bins
`define CNT_LENGTH 4

// async reset value
`define CNT_RESET_VALUE 0

// clear
`define CNT_CLEAR

// set
`define CNT_SET
`define CNT_SET_VALUE 9

// wrap around creates shorter cycle than maximum length
//`define CNT_WRAP
`define CNT_WRAP_VALUE 9

// clock enable
`define CNT_CE

// q_next as an output
//`define CNT_QNEXT

// q=0 as an output
//`define CNT_Z

// q_next=0 as a registered output
//`define CNT_ZQ

// level indicator 1
`define CNT_LEVEL1
`define CNT_LEVEL1_VALUE 1

// level indicator 2
`define CNT_LEVEL2
`define CNT_LEVEL2_VALUE 2
`include "versatile_counter_defines.v"
`define LFSR_LENGTH cnt_length
`include "lfsr_polynom.v"
`let CNT_INDEX=CNT_LENGTH-1
`ifndef CNT_MODULE_NAME
`define CNT_MODULE_NAME vcnt
`endif
module `CNT_MODULE_NAME
  (
`ifdef CNT_TYPE_GRAY
    output reg [cnt_length:1] q,
 `ifdef CNT_Q_BIN
    output [cnt_length:1]    q_bin,
 `endif
`else   
 `ifdef CNT_Q
    output [cnt_length:1]    q,
 `endif
`endif
`ifdef CNT_CLEAR
    input clear,
`endif 
`ifdef CNT_SET
    input set,
`endif
`ifdef CNT_REW
    input rew,
`endif
`ifdef CNT_CE
    input cke,
`endif
`ifdef CNT_QNEXT
    output [cnt_length:1] q_next,
`endif
`ifdef CNT_Z
    output z,
`endif
`ifdef CNT_ZQ
    output reg zq,
`endif
`ifdef CNT_LEVEL1
    output reg level1,
`endif
`ifdef CNT_LEVEL2
    output reg level2,
`endif
    input clk,
    input rst
   );
   
   parameter cnt_length = `CNT_LENGTH;
   parameter cnt_reset_value = `CNT_RESET_VALUE;
`ifdef CNT_SET
   parameter set_value = cnt_length'd`CNT_SET_VALUE;
`endif
`ifdef CNT_WRAP
   parameter wrap_value = cnt_length'd`CNT_WRAP_VALUE;
`endif
`ifdef CNT_LEVEL1
    parameter level1_value = cnt_length'd`CNT_LEVEL1_VALUE;
`endif
`ifdef CNT_LEVEL2
    parameter level2_value = cnt_length'd`CNT_LEVEL2_VALUE;
`endif

   // internal q reg
   reg [cnt_length:1] qi;
   
`ifndef CNT_QNEXT
   wire [cnt_length:1] q_next;   
`endif
`ifdef CNT_REW
   wire [cnt_length:1] q_next_fw;   
   wire [cnt_length:1] q_next_rew;   
`endif

`ifndef CNT_REW   
   assign q_next =
`else
     assign q_next_fw =
`endif	       
`ifdef CNT_CLEAR
       clear ? cnt_length'd0 :
`endif
`ifdef CNT_SET		  
	 set ? set_value :
`endif
`ifdef CNT_WRAP
	   (qi == wrap_value) ? cnt_length'd0 :
`endif
`ifdef CNT_TYPE_LFSR
	     {qi[`CNT_INDEX:1],~(`LFSR_FB)};
`else
   qi + cnt_length'd1;
`endif
   
`ifdef CNT_REW
   assign q_next_rew =
 `ifdef CNT_CLEAR
     clear ? cnt_length'd0 :
 `endif
 `ifdef CNT_SET		  
       set ? set_value :
 `endif
 `ifdef CNT_WRAP
	 (qi == cnt_length'd0) ? wrap_value :
 `endif
 `ifdef CNT_TYPE_LFSR
	   {~(`LFSR_FB_REW),qi[cnt_length:2]};
 `else
   qi - cnt_length'd1;
 `endif
`endif   
   
`ifdef CNT_REW
   assign q_next = rew ? q_next_rew : q_next_fw;
`endif
   
   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= cnt_length'd0;
     else
`ifdef CNT_CE
   if (cke)
`endif
     qi <= q_next;

`ifdef CNT_Q
 `ifdef CNT_TYPE_GRAY
   always @ (posedge clk or posedge rst)
     if (rst)
       q <= `CNT_RESET_VALUE;
     else
  `ifdef CNT_CE
       if (cke)
  `endif
	 q <= (q_next>>1) ^ q_next;
  `ifdef CNT_Q_BIN
   assign q_bin = qi;
  `endif
 `else
   assign q = q_next;
 `endif
`endif
   
`ifdef CNT_Z
   assign z = (q == cnt_length'd0);
`endif

`ifdef CNT_ZQ
   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else
 `ifdef CNT_CE
       if (cke)
 `endif
	 zq <= q_next == cnt_length'd0;
`endif

`ifdef CNT_LEVEL1
    always @ (posedge clk or posedge rst)
        if (rst)
            level1 <= 1'b0;
        else
 `ifdef CNT_CE
        if (cke)
 `endif
            if (q_next == level1_value)
                level1 <= 1'b1;
            else if (q == level1_value & rew)
                level1 <= 1'b0;
`endif

`ifdef CNT_LEVEL2
    always @ (posedge clk or posedge rst)
        if (rst)
            level2 <= 1'b0;
        else
 `ifdef CNT_CE
        if (cke)
 `endif
            if (q_next == level2_value)
                level2 <= 1'b1;
            else if (q == level2_value & rew)
                level2 <= 1'b0;
`endif

endmodule
