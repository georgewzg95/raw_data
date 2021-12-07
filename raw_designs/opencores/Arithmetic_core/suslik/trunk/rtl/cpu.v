
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
