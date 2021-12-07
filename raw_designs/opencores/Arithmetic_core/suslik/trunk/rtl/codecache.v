`include "config.v"

module codecache(input clk,input [31:0] addrA,output `muxnet [31:0] dataA,input [511:0] cacheLine,output wire hit,input readen,input insert,input initEntry);
  wire tagwe;
  wire [31:0] tagAddrA;
  wire [31:0] tagAddrW;
  wire [115:0] tagDataA;
  `muxnet [115:0] tagDataW;
  reg  [31:0] tagAddrA_reg;

  wire ram0We,ram1We,ram2We,ram3We;
  wire [31:0] ramAddrW;
  wire [511:0] ramDataR0;
  wire [511:0] ramDataR1;
  wire [511:0] ramDataR2;
  wire [511:0] ramDataR3;
  wire [511:0] ramDataW;
  reg  [511:0] cacheLine_reg;

  wire [31:0] pad0;
  wire [31:0] pad1;
  wire [31:0] pad2;
  wire [31:0] pad3;
  wire [1:0] pos0;
  wire [1:0] pos1;
  wire [1:0] pos2;
  wire [1:0] pos3;
  wire val0;
  wire val1;
  wire val2;  
  wire val3;

  wire [1:0] newPos0;
  wire [1:0] newPos1;
  wire [1:0] newPos2;
  wire [1:0] newPos3;

  
  `muxnet hit3,hit2,hit1,hit0;
  reg readen_reg=0;
  reg insert_reg=0;
  reg initEntry_reg=0;
  reg [31:0] addrA_reg;
  reg [115:0] tagDataA_fwd;
  wire [115:0] ramTagDataA;
  reg tag_fwd=0;

  wire [31:0] dataA0;
  wire [31:0] dataA1;
  wire [31:0] dataA2;
  wire [31:0] dataA3;
  
  codecacheramtag tag0(clk,tagwe,tagAddrA[11:6],tagAddrW[11:6],ramTagDataA,tagDataW);
  codecacheram ram0(clk,ram0We,tagAddrA[11:6],ramAddrW[11:6],ramDataR0,ramDataW);
  codecacheram ram1(clk,ram1We,tagAddrA[11:6],ramAddrW[11:6],ramDataR1,ramDataW);
  codecacheram ram2(clk,ram2We,tagAddrA[11:6],ramAddrW[11:6],ramDataR2,ramDataW);
  codecacheram ram3(clk,ram3We,tagAddrA[11:6],ramAddrW[11:6],ramDataR3,ramDataW);
  instr_sel instr_sel0(ramDataR0,tagAddrA_reg[5:2],dataA0);
  instr_sel instr_sel1(ramDataR1,tagAddrA_reg[5:2],dataA1);
  instr_sel instr_sel2(ramDataR2,tagAddrA_reg[5:2],dataA2);
  instr_sel instr_sel3(ramDataR3,tagAddrA_reg[5:2],dataA3);
  get_new_pos newpos0(pos0,pos1,pos2,pos3,hit0,hit1,hit2,hit3,newPos0,newPos1,newPos2,newPos3);
  
  assign tagAddrA=addrA;
  assign tagwe=readen_reg || insert_reg || initEntry_reg; 
  assign tagAddrW=tagAddrA_reg;

  assign tagDataA=tag_fwd ? tagDataA_fwd : ramTagDataA;

  assign { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],pos3,pos2,pos1,pos0,val3,val2,val1,val0 } = tagDataA;
  assign pad3[5:0]=6'b0;
  assign pad2[5:0]=6'b0;
  assign pad1[5:0]=6'b0;
  assign pad0[5:0]=6'b0;

  assign tagDataW=readen_reg ? { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],newPos3,newPos2,newPos1,newPos0,val3,val2,val1,val0 } : 116'b`muxval;
  assign tagDataW=(insert_reg && hit0) ? { pad3[31:6],pad2[31:6],pad1[31:6],tagAddrA_reg[31:6],newPos3,newPos2,newPos1,newPos0,val3,val2,val1,1'b1 } : 116'b`muxval;
  assign tagDataW=(insert_reg && hit1) ? { pad3[31:6],pad2[31:6],tagAddrA_reg[31:6],pad0[31:6],newPos3,newPos2,newPos1,newPos0,val3,val2,1'b1,val0 } : 116'b`muxval;
  assign tagDataW=(insert_reg && hit2) ? { pad3[31:6],tagAddrA_reg[31:6],pad1[31:6],pad0[31:6],newPos3,newPos2,newPos1,newPos0,val3,1'b1,val1,val0 } : 116'b`muxval;
  assign tagDataW=(insert_reg && hit3) ? { tagAddrA_reg[31:6],pad2[31:6],pad1[31:6],pad0[31:6],newPos3,newPos2,newPos1,newPos0,1'b1,val2,val1,val0 } : 116'b`muxval;
//  assign tagDataW=(insert_reg && !hit) ? 116'b0 : 116'bz;
  assign tagDataW=initEntry_reg ? { 26'b0,26'b0,26'b0,26'b0,2'b11,2'b10,2'b01,2'b00,1'b0,1'b0,1'b0,1'b0} : 116'b`muxval;
  assign tagDataW=(!insert_reg && !readen_reg && !initEntry_reg) ? 116'b0 : 116'b`muxval;
  
  assign hit3=readen_reg ? val3 && (pad3[31:6]==tagAddrA_reg[31:6]) : 1'b`muxval;
  assign hit2=readen_reg ? val2 && (pad2[31:6]==tagAddrA_reg[31:6]) : 1'b`muxval;
  assign hit1=readen_reg ? val1 && (pad1[31:6]==tagAddrA_reg[31:6]) : 1'b`muxval;
  assign hit0=readen_reg ? val0 && (pad0[31:6]==tagAddrA_reg[31:6]) : 1'b`muxval;

  assign hit3=insert_reg ? (pos3==2'b11) : 1'b`muxval;
  assign hit2=insert_reg ? (pos2==2'b11) : 1'b`muxval;
  assign hit1=insert_reg ? (pos1==2'b11) : 1'b`muxval;
  assign hit0=insert_reg ? (pos0==2'b11) : 1'b`muxval;

  assign hit3=(!insert_reg && !readen_reg) ? 1'b0 : 1'b`muxval;
  assign hit2=(!insert_reg && !readen_reg) ? 1'b0 : 1'b`muxval;
  assign hit1=(!insert_reg && !readen_reg) ? 1'b0 : 1'b`muxval;
  assign hit0=(!insert_reg && !readen_reg) ? 1'b0 : 1'b`muxval;

  assign hit=hit3 || hit2 || hit1 || hit0;
  
  assign ram0We=insert_reg && hit0;
  assign ram1We=insert_reg && hit1;
  assign ram2We=insert_reg && hit2;
  assign ram3We=insert_reg && hit3;

  assign dataA=hit0 ? dataA0 : 32'b`muxval; 
  assign dataA=hit1 ? dataA1 : 32'b`muxval; 
  assign dataA=hit2 ? dataA2 : 32'b`muxval; 
  assign dataA=hit3 ? dataA3 : 32'b`muxval;
  assign dataA= hit ? 32'b`muxval : 32'b0; 

  assign ramDataW=cacheLine_reg;
  assign ramAddrW=tagAddrA_reg;
  
  always @(posedge clk)
    begin
      readen_reg<=readen;
      tagAddrA_reg<=tagAddrA;
      insert_reg<=insert;
      addrA_reg<=addrA;
      cacheLine_reg<=cacheLine;
      initEntry_reg<=initEntry;
      tagDataA_fwd<=ramTagDataA;
      tag_fwd<=(readen_reg || insert_reg || initEntry_reg) && (addrA[11:6]==addrA_reg[11:6]);
    end

endmodule

module codecacheram(input clk,input we,input [5:0] addrA,input [5:0] addrW,output reg [511:0] dataA,input [511:0] dataW);
  reg [511:0] ram [63:0];
  
  always @(posedge clk)
    begin
      dataA<=ram[addrA];
      if (we) ram[addrW]<=dataW;
    end    

endmodule

/*
tag for 4 way set-asociative LRU code cache
{
{pad3,pad2,pad1,pad0}, //4x 26 bit physical address
{pos3,pos2,pos1,pos0}, //4xeach 2 bit LRU position, 8 bit
{val3,val2,val1,val0}  //4x 1 bit valid entry, 4 bit 
}
length =29*4=116 bit tag 
*/

module codecacheramtag(input clk,input we,input [5:0] addrA,input [5:0] addrW,output reg [115:0] dataA,input [115:0] dataW);
  reg [115:0] ram [63:0];
  
  always @(posedge clk)
    begin
      dataA<=ram[addrA];
      if (we) ram[addrW]<=dataW;
    end    

endmodule



module instr_sel(input [511:0] dataIn,input [3:0] sel, output [31:0] instr);
  wire [255:0] bit3Data;
  wire [127:0] bit2Data;
  wire [63:0]  bit1Data;

  assign bit3Data=sel[3] ? dataIn[511:256] : dataIn[255:0];
  assign bit2Data=sel[2] ? bit3Data[255:128] : bit3Data[127:0];
  assign bit1Data=sel[1] ? bit2Data[127:64] : bit2Data[63:0];
  assign instr   =sel[0] ? bit1Data[63:32] : bit1Data[31:0];
  
endmodule 


module get_new_pos(input [1:0] pos0,input [1:0] pos1,input [1:0] pos2,input [1:0] pos3,
                   input hit0,input hit1,input hit2,input hit3,
                   output `muxnet [1:0] newPos0,output `muxnet [1:0] newPos1,output `muxnet [1:0] newPos2,output `muxnet [1:0] newPos3);
  wire hit;

  assign hit=hit0 || hit1 || hit2 || hit3;
  
  assign newPos0=hit0 ? 0 : 2'b`muxval;
  assign newPos1=hit0 ? ((pos1<pos0) ? pos1+1:pos1  ) : 2'b`muxval;
  assign newPos2=hit0 ? ((pos2<pos0) ? pos2+1:pos2  ) : 2'b`muxval;
  assign newPos3=hit0 ? ((pos3<pos0) ? pos3+1:pos3  ) : 2'b`muxval;

  assign newPos1=hit1 ? 0 : 2'b`muxval;
  assign newPos0=hit1 ? ((pos0<pos1) ? pos0+1:pos0  ) : 2'b`muxval;
  assign newPos2=hit1 ? ((pos2<pos1) ? pos2+1:pos2  ) : 2'b`muxval;
  assign newPos3=hit1 ? ((pos3<pos1) ? pos3+1:pos3  ) : 2'b`muxval;

  assign newPos2=hit2 ? 0 : 2'b`muxval;
  assign newPos1=hit2 ? ((pos1<pos2) ? pos1+1:pos1  ) : 2'b`muxval;
  assign newPos0=hit2 ? ((pos0<pos2) ? pos0+1:pos0  ) : 2'b`muxval;
  assign newPos3=hit2 ? ((pos3<pos2) ? pos3+1:pos3  ) : 2'b`muxval;

  assign newPos3=hit3 ? 0 : 2'b`muxval;
  assign newPos1=hit3 ? ((pos1<pos3) ? pos1+1:pos1  ) : 2'b`muxval;
  assign newPos2=hit3 ? ((pos2<pos3) ? pos2+1:pos2  ) : 2'b`muxval;
  assign newPos0=hit3 ? ((pos0<pos3) ? pos0+1:pos0  ) : 2'b`muxval;

  assign newPos0=hit ? 2'b`muxval : pos0;
  assign newPos1=hit ? 2'b`muxval : pos1;
  assign newPos2=hit ? 2'b`muxval : pos2;
  assign newPos3=hit ? 2'b`muxval : pos3;
  
endmodule
