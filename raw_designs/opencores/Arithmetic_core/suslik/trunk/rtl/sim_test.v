`timescale 1 ns / 100 ps

module testram(input clk,input we, input [31:0] addrA, output reg [511:0] dataA,input [511:0] dataW);
  reg [31:0] ram0 [32767:0];
  always @(posedge clk)
    begin
      dataA<=
      {
        ram0[{addrA[16:6],4'd15}],
        ram0[{addrA[16:6],4'd14}],
        ram0[{addrA[16:6],4'd13}],
        ram0[{addrA[16:6],4'd12}],
        ram0[{addrA[16:6],4'd11}],
        ram0[{addrA[16:6],4'd10}],
        ram0[{addrA[16:6],4'd9}],
        ram0[{addrA[16:6],4'd8}],
        ram0[{addrA[16:6],4'd7}],
        ram0[{addrA[16:6],4'd6}],
        ram0[{addrA[16:6],4'd5}],
        ram0[{addrA[16:6],4'd4}],
        ram0[{addrA[16:6],4'd3}],
        ram0[{addrA[16:6],4'd2}],
        ram0[{addrA[16:6],4'd1}],
        ram0[{addrA[16:6],4'd0}]
      };
      if (we)
        begin
          ram0[{addrA[16:6],4'd0}]<=dataW[31:0];
          ram0[{addrA[16:6],4'd1}]<=dataW[63:32];
          ram0[{addrA[16:6],4'd2}]<=dataW[95:64];
          ram0[{addrA[16:6],4'd3}]<=dataW[127:96];
          ram0[{addrA[16:6],4'd4}]<=dataW[159:128];
          ram0[{addrA[16:6],4'd5}]<=dataW[191:160];
          ram0[{addrA[16:6],4'd6}]<=dataW[223:192];
          ram0[{addrA[16:6],4'd7}]<=dataW[255:224];
          ram0[{addrA[16:6],4'd8}]<=dataW[287:256];
          ram0[{addrA[16:6],4'd9}]<=dataW[319:288];
          ram0[{addrA[16:6],4'd10}]<=dataW[351:320];
          ram0[{addrA[16:6],4'd11}]<=dataW[383:352];
          ram0[{addrA[16:6],4'd12}]<=dataW[415:384];
          ram0[{addrA[16:6],4'd13}]<=dataW[447:416];
          ram0[{addrA[16:6],4'd14}]<=dataW[479:448];
          ram0[{addrA[16:6],4'd15}]<=dataW[511:480];
        end

    end
endmodule

module cpu2r6test();

  reg clk=0;
  wire busEnRead=1;
  wire busEnWrite=1;
  wire busRead;
  wire busWrite;
  wire [31:0] busAddr;
  wire [511:0] busInput;
  wire [511:0] ramDataA;
  wire [511:0] ramDataW;
  reg [511:0] dataW_reg;
  reg we_reg=0;
  wire we;
  reg [31:0] addr_reg;
  reg busRdy=0;

  wire [31:0] ioBusAddr;
  wire [1:0] ioBusSize;
  wire [31:0] ioBusOut;
  wire [31:0] ioBusIn;
  reg ioBusRdy=0;
  wire ioBusWr;
  wire ioBusRd;
  wire [3:0] dummy;

  cpu2r6 mycpu2(clk,busEnRead,busEnWrite,busRdy,busRead,busWrite,busAddr,busInput,ramDataW,
                ioBusAddr,ioBusSize,ioBusOut,ioBusIn,ioBusRdy,ioBusWr,ioBusRd,dummy);
  testram ram0(clk,we,busAddr,ramDataA,ramDataW);

  assign busInput=(we_reg && (busAddr==addr_reg)) ? dataW_reg : ramDataA;
  assign we=busWrite;
  
  always @(posedge clk)
    begin
      ioBusRdy<=ioBusWr || ioBusRd;
      we_reg<=we;
      dataW_reg<=ramDataW;
      addr_reg<=busAddr;
      busRdy<=busRead;
      if (ioBusWr) $display("out addr %h,data %h",ioBusAddr,ioBusOut);
      if (ioBusRd) $display("in addr %h",ioBusAddr);      
    end
    
  always
    #100 clk<=!clk;

  initial
    begin
      $readmemh("testmem6.hex",ram0.ram0);
      $monitor("r2=0x%h",mycpu2.regf0.ram0.regs[2]);
    end
  
endmodule


