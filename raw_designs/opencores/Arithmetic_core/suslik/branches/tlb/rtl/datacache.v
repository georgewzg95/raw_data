`include "config.v"

module datacache(
  input clk,
  input stall,
  input [4:0] stginhibit, 
  input [4:0] codemiss,
  input [31:0] addrA,
  output wire [511:0] dataA,
  input [511:0] cacheLine,
  input [31:0] writeData,
  output wire cacheHit,
  input readen,
  input writeen,
  input insert,
  input initEntry,
  input [1:0] readsz,
  output wire [31:0] oldAddr);

  wire tagwe;
  wire [31:0] tagAddrA;
  wire [31:0] tagAddrW;
  wire [119:0] tagDataA;
  wire [119:0] tagDataW;
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

  wire hit3,hit2,hit1,hit0;
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

  assign hit3=(readen_reg || writeen_reg) ? val3 && (pad3[31:6]==tagAddrA_reg[31:6]) : 1'bz;
  assign hit2=(readen_reg || writeen_reg) ? val2 && (pad2[31:6]==tagAddrA_reg[31:6]) : 1'bz;
  assign hit1=(readen_reg || writeen_reg) ? val1 && (pad1[31:6]==tagAddrA_reg[31:6]) : 1'bz;
  assign hit0=(readen_reg || writeen_reg) ? val0 && (pad0[31:6]==tagAddrA_reg[31:6]) : 1'bz;

  assign hit3=insert_reg ? (pos3==2'b11) : 1'bz;
  assign hit2=insert_reg ? (pos2==2'b11) : 1'bz;
  assign hit1=insert_reg ? (pos1==2'b11) : 1'bz;
  assign hit0=insert_reg ? (pos0==2'b11) : 1'bz;

  assign hit3=(!insert_reg && !readen_reg && !writeen_reg) ? 1'b0 : 1'bz;
  assign hit2=(!insert_reg && !readen_reg && !writeen_reg) ? 1'b0 : 1'bz;
  assign hit1=(!insert_reg && !readen_reg && !writeen_reg) ? 1'b0 : 1'bz;
  assign hit0=(!insert_reg && !readen_reg && !writeen_reg) ? 1'b0 : 1'bz;

  assign hit=hit3 || hit2 || hit1 || hit0;

  assign cacheHit= (insert_reg && hit0) ? val0 && dir0 : 1'bz;
  assign cacheHit= (insert_reg && hit1) ? val1 && dir1 : 1'bz;
  assign cacheHit= (insert_reg && hit2) ? val2 && dir2 : 1'bz;
  assign cacheHit= (insert_reg && hit3) ? val3 && dir3 : 1'bz;
  assign cacheHit= insert_reg ? 1'bz : hit;

  assign tagDataW=readen_reg ? { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                 newPos3,newPos2,newPos1,newPos0,
                                 val3,val2,val1,val0,
                                 dir3,dir2,dir1,dir0 } : 120'bz;
  assign tagDataW=(writeen_reg && hit0) ? { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                            newPos3,newPos2,newPos1,newPos0,
                                            val3,val2,val1,val0,
                                            dir3,dir2,dir1,1'b1 } : 120'bz;
  assign tagDataW=(writeen_reg && hit1) ? { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                            newPos3,newPos2,newPos1,newPos0,
                                            val3,val2,val1,val0,
                                            dir3,dir2,1'b1,dir0 } : 120'bz;
  assign tagDataW=(writeen_reg && hit2) ? { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                            newPos3,newPos2,newPos1,newPos0,
                                            val3,val2,val1,val0,
                                            dir3,1'b1,dir1,dir0 } : 120'bz;
  assign tagDataW=(writeen_reg && hit3) ? { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                            newPos3,newPos2,newPos1,newPos0,
                                            val3,val2,val1,val0,
                                            1'b1,dir2,dir1,dir0 } : 120'bz;
  assign tagDataW=(writeen_reg && !hit) ? { pad3[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                            newPos3,newPos2,newPos1,newPos0,
                                            val3,val2,val1,val0,
                                            dir3,dir2,dir1,dir0 } : 120'bz;

  assign tagDataW=(insert_reg && hit0) ? { pad3[31:6],pad2[31:6],pad1[31:6],tagAddrA_reg[31:6],
                                           newPos3,newPos2,newPos1,newPos0,
                                           val3,val2,val1,1'b1,
                                           dir3,dir2,dir1,1'b0 } : 120'bz;
  assign tagDataW=(insert_reg && hit1) ? { pad3[31:6],pad2[31:6],tagAddrA_reg[31:6],pad0[31:6],
                                           newPos3,newPos2,newPos1,newPos0,
                                           val3,val2,1'b1,val0,
                                           dir3,dir2,1'b0,dir0 } : 120'bz;
  assign tagDataW=(insert_reg && hit2) ? { pad3[31:6],tagAddrA_reg[31:6],pad1[31:6],pad0[31:6],
                                           newPos3,newPos2,newPos1,newPos0,
                                           val3,1'b1,val1,val0,
                                           dir3,1'b0,dir1,dir0 } : 120'bz;
  assign tagDataW=(insert_reg && hit3) ? { tagAddrA_reg[31:6],pad2[31:6],pad1[31:6],pad0[31:6],
                                           newPos3,newPos2,newPos1,newPos0,
                                           1'b1,val2,val1,val0,
                                           1'b0,dir2,dir1,dir0 } : 120'bz;
//  assign tagDataW=(insert_reg && !hit) ? 120'b0 : 120'bz;
  assign tagDataW=initEntry_reg ? { 26'b0,26'b0,26'b0,26'b0,
                                    2'b11,2'b10,2'b01,2'b00,
                                    1'b0,1'b0,1'b0,1'b0,
                                    1'b0,1'b0,1'b0,1'b0} : 120'bz;
  assign tagDataW=(!insert_reg && !readen_reg && !writeen_reg && !initEntry_reg) ? 120'b0 : 120'bz;

  assign dataA=(!insert_reg && hit0) ? {480'b0,dataA0} : 512'bz; 
  assign dataA=(!insert_reg && hit1) ? {480'b0,dataA1} : 512'bz; 
  assign dataA=(!insert_reg && hit2) ? {480'b0,dataA2} : 512'bz; 

  assign dataA=(!insert_reg && hit3) ? {480'b0,dataA3} : 512'bz;

  assign dataA=(insert_reg && hit0) ? ramDataR0 : 512'bz; 

  assign dataA=(insert_reg && hit1) ? ramDataR1 : 512'bz; 
  assign dataA=(insert_reg && hit2) ? ramDataR2 : 512'bz; 
  assign dataA=(insert_reg && hit3) ? ramDataR3 : 512'bz; 

  assign dataA= hit ? 512'bz : 512'b0;  //change to accomodate non-read ops
  
  assign ramDataW0=insert_reg ? cacheLine_reg : ramDataWA0;
  assign ramDataW1=insert_reg ? cacheLine_reg : ramDataWA1;
  assign ramDataW2=insert_reg ? cacheLine_reg : ramDataWA2;
  assign ramDataW3=insert_reg ? cacheLine_reg : ramDataWA3;

  assign ram0We=(insert_reg || (writeen_reg && !stall && !codemiss[4] && !stginhibit[4])) && hit0;
  assign ram1We=(insert_reg || (writeen_reg && !stall && !codemiss[4] && !stginhibit[4])) && hit1;
  assign ram2We=(insert_reg || (writeen_reg && !stall && !codemiss[4] && !stginhibit[4])) && hit2;
  assign ram3We=(insert_reg || (writeen_reg && !stall && !codemiss[4] && !stginhibit[4])) && hit3;

  assign oldAddr=(insert_reg && hit0) ? pad0 : 32'bz;
  assign oldAddr=(insert_reg && hit1) ? pad1 : 32'bz;
  assign oldAddr=(insert_reg && hit2) ? pad2 : 32'bz;
  assign oldAddr=(insert_reg && hit3) ? pad3 : 32'bz;
  assign oldAddr=(!insert_reg) ? 32'b0 : 32'bz;

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


module datacache_data_sel(input [511:0] dataIn,input [5:0] sel, input [1:0] readsz, output wire [31:0] dataOut);
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

  assign dataOut=(readsz==0) ? {24'b0,data8} : 32'bz;
  assign dataOut=(readsz==1) ? {16'b0,data16} : 32'bz;
  assign dataOut=(readsz==2) ? data32 : 32'bz;
  assign dataOut=(readsz==4) ? 32'b0 : 32'bz;
  
endmodule 


module datacache_write_shift(input [31:0] dataIn,input [1:0] writesz,input [31:0] addr, output wire [511:0] dataOut, output wire [63:0] byteEnable);
  wire [511:0] data6;
  wire [511:0] data5;
  wire [511:0] data4;
  wire [511:0] data3;
  wire [511:0] data2;
  wire [511:0] data1;
  wire [511:0] data0;

  wire [63:0] byteEnable6;
  wire [63:0] byteEnable5;
  wire [63:0] byteEnable4;
  wire [63:0] byteEnable3;
  wire [63:0] byteEnable2;
  wire [63:0] byteEnable1;
  wire [63:0] byteEnable0;

// change data6 to explicit mux!
  assign data6=(writesz==0) ? {504'b0,dataIn[7:0]} : 512'bz;
  assign data6=(writesz==1) ? {496'b0,dataIn[15:0]} : 512'bz;
  assign data6=(writesz==2) ? {480'b0,dataIn} : 512'bz;
  assign data6=(writesz==3) ? 512'b0 : 512'bz;

  assign data5=addr[5] ? { data6[255:0], 256'b0 }: data6;
  assign data4=addr[4] ? { data5[383:0], 128'b0 }: data5;
  assign data3=addr[3] ? { data4[447:0], 64'b0 }: data4;
  assign data2=addr[2] ? { data3[479:0], 32'b0 }: data3;
  assign data1=addr[1] ? { data2[495:0], 16'b0 }: data2;
  assign data0=addr[0] ? { data1[503:0], 8'b0 }: data1;

  assign dataOut=data0;
 //change byteEnable6 to explicit mux! 
  assign byteEnable6=(writesz==0) ? 64'b0001 : 64'bz;
  assign byteEnable6=(writesz==1) ? 64'b0011 : 64'bz;
  assign byteEnable6=(writesz==2) ? 64'b1111 : 64'bz;
  assign byteEnable6=(writesz==3) ? 64'b0000 : 64'bz;

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
