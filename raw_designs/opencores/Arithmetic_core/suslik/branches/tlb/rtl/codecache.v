`include "config.v"

module codecache(
  input clk,
  input [31:0] addrA,
  input [31:0] addrB,
  input tlbA;
  input tlbB;
  output [31:0] dataA,
  input [127:0] cacheLine,
  output hit,
  input readen,
  input insert,
  input initEntry);
  wire tagwe;
  wire [31:0] tagAddrA;
  wire [31:0] tagAddrW;
  wire [123:0] tagDataA;
  wire [123:0] tagDataW;
  reg  [31:0] tagAddrA_reg;

  wire ram0We,ram1We,ram2We,ram3We;
  wire [31:0] ramAddrW;
  wire [127:0] ramDataR0;
  wire [127:0] ramDataR1;
  wire [127:0] ramDataR2;
  wire [127:0] ramDataR3;
  wire [127:0] ramDataW;
  reg  [127:0] cacheLine_reg;

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

  
  wire hit3,hit2,hit1,hit0;
  wire hit3A,hit2A,hit1A,hit0A;
  wire hit3B,hit2B,hit1B,hit0B;
  wire hitA,hitB;
  
  reg readen_reg=0;
  reg insert_reg=0;
  reg initEntry_reg=0;
  reg [31:0] addrA_reg;
  reg [31:0] addrB_reg;
  reg [123:0] tagDataA_fwd;
  wire [123:0] ramTagDataA;
  reg tag_fwd=0;

  wire [31:0] dataA0;
  wire [31:0] dataA1;
  wire [31:0] dataA2;
  wire [31:0] dataA3;

  codecacheramtag tag0(clk,tagwe,tagAddrA[11:4],tagAddrW[11:4],ramTagDataA,tagDataW);
  codecacheram ram0(clk,ram0We,tagAddrA[11:4],ramAddrW[11:4],ramDataR0,ramDataW);
  codecacheram ram1(clk,ram1We,tagAddrA[11:4],ramAddrW[11:4],ramDataR1,ramDataW);
  codecacheram ram2(clk,ram2We,tagAddrA[11:4],ramAddrW[11:4],ramDataR2,ramDataW);
  codecacheram ram3(clk,ram3We,tagAddrA[11:4],ramAddrW[11:4],ramDataR3,ramDataW);
  instr_sel instr_sel0(ramDataR0,tagAddrA_reg[3:2],dataA0);
  instr_sel instr_sel1(ramDataR1,tagAddrA_reg[3:2],dataA1);
  instr_sel instr_sel2(ramDataR2,tagAddrA_reg[3:2],dataA2);
  instr_sel instr_sel3(ramDataR3,tagAddrA_reg[3:2],dataA3);
  get_new_pos newpos0(pos0,pos1,pos2,pos3,hit0A&tlbA||hit0B&tlbB,
    hit1A&tlbA||hit1B&tlbB,hit2A&tlbA||hit2B&tlbB,hit3A&tlbA||hit3B&tlbB,
    newPos0,newPos1,newPos2,newPos3);
  
  assign tagAddrA=addrA;
  assign tagwe=readen_reg || insert_reg || initEntry_reg; 
  assign tagAddrW=tagAddrA_reg;

  assign tagDataA=tag_fwd ? tagDataA_fwd : ramTagDataA;

  assign { pad3[31:4],pad2[31:4],pad1[31:4],pad0[31:4],pos3,pos2,pos1,pos0,val3,val2,val1,val0 } = tagDataA;
  assign pad3[3:0]=4'b0;
  assign pad2[3:0]=4'b0;
  assign pad1[3:0]=4'b0;
  assign pad0[3:0]=4'b0;

  assign tagDataW=readen_reg ? { pad3[31:4],pad2[31:4],pad1[31:4],pad0[31:4],newPos3,newPos2,newPos1,newPos0,val3,val2,val1,val0 } : 124'bz;
  assign tagDataW=(insert_reg && hit0) ? { pad3[31:4],pad2[31:4],pad1[31:4],tagAddrA_reg[31:4],newPos3,newPos2,newPos1,newPos0,val3,val2,val1,1'b1 } : 124'bz;
  assign tagDataW=(insert_reg && hit1) ? { pad3[31:4],pad2[31:4],tagAddrA_reg[31:4],pad0[31:4],newPos3,newPos2,newPos1,newPos0,val3,val2,1'b1,val0 } : 124'bz;
  assign tagDataW=(insert_reg && hit2) ? { pad3[31:4],tagAddrA_reg[31:4],pad1[31:4],pad0[31:4],newPos3,newPos2,newPos1,newPos0,val3,1'b1,val1,val0 } : 124'bz;
  assign tagDataW=(insert_reg && hit3) ? { tagAddrA_reg[31:6],pad2[31:4],pad1[31:4],pad0[31:4],newPos3,newPos2,newPos1,newPos0,1'b1,val2,val1,val0 } : 124'bz;
//  assign tagDataW=(insert_reg && !hit) ? 116'b0 : 116'bz;
  assign tagDataW=initEntry_reg ? { 28'b0,28'b0,28'b0,28'b0,2'b11,2'b10,2'b01,2'b00,1'b0,1'b0,1'b0,1'b0} : 124'bz;
  assign tagDataW=(!insert_reg && !readen_reg && !initEntry_reg) ? 124'b0 : 124'bz;
  
  assign hit3A=readen_reg & val3 && (pad3[31:4]==tagAddrA_reg[31:4]) : 1'bz;
  assign hit2A=readen_reg & val2 && (pad2[31:4]==tagAddrA_reg[31:4]) : 1'bz;
  assign hit1A=readen_reg & val1 && (pad1[31:4]==tagAddrA_reg[31:4]) : 1'bz;
  assign hit0A=readen_reg & val0 && (pad0[31:4]==tagAddrA_reg[31:4]) : 1'bz;

  assign hit3B=readen_reg & val3 && (pad3[31:4]==tagAddrB_reg[31:4]) : 1'bz;
  assign hit2B=readen_reg & val2 && (pad2[31:4]==tagAddrB_reg[31:4]) : 1'bz;
  assign hit1B=readen_reg & val1 && (pad1[31:4]==tagAddrB_reg[31:4]) : 1'bz;
  assign hit0B=readen_reg & val0 && (pad0[31:4]==tagAddrB_reg[31:4]) : 1'bz;

  assign hit3=insert_reg & (pos3==2'b11);
  assign hit2=insert_reg & (pos2==2'b11);
  assign hit1=insert_reg & (pos1==2'b11);
  assign hit0=insert_reg & (pos0==2'b11);


  assign hitA=hit3A || hit2A || hit1A || hit0A;
  assign hitB=hit3B || hit2B || hit1B || hit0B;
  
  assign ram0We=insert_reg && hit0;
  assign ram1We=insert_reg && hit1;
  assign ram2We=insert_reg && hit2;
  assign ram3We=insert_reg && hit3;

  assign dataA=hit0A & tlbA ? dataA0 : 32'bz; 
  assign dataA=hit1A & tlbA ? dataA1 : 32'bz; 
  assign dataA=hit2A & tlbA ? dataA2 : 32'bz; 
  assign dataA=hit3A & tlbA ? dataA3 : 32'bz;
  assign dataA=hit0B & tlbB ? dataA0 : 32'bz; 
  assign dataA=hit1B & tlbB ? dataA1 : 32'bz; 
  assign dataA=hit2B & tlbB ? dataA2 : 32'bz; 
  assign dataA=hit3B & tlbB ? dataA3 : 32'bz;
  assign dataA= hitA & tlbA || hitB & tlbB ? 32'bz : 32'b0; 

  assign ramDataW=cacheLine_reg;
  assign ramAddrW=tagAddrA_reg;
  
  assign hit=hitA & tlbA || hitB & tlbB;
  
  always @(posedge clk)
    begin
      readen_reg<=readen;
      tagAddrA_reg<=tagAddrA;
      insert_reg<=insert;
      addrA_reg<=addrA;
      addrB_reg<=addrB;
      cacheLine_reg<=cacheLine;
      initEntry_reg<=initEntry;
      tagDataA_fwd<=ramTagDataA;
      tag_fwd<=(readen_reg || insert_reg || initEntry_reg) && (addrA[11:4]==addrA_reg[11:4]);
    end

endmodule

module codecacheram(input clk,input we,input [7:0] addrA,input [7:0] addrW,output [127:0] dataA,input [127:0] dataW);
  reg [127:0] ram [127:0];
  
  reg [7:0] addrA_reg;
  
  assign dataA=ram[addrA_reg];
  
  always @(posedge clk)
    begin
      if (we) ram[addrW]<=dataW;
      addrA_reg<=addrA;
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

module codecacheramtag(input clk,input we,input [7:0] addrA,input [7:0] addrW,output reg [123:0] dataA,input [123:0] dataW);
  reg [123:0] ram [63:0];
  
  reg [7:0] addrA_reg;
  assign dataA=ram[addrA_reg];
  
  always @(posedge clk)
    begin
      addrA_reg<=addrA;
      if (we) ram[addrW]<=dataW;
    end    

endmodule



module instr_sel(input [127:0] dataIn,input [1:0] sel, output [31:0] instr);
  wire [63:0]  bit1Data;

  assign bit1Data=sel[1] ? dataIn[127:64] : dataIn[63:0];
  assign instr   =sel[0] ? bit1Data[63:32] : bit1Data[31:0];
  
endmodule 


module get_new_pos(input [1:0] pos0,input [1:0] pos1,input [1:0] pos2,input [1:0] pos3,
                   input hit0,input hit1,input hit2,input hit3,
                   output wire [1:0] newPos0,output wire [1:0] newPos1,output wire [1:0] newPos2,output wire [1:0] newPos3);
  wire hit;

  assign hit=hit0 || hit1 || hit2 || hit3;
  
  assign newPos0=hit0 ? 0 : 2'bz;
  assign newPos1=hit0 ? ((pos1<pos0) ? pos1+1:pos1  ) : 2'bz;
  assign newPos2=hit0 ? ((pos2<pos0) ? pos2+1:pos2  ) : 2'bz;
  assign newPos3=hit0 ? ((pos3<pos0) ? pos3+1:pos3  ) : 2'bz;

  assign newPos1=hit1 ? 0 : 2'bz;
  assign newPos0=hit1 ? ((pos0<pos1) ? pos0+1:pos0  ) : 2'bz;
  assign newPos2=hit1 ? ((pos2<pos1) ? pos2+1:pos2  ) : 2'bz;
  assign newPos3=hit1 ? ((pos3<pos1) ? pos3+1:pos3  ) : 2'bz;

  assign newPos2=hit2 ? 0 : 2'bz;
  assign newPos1=hit2 ? ((pos1<pos2) ? pos1+1:pos1  ) : 2'bz;
  assign newPos0=hit2 ? ((pos0<pos2) ? pos0+1:pos0  ) : 2'bz;
  assign newPos3=hit2 ? ((pos3<pos2) ? pos3+1:pos3  ) : 2'bz;

  assign newPos3=hit3 ? 0 : 2'bz;
  assign newPos1=hit3 ? ((pos1<pos3) ? pos1+1:pos1  ) : 2'bz;
  assign newPos2=hit3 ? ((pos2<pos3) ? pos2+1:pos2  ) : 2'bz;
  assign newPos0=hit3 ? ((pos0<pos3) ? pos0+1:pos0  ) : 2'bz;

  assign newPos0=hit ? 2'bz : pos0;
  assign newPos1=hit ? 2'bz : pos1;
  assign newPos2=hit ? 2'bz : pos2;
  assign newPos3=hit ? 2'bz : pos3;
  
endmodule
