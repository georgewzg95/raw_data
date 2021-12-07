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

module aluplus(instr, val1, val2, valres, wrtval, cjmpinstr,cjmp,const1,retaddr,wrspec,irq_bits);

  input [31:0] instr, val1, val2;
  output [31:0] valres;
  output wire wrtval,cjmpinstr;
  output cjmp;
  input [31:0] const1;
  input [31:0] retaddr;
  output wrspec;
  input [15:0] irq_bits;

  wire [5:0] code;
  wire [31:0] valcmp;
  wire CF,NF,VF,ZF;
  
  /*
    wrtval=1 if valres needs to be stored in register.
    cjmpinstr=1 if compare and jump instruction
    cjmp=1 if jump taken 0 otherwise (only valid if cjmpinstr=1)
  */

  //assign const1={{16{instr[31]}},instr[31:21],instr[15:11]};
  assign code=instr[5:0];

  assign valres=(code==0) ? {const1[15:0],val1[15:0]}    : 32'bz;
  assign valres=(code==1) ? const1        : 32'bz;
  assign valres=(code==2) ? val1 & val2            : 32'bz;
  assign valres=(code==3) ? val1 & const1 : 32'bz;
  assign valres=(code==4) ? val1 | val2            : 32'bz;
  assign valres=(code==5) ? val1 | const1 : 32'bz;
  assign valres=(code==6) ? val1 ^ val2            : 32'bz;
  assign valres=(code==7) ? val1 ^ const1 : 32'bz;
  assign valres=(code==8) ? val1 + val2            : 32'bz;
  assign valres=(code==9) ? val1 + const1 : 32'bz;
  assign valres=(code==10)? val1 - val2            : 32'bz;
  assign valres=(code==11)? val1 - const1 : 32'bz;
  assign valres=wrspec ? val1 : 32'bz;
  assign valres=(code==12 && instr[15:11]==5'd2 && instr[31:24]=8'hff) ? irq_bits : 32'bz;
  assign valres=(code==13)? val1 & {16'b1111111111111111, const1[15:0]} : 32'bz;
  assign valres=(code==46) ? retaddr : 32'bz;
  assign valres=(code==14)? val1 << val2[5:0] : 32'bz;
  assign valres=(code==15)? val1 << const1[5:0] : 32'bz;
  assign valres=(code==16)? val1 >> val2[5:0] : 32'bz;
  assign valres=(code==17)? val1 >> const1[5:0] : 32'bz;
  assign valres=(code==18)? {32{val1[31]},val1} >> val2[5:0] : 32'bz;
  assign valres=(code==19)? {32{val1[31]},val1} >> const1[5:0] : 32'bz;

  assign valres=wrtval | wrspec ? 32'bz : 32'b0;
  
  assign wrtval=((code<=11) || (code>=13 && code<=19) || (code==46)) || (code==12 && instr[15:11]==5'd2 && instr[31:24]=8'hff);
  assign wrspec=(code==12) && (instr[15:11]=5'd1);

  //flags for compare &jump
  assign {CF,valcmp}=val1 - val2;
  assign NF=valcmp[31];
  assign ZF=(val1==val2);
  assign VF=(val1[31] & !val2[31] & !valcmp[31]) | (!val1[31] & val2[31] & valcmp[31]);

  assign cjmpinstr=((code>=32)&&(code<=45));

  assign cjmp= (code==32) ? (CF)              : 1'bz;
  assign cjmp= (code==33) ? (!CF)             : 1'bz;
  assign cjmp= (code==34) ? (ZF)              : 1'bz;
  assign cjmp= (code==35) ? (!ZF)             : 1'bz;
  assign cjmp= (code==36) ? (CF ^ ZF)         : 1'bz;
  assign cjmp= (code==37) ? !(CF ^ ZF)        : 1'bz;
  assign cjmp= (code==38) ? (NF)              : 1'bz;
  assign cjmp= (code==39) ? !(NF)             : 1'bz;
  assign cjmp= (code==40) ? (VF ^ NF)         : 1'bz;
  assign cjmp= (code==41) ? !(VF ^ NF)        : 1'bz;
  assign cjmp= (code==42) ? ((VF ^ NF) | ZF)  : 1'bz;
  assign cjmp= (code==43) ? !((VF ^ NF) | ZF) : 1'bz;
  assign cjmp= (code==44) ? (VF)              : 1'bz;
  assign cjmp= (code==45) ? (!VF)             : 1'bz;

  assign cjmp= cjmpinstr ? 1'bz : 1'b0;

endmodule

module subagu(input clk, input stall,input [4:0] stginhibit,input [31:0] baseOP,input [31:0] instr0,input [31:0] instr, input [31:0] instrprev,output wire [31:0] addr,output wire aguwrtval,output wire delayedstall, output reg [1:0] readsz, output wire readen,output wire writeen, input [31:0] offset);
  wire [4:0] instr_rA,instrprev_rF;
  wire writeinstrprev;
  wire [5:0] instrprev_code,instr_code,instr0_code;
  wire instr0_load,instr0_store,instr_load,instr_store;
  reg aguwrtval_reg;
  reg delayedstall_reg=0;
  //reg readen_reg;
  //wire [18:0] shortaddr;
  
  assign instr_rA=instr[10:6];
  assign instrprev_rF=instrprev[20:16];
  assign instrprev_code=instrprev[5:0];
  assign instr_code=instr[5:0];
  assign instr0_code=instr0[5:0];
  
  assign writereginstrprev=((instrprev_code<=11) || (instrprev_code==13) ||
    ((instrprev_code >= 56) && (instrprev_code <=58))) && !stginhibit[4] && !stall; //remove !stall ??
  assign delayedstall=writereginstrprev && (instr_load || instr_store) && ( instr_rA==instrprev_rF ) && (!stginhibit[3]); //add constant add stalless support

  assign instr_load=(instr_code >= 56) && (instr_code <=58);
  assign instr_store=(instr_code >= 60) && (instr_code <=62);
  assign instr0_load=(instr0_code >= 56) && (instr0_code <=58);
  assign instr0_store=(instr0_code >= 60) && (instr0_code <=62);

  assign addr=baseOP + offset;
  //assign shortaddr=baseOP[18:0] + offset[18:0];

  assign readen=instr_load && !stall && !stginhibit[3];
  assign writeen=instr_store && !stall && !stginhibit[3] && !delayedstall_reg;
  assign aguwrtval=!stall && !stginhibit[4] && aguwrtval_reg; 
   
  always @(posedge clk)
    begin
      if (!stall && !stginhibit[3]) aguwrtval_reg<=instr_load;
      ///*if (!stall && !stginhibit[2]) */readen_reg<=instr0_load;
      if (!stall && !stginhibit[2])
        case (instr0_code)
          56: readsz<=2;
          57: readsz<=1;
          58: readsz<=0;
          60: readsz<=2;
          61: readsz<=1;
          62: readsz<=0;
          default: readsz<=0;
        endcase
      delayedstall_reg<=delayedstall;
    end

endmodule


module regfileint0(clk,we,rA,rB,rC,rF,dataA,dataB,dataC,dataF);
  input [4:0] rA,rB,rC,rF;
  output wire [31:0] dataA,dataB,dataC;
  input [31:0] dataF;
  input clk,we;
  reg [31:0] regs [31:0];

  regram ram0(clk,we,rA,rF,dataA,dataF);
  regram ram1(clk,we,rB,rF,dataB,dataF);
  regram ram2(clk,we,rC,rF,dataC,dataF);
    
endmodule

module regram(input clk,input we,input [4:0] rA, input [4:0] rF, output reg [31:0] dataA, input [31:0] dataF);
  reg [31:0] regs[31:0];
  always @(posedge clk)
    begin
      dataA<=regs[rA];
      if (we) regs[rF]<=dataF;
    end
endmodule

module ioinstr(input clk,input stall, input [4:0] stginhibit,input [31:0] instr,input [31:0] val1,input [31:0] val2, output [31:0] valres, input multiCycleStall,
               output wire wrtVal, output wire doStall, output wire keepStalling,
               output wire [31:0] ioBusAddr,output reg [1:0] ioBusSize, output wire [31:0] ioBusOut, input [31:0] ioBusIn, input ioBusRdy,
               output wire ioBusWr,output wire ioBusRd);

wire [5:0] code;
wire [5:0] auxCode;
reg keepStalling_reg=0;
reg [31:0] inputValue;
assign code=instr[5:0];
assign auxCode=instr[26:21];
assign doStall=(code==31) && !multiCycleStall && !stall && !stginhibit[4];
assign wrtVal=multiCycleStall && (code==31) && ((auxCode==0) || (auxCode==1) || (auxCode==2)) && !stall && !stginhibit[4];
assign ioBusAddr=val1;
assign ioBusOut=val2;

assign ioBusOut=val2;
assign ioBusAddr=val1;
assign ioBusWr=!stall && !stginhibit[4] && !multiCycleStall && (code==31) && ((auxCode==4) || (auxCode==5) || (auxCode==6));
assign ioBusRd=!stall && !stginhibit[4] && !multiCycleStall && (code==31) && ((auxCode==0) || (auxCode==1) || (auxCode==2));
assign valres=inputValue;

assign keepStalling=keepStalling_reg;

always @(auxCode)
  begin
    case(auxCode)
      0,4: ioBusSize=0;
      1,5: ioBusSize=1;
      2,6: ioBusSize=2;
      default: ioBusSize=0;
    endcase
  end

always @(posedge clk)
  begin
    if (!stall && !stginhibit[4] && (code==31) && !multiCycleStall)
      begin
        keepStalling_reg<=1;
      end
    if (ioBusRdy)
      begin
        keepStalling_reg<=0;
      end
    if (ioBusRdy)
      begin
        inputValue<=ioBusIn;
      end
  end
  
endmodule 

module brpred(input clk,input stall, input [4:0] stginhibit,input [31:0] fetchaddr, output wire hit, output wire [31:0] branchinstr,
              output wire [31:0] nextaddr,output wire branchtaken, 
              input [31:0] insertaddr, input [31:0] insertinstr,input [31:0] inserttargetnext,input inserttaken,input jumpinstr,output wire addrMismatch);
  wire wen;
  wire [5:0] ramAddrB;
  wire [96:0] ramDataA;
  wire [96:0] ramDataB;
  wire [96:0] dataA;
  reg [31:0] fetchaddr_reg=0;
  reg branchtaken3;
  reg branchtaken4;
  reg branchtaken5;
  reg wen_reg=0;
  reg fwd;
  reg [96:0] fwdData;
  reg init=1;
  reg [5:0] initcount=63;

  reg [31:0] nextaddr3;
  reg [31:0] nextaddr4;
  reg [31:0] nextaddr5;
  
  brpred_ram ram0(clk,fetchaddr[7:2],ramAddrB,wen, ramDataA, ramDataB);

  assign dataA=fwd ? fwdData : ramDataA;
  
  assign hit=(dataA[63:32]==fetchaddr_reg);
  assign branchinstr=dataA[31:0];
  assign branchtaken=dataA[96];
  assign nextaddr=dataA[95:64];

  assign wen=((!stall && !stginhibit[4]) && (branchtaken5 ^ inserttaken) && jumpinstr) | init; //only write on failed prediction
  assign ramDataB=(!init) ? {inserttaken,inserttargetnext,insertaddr,insertinstr} : {1'b0,32'b0,32'b11,32'b0};
  assign ramAddrB= init ? initcount : insertaddr[7:2];

  assign addrMismatch=jumpinstr && (inserttargetnext != nextaddr5) && branchtaken5;
  
  always @(posedge clk)
    begin
      wen_reg<=wen;
      fwd<=wen && (ramAddrB == fetchaddr[7:2]);
      fwdData<=ramDataB;

      if (init)
        begin
          initcount<=initcount-1;
          if (initcount==0) init<=0;
        end
      
      if (!stall)
        begin 
          fetchaddr_reg<=fetchaddr;
        end
      if (!stall && !stginhibit[1])
        begin
          branchtaken3<=hit && branchtaken;
          nextaddr3<=nextaddr;
        end
      if (!stall && !stginhibit[2])
        begin
          branchtaken4<=branchtaken3;
          nextaddr4<=nextaddr3;
        end
      if (!stall && !stginhibit[3])
        begin
          branchtaken5<=branchtaken4;
          nextaddr5<=nextaddr4;
        end
      if (!stall && !stginhibit[4])
        begin
        end
    end
endmodule 

module brpred_ram(input clk, input [5:0] addrA, input [5:0] addrB, input wen, output reg [96:0] dataA, input [96:0] dataB);
  reg [96:0] ram[63:0];
  always @(posedge clk)
    begin
      dataA<=ram[addrA];
      if (wen) ram[addrB]<=dataB;
    end
endmodule 

module cpu(input clk,input busEnRead,input busEnWrite, input busDataReady, output wire busRead, output wire busWrite,output wire [31:0] busAddr, 
              input [511:0] busInput,output wire [511:0] busOutput,
              output wire [31:0] ioBusAddr,output wire [1:0] ioBusSize, output wire [31:0] ioBusOut, input [31:0] ioBusIn, input ioBusRdy,
              output wire ioBusWr,output wire ioBusRd,output wire [3:0] dummy, input [15:0] irq);
  wire [31:0] fetchaddr,fetchdata,readaddr,readdata;
  reg [31:0] readaddr_reg;
  reg [4:0] stginhibit=5'b11110;
  reg [4:0] stginhibit_wrt;
  reg [31:0] IP=32'b0,IP2,IP3,IP4,IP5,instr=0,instr4=0;
  reg stall0=0;
  wor stall;
  wire [4:0] rA0,rB0,rC,rF0,rFprev,rFprevprev;
  //reg [31:0] cjmpoff;
  reg [4:0] rA,rB,rF,rAprev,rBprev;
  wire intregwe;
  wire [31:0] intregdataF;
  wire [31:0] intregdataA,intregdataB,intregdataC;
  wire [31:0] opA,opB,opC,opF;
  reg rAfwd,rBfwd,rCfwd,rAfwd0,rBfwd0,rCfwd0;
  reg cycle1prev=0;
  reg [31:0] instr0=0;
  //reg [31:0] reg_instr0;
  wire aluwrtval,alucjmpinstr,alucjmp;
  //reg regfwrt=0;
  reg [31:0] regfwd;
  wire [31:0] aguaddr;
  wire agustall,aguwrtval;
  wire [1:0] agureadsz;
  wire agureaden;
  wire aguwriteen;
  reg agureaden_reg;
  reg aguwriteen_reg;
  reg agustall_reg=0;
  //aguwrtval ignores exceptions for now
  reg [31:0] cjmpoffset;
  reg [31:0] cjmpoffset0;
  reg [31:0] cjmpaddr;
  wire brpred_hit;
  wire [31:0] brpred_instr;
  wire [31:0] brpred_nextaddr;
  wire brpred_taken;
  wire [31:0] brpred_instertaddr;
  wire [31:0] brpred_instertinstr;
  wire [31:0] brpred_insertnextaddr;
  wire brpred_inserttaken;
  wire brpred_jumpinstr;
  wire brpred_addrMismatch;

  reg brtaken3,brtaken4,brtaken5;
  
  reg init=1;
  reg ccInit=1;
  reg dcInit=1;
  reg [6:0] initcount=66;
  reg [5:0] ccInitCount=63;
  reg [5:0] dcInitCount=63;
  reg [4:0] codeMiss=0;
  wire [31:0] ccFetchAddr;
  //wire [511:0] cacheLineInput;
  wire ccHit,ccReadEn,ccInsert;
  reg ccInsertInProgress_tsk=0;
  reg ccInsertRamReq_tsk=0;
  reg ccInsertInsert_tsk=0;
  reg ccInsertWait1_tsk=0;
  reg ccInsertWait2_tsk=0;

  wire [31:0] dcAddr;
  wire [511:0] dcDataA;
  wire [511:0] dcDataWriteBack;
  reg  [511:0] dcDataWriteBack_reg;
  wire dcHit;
  wire dcReadEn,dcWriteEn,dcInsert,dcInitEntry;
  reg dcInsertInProgress_tsk=0;
  reg dcInsertRamReq_tsk=0;
  reg dcInsertInsert_tsk=0;
  reg dcInsertCheckDirty_tsk=0;
  reg dcInsertWriteBack_tsk=0;
  reg [31:0] dcReadAddr;
  reg [31:0] dcOldAddr_reg;
  wire [31:0] dcOldAddr;

  reg [31:0] constBits; // contains the constant bits
  reg [31:0] constBits4;
  reg prevUpperBits=0; //bit 0 set => constBits countains the upper constant bits of the next instruction
  
  wire [31:0] retAddr;
  wire uJmpInstr;
  reg [31:0] aguaddr_reg;

  reg [4:0] multiCycleStall=0;
  
  wire [31:0] ioInstrResult;
  wire wasGlobalStall=multiCycleStall[4];
  wire ioInstrWrtVal;
  wire ioInstrDoStall;
  wire ioInstrKeepStalling;

  reg [15:0] irq_bits=16'b0;
  reg [31:0] irq_handler=32'hffff_fff0;
  
  wire wrspec;
  reg [31:0] sys_flags=32'b0;
  reg [15:0] irq_mask;
  
  //dataunit data0(clk,stall,stginhibit,readaddr,readdata,agureadsz,agureaden,aguwriteen,opB);
  datacache datacache0(clk,stall,stginhibit,codeMiss,dcAddr,dcDataA,busInput,opB,dcHit,dcReadEn,dcWriteEn,dcInsert,dcInitEntry,agureadsz,dcOldAddr);
  regfileint0 regf0(clk,intregwe,rA,rB,rC,rF,intregdataA,intregdataB,intregdataC,intregdataF);
  aluplus alu0(instr4,opA,opB,opF,aluwrtval,alucjmpinstr,alucjmp,constBits4,retAddr,wrspec,irq_bits);
  ioinstr ioinstr0(clk,stall,stginhibit,instr4,opA,opB,ioInstrResult,wasGlobalStall,ioInstrWrtVal,ioInstrDoStall,ioInstrKeepStalling,
                   ioBusAddr,ioBusSize,ioBusOut,ioBusIn,ioBusRdy,ioBusWr,ioBusRd);
  subagu agu0(clk,stall,stginhibit,opC,instr0,instr,instr4,aguaddr,aguwrtval,agustall,agureadsz,agureaden,aguwriteen,constBits);
  brpred brpred0(clk,stall,stginhibit,fetchaddr,brpred_hit,brpred_instr,brpred_nextaddr,brpred_taken,
                 brpred_instertaddr,brpred_instertinstr,brpred_insertnextaddr,brpred_inserttaken,brpred_jumpinstr,brpred_addrMismatch);
  codecache codecache0(clk,ccFetchAddr,fetchdata,busInput,ccHit,ccReadEn,ccInsert,ccInit);

  assign dummy=stginhibit[4:1];
  assign fetchaddr=!(!stall && !stginhibit[1] && brpred_hit&&brpred_taken) ? IP : brpred_nextaddr;
  assign stall=init || ccInsertInProgress_tsk || dcInsertInProgress_tsk || ioInstrKeepStalling;

  assign readdata=dcDataA[31:0];
  assign dcReadEn=agureaden && !agustall;
  assign dcWriteEn=aguwriteen && !agustall;
  assign dcInsert=dcInsertInsert_tsk && busDataReady;
  assign dcInitEntry=dcInit;

  assign dcAddr=dcInit ? { 20'b0,dcInitCount,6'b0} : 32'bz;
  assign dcAddr=(dcReadEn || dcWriteEn) ? readaddr : 32'bz;
  assign dcAddr=dcInsert ? dcReadAddr : 32'bz;
  assign dcAddr=(!dcInit && !dcReadEn && !dcWriteEn && !dcInsert) ? 32'b0 : 32'bz;
  
  assign ccFetchAddr=ccInit ? { 20'b0,ccInitCount,6'b0} : 32'bz;
  assign ccFetchAddr=(!ccInit && !ccInsertInsert_tsk)? fetchaddr : 32'bz; //that should change to accomodate cache line insert
  assign ccFetchAddr=ccInsertInsert_tsk ? IP & 32'hffff_ffc0 : 32'bz;
  
  assign ccReadEn=!stall && !codeMiss[1] && !ccInit && !init;
  assign ccInsert=ccInsertInsert_tsk && busDataReady;

  assign busAddr=ccInsertRamReq_tsk ? IP & 32'hffff_ffc0 :32'bz; 
  assign busAddr=dcInsertRamReq_tsk ? dcReadAddr & 32'hffff_ffc0: 32'bz;
  assign busAddr=dcInsertWriteBack_tsk ? dcOldAddr_reg : 32'bz;
  assign busAddr=(!ccInsertRamReq_tsk && !dcInsertRamReq_tsk && !dcInsertWriteBack_tsk) ? 32'b0 : 32'bz;

  assign busRead=(ccInsertRamReq_tsk || dcInsertRamReq_tsk) && busEnRead;
  assign busWrite=dcInsertWriteBack_tsk && busEnWrite;

  assign dcDataWriteBack=dcDataA;
  assign busOutput=dcDataWriteBack_reg;
  
  assign rA0=instr0[10:6];
  assign rB0=instr0[15:11];
  assign rF0=instr0[20:16];
  assign rC=instr0[10:6];
  
  assign intregwe=!stall && !stginhibit[4] && (aluwrtval || aguwrtval) && (!agustall_reg) && !((agureaden_reg || aguwriteen_reg) && !dcHit); // adjust for other cases ie mem read-done;
  assign intregdataF= aguwrtval ? readdata : opF; //adjust for ie mem read-done
  assign opA=rAfwd ? regfwd : intregdataA;
  assign opB=rBfwd ? regfwd : intregdataB;
  assign opC=rCfwd ? regfwd : intregdataC; 

  //assign instr0=fetchdata; //change for branch prediction

  assign rFprev=instr[20:16];
  assign rFprevprev=instr4[20:16];
  //assign rAfwd=(rA==rFprev);
  //assign rBfwd=(rB==rFprev);
  //assign intregdataF=opF;

  assign readaddr=aguaddr;

  assign brpred_jumpinstr=alucjmpinstr || uJmpInstr;
  assign brpred_inserttaken=alucjmp || uJmpInstr;
  assign brpred_instertinstr=instr4;
  assign brpred_instertaddr=IP5;
  assign brpred_insertnextaddr=alucjmpinstr ? cjmpaddr : aguaddr_reg ;

  assign retAddr=IP5+4;
  assign uJmpInstr=(instr4[5:0]==46 || instr4[5:0]==47); 
  
  //regfwrt<=0;
  always @(posedge clk)
    begin
      if (init)
        begin
          initcount<=initcount-1;
          if (initcount==0) init<=0;
        end
      if (ccInit)
        begin
          ccInitCount<=ccInitCount-1;
          if (ccInitCount==0) ccInit<=0;
        end
      if (dcInit)
        begin
          dcInitCount<=dcInitCount-1;
          if (dcInitCount==0) dcInit<=0;
        end
      if (ccInsertRamReq_tsk && busEnRead)
        begin
          ccInsertRamReq_tsk<=0;
          ccInsertInsert_tsk<=1;
        end
      if (ccInsertInsert_tsk && busDataReady)
        begin
          ccInsertInsert_tsk<=0;
          ccInsertWait1_tsk<=1;
        end      
      if (ccInsertWait1_tsk)
        begin
          ccInsertWait1_tsk<=0;
          ccInsertWait2_tsk<=1;
        end      
      if (ccInsertWait2_tsk)
        begin
          ccInsertWait2_tsk<=0;
          ccInsertInProgress_tsk<=0;
        end      
      if (dcInsertRamReq_tsk && busEnRead)
        begin
          dcInsertRamReq_tsk<=0;
          dcInsertInsert_tsk<=1;
        end
      if (dcInsertInsert_tsk && busDataReady)
        begin
          dcInsertInsert_tsk<=0;
          dcInsertCheckDirty_tsk<=1;
        end
      if (dcInsertCheckDirty_tsk)
        begin
          dcInsertCheckDirty_tsk<=0;
          if (dcHit)
            begin
              dcInsertWriteBack_tsk<=1;
              dcOldAddr_reg<=dcOldAddr;
              dcDataWriteBack_reg<=dcDataWriteBack;
            end
          else
            begin
              dcInsertInProgress_tsk<=0;
            end
        end
      if (dcInsertWriteBack_tsk && busEnWrite)
        begin
          dcInsertWriteBack_tsk<=0;
          dcInsertInProgress_tsk<=0;
        end      
      //stginhibit_wrt=stginhibit;
      if (stginhibit[1]) stginhibit_wrt[2]=1;
      if (stginhibit[2]) stginhibit_wrt[3]=1;
      if (stginhibit[3]) stginhibit_wrt[4]=1;
      agustall_reg<=agustall;
      agureaden_reg<=agureaden;
      aguwriteen_reg<=aguwriteen;
      readaddr_reg<=readaddr;
      //cycle 1
      if (!stall)
        begin
          stginhibit[1]<=0;
          cycle1prev<=1;
          IP<=fetchaddr+4;
          IP2<=fetchaddr;
          multiCycleStall[1]<=multiCycleStall[0];
          multiCycleStall[0]<=0;
          if (irq&irq_mask)
            begin
              stginhibit<=5'b11110;
              codeMiss<=0;
              IP<=irq_handler;
              irq_bits<=irq;
            end
        end
      else  cycle1prev<=0;

      //cycle 2
      if (!stall && !stginhibit[1])
        begin
          stginhibit[2]<=0;
          IP3<=IP2;
          multiCycleStall[2]<=multiCycleStall[1];
          if (!(brpred_hit&&brpred_taken)) instr0<=ccHit ? fetchdata : 32'b01100;
            else instr0<=brpred_instr;
          brtaken3<=(brpred_hit&&brpred_taken);
          if (!ccHit) 
            begin
              codeMiss[1]<=1;
              codeMiss[2]<=1;
            end
          if (codeMiss[1]) codeMiss[2]<=1;
             
        end
      //cycle 3
      if (!stall && !stginhibit[2])
        begin
          instr<=instr0;
          //reg_instr0<=fetchdata;
          stginhibit[3]<=0;
          multiCycleStall[3]<=multiCycleStall[2];
          IP4<=IP3;
          rA<=instr0[10:6];
          rB<=instr0[15:11];
          brtaken4<=brtaken3;
          codeMiss[3]<=codeMiss[2];
          cjmpoffset0<={ {14{instr0[31]}}, instr0[31:16],2'b0 };
          if (instr0[5:0]==30) //upper bits instr
            begin
              prevUpperBits<=1;
              constBits[31:16]<=instr0[31:16];
            end
          else
            begin
              prevUpperBits<=0;
            end
          if (instr0[5:0]==60 || instr0[5:0]==61 || instr0[5:0]==62) //store instr
            begin
              constBits[15:0]<=instr0[31:16];
            end
          else  //non-store instr
            begin
              constBits[15:0]<={instr0[31:21],instr0[15:11]};
            end
          if (!prevUpperBits) constBits[31:16]<={16{instr0[31]}};
        end
      //cycle 4
      if (!stall && !stginhibit[3])
        begin
          constBits4<=constBits;
          stginhibit[4]<=0;
          IP5<=IP4;
          multiCycleStall[4]<=multiCycleStall[3];
          rAfwd0<=(rA0==rFprev);
          rBfwd0<=(rB0==rFprev);
          instr4<=instr;
          rF<=instr[20:16];
          cjmpoffset<={ {14{instr[31]}}, instr[31:16],2'b0 };
          cjmpaddr<=IP4+cjmpoffset0;
          brtaken5<=brtaken4;
          codeMiss[4]<=codeMiss[3];
          aguaddr_reg<=aguaddr;
        end
      //cycle 5
      
      if (!stall && !stginhibit[4]) //remove !stall ??
        begin
          rAfwd<=rAfwd0 && (aluwrtval || aguwrtval) && (!agustall_reg); //adjust for other sources of data
          rBfwd<=rBfwd0 && (aluwrtval || aguwrtval) && (!agustall_reg); //these 2 indicate forwarding of operands from regfwd
          rCfwd<=(rA0==rFprevprev) && (aluwrtval || aguwrtval) && (!agustall_reg);

          regfwd<=aguwrtval ? readdata : opF;
          if (codeMiss[4])
            begin
              stginhibit<=5'b11110;
              codeMiss<=0;
              IP<=IP5;
              ccInsertInProgress_tsk<=1;
              ccInsertRamReq_tsk<=1;
            end
          else if ((agureaden_reg || aguwriteen_reg) && !dcHit && !agustall_reg)
            begin
              stginhibit<=5'b11110;
              codeMiss<=0;
              IP<=IP5;
              dcInsertInProgress_tsk<=1;
              dcInsertRamReq_tsk<=1;
              dcReadAddr<=readaddr_reg;
            end
          else if ((((alucjmpinstr && alucjmp) || uJmpInstr) ^ brtaken5) || brpred_addrMismatch)  
            begin
              stginhibit<=5'b11110;
              codeMiss<=0;
              IP<=(alucjmp || uJmpInstr) ? (alucjmpinstr ? (IP5+cjmpoffset) : (opA+constBits4) ): IP5+4;
            end
          else if (agustall_reg)
            begin
              stginhibit<=5'b11110;
              codeMiss<=0;
              IP<=IP5;
            end
          else if (ioInstrDoStall)
            begin
              stginhibit<=5'b11110;
              codeMiss<=0;
              IP<=IP5;
              multiCycleStall[0]<=1;
            end
          else if (wrspec)
            begin
              case (instr4[31:24])
                8'd0: irq_handler<=opF;
                8'd1: sys_flags<=opF;
                8'd2: irq_mask<=opF;
              endcase
            end
        end
      else
        begin
          rAfwd<=0;
          rBfwd<=0;
          rCfwd<=0;
        end
      //
    end
endmodule
`include "config.v"

module datacache(input clk,input stall,input [4:0] stginhibit,input [4:0] codemiss,input [31:0] addrA,output `muxnet [511:0] dataA,input [511:0] cacheLine,input [31:0] writeData,output `muxnet cacheHit,input readen,input writeen,input insert,input initEntry,input [1:0] readsz,output `muxnet [31:0] oldAddr);

  wire tagwe;
  wire [31:0] tagAddrA;
  wire [31:0] tagAddrW;
  wire [119:0] tagDataA;
  `muxnet [119:0] tagDataW;
  reg  [31:0] tagAddrA_reg;

  reg readen_reg=0;
  reg writeen_reg=0;
  reg insert_reg=0;
  reg initEntry_reg=0;
  reg [119:0] tagDataA_fwd;
  wire [119:0] ramTagDataA;
  reg tag_fwd=0;

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
  wire dir0;
  wire dir1;
  wire dir2;
  wire dir3;

  wire [1:0] newPos0;
  wire [1:0] newPos1;
  wire [1:0] newPos2;
  wire [1:0] newPos3;

  `muxnet hit3,hit2,hit1,hit0;
  wire hit;

  wire ram0We,ram1We,ram2We,ram3We;
  wire [31:0] ramAddrW;
  wire [31:0] ramAddrA;
  wire [511:0] ramDataR0;
  wire [511:0] ramDataR1;
  wire [511:0] ramDataR2;
  wire [511:0] ramDataR3;
  wire [511:0] ramDataW0;
  wire [511:0] ramDataW1;
  wire [511:0] ramDataW2;
  wire [511:0] ramDataW3;
  wire [511:0] ramDataWA0;
  wire [511:0] ramDataWA1;
  wire [511:0] ramDataWA2;
  wire [511:0] ramDataWA3;
  reg  [511:0] cacheLine_reg;

  wire [31:0] dataA0;
  wire [31:0] dataA1;
  wire [31:0] dataA2;
  wire [31:0] dataA3;

  reg [1:0] readsz_reg;
  

  datacacheramtag tag0(clk,tagwe,tagAddrA[11:6],tagAddrW[11:6],ramTagDataA,tagDataW);
  datacache_get_new_pos newpos0(pos0,pos1,pos2,pos3,hit0,hit1,hit2,hit3,newPos0,newPos1,newPos2,newPos3);
  datacacheramfwd ram0(clk,ram0We,ramAddrA,ramAddrW,ramDataR0,ramDataW0);
  datacacheramfwd ram1(clk,ram1We,ramAddrA,ramAddrW,ramDataR1,ramDataW1);
  datacacheramfwd ram2(clk,ram2We,ramAddrA,ramAddrW,ramDataR2,ramDataW2);
  datacacheramfwd ram3(clk,ram3We,ramAddrA,ramAddrW,ramDataR3,ramDataW3);
  datacache_data_sel data_sel0(ramDataR0,tagAddrA_reg[5:0],readsz_reg,dataA0);
  datacache_data_sel data_sel1(ramDataR1,tagAddrA_reg[5:0],readsz_reg,dataA1);
  datacache_data_sel data_sel2(ramDataR2,tagAddrA_reg[5:0],readsz_reg,dataA2);
  datacache_data_sel data_sel3(ramDataR3,tagAddrA_reg[5:0],readsz_reg,dataA3);
  datacache_get_write_data wrtdat0 (ramDataR0,writeData,tagAddrA_reg,readsz_reg,ramDataWA0);
  datacache_get_write_data wrtdat1 (ramDataR1,writeData,tagAddrA_reg,readsz_reg,ramDataWA1);
  datacache_get_write_data wrtdat2 (ramDataR2,writeData,tagAddrA_reg,readsz_reg,ramDataWA2);
  datacache_get_write_data wrtdat3 (ramDataR3,writeData,tagAddrA_reg,readsz_reg,ramDataWA3);

  assign tagAddrA=addrA;
  assign tagDataA=tag_fwd ? tagDataA_fwd : ramTagDataA;
  assign tagwe=((readen_reg || writeen_reg) && !stall && !stginhibit[4] && !codemiss[4] ) || insert_reg || initEntry_reg; 
  assign tagAddrW=tagAddrA_reg;
  
  assign { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
           pos3,pos2,pos1,pos0,
           val3,val2,val1,val0,
           dir3,dir2,dir1,dir0 } = tagDataA;
  assign pad3[5:0]=6'b0;
  assign pad2[5:0]=6'b0;
  assign pad1[5:0]=6'b0;
  assign pad0[5:0]=6'b0;

  assign hit3=(readen_reg || writeen_reg) ? val3 && (pad3[31:6]==tagAddrA_reg[31:6]) : 1'b`muxval;
  assign hit2=(readen_reg || writeen_reg) ? val2 && (pad2[31:6]==tagAddrA_reg[31:6]) : 1'b`muxval;
  assign hit1=(readen_reg || writeen_reg) ? val1 && (pad1[31:6]==tagAddrA_reg[31:6]) : 1'b`muxval;
  assign hit0=(readen_reg || writeen_reg) ? val0 && (pad0[31:6]==tagAddrA_reg[31:6]) : 1'b`muxval;

  assign hit3=insert_reg ? (pos3==2'b11) : 1'b`muxval;
  assign hit2=insert_reg ? (pos2==2'b11) : 1'b`muxval;
  assign hit1=insert_reg ? (pos1==2'b11) : 1'b`muxval;
  assign hit0=insert_reg ? (pos0==2'b11) : 1'b`muxval;

  assign hit3=(!insert_reg && !readen_reg && !writeen_reg) ? 1'b0 : 1'b`muxval;
  assign hit2=(!insert_reg && !readen_reg && !writeen_reg) ? 1'b0 : 1'b`muxval;
  assign hit1=(!insert_reg && !readen_reg && !writeen_reg) ? 1'b0 : 1'b`muxval;
  assign hit0=(!insert_reg && !readen_reg && !writeen_reg) ? 1'b0 : 1'b`muxval;

  assign hit=hit3 || hit2 || hit1 || hit0;

  assign cacheHit= (insert_reg && hit0) ? val0 && dir0 : 1'b`muxval;
  assign cacheHit= (insert_reg && hit1) ? val1 && dir1 : 1'b`muxval;
  assign cacheHit= (insert_reg && hit2) ? val2 && dir2 : 1'b`muxval;
  assign cacheHit= (insert_reg && hit3) ? val3 && dir3 : 1'b`muxval;
  assign cacheHit= insert_reg ? 1'b`muxval : hit;

  assign tagDataW=readen_reg ? { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                 newPos3,newPos2,newPos1,newPos0,
                                 val3,val2,val1,val0,
                                 dir3,dir2,dir1,dir0 } : 120'b`muxval;
  assign tagDataW=(writeen_reg && hit0) ? { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                            newPos3,newPos2,newPos1,newPos0,
                                            val3,val2,val1,val0,
                                            dir3,dir2,dir1,1'b1 } : 120'b`muxval;
  assign tagDataW=(writeen_reg && hit1) ? { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                            newPos3,newPos2,newPos1,newPos0,
                                            val3,val2,val1,val0,
                                            dir3,dir2,1'b1,dir0 } : 120'b`muxval;
  assign tagDataW=(writeen_reg && hit2) ? { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                            newPos3,newPos2,newPos1,newPos0,
                                            val3,val2,val1,val0,
                                            dir3,1'b1,dir1,dir0 } : 120'b`muxval;
  assign tagDataW=(writeen_reg && hit3) ? { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                            newPos3,newPos2,newPos1,newPos0,
                                            val3,val2,val1,val0,
                                            1'b1,dir2,dir1,dir0 } : 120'b`muxval;
  assign tagDataW=(writeen_reg && !hit) ? { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                            newPos3,newPos2,newPos1,newPos0,
                                            val3,val2,val1,val0,
                                            dir3,dir2,dir1,dir0 } : 120'b`muxval;

  assign tagDataW=(insert_reg && hit0) ? { pad3[31:6],pad2[31:6],pad1[31:6],tagAddrA_reg[31:6],
                                           newPos3,newPos2,newPos1,newPos0,
                                           val3,val2,val1,1'b1,
                                           dir3,dir2,dir1,1'b0 } : 120'b`muxval;
  assign tagDataW=(insert_reg && hit1) ? { pad3[31:6],pad2[31:6],tagAddrA_reg[31:6],pad0[31:6],
                                           newPos3,newPos2,newPos1,newPos0,
                                           val3,val2,1'b1,val0,
                                           dir3,dir2,1'b0,dir0 } : 120'b`muxval;
  assign tagDataW=(insert_reg && hit2) ? { pad3[31:6],tagAddrA_reg[31:6],pad1[31:6],pad0[31:6],
                                           newPos3,newPos2,newPos1,newPos0,
                                           val3,1'b1,val1,val0,
                                           dir3,1'b0,dir1,dir0 } : 120'b`muxval;
  assign tagDataW=(insert_reg && hit3) ? { tagAddrA_reg[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                           newPos3,newPos2,newPos1,newPos0,
                                           1'b1,val2,val1,val0,
                                           1'b0,dir2,dir1,dir0 } : 120'b`muxval;
//  assign tagDataW=(insert_reg && !hit) ? 120'b0 : 120'bz;
  assign tagDataW=initEntry_reg ? { 26'b0,26'b0,26'b0,26'b0,
                                    2'b11,2'b10,2'b01,2'b00,
                                    1'b0,1'b0,1'b0,1'b0,
                                    1'b0,1'b0,1'b0,1'b0} : 120'b`muxval;
  assign tagDataW=(!insert_reg && !readen_reg && !writeen_reg && !initEntry_reg) ? 120'b0 : 120'b`muxval;

  assign dataA=(!insert_reg && hit0) ? {480'b0,dataA0} : 512'b`muxval; 
  assign dataA=(!insert_reg && hit1) ? {480'b0,dataA1} : 512'b`muxval; 
  assign dataA=(!insert_reg && hit2) ? {480'b0,dataA2} : 512'b`muxval; 

  assign dataA=(!insert_reg && hit3) ? {480'b0,dataA3} : 512'b`muxval;

  assign dataA=(insert_reg && hit0) ? ramDataR0 : 512'b`muxval; 

  assign dataA=(insert_reg && hit1) ? ramDataR1 : 512'b`muxval; 
  assign dataA=(insert_reg && hit2) ? ramDataR2 : 512'b`muxval; 
  assign dataA=(insert_reg && hit3) ? ramDataR3 : 512'b`muxval; 

  assign dataA= hit ? 512'b`muxval : 512'b0;  //change to accomodate non-read ops
  
  assign ramDataW0=insert_reg ? cacheLine_reg : ramDataWA0;
  assign ramDataW1=insert_reg ? cacheLine_reg : ramDataWA1;
  assign ramDataW2=insert_reg ? cacheLine_reg : ramDataWA2;
  assign ramDataW3=insert_reg ? cacheLine_reg : ramDataWA3;

  assign ram0We=(insert_reg || (writeen_reg && !stall && !codemiss[4] && !stginhibit[4])) && hit0;
  assign ram1We=(insert_reg || (writeen_reg && !stall && !codemiss[4] && !stginhibit[4])) && hit1;
  assign ram2We=(insert_reg || (writeen_reg && !stall && !codemiss[4] && !stginhibit[4])) && hit2;
  assign ram3We=(insert_reg || (writeen_reg && !stall && !codemiss[4] && !stginhibit[4])) && hit3;

  assign oldAddr=(insert_reg && hit0) ? pad0 : 32'b`muxval;
  assign oldAddr=(insert_reg && hit1) ? pad1 : 32'b`muxval;
  assign oldAddr=(insert_reg && hit2) ? pad2 : 32'b`muxval;
  assign oldAddr=(insert_reg && hit3) ? pad3 : 32'b`muxval;
  assign oldAddr=(!insert_reg) ? 32'b0 : 32'b`muxval;

  assign ramAddrA={tagAddrA[31:6],6'b0};
  assign ramAddrW={tagAddrA_reg[31:6],6'b0};

  always @(posedge clk)
    begin
      tagDataA_fwd<=tagDataW;
      tag_fwd<=tagwe && (addrA[11:6]==tagAddrA_reg[11:6]);
      tagAddrA_reg<=tagAddrA;
      readen_reg<=readen;
      writeen_reg<=writeen;
      insert_reg<=insert;
      initEntry_reg<=initEntry;
      cacheLine_reg<=cacheLine;
      readsz_reg<=readsz;
    end

endmodule

module datacacheram(input clk,input we,input [5:0] addrA,input [5:0] addrW,output reg [511:0] dataA,input [511:0] dataW);
  reg [511:0] ram [63:0];
  
  always @(posedge clk)
    begin
      dataA<=ram[addrA];
      if (we) ram[addrW]<=dataW;
    end    

endmodule

module datacacheramfwd(input clk,input we,input [31:0] addrA,input [31:0] addrW,output wire [511:0] dataA,input [511:0] dataW);
  wire [511:0] ramDataA;
  reg we_reg;
  reg [511:0] dataW_reg;
  reg [31:0] addrW_reg;
  reg fwd=0;

  datacacheram ram0(clk,we,addrA[11:6],addrW[11:6],ramDataA,dataW);

  
  assign dataA=fwd ? dataW_reg : ramDataA;
  
  always@(posedge clk)
    begin
      we_reg<=we;
      dataW_reg<=dataW;
      addrW_reg<=addrW;
      fwd<=we && (addrW[11:6]==addrA[11:6]);
    end
    
endmodule

/*
tag for 4 way set-asociative LRU data cache
{
{pad3,pad2,pad1,pad0}, //4x 26 bit physical address
{pos3,pos2,pos1,pos0}, //4xeach 2 bit LRU position, 8 bit
{val3,val2,val1,val0}  //4x 1 bit valid entry, 4 bit
{dir3,dir2,dir1,dir0}  //4x dirty bit 
}
length =30*4=120 bit tag 
*/

module datacacheramtag(input clk,input we,input [5:0] addrA,input [5:0] addrW,output reg [119:0] dataA,input [119:0] dataW);
  reg [119:0] ram [63:0];
  
  always @(posedge clk)
    begin
      dataA<=ram[addrA];
      if (we) ram[addrW]<=dataW;
    end    

endmodule

module datacache_get_new_pos(input [1:0] pos0,input [1:0] pos1,input [1:0] pos2,input [1:0] pos3,
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


module datacache_data_sel(input [511:0] dataIn,input [5:0] sel, input [1:0] readsz, output `muxnet [31:0] dataOut);
  wire [255:0] bit5Data;
  wire [127:0] bit4Data;
  wire [63:0]  bit3Data;
  wire [31:0]  data32;
  wire [15:0]  data16;
  wire [7:0]   data8;

  assign bit5Data=sel[5] ? dataIn[511:256] : dataIn[255:0];
  assign bit4Data=sel[4] ? bit5Data[255:128] : bit5Data[127:0];
  assign bit3Data=sel[3] ? bit4Data[127:64] : bit4Data[63:0];

  assign data32  =sel[2] ? bit3Data[63:32] : bit3Data[31:0];
  assign data16  =sel[1] ? data32[31:16] : data32[15:0];
  assign data8   =sel[0] ? data16[15:8] : data16[7:0];

  assign dataOut=(readsz==0) ? {24'b0,data8} : 32'b`muxval;
  assign dataOut=(readsz==1) ? {16'b0,data16} : 32'b`muxval;
  assign dataOut=(readsz==2) ? data32 : 32'b`muxval;
  assign dataOut=(readsz==4) ? 32'b0 : 32'b`muxval;
  
endmodule 


module datacache_write_shift(input [31:0] dataIn,input [1:0] writesz,input [31:0] addr, output wire [511:0] dataOut, output wire [63:0] byteEnable);
  `muxnet [511:0] data6;
  wire [511:0] data5;
  wire [511:0] data4;
  wire [511:0] data3;
  wire [511:0] data2;
  wire [511:0] data1;
  wire [511:0] data0;

  `muxnet [63:0] byteEnable6;
  wire [63:0] byteEnable5;
  wire [63:0] byteEnable4;
  wire [63:0] byteEnable3;
  wire [63:0] byteEnable2;
  wire [63:0] byteEnable1;
  wire [63:0] byteEnable0;

// change data6 to explicit mux!
  assign data6=(writesz==0) ? {504'b0,dataIn[7:0]} : 512'b`muxval;
  assign data6=(writesz==1) ? {496'b0,dataIn[15:0]} : 512'b`muxval;
  assign data6=(writesz==2) ? {480'b0,dataIn} : 512'b`muxval;
  assign data6=(writesz==3) ? 512'b0 : 512'b`muxval;

  assign data5=addr[5] ? { data6[255:0], 256'b0 }: data6;
  assign data4=addr[4] ? { data5[383:0], 128'b0 }: data5;
  assign data3=addr[3] ? { data4[447:0], 64'b0 }: data4;
  assign data2=addr[2] ? { data3[479:0], 32'b0 }: data3;
  assign data1=addr[1] ? { data2[495:0], 16'b0 }: data2;
  assign data0=addr[0] ? { data1[503:0], 8'b0 }: data1;

  assign dataOut=data0;
 //change byteEnable6 to explicit mux! 
  assign byteEnable6=(writesz==0) ? 64'b0001 : 64'b`muxval;
  assign byteEnable6=(writesz==1) ? 64'b0011 : 64'b`muxval;
  assign byteEnable6=(writesz==2) ? 64'b1111 : 64'b`muxval;
  assign byteEnable6=(writesz==3) ? 64'b0000 : 64'b`muxval;

  assign byteEnable5=addr[5] ? { byteEnable6[31:0],32'b0 } : byteEnable6;  
  assign byteEnable4=addr[4] ? { byteEnable5[47:0],16'b0 } : byteEnable5;  
  assign byteEnable3=addr[3] ? { byteEnable4[55:0],8'b0 } : byteEnable4;  
  assign byteEnable2=addr[2] ? { byteEnable3[59:0],4'b0 } : byteEnable3;  
  assign byteEnable1=addr[1] ? { byteEnable2[61:0],2'b0 } : byteEnable2;  
  assign byteEnable0=addr[0] ? { byteEnable1[62:0],1'b0 } : byteEnable1;  

  assign byteEnable=byteEnable0;

endmodule


module datacache_get_write_data(input [511:0] prevCacheline, input [31:0] data, input [31:0] addr, input [1:0] writesz,output wire [511:0] newCacheline);
  wire [511:0] cacheLine1;
  wire [63:0] byteEnable;
  datacache_write_shift shift0(data,writesz,addr,cacheLine1,byteEnable);
  assign newCacheline= 
    {
      byteEnable[63] ? cacheLine1[511:504] : prevCacheline[511:504],
      byteEnable[62] ? cacheLine1[503:496] : prevCacheline[503:496],
      byteEnable[61] ? cacheLine1[495:488] : prevCacheline[495:488],
      byteEnable[60] ? cacheLine1[487:480] : prevCacheline[487:480],
      byteEnable[59] ? cacheLine1[479:472] : prevCacheline[479:472],
      byteEnable[58] ? cacheLine1[471:464] : prevCacheline[471:464],
      byteEnable[57] ? cacheLine1[463:456] : prevCacheline[463:456],
      byteEnable[56] ? cacheLine1[455:448] : prevCacheline[455:448],
      byteEnable[55] ? cacheLine1[447:440] : prevCacheline[447:440],
      byteEnable[54] ? cacheLine1[439:432] : prevCacheline[439:432],
      byteEnable[53] ? cacheLine1[431:424] : prevCacheline[431:424],
      byteEnable[52] ? cacheLine1[423:416] : prevCacheline[423:416],
      byteEnable[51] ? cacheLine1[415:408] : prevCacheline[415:408],
      byteEnable[50] ? cacheLine1[407:400] : prevCacheline[407:400],
      byteEnable[49] ? cacheLine1[399:392] : prevCacheline[399:392],
      byteEnable[48] ? cacheLine1[391:384] : prevCacheline[391:384],
      byteEnable[47] ? cacheLine1[383:376] : prevCacheline[383:376],
      byteEnable[46] ? cacheLine1[375:368] : prevCacheline[375:368],
      byteEnable[45] ? cacheLine1[367:360] : prevCacheline[367:360],
      byteEnable[44] ? cacheLine1[359:352] : prevCacheline[359:352],
      byteEnable[43] ? cacheLine1[351:344] : prevCacheline[351:344],
      byteEnable[42] ? cacheLine1[343:336] : prevCacheline[343:336],
      byteEnable[41] ? cacheLine1[335:328] : prevCacheline[335:328],
      byteEnable[40] ? cacheLine1[327:320] : prevCacheline[327:320],
      byteEnable[39] ? cacheLine1[319:312] : prevCacheline[319:312],
      byteEnable[38] ? cacheLine1[311:304] : prevCacheline[311:304],
      byteEnable[37] ? cacheLine1[303:296] : prevCacheline[303:296],
      byteEnable[36] ? cacheLine1[295:288] : prevCacheline[295:288],
      byteEnable[35] ? cacheLine1[287:280] : prevCacheline[287:280],
      byteEnable[34] ? cacheLine1[279:272] : prevCacheline[279:272],
      byteEnable[33] ? cacheLine1[271:264] : prevCacheline[271:264],
      byteEnable[32] ? cacheLine1[263:256] : prevCacheline[263:256],
      byteEnable[31] ? cacheLine1[255:248] : prevCacheline[255:248],
      byteEnable[30] ? cacheLine1[247:240] : prevCacheline[247:240],
      byteEnable[29] ? cacheLine1[239:232] : prevCacheline[239:232],
      byteEnable[28] ? cacheLine1[231:224] : prevCacheline[231:224],
      byteEnable[27] ? cacheLine1[223:216] : prevCacheline[223:216],
      byteEnable[26] ? cacheLine1[215:208] : prevCacheline[215:208],
      byteEnable[25] ? cacheLine1[207:200] : prevCacheline[207:200],
      byteEnable[24] ? cacheLine1[199:192] : prevCacheline[199:192],
      byteEnable[23] ? cacheLine1[191:184] : prevCacheline[191:184],
      byteEnable[22] ? cacheLine1[183:176] : prevCacheline[183:176],
      byteEnable[21] ? cacheLine1[175:168] : prevCacheline[175:168],
      byteEnable[20] ? cacheLine1[167:160] : prevCacheline[167:160],
      byteEnable[19] ? cacheLine1[159:152] : prevCacheline[159:152],
      byteEnable[18] ? cacheLine1[151:144] : prevCacheline[151:144],
      byteEnable[17] ? cacheLine1[143:136] : prevCacheline[143:136],
      byteEnable[16] ? cacheLine1[135:128] : prevCacheline[135:128],
      byteEnable[15] ? cacheLine1[127:120] : prevCacheline[127:120],
      byteEnable[14] ? cacheLine1[119:112] : prevCacheline[119:112],
      byteEnable[13] ? cacheLine1[111:104] : prevCacheline[111:104],
      byteEnable[12] ? cacheLine1[103:96] : prevCacheline[103:96],
      byteEnable[11] ? cacheLine1[95:88] : prevCacheline[95:88],
      byteEnable[10] ? cacheLine1[87:80] : prevCacheline[87:80],
      byteEnable[9] ? cacheLine1[79:72] : prevCacheline[79:72],
      byteEnable[8] ? cacheLine1[71:64] : prevCacheline[71:64],
      byteEnable[7] ? cacheLine1[63:56] : prevCacheline[63:56],
      byteEnable[6] ? cacheLine1[55:48] : prevCacheline[55:48],
      byteEnable[5] ? cacheLine1[47:40] : prevCacheline[47:40],
      byteEnable[4] ? cacheLine1[39:32] : prevCacheline[39:32],
      byteEnable[3] ? cacheLine1[31:24] : prevCacheline[31:24],
      byteEnable[2] ? cacheLine1[23:16] : prevCacheline[23:16],
      byteEnable[1] ? cacheLine1[15:8] : prevCacheline[15:8],
      byteEnable[0] ? cacheLine1[7:0] : prevCacheline[7:0]
    };
  
endmodule
