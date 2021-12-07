//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "fault_sm.v"                                      ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module fault_sm(/*AUTOARG*/
  // Outputs
  status_local_fault_crx, status_remote_fault_crx,
  // Inputs
  clk_xgmii_rx, reset_xgmii_rx_n, local_fault_msg_det,
  remote_fault_msg_det
  );

input         clk_xgmii_rx;
input         reset_xgmii_rx_n;
   
input  [1:0]  local_fault_msg_det;
input  [1:0]  remote_fault_msg_det;

output        status_local_fault_crx;
output        status_remote_fault_crx;

/*AUTOREG*/
// Beginning of automatic regs (for this module's undeclared outputs)
reg                     status_local_fault_crx;
reg                     status_remote_fault_crx;
// End of automatics

reg    [1:0]  curr_state;

reg    [7:0]  col_cnt;
reg    [1:0]  fault_sequence;
reg    [1:0]  last_seq_type;
reg    [1:0]  link_fault;
reg    [2:0]  seq_cnt;
reg    [1:0]  seq_type;

reg    [1:0]  seq_add;

/*AUTOWIRE*/


parameter [1:0]
             SM_INIT       = 2'd0,
             SM_COUNT      = 2'd1,
             SM_FAULT      = 2'd2,
             SM_NEW_FAULT  = 2'd3;


always @(/*AS*/local_fault_msg_det or remote_fault_msg_det) begin

    //---
    // Fault indication. Indicate remote or local fault

    fault_sequence = local_fault_msg_det | remote_fault_msg_det;


    //---
    // Sequence type, local, remote, or ok

    if (|local_fault_msg_det) begin
        seq_type = `LINK_FAULT_LOCAL;
    end
    else if (|remote_fault_msg_det) begin
        seq_type = `LINK_FAULT_REMOTE;
    end
    else begin
        seq_type = `LINK_FAULT_OK;
    end


    //---
    // Adder for number of faults, if detected in lower 4 lanes and
    // upper 4 lanes, add 2. That's because we process 64-bit at a time
    // instead of typically 32-bit xgmii.

    if (|remote_fault_msg_det) begin
        seq_add = remote_fault_msg_det[1] + remote_fault_msg_det[0];
    end
    else begin
        seq_add = local_fault_msg_det[1] + local_fault_msg_det[0];
    end

end

always @(posedge clk_xgmii_rx or negedge reset_xgmii_rx_n) begin

    if (reset_xgmii_rx_n == 1'b0) begin


        status_local_fault_crx <= 1'b0;
        status_remote_fault_crx <= 1'b0;

    end
    else begin

        //---
        // Status signal to generate local/remote fault interrupts

        status_local_fault_crx <= curr_state == SM_FAULT &&
                                  link_fault == `LINK_FAULT_LOCAL;

        status_remote_fault_crx <= curr_state == SM_FAULT &&
                                   link_fault == `LINK_FAULT_REMOTE;

    end

end

always @(posedge clk_xgmii_rx or negedge reset_xgmii_rx_n) begin

    if (reset_xgmii_rx_n == 1'b0) begin

        curr_state <= SM_INIT;

        col_cnt <= 8'b0;
        last_seq_type <= `LINK_FAULT_OK;
        link_fault <= `LINK_FAULT_OK;
        seq_cnt <= 3'b0;

    end
    else begin

        case (curr_state)

          SM_INIT:
            begin

                last_seq_type <= seq_type;

                if (|fault_sequence) begin

                    // If a fault is detected, capture the type of
                    // fault and start column counter. We need 4 fault
                    // messages in 128 columns to accept the fault.

                    if (fault_sequence[0]) begin
                        col_cnt <= 8'd2;
                    end
                    else begin
                        col_cnt <= 8'd1;
                    end
                    seq_cnt <= {1'b0, seq_add};
                    curr_state <= SM_COUNT;

                end
                else begin

                    // If no faults, stay in INIT and clear counters
                    
                    col_cnt <= 8'b0;
                    seq_cnt <= 3'b0;

                end
            end

          SM_COUNT:
            begin

                col_cnt <= col_cnt + 8'd2;
                seq_cnt <= seq_cnt + {1'b0, seq_add};

                if (!fault_sequence[0] && col_cnt >= 8'd127) begin

                    // No new fault in lower lanes and almost
                    // reached the 128 columns count, abort fault. 

                    curr_state <= SM_INIT;

                end
                else if (col_cnt > 8'd127) begin

                    // Reached the 128 columns count, abort fault.
                    
                    curr_state <= SM_INIT;

                end
                else if (|fault_sequence) begin

                    // If fault type has changed, move to NEW_FAULT.
                    // If not, after detecting 4 fault messages move to
                    // FAULT state.

                    if (seq_type != last_seq_type) begin
                        curr_state <= SM_NEW_FAULT;
                    end
                    else begin
                        if ((seq_cnt + {1'b0, seq_add}) > 3'd3) begin
                            col_cnt <= 8'b0;
                            link_fault <= seq_type;
                            curr_state <= SM_FAULT;
                        end
                    end

                end
            end

          SM_FAULT:
            begin

                col_cnt <= col_cnt + 8'd2;
                
                if (!fault_sequence[0] && col_cnt >= 8'd127) begin

                    // No new fault in lower lanes and almost
                    // reached the 128 columns count, abort fault. 

                    curr_state <= SM_INIT;

                end
                else if (col_cnt > 8'd127) begin

                    // Reached the 128 columns count, abort fault.

                    curr_state <= SM_INIT;

                end
                else if (|fault_sequence) begin

                    // Clear the column count each time we see a fault,
                    // if fault changes, go no next state.

                    col_cnt <= 8'd0;

                    if (seq_type != last_seq_type) begin
                        curr_state <= SM_NEW_FAULT;
                    end
                end

            end

          SM_NEW_FAULT:
            begin

                // Capture new fault type. Start counters.
                
                col_cnt <= 8'b0;
                last_seq_type <= seq_type;

                seq_cnt <= {1'b0, seq_add};
                curr_state <= SM_COUNT;

            end

        endcase
       
    end

end

endmodule

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "generic_fifo_ctrl.v"                             ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


module generic_fifo_ctrl(

    wclk,
    wrst_n,
    wen,
    wfull,
    walmost_full,

    mem_wen,
    mem_waddr,

    rclk,
    rrst_n,
    ren,
    rempty,
    ralmost_empty,

    mem_ren,
    mem_raddr
);

//---
// Parameters

parameter AWIDTH = 3;
parameter RAM_DEPTH = (1 << AWIDTH);
parameter EARLY_READ = 0;
parameter CLOCK_CROSSING = 1;
parameter ALMOST_EMPTY_THRESH = 1;
parameter ALMOST_FULL_THRESH = RAM_DEPTH-2;

//---
// Ports

input              wclk;
input              wrst_n;
input              wen;
output             wfull;
output             walmost_full;

output             mem_wen;
output [AWIDTH:0]  mem_waddr;

input              rclk;
input              rrst_n;
input              ren;
output             rempty;
output             ralmost_empty;

output             mem_ren;
output [AWIDTH:0]  mem_raddr;



//---
// Local declarations

// Registers

reg  [AWIDTH:0]   wr_ptr;
reg  [AWIDTH:0]   rd_ptr;
reg  [AWIDTH:0]   next_rd_ptr;

// Combinatorial

wire [AWIDTH:0]   wr_gray;
reg  [AWIDTH:0]   wr_gray_reg;
reg  [AWIDTH:0]   wr_gray_meta;
reg  [AWIDTH:0]   wr_gray_sync;
reg  [AWIDTH:0]   wck_rd_ptr;
wire [AWIDTH:0]   wck_level;

wire [AWIDTH:0]   rd_gray;
reg  [AWIDTH:0]   rd_gray_reg;
reg  [AWIDTH:0]   rd_gray_meta;
reg  [AWIDTH:0]   rd_gray_sync;
reg  [AWIDTH:0]   rck_wr_ptr;
wire [AWIDTH:0]   rck_level;

wire [AWIDTH:0]   depth;
wire [AWIDTH:0]   empty_thresh;
wire [AWIDTH:0]   full_thresh;

// Variables

integer         i;

//---
// Assignments

assign depth = RAM_DEPTH[AWIDTH:0];
assign empty_thresh = ALMOST_EMPTY_THRESH[AWIDTH:0];
assign full_thresh = ALMOST_FULL_THRESH[AWIDTH:0];

assign wfull = (wck_level == depth);
assign walmost_full = (wck_level >= (depth - full_thresh));
assign rempty = (rck_level == 0);
assign ralmost_empty = (rck_level <= empty_thresh);

//---
// Write Pointer

always @(posedge wclk or negedge wrst_n)
begin
    if (!wrst_n) begin
        wr_ptr <= {(AWIDTH+1){1'b0}};
    end
    else if (wen && !wfull) begin
        wr_ptr <= wr_ptr + {{(AWIDTH){1'b0}}, 1'b1};
    end
end

//---
// Read Pointer

always @(ren, rd_ptr, rck_wr_ptr)
begin
    next_rd_ptr = rd_ptr;
    if (ren && rd_ptr != rck_wr_ptr) begin
        next_rd_ptr = rd_ptr + {{(AWIDTH){1'b0}}, 1'b1};
    end
end

always @(posedge rclk or negedge rrst_n)
begin
    if (!rrst_n) begin
        rd_ptr <= {(AWIDTH+1){1'b0}};
    end
    else begin
        rd_ptr <= next_rd_ptr;
    end
end

//---
// Binary to Gray conversion

assign wr_gray = wr_ptr ^ (wr_ptr >> 1);
assign rd_gray = rd_ptr ^ (rd_ptr >> 1);

//---
// Gray to Binary conversion

always @(wr_gray_sync)
begin
    rck_wr_ptr[AWIDTH] = wr_gray_sync[AWIDTH];
    for (i = 0; i < AWIDTH; i = i + 1) begin
        rck_wr_ptr[AWIDTH-i-1] = rck_wr_ptr[AWIDTH-i] ^ wr_gray_sync[AWIDTH-i-1];
    end
end

always @(rd_gray_sync)
begin
    wck_rd_ptr[AWIDTH] = rd_gray_sync[AWIDTH];
    for (i = 0; i < AWIDTH; i = i + 1) begin
        wck_rd_ptr[AWIDTH-i-1] = wck_rd_ptr[AWIDTH-i] ^ rd_gray_sync[AWIDTH-i-1];
    end
end

//---
// Clock-Domain Crossing

generate
    if (CLOCK_CROSSING) begin

        // Instantiate metastability flops
        always @(posedge rclk or negedge rrst_n)
        begin
            if (!rrst_n) begin
                rd_gray_reg <= {(AWIDTH+1){1'b0}};
                wr_gray_meta <= {(AWIDTH+1){1'b0}};
                wr_gray_sync <= {(AWIDTH+1){1'b0}};
            end
            else begin
                rd_gray_reg <= rd_gray;
                wr_gray_meta <= wr_gray_reg;
                wr_gray_sync <= wr_gray_meta;
            end
        end

        always @(posedge wclk or negedge wrst_n)
        begin
            if (!wrst_n) begin
                wr_gray_reg <= {(AWIDTH+1){1'b0}};
                rd_gray_meta <= {(AWIDTH+1){1'b0}};
                rd_gray_sync <= {(AWIDTH+1){1'b0}};
            end
            else begin
                wr_gray_reg <= wr_gray;
                rd_gray_meta <= rd_gray_reg;
                rd_gray_sync <= rd_gray_meta;
            end
        end
    end
    else begin

        // No clock domain crossing
        always @(wr_gray or rd_gray)
        begin
            wr_gray_sync = wr_gray;
            rd_gray_sync = rd_gray;
        end
    end
endgenerate

//---
// FIFO Level

assign wck_level = wr_ptr - wck_rd_ptr;
assign rck_level = rck_wr_ptr - rd_ptr;

//---
// Memory controls

assign  mem_waddr = wr_ptr;
assign  mem_wen = wen && !wfull;

generate
    if (EARLY_READ) begin

        // With early read, data will be present at output
        // before ren is asserted. Usufull if we want to add
        // an output register and not add latency.
        assign mem_raddr = next_rd_ptr;
        assign mem_ren = 1'b1;

    end
    else begin

        assign mem_raddr = rd_ptr;
        assign mem_ren = ren;

    end
endgenerate

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "generic_fifo.v"                                  ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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

`include "defines.v"

module generic_fifo(

    wclk,
    wrst_n,
    wen,
    wdata,
    wfull,
    walmost_full,

    rclk,
    rrst_n,
    ren,
    rdata,
    rempty,
    ralmost_empty
);

//---
// Parameters

parameter DWIDTH = 32;
parameter AWIDTH = 3;
parameter RAM_DEPTH = (1 << AWIDTH);
parameter REGISTER_READ = 0;
parameter EARLY_READ = 0;
parameter CLOCK_CROSSING = 1;
parameter ALMOST_EMPTY_THRESH = 1;
parameter ALMOST_FULL_THRESH = RAM_DEPTH-2;
parameter MEM_TYPE = `MEM_AUTO_SMALL;

//---
// Ports

input          wclk;
input          wrst_n;
input          wen;
input  [DWIDTH-1:0] wdata;
output         wfull;
output         walmost_full;

input          rclk;
input          rrst_n;
input          ren;
output [DWIDTH-1:0] rdata;
output         rempty;
output         ralmost_empty;

// Wires

wire             mem_wen;
wire [AWIDTH:0]  mem_waddr;

wire             mem_ren;
wire [AWIDTH:0]  mem_raddr;


generic_fifo_ctrl #(.AWIDTH (AWIDTH),
                    .RAM_DEPTH (RAM_DEPTH),
                    .EARLY_READ (EARLY_READ),
                    .CLOCK_CROSSING (CLOCK_CROSSING),
                    .ALMOST_EMPTY_THRESH (ALMOST_EMPTY_THRESH),
                    .ALMOST_FULL_THRESH (ALMOST_FULL_THRESH)
                    )
  ctrl0(.wclk (wclk),
        .wrst_n (wrst_n),
        .wen (wen),
        .wfull (wfull),
        .walmost_full (walmost_full),

        .mem_wen (mem_wen),
        .mem_waddr (mem_waddr),

        .rclk (rclk),
        .rrst_n (rrst_n),
        .ren (ren),
        .rempty (rempty),
        .ralmost_empty (ralmost_empty),

        .mem_ren (mem_ren),
        .mem_raddr (mem_raddr)
        );


generate
    if (MEM_TYPE == `MEM_AUTO_SMALL) begin

        generic_mem_small #(.DWIDTH (DWIDTH),
                            .AWIDTH (AWIDTH),
                            .RAM_DEPTH (RAM_DEPTH),
                            .REGISTER_READ (REGISTER_READ)
                            )
          mem0(.wclk (wclk),
               .wrst_n (wrst_n),
               .wen (mem_wen),
               .waddr (mem_waddr[AWIDTH-1:0]),
               .wdata (wdata),

               .rclk (rclk),
               .rrst_n (rrst_n),
               .ren (mem_ren),
               .roen (ren),
               .raddr (mem_raddr[AWIDTH-1:0]),
               .rdata (rdata)
               );

    end

    if (MEM_TYPE == `MEM_AUTO_MEDIUM) begin

        generic_mem_medium #(.DWIDTH (DWIDTH),
                             .AWIDTH (AWIDTH),
                             .RAM_DEPTH (RAM_DEPTH),
                             .REGISTER_READ (REGISTER_READ)
                             )
          mem0(.wclk (wclk),
               .wrst_n (wrst_n),
               .wen (mem_wen),
               .waddr (mem_waddr[AWIDTH-1:0]),
               .wdata (wdata),

               .rclk (rclk),
               .rrst_n (rrst_n),
               .ren (mem_ren),
               .roen (ren),
               .raddr (mem_raddr[AWIDTH-1:0]),
               .rdata (rdata)
               );

    end

endgenerate

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "generic_mem_medium.v"                            ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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

`include "defines.v"

/* synthesis ramstyle = "M4K" */

module generic_mem_medium(

    wclk,
    wrst_n,
    wen,
    waddr,
    wdata,

    rclk,
    rrst_n,
    ren,
    roen,
    raddr,
    rdata
);

//---
// Parameters

parameter DWIDTH = 32;
parameter AWIDTH = 3;
parameter RAM_DEPTH = (1 << AWIDTH);
parameter REGISTER_READ = 0;

//---
// Ports

input               wclk;
input               wrst_n;
input               wen;
input  [AWIDTH-1:0] waddr;
input  [DWIDTH-1:0] wdata;

input               rclk;
input               rrst_n;
input               ren;
input               roen;
input  [AWIDTH-1:0] raddr;
output [DWIDTH-1:0] rdata;

// Registered outputs
reg    [DWIDTH-1:0] rdata;


//---
// Local declarations

// Registers

reg  [DWIDTH-1:0] mem_rdata;
reg  [AWIDTH-1:0] raddr_d1;

// Memory

reg  [DWIDTH-1:0] mem [0:RAM_DEPTH-1];

// Variables

integer         i;


//---
// Memory Write

// Generate synchronous write
always @(posedge wclk)
begin
    if (wen) begin
        mem[waddr[AWIDTH-1:0]] <= wdata;
    end
end

//---
// Memory Read

// Generate registered memory read

`ifdef XIL

//always @(posedge rclk)
//begin
//    if (ren) begin
//        raddr_d1 <= raddr;
//    end
//end
//always @(raddr_d1, rclk)
//begin
//    mem_rdata = mem[raddr_d1[AWIDTH-1:0]];
//end

always @(posedge rclk)
begin
    if (!rrst_n) begin
        mem_rdata <= {(DWIDTH){1'b0}};
    end else if (ren) begin
        mem_rdata <= mem[raddr[AWIDTH-1:0]];
    end
end

`else

//always @(posedge rclk or negedge rrst_n)
//begin
//    if (!rrst_n) begin
//        mem_rdata <= {(DWIDTH){1'b0}};
//    end else if (ren) begin
//        mem_rdata <= mem[raddr[AWIDTH-1:0]];
//    end
//end

always @(posedge rclk)
begin
    if (ren) begin
        raddr_d1 <= raddr;
    end
end
always @(raddr_d1, rclk)
begin
    mem_rdata = mem[raddr_d1[AWIDTH-1:0]];
end

`endif

generate
    if (REGISTER_READ) begin

        // Generate registered output
        always @(posedge rclk or negedge rrst_n)
        begin
            if (!rrst_n) begin
                rdata <= {(DWIDTH){1'b0}};
            end else if (roen) begin
                rdata <= mem_rdata;
            end
        end

    end
    else begin

        // Generate unregisters output
        always @(mem_rdata)
        begin
            rdata = mem_rdata;
        end

    end
endgenerate

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "generic_mem_small.v"                             ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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

`include "defines.v"

/* synthesis ramstyle = "M512" */

module generic_mem_small(

    wclk,
    wrst_n,
    wen,
    waddr,
    wdata,

    rclk,
    rrst_n,
    ren,
    roen,
    raddr,
    rdata
);

//---
// Parameters

parameter DWIDTH = 32;
parameter AWIDTH = 3;
parameter RAM_DEPTH = (1 << AWIDTH);
parameter REGISTER_READ = 0;

//---
// Ports

input               wclk;
input               wrst_n;
input               wen;
input  [AWIDTH-1:0] waddr;
input  [DWIDTH-1:0] wdata;

input               rclk;
input               rrst_n;
input               ren;
input               roen;
input  [AWIDTH-1:0] raddr;
output [DWIDTH-1:0] rdata;

// Registered outputs
reg    [DWIDTH-1:0] rdata;


//---
// Local declarations

// Registers

reg  [DWIDTH-1:0] mem_rdata;
reg  [AWIDTH-1:0] raddr_d1;


// Memory

reg  [DWIDTH-1:0] mem [0:RAM_DEPTH-1];

// Variables

integer         i;


//---
// Memory Write

// Generate synchronous write
always @(posedge wclk)
begin
    if (wen) begin
        mem[waddr[AWIDTH-1:0]] <= wdata;
    end
end

//---
// Memory Read

// Generate registered memory read

`ifdef XIL

//always @(posedge rclk)
//begin
//    if (ren) begin
//        raddr_d1 <= raddr;
//    end
//end
//always @(raddr_d1, rclk)
//begin
//    mem_rdata = mem[raddr_d1[AWIDTH-1:0]];
//end

always @(posedge rclk)
begin
    if (!rrst_n) begin
        mem_rdata <= {(DWIDTH){1'b0}};
    end else if (ren) begin
        mem_rdata <= mem[raddr[AWIDTH-1:0]];
    end
end

`else

//always @(posedge rclk or negedge rrst_n)
//begin
//    if (!rrst_n) begin
//        mem_rdata <= {(DWIDTH){1'b0}};
//    end else if (ren) begin
//        mem_rdata <= mem[raddr[AWIDTH-1:0]];
//    end
//end

always @(posedge rclk)
begin
    if (ren) begin
        raddr_d1 <= raddr;
    end
end
always @(raddr_d1, rclk)
begin
    mem_rdata = mem[raddr_d1[AWIDTH-1:0]];
end

`endif

generate
    if (REGISTER_READ) begin

        // Generate registered output
        always @(posedge rclk or negedge rrst_n)
        begin
            if (!rrst_n) begin
                rdata <= {(DWIDTH){1'b0}};
            end else if (roen) begin
                rdata <= mem_rdata;
            end
        end

    end
    else begin

        // Generate unregisters output
        always @(mem_rdata)
        begin
            rdata = mem_rdata;
        end

    end
endgenerate

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "meta_sync_single.v"                              ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


module meta_sync_single(/*AUTOARG*/
  // Outputs
  out,
  // Inputs
  clk, reset_n, in
  );

parameter EDGE_DETECT = 0;

input   clk;
input   reset_n;
   
input   in;

output  out;

reg     out;



generate

    if (EDGE_DETECT) begin

      reg   meta;
      reg   edg1;
      reg   edg2;

        always @(posedge clk or negedge reset_n) begin

            if (reset_n == 1'b0) begin
                meta <= 1'b0;
                edg1 <= 1'b0;
                edg2 <= 1'b0;
                out <= 1'b0;
            end
            else begin
                meta <= in;
                edg1 <= meta;
                edg2 <= edg1;
                out <= edg1 ^ edg2;
            end
        end

    end
    else begin

      reg   meta;

        always @(posedge clk or negedge reset_n) begin

            if (reset_n == 1'b0) begin
                meta <= 1'b0;
                out <= 1'b0;
            end
            else begin
                meta <= in;
                out <= meta;
            end
        end

    end

endgenerate

endmodule

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "meta_sync.v"                                     ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


module meta_sync(/*AUTOARG*/
  // Outputs
  out,
  // Inputs
  clk, reset_n, in
  );

parameter DWIDTH = 1;
parameter EDGE_DETECT = 0;

input                clk;
input                reset_n;
   
input  [DWIDTH-1:0]  in;

output [DWIDTH-1:0]  out;

generate
genvar               i;

    for (i = 0; i < DWIDTH; i = i + 1) begin : meta

        meta_sync_single #(.EDGE_DETECT (EDGE_DETECT))
          meta_sync_single0 (
                      // Outputs
                      .out              (out[i]),
                      // Inputs
                      .clk              (clk),
                      .reset_n          (reset_n),
                      .in               (in[i]));

    end

endgenerate

endmodule

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "rx_data_fifo.v"                                  ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module rx_data_fifo(/*AUTOARG*/
  // Outputs
  rxdfifo_wfull, rxdfifo_rdata, rxdfifo_rstatus, rxdfifo_rempty,
  rxdfifo_ralmost_empty,
  // Inputs
  clk_xgmii_rx, clk_156m25, reset_xgmii_rx_n, reset_156m25_n,
  rxdfifo_wdata, rxdfifo_wstatus, rxdfifo_wen, rxdfifo_ren
  );

input         clk_xgmii_rx;
input         clk_156m25;
input         reset_xgmii_rx_n;
input         reset_156m25_n;

input [63:0]  rxdfifo_wdata;
input [7:0]   rxdfifo_wstatus;
input         rxdfifo_wen;

input         rxdfifo_ren;

output        rxdfifo_wfull;

output [63:0] rxdfifo_rdata;
output [7:0]  rxdfifo_rstatus;
output        rxdfifo_rempty;
output        rxdfifo_ralmost_empty;

generic_fifo #(
  .DWIDTH (72),
  .AWIDTH (`RX_DATA_FIFO_AWIDTH),
  .REGISTER_READ (0),
  .EARLY_READ (1),
  .CLOCK_CROSSING (1),
  .ALMOST_EMPTY_THRESH (4),
  .MEM_TYPE (`MEM_AUTO_MEDIUM)
)
fifo0(
    .wclk (clk_xgmii_rx),
    .wrst_n (reset_xgmii_rx_n),
    .wen (rxdfifo_wen),
    .wdata ({rxdfifo_wstatus, rxdfifo_wdata}),
    .wfull (rxdfifo_wfull),
    .walmost_full (),

    .rclk (clk_156m25),
    .rrst_n (reset_156m25_n),
    .ren (rxdfifo_ren),
    .rdata ({rxdfifo_rstatus, rxdfifo_rdata}),
    .rempty (rxdfifo_rempty),
    .ralmost_empty (rxdfifo_ralmost_empty)
);

   
endmodule

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "rx_dequeue.v"                                    ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module rx_dequeue(/*AUTOARG*/
  // Outputs
  rxdfifo_ren, pkt_rx_data, pkt_rx_val, pkt_rx_sop, pkt_rx_eop,
  pkt_rx_err, pkt_rx_mod, pkt_rx_avail, status_rxdfifo_udflow_tog,
  // Inputs
  clk_156m25, reset_156m25_n, rxdfifo_rdata, rxdfifo_rstatus,
  rxdfifo_rempty, rxdfifo_ralmost_empty, pkt_rx_ren
  );

input         clk_156m25;
input         reset_156m25_n;

input [63:0]  rxdfifo_rdata;
input [7:0]   rxdfifo_rstatus;
input         rxdfifo_rempty;
input         rxdfifo_ralmost_empty;

input         pkt_rx_ren;

output        rxdfifo_ren;

output [63:0] pkt_rx_data;
output        pkt_rx_val;
output        pkt_rx_sop;
output        pkt_rx_eop;
output        pkt_rx_err;
output [2:0]  pkt_rx_mod;
output        pkt_rx_avail;

output        status_rxdfifo_udflow_tog;

/*AUTOREG*/
// Beginning of automatic regs (for this module's undeclared outputs)
reg                     pkt_rx_avail;
reg [63:0]              pkt_rx_data;
reg                     pkt_rx_eop;
reg                     pkt_rx_err;
reg [2:0]               pkt_rx_mod;
reg                     pkt_rx_sop;
reg                     pkt_rx_val;
reg                     status_rxdfifo_udflow_tog;
// End of automatics

reg           end_eop;

/*AUTOWIRE*/


// End eop to force one cycle between packets

assign rxdfifo_ren = !rxdfifo_rempty && pkt_rx_ren && !end_eop;



always @(posedge clk_156m25 or negedge reset_156m25_n) begin

    if (reset_156m25_n == 1'b0) begin

        pkt_rx_avail <= 1'b0;

        pkt_rx_data <= 64'b0;
        pkt_rx_sop <= 1'b0;
        pkt_rx_eop <= 1'b0;
        pkt_rx_err <= 1'b0;
        pkt_rx_mod <= 3'b0;

        pkt_rx_val <= 1'b0;

        end_eop <= 1'b0;

        status_rxdfifo_udflow_tog <= 1'b0;

    end
    else begin

        pkt_rx_avail <= !rxdfifo_ralmost_empty;



        // If eop shows up at the output of the fifo, we drive eop on
        // the bus on the next read. This will be the last read for this
        // packet. The fifo is designed to output data early. On last read,
        // data from next packet will appear at the output of fifo. Modulus
        // of packet length is in lower bits.

        pkt_rx_eop <= rxdfifo_ren && rxdfifo_rstatus[`RXSTATUS_EOP];
        pkt_rx_mod <= {3{rxdfifo_ren & rxdfifo_rstatus[`RXSTATUS_EOP]}} & rxdfifo_rstatus[2:0];


        pkt_rx_val <= rxdfifo_ren;

        if (rxdfifo_ren) begin

            `ifdef BIGENDIAN
	    pkt_rx_data <= {rxdfifo_rdata[7:0],
                            rxdfifo_rdata[15:8],
                            rxdfifo_rdata[23:16],
                            rxdfifo_rdata[31:24],
                            rxdfifo_rdata[39:32],
                            rxdfifo_rdata[47:40],
                            rxdfifo_rdata[55:48],
                            rxdfifo_rdata[63:56]};
            `else
	    pkt_rx_data <= rxdfifo_rdata;
            `endif

        end


        if (rxdfifo_ren && rxdfifo_rstatus[`RXSTATUS_SOP]) begin

            // SOP indication on first word

            pkt_rx_sop <= 1'b1;
            pkt_rx_err <= 1'b0;

        end
        else begin

            pkt_rx_sop <= 1'b0;


            // Give an error if FIFO is to underflow

            if (rxdfifo_rempty && pkt_rx_ren && !end_eop) begin
                pkt_rx_val <= 1'b1;
                pkt_rx_eop <= 1'b1;
                pkt_rx_err <= 1'b1;
            end

        end


        if (rxdfifo_ren && |(rxdfifo_rstatus[`RXSTATUS_ERR])) begin

            // Status stored in FIFO is propagated to error signal.

            pkt_rx_err <= 1'b1;

        end


        //---
        // EOP indication at the end of the frame. Cleared otherwise.

        if (rxdfifo_ren && rxdfifo_rstatus[`RXSTATUS_EOP]) begin
            end_eop <= 1'b1;
        end
        else if (pkt_rx_ren) begin
            end_eop <= 1'b0;
        end



        //---
        // FIFO errors, used to generate interrupts

        if (rxdfifo_rempty && pkt_rx_ren && !end_eop) begin
            status_rxdfifo_udflow_tog <= ~status_rxdfifo_udflow_tog;
        end

    end
end

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "rx_enqueue.v"                                    ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module rx_enqueue(/*AUTOARG*/
  // Outputs
  rxdfifo_wdata, rxdfifo_wstatus, rxdfifo_wen, rxhfifo_ren,
  rxhfifo_wdata, rxhfifo_wstatus, rxhfifo_wen, local_fault_msg_det,
  remote_fault_msg_det, status_crc_error_tog,
  status_fragment_error_tog, status_lenght_error_tog,
  status_rxdfifo_ovflow_tog, status_pause_frame_rx_tog, rxsfifo_wen,
  rxsfifo_wdata,
  // Inputs
  clk_xgmii_rx, reset_xgmii_rx_n, xgmii_rxd, xgmii_rxc, rxdfifo_wfull,
  rxhfifo_rdata, rxhfifo_rstatus, rxhfifo_rempty,
  rxhfifo_ralmost_empty
  );

`include "CRC32_D64.v"
`include "CRC32_D8.v"
`include "utils.v"

input         clk_xgmii_rx;
input         reset_xgmii_rx_n;

input  [63:0] xgmii_rxd;
input  [7:0]  xgmii_rxc;

input         rxdfifo_wfull;

input  [63:0] rxhfifo_rdata;
input  [7:0]  rxhfifo_rstatus;
input         rxhfifo_rempty;
input         rxhfifo_ralmost_empty;

output [63:0] rxdfifo_wdata;
output [7:0]  rxdfifo_wstatus;
output        rxdfifo_wen;

output        rxhfifo_ren;

output [63:0] rxhfifo_wdata;
output [7:0]  rxhfifo_wstatus;
output        rxhfifo_wen;

output [1:0]  local_fault_msg_det;
output [1:0]  remote_fault_msg_det;

output        status_crc_error_tog;
output        status_fragment_error_tog;
output        status_lenght_error_tog;
output        status_rxdfifo_ovflow_tog;

output        status_pause_frame_rx_tog;

output        rxsfifo_wen;
output [13:0] rxsfifo_wdata;



/*AUTOREG*/
// Beginning of automatic regs (for this module's undeclared outputs)
reg [1:0]               local_fault_msg_det;
reg [1:0]               remote_fault_msg_det;
reg [63:0]              rxdfifo_wdata;
reg                     rxdfifo_wen;
reg [7:0]               rxdfifo_wstatus;
reg                     rxhfifo_ren;
reg [63:0]              rxhfifo_wdata;
reg                     rxhfifo_wen;
reg [7:0]               rxhfifo_wstatus;
reg [13:0]              rxsfifo_wdata;
reg                     rxsfifo_wen;
reg                     status_crc_error_tog;
reg                     status_fragment_error_tog;
reg                     status_lenght_error_tog;
reg                     status_pause_frame_rx_tog;
reg                     status_rxdfifo_ovflow_tog;
// End of automatics

/*AUTOWIRE*/


reg [63:32]   xgmii_rxd_d1;
reg [7:4]     xgmii_rxc_d1;

reg [63:0]    xgxs_rxd_barrel;
reg [7:0]     xgxs_rxc_barrel;

reg [63:0]    xgxs_rxd_barrel_d1;
reg [7:0]     xgxs_rxc_barrel_d1;

reg           barrel_shift;

reg [31:0]    crc32_d64;
reg [31:0]    crc32_d8;

reg [3:0]     crc_bytes;
reg [3:0]     next_crc_bytes;

reg [63:0]    crc_shift_data;
reg           crc_start_8b;
reg           crc_done;
reg	      crc_good;
reg           crc_clear;

reg [31:0]    crc_rx;
reg [31:0]    next_crc_rx;

reg [2:0]     curr_state;
reg [2:0]     next_state;

reg [13:0]    curr_byte_cnt;
reg [13:0]    next_byte_cnt;
reg [13:0]    frame_lenght;

reg           frame_end_flag;
reg           next_frame_end_flag;

reg [2:0]     frame_end_bytes;
reg [2:0]     next_frame_end_bytes;

reg           fragment_error;
reg           rxd_ovflow_error;

reg           lenght_error;

reg           coding_error;
reg           next_coding_error;

reg [7:0]     addmask;
reg [7:0]     datamask;

reg           pause_frame;
reg           next_pause_frame;
reg           pause_frame_hold;

reg           good_pause_frame;

reg           drop_data;
reg           next_drop_data;

reg           pkt_pending;

reg           rxhfifo_ren_d1;

reg           rxhfifo_ralmost_empty_d1;


parameter [2:0]
             SM_IDLE = 3'd0,
             SM_RX = 3'd1;

// count the number of set bits in a nibble
function [2:0] bit_cnt4;
input   [3:0]   bits;
    begin
    case (bits)
    0:  bit_cnt4 = 0;
    1:  bit_cnt4 = 1;
    2:  bit_cnt4 = 1;
    3:  bit_cnt4 = 2;
    4:  bit_cnt4 = 1;
    5:  bit_cnt4 = 2;
    6:  bit_cnt4 = 2;
    7:  bit_cnt4 = 3;
    8:  bit_cnt4 = 1;
    9:  bit_cnt4 = 2;
    10: bit_cnt4 = 2;
    11: bit_cnt4 = 3;
    12: bit_cnt4 = 2;
    13: bit_cnt4 = 3;
    14: bit_cnt4 = 3;
    15: bit_cnt4 = 4;
    endcase
    end
endfunction

function [3:0] bit_cnt8;
input   [7:0]   bits;
    begin
    bit_cnt8 = bit_cnt4(bits[3:0]) + bit_cnt4(bits[7:4]);
    end
endfunction

always @(posedge clk_xgmii_rx or negedge reset_xgmii_rx_n) begin

    if (reset_xgmii_rx_n == 1'b0) begin

        xgmii_rxd_d1 <= 32'b0;
        xgmii_rxc_d1 <= 4'b0;

        xgxs_rxd_barrel <= 64'b0;
        xgxs_rxc_barrel <= 8'b0;

        xgxs_rxd_barrel_d1 <= 64'b0;
        xgxs_rxc_barrel_d1 <= 8'b0;

        barrel_shift <= 1'b0;

        local_fault_msg_det <= 2'b0;
        remote_fault_msg_det <= 2'b0;

        crc32_d64 <= 32'b0;
        crc32_d8 <= 32'b0;
        crc_bytes <= 4'b0;

        crc_shift_data <= 64'b0;
        crc_done <= 1'b0;
        crc_rx <= 32'b0;

        pause_frame_hold <= 1'b0;

        status_crc_error_tog <= 1'b0;
        status_fragment_error_tog <= 1'b0;
        status_lenght_error_tog <= 1'b0;
        status_rxdfifo_ovflow_tog <= 1'b0;

        status_pause_frame_rx_tog <= 1'b0;

        rxsfifo_wen <= 1'b0;
        rxsfifo_wdata <= 14'b0;

        datamask <= 8'b0;

        lenght_error <= 1'b0;

    end
    else begin

        rxsfifo_wen <= 1'b0;
        rxsfifo_wdata <= frame_lenght;

        lenght_error <= 1'b0;

        //---
        // Link status RC layer
        // Look for local/remote messages on lower 4 lanes and upper
        // 4 lanes. This is a 64-bit interface but look at each 32-bit
        // independantly.

        local_fault_msg_det[1] <= (xgmii_rxd[63:32] ==
                                   {`LOCAL_FAULT, 8'h0, 8'h0, `SEQUENCE} &&
                                   xgmii_rxc[7:4] == 4'b0001);

        local_fault_msg_det[0] <= (xgmii_rxd[31:0] ==
                                   {`LOCAL_FAULT, 8'h0, 8'h0, `SEQUENCE} &&
                                   xgmii_rxc[3:0] == 4'b0001);

        remote_fault_msg_det[1] <= (xgmii_rxd[63:32] ==
                                    {`REMOTE_FAULT, 8'h0, 8'h0, `SEQUENCE} &&
                                    xgmii_rxc[7:4] == 4'b0001);

        remote_fault_msg_det[0] <= (xgmii_rxd[31:0] ==
                                    {`REMOTE_FAULT, 8'h0, 8'h0, `SEQUENCE} &&
                                    xgmii_rxc[3:0] == 4'b0001);


        //---
        // Rotating barrel. This function allow us to always align the start of
        // a frame with LANE0. If frame starts in LANE4, it will be shifted 4 bytes
        // to LANE0, thus reducing the amount of logic needed at the next stage.

        xgmii_rxd_d1[63:32] <= xgmii_rxd[63:32];
        xgmii_rxc_d1[7:4] <= xgmii_rxc[7:4];

        if (xgmii_rxd[`LANE0] == `START && xgmii_rxc[0]) begin

            xgxs_rxd_barrel <= xgmii_rxd;
            xgxs_rxc_barrel <= xgmii_rxc;

            barrel_shift <= 1'b0;

        end
        else if (xgmii_rxd[`LANE4] == `START && xgmii_rxc[4]) begin

            xgxs_rxd_barrel[63:32] <= xgmii_rxd[31:0];
            xgxs_rxc_barrel[7:4] <= xgmii_rxc[3:0];

            if (barrel_shift) begin
                xgxs_rxd_barrel[31:0] <= xgmii_rxd_d1[63:32];
                xgxs_rxc_barrel[3:0] <= xgmii_rxc_d1[7:4];
            end
            else begin
                xgxs_rxd_barrel[31:0] <= 32'h07070707;
                xgxs_rxc_barrel[3:0] <= 4'hf;
            end

            barrel_shift <= 1'b1;

        end
        else if (barrel_shift) begin

            xgxs_rxd_barrel <= {xgmii_rxd[31:0], xgmii_rxd_d1[63:32]};
            xgxs_rxc_barrel <= {xgmii_rxc[3:0], xgmii_rxc_d1[7:4]};

        end
        else begin

            xgxs_rxd_barrel <= xgmii_rxd;
            xgxs_rxc_barrel <= xgmii_rxc;

        end

        xgxs_rxd_barrel_d1 <= xgxs_rxd_barrel;
        xgxs_rxc_barrel_d1 <= xgxs_rxc_barrel;

        //---
        // Mask for end-of-frame

        datamask[0] <= addmask[0];
        datamask[1] <= &addmask[1:0];
        datamask[2] <= &addmask[2:0];
        datamask[3] <= &addmask[3:0];
        datamask[4] <= &addmask[4:0];
        datamask[5] <= &addmask[5:0];
        datamask[6] <= &addmask[6:0];
        datamask[7] <= &addmask[7:0];

        //---
        // When final CRC calculation begins we capture info relevant to
        // current frame CRC claculation continues while next frame is
        // being received.

        if (crc_start_8b) begin

            pause_frame_hold <= pause_frame;

        end

        //---
        // CRC Checking

        crc_rx <= next_crc_rx;

        if (crc_clear) begin

            // CRC is cleared at the beginning of the frame, calculate
            // 64-bit at a time otherwise

            crc32_d64 <= 32'hffffffff;

        end
        else begin

            crc32_d64 <= nextCRC32_D64(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64);

        end

        if (crc_bytes != 4'b0) begin

            // When reaching the end of the frame we switch from 64-bit mode
            // to 8-bit mode to accomodate odd number of bytes in the frame.
            // crc_bytes indicated the number of remaining payload byte to
            // compute CRC on. Calculate and decrement until it reaches 0.

            if (crc_bytes == 4'b1) begin
                crc_done <= 1'b1;
            end

            crc32_d8 <= nextCRC32_D8(reverse_8b(crc_shift_data[7:0]), crc32_d8);
            crc_shift_data <= {8'h00, crc_shift_data[63:8]};
            crc_bytes <= crc_bytes - 4'b1;

        end
        else if (crc_bytes == 4'b0) begin

            // Per Clause 46. Control code during data must be reported
            // as a CRC error. Indicated here by coding_error. Corrupt CRC
            // if coding error is detected.

            if (coding_error || next_coding_error) begin
                crc32_d8 <= ~crc32_d64;
            end
            else begin
                crc32_d8 <= crc32_d64;
            end

            crc_done <= 1'b0;

            crc_shift_data <= xgxs_rxd_barrel_d1;
            crc_bytes <= next_crc_bytes;

        end

        //---
        // Error detection

        if (crc_done && !crc_good) begin
            status_crc_error_tog <= ~status_crc_error_tog;
        end

        if (fragment_error) begin
            status_fragment_error_tog <= ~status_fragment_error_tog;
        end

        if (rxd_ovflow_error) begin
            status_rxdfifo_ovflow_tog <= ~status_rxdfifo_ovflow_tog;
        end

        //---
        // Frame receive indication

        if (good_pause_frame) begin
            status_pause_frame_rx_tog <= ~status_pause_frame_rx_tog;
        end

        if (frame_end_flag) begin
            rxsfifo_wen <= 1'b1;
        end

        //---
        // Check frame lenght

        if (frame_end_flag && frame_lenght > `MAX_FRAME_SIZE) begin
            lenght_error <= 1'b1;
            status_lenght_error_tog <= ~status_lenght_error_tog;
        end

    end

end


always @(/*AS*/crc32_d8 or crc_done or crc_rx or pause_frame_hold) begin


    crc_good = 1'b0;
    good_pause_frame = 1'b0;

    if (crc_done) begin

        // Check CRC. If this is a pause frame, report it to cpu.

        if (crc_rx == ~reverse_32b(crc32_d8)) begin
            crc_good = 1'b1;
            good_pause_frame = pause_frame_hold;
        end

    end

end

always @(posedge clk_xgmii_rx or negedge reset_xgmii_rx_n) begin

    if (reset_xgmii_rx_n == 1'b0) begin

        curr_state <= SM_IDLE;
        curr_byte_cnt <= 14'b0;
        frame_end_flag <= 1'b0;
        frame_end_bytes <= 3'b0;
        coding_error <= 1'b0;
        pause_frame <= 1'b0;

    end
    else begin

        curr_state <= next_state;
        curr_byte_cnt <= next_byte_cnt;
        frame_end_flag <= next_frame_end_flag;
        frame_end_bytes <= next_frame_end_bytes;
        coding_error <= next_coding_error;
        pause_frame <= next_pause_frame;

    end

end


always @(/*AS*/coding_error or crc_rx or curr_byte_cnt or curr_state
         or datamask or frame_end_bytes or pause_frame
         or xgxs_rxc_barrel or xgxs_rxc_barrel_d1 or xgxs_rxd_barrel
         or xgxs_rxd_barrel_d1) begin

    next_state = curr_state;

    rxhfifo_wdata = xgxs_rxd_barrel_d1;
    rxhfifo_wstatus = `RXSTATUS_NONE;
    rxhfifo_wen = 1'b0;

    next_crc_bytes = 4'b0;
    next_crc_rx = crc_rx;
    crc_start_8b = 1'b0;
    crc_clear = 1'b0;

    next_byte_cnt = curr_byte_cnt;
    next_frame_end_flag = 1'b0;
    next_frame_end_bytes = 3'b0;

    fragment_error = 1'b0;

    frame_lenght = curr_byte_cnt + {11'b0, frame_end_bytes};

    next_coding_error = coding_error;
    next_pause_frame = pause_frame;

    addmask[0] = !(xgxs_rxd_barrel[`LANE0] == `TERMINATE && xgxs_rxc_barrel[0]);
    addmask[1] = !(xgxs_rxd_barrel[`LANE1] == `TERMINATE && xgxs_rxc_barrel[1]);
    addmask[2] = !(xgxs_rxd_barrel[`LANE2] == `TERMINATE && xgxs_rxc_barrel[2]);
    addmask[3] = !(xgxs_rxd_barrel[`LANE3] == `TERMINATE && xgxs_rxc_barrel[3]);
    addmask[4] = !(xgxs_rxd_barrel[`LANE4] == `TERMINATE && xgxs_rxc_barrel[4]);
    addmask[5] = !(xgxs_rxd_barrel[`LANE5] == `TERMINATE && xgxs_rxc_barrel[5]);
    addmask[6] = !(xgxs_rxd_barrel[`LANE6] == `TERMINATE && xgxs_rxc_barrel[6]);
    addmask[7] = !(xgxs_rxd_barrel[`LANE7] == `TERMINATE && xgxs_rxc_barrel[7]);

    case (curr_state)

        SM_IDLE:
          begin

              next_byte_cnt = 14'b0;
              crc_clear = 1'b1;
              next_coding_error = 1'b0;
              next_pause_frame = 1'b0;


              // Detect the start of a frame

              if (xgxs_rxd_barrel_d1[`LANE0] == `START && xgxs_rxc_barrel_d1[0] &&
                  xgxs_rxd_barrel_d1[`LANE1] == `PREAMBLE && !xgxs_rxc_barrel_d1[1] &&
                  xgxs_rxd_barrel_d1[`LANE2] == `PREAMBLE && !xgxs_rxc_barrel_d1[2] &&
                  xgxs_rxd_barrel_d1[`LANE3] == `PREAMBLE && !xgxs_rxc_barrel_d1[3] &&
                  xgxs_rxd_barrel_d1[`LANE4] == `PREAMBLE && !xgxs_rxc_barrel_d1[4] &&
                  xgxs_rxd_barrel_d1[`LANE5] == `PREAMBLE && !xgxs_rxc_barrel_d1[5] &&
                  xgxs_rxd_barrel_d1[`LANE6] == `PREAMBLE && !xgxs_rxc_barrel_d1[6] &&
                  xgxs_rxd_barrel_d1[`LANE7] == `SFD && !xgxs_rxc_barrel_d1[7]) begin

                  next_state = SM_RX;
              end

          end

        SM_RX:
          begin

              // Pause frames are filtered

              rxhfifo_wen = !pause_frame;


              if (xgxs_rxd_barrel_d1[`LANE0] == `START && xgxs_rxc_barrel_d1[0] &&
                  xgxs_rxd_barrel_d1[`LANE7] == `SFD && !xgxs_rxc_barrel_d1[7]) begin

                  // Fragment received, if we are still at SOP stage don't store
                  // the frame. If not, write a fake EOP and flag frame as bad.

                  next_byte_cnt = 14'b0;
                  crc_clear = 1'b1;
                  next_coding_error = 1'b0;

                  fragment_error = 1'b1;
                  rxhfifo_wstatus[`RXSTATUS_ERR] = 1'b1;

                  if (curr_byte_cnt == 14'b0) begin
                      rxhfifo_wen = 1'b0;
                  end
                  else begin
                      rxhfifo_wstatus[`RXSTATUS_EOP] = 1'b1;
                  end

              end
              else if (curr_byte_cnt > 14'd16100) begin

                  // Frame too long, TERMMINATE must have been corrupted.
                  // Abort transfer, write a fake EOP, report as fragment.

                  fragment_error = 1'b1;
                  rxhfifo_wstatus[`RXSTATUS_ERR] = 1'b1;

                  rxhfifo_wstatus[`RXSTATUS_EOP] = 1'b1;
                  next_state = SM_IDLE;

              end
              else begin

                  // Pause frame receive, these frame will be filtered

                  if (curr_byte_cnt == 14'd0 &&
                      xgxs_rxd_barrel_d1[47:0] == `PAUSE_FRAME) begin

                      rxhfifo_wen = 1'b0;
                      next_pause_frame = 1'b1;
                  end


                  // Control character during data phase, force CRC error

                  if (|(xgxs_rxc_barrel_d1 & datamask)) begin

                      next_coding_error = 1'b1;
                  end


                  // Write SOP to status bits during first byte

                  if (curr_byte_cnt == 14'b0) begin
                      rxhfifo_wstatus[`RXSTATUS_SOP] = 1'b1;
                  end

                  /* verilator lint_off WIDTH */
                  //next_byte_cnt = curr_byte_cnt +
                  //                addmask[0] + addmask[1] + addmask[2] + addmask[3] +
                  //                addmask[4] + addmask[5] + addmask[6] + addmask[7];
                  /* verilator lint_on WIDTH */
                  // don't infer a chain of adders
                  next_byte_cnt = curr_byte_cnt + {10'b0, bit_cnt8(datamask[7:0])};


                  // We will not write to the fifo if all is left
                  // are four or less bytes of crc. We also strip off the
                  // crc, which requires looking one cycle ahead
                  // wstatus:
                  //   [2:0] modulus of packet length

                  // Look one cycle ahead for TERMINATE in lanes 0 to 4

                  if (xgxs_rxd_barrel[`LANE4] == `TERMINATE && xgxs_rxc_barrel[4]) begin

                      rxhfifo_wstatus[`RXSTATUS_EOP] = 1'b1;
                      rxhfifo_wstatus[2:0] = 3'd0;

                      crc_start_8b = 1'b1;
                      next_crc_bytes = 4'd8;
                      next_crc_rx = xgxs_rxd_barrel[31:0];

                      next_frame_end_flag = 1'b1;
                      next_frame_end_bytes = 3'd4;

                      next_state = SM_IDLE;

                  end

                  if (xgxs_rxd_barrel[`LANE3] == `TERMINATE && xgxs_rxc_barrel[3]) begin

                      rxhfifo_wstatus[`RXSTATUS_EOP] = 1'b1;
                      rxhfifo_wstatus[2:0] = 3'd7;

                      crc_start_8b = 1'b1;
                      next_crc_bytes = 4'd7;
                      next_crc_rx = {xgxs_rxd_barrel[23:0], xgxs_rxd_barrel_d1[63:56]};

                      next_frame_end_flag = 1'b1;
                      next_frame_end_bytes = 3'd3;

                      next_state = SM_IDLE;

                  end

                  if (xgxs_rxd_barrel[`LANE2] == `TERMINATE && xgxs_rxc_barrel[2]) begin

                      rxhfifo_wstatus[`RXSTATUS_EOP] = 1'b1;
                      rxhfifo_wstatus[2:0] = 3'd6;

                      crc_start_8b = 1'b1;
                      next_crc_bytes = 4'd6;
                      next_crc_rx = {xgxs_rxd_barrel[15:0], xgxs_rxd_barrel_d1[63:48]};

                      next_frame_end_flag = 1'b1;
                      next_frame_end_bytes = 3'd2;

                      next_state = SM_IDLE;

                  end

                  if (xgxs_rxd_barrel[`LANE1] == `TERMINATE && xgxs_rxc_barrel[1]) begin

                      rxhfifo_wstatus[`RXSTATUS_EOP] = 1'b1;
                      rxhfifo_wstatus[2:0] = 3'd5;

                      crc_start_8b = 1'b1;
                      next_crc_bytes = 4'd5;
                      next_crc_rx = {xgxs_rxd_barrel[7:0], xgxs_rxd_barrel_d1[63:40]};

                      next_frame_end_flag = 1'b1;
                      next_frame_end_bytes = 3'd1;

                      next_state = SM_IDLE;

                  end

                  if (xgxs_rxd_barrel[`LANE0] == `TERMINATE && xgxs_rxc_barrel[0]) begin

                      rxhfifo_wstatus[`RXSTATUS_EOP] = 1'b1;
                      rxhfifo_wstatus[2:0] = 3'd4;

                      crc_start_8b = 1'b1;
                      next_crc_bytes = 4'd4;
                      next_crc_rx = xgxs_rxd_barrel_d1[63:32];

                      next_frame_end_flag = 1'b1;

                      next_state = SM_IDLE;

                  end

                  // Look at current cycle for TERMINATE in lanes 5 to 7

                  if (xgxs_rxd_barrel_d1[`LANE7] == `TERMINATE &&
                      xgxs_rxc_barrel_d1[7]) begin

                      rxhfifo_wstatus[`RXSTATUS_EOP] = 1'b1;
                      rxhfifo_wstatus[2:0] = 3'd3;

                      crc_start_8b = 1'b1;
                      next_crc_bytes = 4'd3;
                      next_crc_rx = xgxs_rxd_barrel_d1[55:24];

                      next_frame_end_flag = 1'b1;

                      next_state = SM_IDLE;

                  end

                  if (xgxs_rxd_barrel_d1[`LANE6] == `TERMINATE &&
                      xgxs_rxc_barrel_d1[6]) begin

                      rxhfifo_wstatus[`RXSTATUS_EOP] = 1'b1;
                      rxhfifo_wstatus[2:0] = 3'd2;

                      crc_start_8b = 1'b1;
                      next_crc_bytes = 4'd2;
                      next_crc_rx = xgxs_rxd_barrel_d1[47:16];

                      next_frame_end_flag = 1'b1;

                      next_state = SM_IDLE;

                  end

                  if (xgxs_rxd_barrel_d1[`LANE5] == `TERMINATE &&
                      xgxs_rxc_barrel_d1[5]) begin

                      rxhfifo_wstatus[`RXSTATUS_EOP] = 1'b1;
                      rxhfifo_wstatus[2:0] = 3'd1;

                      crc_start_8b = 1'b1;
                      next_crc_bytes = 4'd1;
                      next_crc_rx = xgxs_rxd_barrel_d1[39:8];

                      next_frame_end_flag = 1'b1;

                      next_state = SM_IDLE;

                  end
              end
          end

        default:
          begin
              next_state = SM_IDLE;
          end

    endcase

end


always @(posedge clk_xgmii_rx or negedge reset_xgmii_rx_n) begin

    if (reset_xgmii_rx_n == 1'b0) begin

        rxhfifo_ralmost_empty_d1 <= 1'b1;

        drop_data <= 1'b0;

        pkt_pending <= 1'b0;

        rxhfifo_ren_d1 <= 1'b0;

    end
    else begin

        rxhfifo_ralmost_empty_d1 <= rxhfifo_ralmost_empty;

        drop_data <= next_drop_data;

        pkt_pending <= rxhfifo_ren;

        rxhfifo_ren_d1 <= rxhfifo_ren;

    end

end

always @(/*AS*/crc_done or crc_good or drop_data or lenght_error
         or pkt_pending or rxdfifo_wfull or rxhfifo_ralmost_empty_d1
         or rxhfifo_rdata or rxhfifo_ren_d1 or rxhfifo_rstatus) begin

    rxd_ovflow_error = 1'b0;

    rxdfifo_wdata = rxhfifo_rdata;
    rxdfifo_wstatus = rxhfifo_rstatus;

    next_drop_data = drop_data;


    // There must be at least 8 words in holding FIFO before we start reading.
    // This provides enough time for CRC calculation.

    rxhfifo_ren = !rxhfifo_ralmost_empty_d1 ||
                  (pkt_pending && !rxhfifo_rstatus[`RXSTATUS_EOP]);


    if (rxhfifo_ren_d1 && rxhfifo_rstatus[`RXSTATUS_SOP]) begin

        // Reset drop flag on SOP

        next_drop_data = 1'b0;

    end

    if (rxhfifo_ren_d1 && rxdfifo_wfull && !next_drop_data) begin

        // FIFO overflow, abort transfer. The rest of the frame
        // will be dropped. Since we can't put an EOP indication
        // in a fifo already full, there will be no EOP and receive
        // side will need to sync on next SOP.

        rxd_ovflow_error = 1'b1;
        next_drop_data = 1'b1;

    end


    rxdfifo_wen = rxhfifo_ren_d1 && !next_drop_data;



    if ((crc_done && !crc_good) || lenght_error) begin

        // Flag packet with error when CRC error is detected

        rxdfifo_wstatus[`RXSTATUS_ERR] = 1'b1;

    end

end

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "rx_hold_fifo.v"                                  ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module rx_hold_fifo(/*AUTOARG*/
  // Outputs
  rxhfifo_rdata, rxhfifo_rstatus, rxhfifo_rempty,
  rxhfifo_ralmost_empty,
  // Inputs
  clk_xgmii_rx, reset_xgmii_rx_n, rxhfifo_wdata, rxhfifo_wstatus,
  rxhfifo_wen, rxhfifo_ren
  );

input         clk_xgmii_rx;
input         reset_xgmii_rx_n;

input [63:0]  rxhfifo_wdata;
input [7:0]   rxhfifo_wstatus;
input         rxhfifo_wen;

input         rxhfifo_ren;

output [63:0] rxhfifo_rdata;
output [7:0]  rxhfifo_rstatus;
output        rxhfifo_rempty;
output        rxhfifo_ralmost_empty;

generic_fifo #(
  .DWIDTH (72),
  .AWIDTH (`RX_HOLD_FIFO_AWIDTH),
  .REGISTER_READ (1),
  .EARLY_READ (1),
  .CLOCK_CROSSING (0),
  .ALMOST_EMPTY_THRESH (7),
  .MEM_TYPE (`MEM_AUTO_SMALL)
)
fifo0(
    .wclk (clk_xgmii_rx),
    .wrst_n (reset_xgmii_rx_n),
    .wen (rxhfifo_wen),
    .wdata ({rxhfifo_wstatus, rxhfifo_wdata}),
    .wfull (),
    .walmost_full (),

    .rclk (clk_xgmii_rx),
    .rrst_n (reset_xgmii_rx_n),
    .ren (rxhfifo_ren),
    .rdata ({rxhfifo_rstatus, rxhfifo_rdata}),
    .rempty (rxhfifo_rempty),
    .ralmost_empty (rxhfifo_ralmost_empty)
);

   
endmodule

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "tx_hold_fifo.v"                                  ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module rx_stats_fifo(/*AUTOARG*/
  // Outputs
  rxsfifo_rdata, rxsfifo_rempty,
  // Inputs
  clk_xgmii_rx, reset_xgmii_rx_n, wb_clk_i, wb_rst_i, rxsfifo_wdata,
  rxsfifo_wen
  );

input         clk_xgmii_rx;
input         reset_xgmii_rx_n;
input         wb_clk_i;
input         wb_rst_i;

input [13:0]  rxsfifo_wdata;
input         rxsfifo_wen;

output [13:0] rxsfifo_rdata;
output        rxsfifo_rempty;

generic_fifo #(
  .DWIDTH (14),
  .AWIDTH (`RX_STAT_FIFO_AWIDTH),
  .REGISTER_READ (1),
  .EARLY_READ (1),
  .CLOCK_CROSSING (1),
  .ALMOST_EMPTY_THRESH (7),
  .ALMOST_FULL_THRESH (12),
  .MEM_TYPE (`MEM_AUTO_SMALL)
)
fifo0(
    .wclk (clk_xgmii_rx),
    .wrst_n (reset_xgmii_rx_n),
    .wen (rxsfifo_wen),
    .wdata (rxsfifo_wdata),
    .wfull (),
    .walmost_full (),

    .rclk (wb_clk_i),
    .rrst_n (~wb_rst_i),
    .ren (1'b1),
    .rdata (rxsfifo_rdata),
    .rempty (rxsfifo_rempty),
    .ralmost_empty ()
);

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "wishbone.v"                                      ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module stats_sm(/*AUTOARG*/
  // Outputs
  stats_tx_octets, stats_tx_pkts, stats_rx_octets, stats_rx_pkts,
  // Inputs
  wb_clk_i, wb_rst_i, txsfifo_rdata, txsfifo_rempty, rxsfifo_rdata,
  rxsfifo_rempty, clear_stats_tx_octets, clear_stats_tx_pkts,
  clear_stats_rx_octets, clear_stats_rx_pkts
  );


input         wb_clk_i;
input         wb_rst_i;

input  [13:0] txsfifo_rdata;
input         txsfifo_rempty;

input  [13:0] rxsfifo_rdata;
input         rxsfifo_rempty;

output [31:0] stats_tx_octets;
output [31:0] stats_tx_pkts;

output [31:0] stats_rx_octets;
output [31:0] stats_rx_pkts;

input         clear_stats_tx_octets;
input         clear_stats_tx_pkts;
input         clear_stats_rx_octets;
input         clear_stats_rx_pkts;

/*AUTOREG*/
// Beginning of automatic regs (for this module's undeclared outputs)
reg [31:0]              stats_rx_octets;
reg [31:0]              stats_rx_pkts;
reg [31:0]              stats_tx_octets;
reg [31:0]              stats_tx_pkts;
// End of automatics


/*AUTOWIRE*/

reg           txsfifo_rempty_d1;
reg           rxsfifo_rempty_d1;

reg [31:0]    next_stats_tx_octets;
reg [31:0]    next_stats_tx_pkts;

reg [31:0]    next_stats_rx_octets;
reg [31:0]    next_stats_rx_pkts;

always @(posedge wb_clk_i or posedge wb_rst_i) begin

    if (wb_rst_i == 1'b1) begin

        txsfifo_rempty_d1 <= 1'b1;
        rxsfifo_rempty_d1 <= 1'b1;

        stats_tx_octets <= 32'b0;
        stats_tx_pkts <= 32'b0;

        stats_rx_octets <= 32'b0;
        stats_rx_pkts <= 32'b0;

    end
    else begin

        txsfifo_rempty_d1 <= txsfifo_rempty;
        rxsfifo_rempty_d1 <= rxsfifo_rempty;

        stats_tx_octets <= next_stats_tx_octets;
        stats_tx_pkts <= next_stats_tx_pkts;

        stats_rx_octets <= next_stats_rx_octets;
        stats_rx_pkts <= next_stats_rx_pkts;

    end

end

always @(/*AS*/clear_stats_rx_octets or clear_stats_rx_pkts
         or clear_stats_tx_octets or clear_stats_tx_pkts
         or rxsfifo_rdata or rxsfifo_rempty_d1 or stats_rx_octets
         or stats_rx_pkts or stats_tx_octets or stats_tx_pkts
         or txsfifo_rdata or txsfifo_rempty_d1) begin

    next_stats_tx_octets = {32{~clear_stats_tx_octets}} & stats_tx_octets;
    next_stats_tx_pkts = {32{~clear_stats_tx_pkts}} & stats_tx_pkts;

    next_stats_rx_octets = {32{~clear_stats_rx_octets}} & stats_rx_octets;
    next_stats_rx_pkts = {32{~clear_stats_rx_pkts}} & stats_rx_pkts;

    if (!txsfifo_rempty_d1) begin
        next_stats_tx_octets = next_stats_tx_octets + {18'b0, txsfifo_rdata};
        next_stats_tx_pkts = next_stats_tx_pkts + 32'b1;
    end

    if (!rxsfifo_rempty_d1) begin
        next_stats_rx_octets = next_stats_rx_octets + {18'b0, rxsfifo_rdata};
        next_stats_rx_pkts = next_stats_rx_pkts + 32'b1;
    end

end

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "wishbone.v"                                      ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module stats(/*AUTOARG*/
  // Outputs
  stats_tx_pkts, stats_tx_octets, stats_rx_pkts, stats_rx_octets,
  // Inputs
  wb_rst_i, wb_clk_i, txsfifo_wen, txsfifo_wdata, rxsfifo_wen,
  rxsfifo_wdata, reset_xgmii_tx_n, reset_xgmii_rx_n, clk_xgmii_tx,
  clk_xgmii_rx, clear_stats_tx_pkts, clear_stats_tx_octets,
  clear_stats_rx_pkts, clear_stats_rx_octets
  );


/*AUTOINPUT*/
// Beginning of automatic inputs (from unused autoinst inputs)
input                   clear_stats_rx_octets;  // To stats_sm0 of stats_sm.v
input                   clear_stats_rx_pkts;    // To stats_sm0 of stats_sm.v
input                   clear_stats_tx_octets;  // To stats_sm0 of stats_sm.v
input                   clear_stats_tx_pkts;    // To stats_sm0 of stats_sm.v
input                   clk_xgmii_rx;           // To rx_stats_fifo0 of rx_stats_fifo.v
input                   clk_xgmii_tx;           // To tx_stats_fifo0 of tx_stats_fifo.v
input                   reset_xgmii_rx_n;       // To rx_stats_fifo0 of rx_stats_fifo.v
input                   reset_xgmii_tx_n;       // To tx_stats_fifo0 of tx_stats_fifo.v
input [13:0]            rxsfifo_wdata;          // To rx_stats_fifo0 of rx_stats_fifo.v
input                   rxsfifo_wen;            // To rx_stats_fifo0 of rx_stats_fifo.v
input [13:0]            txsfifo_wdata;          // To tx_stats_fifo0 of tx_stats_fifo.v
input                   txsfifo_wen;            // To tx_stats_fifo0 of tx_stats_fifo.v
input                   wb_clk_i;               // To tx_stats_fifo0 of tx_stats_fifo.v, ...
input                   wb_rst_i;               // To tx_stats_fifo0 of tx_stats_fifo.v, ...
// End of automatics

/*AUTOOUTPUT*/
// Beginning of automatic outputs (from unused autoinst outputs)
output [31:0]           stats_rx_octets;        // From stats_sm0 of stats_sm.v
output [31:0]           stats_rx_pkts;          // From stats_sm0 of stats_sm.v
output [31:0]           stats_tx_octets;        // From stats_sm0 of stats_sm.v
output [31:0]           stats_tx_pkts;          // From stats_sm0 of stats_sm.v
// End of automatics

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [13:0]             rxsfifo_rdata;          // From rx_stats_fifo0 of rx_stats_fifo.v
wire                    rxsfifo_rempty;         // From rx_stats_fifo0 of rx_stats_fifo.v
wire [13:0]             txsfifo_rdata;          // From tx_stats_fifo0 of tx_stats_fifo.v
wire                    txsfifo_rempty;         // From tx_stats_fifo0 of tx_stats_fifo.v
// End of automatics

tx_stats_fifo tx_stats_fifo0(/*AUTOINST*/
                             // Outputs
                             .txsfifo_rdata     (txsfifo_rdata[13:0]),
                             .txsfifo_rempty    (txsfifo_rempty),
                             // Inputs
                             .clk_xgmii_tx      (clk_xgmii_tx),
                             .reset_xgmii_tx_n  (reset_xgmii_tx_n),
                             .wb_clk_i          (wb_clk_i),
                             .wb_rst_i          (wb_rst_i),
                             .txsfifo_wdata     (txsfifo_wdata[13:0]),
                             .txsfifo_wen       (txsfifo_wen));

rx_stats_fifo rx_stats_fifo0(/*AUTOINST*/
                             // Outputs
                             .rxsfifo_rdata     (rxsfifo_rdata[13:0]),
                             .rxsfifo_rempty    (rxsfifo_rempty),
                             // Inputs
                             .clk_xgmii_rx      (clk_xgmii_rx),
                             .reset_xgmii_rx_n  (reset_xgmii_rx_n),
                             .wb_clk_i          (wb_clk_i),
                             .wb_rst_i          (wb_rst_i),
                             .rxsfifo_wdata     (rxsfifo_wdata[13:0]),
                             .rxsfifo_wen       (rxsfifo_wen));

stats_sm stats_sm0(/*AUTOINST*/
                   // Outputs
                   .stats_tx_octets     (stats_tx_octets[31:0]),
                   .stats_tx_pkts       (stats_tx_pkts[31:0]),
                   .stats_rx_octets     (stats_rx_octets[31:0]),
                   .stats_rx_pkts       (stats_rx_pkts[31:0]),
                   // Inputs
                   .wb_clk_i            (wb_clk_i),
                   .wb_rst_i            (wb_rst_i),
                   .txsfifo_rdata       (txsfifo_rdata[13:0]),
                   .txsfifo_rempty      (txsfifo_rempty),
                   .rxsfifo_rdata       (rxsfifo_rdata[13:0]),
                   .rxsfifo_rempty      (rxsfifo_rempty),
                   .clear_stats_tx_octets(clear_stats_tx_octets),
                   .clear_stats_tx_pkts (clear_stats_tx_pkts),
                   .clear_stats_rx_octets(clear_stats_rx_octets),
                   .clear_stats_rx_pkts (clear_stats_rx_pkts));

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sync_clk_core.v"                                 ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module sync_clk_core(/*AUTOARG*/
  // Inputs
  clk_xgmii_tx, reset_xgmii_tx_n
  );

input         clk_xgmii_tx;
input         reset_xgmii_tx_n;

//input         ctrl_tx_disable_padding;

//output        ctrl_tx_disable_padding_ccr;


/*AUTOREG*/

/*AUTOWIRE*/

//wire  [0:0]             sig_out;

//assign {ctrl_tx_disable_padding_ccr} = sig_out;

//meta_sync #(.DWIDTH (1)) meta_sync0 (
//                      // Outputs
//                      .out              (sig_out),
//                      // Inputs
//                      .clk              (clk_xgmii_tx),
//                      .reset_n          (reset_xgmii_tx_n),
//                      .in               ({
//                                          ctrl_tx_disable_padding
//                                         }));

endmodule

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sync_clk_wb.v"                                   ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module sync_clk_wb(/*AUTOARG*/
  // Outputs
  status_crc_error, status_fragment_error, status_lenght_error,
  status_txdfifo_ovflow, status_txdfifo_udflow, status_rxdfifo_ovflow,
  status_rxdfifo_udflow, status_pause_frame_rx, status_local_fault,
  status_remote_fault,
  // Inputs
  wb_clk_i, wb_rst_i, status_crc_error_tog, status_fragment_error_tog,
  status_lenght_error_tog, status_txdfifo_ovflow_tog,
  status_txdfifo_udflow_tog, status_rxdfifo_ovflow_tog,
  status_rxdfifo_udflow_tog, status_pause_frame_rx_tog,
  status_local_fault_crx, status_remote_fault_crx
  );

input         wb_clk_i;
input         wb_rst_i;

input         status_crc_error_tog;
input         status_fragment_error_tog;
input         status_lenght_error_tog;

input         status_txdfifo_ovflow_tog;

input         status_txdfifo_udflow_tog;

input         status_rxdfifo_ovflow_tog;

input         status_rxdfifo_udflow_tog;

input         status_pause_frame_rx_tog;

input         status_local_fault_crx;
input         status_remote_fault_crx;

output        status_crc_error;
output        status_fragment_error;
output        status_lenght_error;

output        status_txdfifo_ovflow;

output        status_txdfifo_udflow;

output        status_rxdfifo_ovflow;

output        status_rxdfifo_udflow;

output        status_pause_frame_rx;

output        status_local_fault;
output        status_remote_fault;

/*AUTOREG*/

/*AUTOWIRE*/

wire  [7:0]             sig_out1;
wire  [1:0]             sig_out2;

assign status_lenght_error = sig_out1[7];
assign status_crc_error = sig_out1[6];
assign status_fragment_error = sig_out1[5];
assign status_txdfifo_ovflow = sig_out1[4];
assign status_txdfifo_udflow = sig_out1[3];
assign status_rxdfifo_ovflow = sig_out1[2];
assign status_rxdfifo_udflow = sig_out1[1];
assign status_pause_frame_rx = sig_out1[0];

assign status_local_fault = sig_out2[1];
assign status_remote_fault = sig_out2[0];

meta_sync #(.DWIDTH (8), .EDGE_DETECT (1)) meta_sync0 (
                      // Outputs
                      .out              (sig_out1),
                      // Inputs
                      .clk              (wb_clk_i),
                      .reset_n          (~wb_rst_i),
                      .in               ({
                                          status_lenght_error_tog,
                                          status_crc_error_tog,
                                          status_fragment_error_tog,
                                          status_txdfifo_ovflow_tog,
                                          status_txdfifo_udflow_tog,
                                          status_rxdfifo_ovflow_tog,
                                          status_rxdfifo_udflow_tog,
                                          status_pause_frame_rx_tog
                                         }));

meta_sync #(.DWIDTH (2), .EDGE_DETECT (0)) meta_sync1 (
                      // Outputs
                      .out              (sig_out2),
                      // Inputs
                      .clk              (wb_clk_i),
                      .reset_n          (~wb_rst_i),
                      .in               ({
                                          status_local_fault_crx,
                                          status_remote_fault_crx
                                         }));

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sync_clk_xgmii.v"                                ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module sync_clk_xgmii_tx(/*AUTOARG*/
  // Outputs
  ctrl_tx_enable_ctx, status_local_fault_ctx, status_remote_fault_ctx,
  // Inputs
  clk_xgmii_tx, reset_xgmii_tx_n, ctrl_tx_enable,
  status_local_fault_crx, status_remote_fault_crx
  );

input         clk_xgmii_tx;
input         reset_xgmii_tx_n;

input         ctrl_tx_enable;

input         status_local_fault_crx;
input         status_remote_fault_crx;

output        ctrl_tx_enable_ctx;

output        status_local_fault_ctx;
output        status_remote_fault_ctx;

/*AUTOREG*/

/*AUTOWIRE*/

wire  [2:0]             sig_out;

assign ctrl_tx_enable_ctx = sig_out[2];
assign status_local_fault_ctx = sig_out[1];
assign status_remote_fault_ctx = sig_out[0];

meta_sync #(.DWIDTH (3)) meta_sync0 (
                      // Outputs
                      .out              (sig_out),
                      // Inputs
                      .clk              (clk_xgmii_tx),
                      .reset_n          (reset_xgmii_tx_n),
                      .in               ({
                                          ctrl_tx_enable,
                                          status_local_fault_crx,
                                          status_remote_fault_crx
                                         }));

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "tx_data_fifo.v"                                  ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module tx_data_fifo(/*AUTOARG*/
  // Outputs
  txdfifo_wfull, txdfifo_walmost_full, txdfifo_rdata, txdfifo_rstatus,
  txdfifo_rempty, txdfifo_ralmost_empty,
  // Inputs
  clk_xgmii_tx, clk_156m25, reset_xgmii_tx_n, reset_156m25_n,
  txdfifo_wdata, txdfifo_wstatus, txdfifo_wen, txdfifo_ren
  );

input         clk_xgmii_tx;
input         clk_156m25;
input         reset_xgmii_tx_n;
input         reset_156m25_n;

input [63:0]  txdfifo_wdata;
input [7:0]   txdfifo_wstatus;
input         txdfifo_wen;

input         txdfifo_ren;

output        txdfifo_wfull;
output        txdfifo_walmost_full;

output [63:0] txdfifo_rdata;
output [7:0]  txdfifo_rstatus;
output        txdfifo_rempty;
output        txdfifo_ralmost_empty;

generic_fifo #(
  .DWIDTH (72),
  .AWIDTH (`TX_DATA_FIFO_AWIDTH),
  .REGISTER_READ (1),
  .EARLY_READ (1),
  .CLOCK_CROSSING (1),
  .ALMOST_EMPTY_THRESH (7),
  .ALMOST_FULL_THRESH (12),
  .MEM_TYPE (`MEM_AUTO_MEDIUM)
)
fifo0(
    .wclk (clk_156m25),
    .wrst_n (reset_156m25_n),
    .wen (txdfifo_wen),
    .wdata ({txdfifo_wstatus, txdfifo_wdata}),
    .wfull (txdfifo_wfull),
    .walmost_full (txdfifo_walmost_full),

    .rclk (clk_xgmii_tx),
    .rrst_n (reset_xgmii_tx_n),
    .ren (txdfifo_ren),
    .rdata ({txdfifo_rstatus, txdfifo_rdata}),
    .rempty (txdfifo_rempty),
    .ralmost_empty (txdfifo_ralmost_empty)
);

endmodule

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "tx_dequeue.v"                                    ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module tx_dequeue(/*AUTOARG*/
  // Outputs
  txdfifo_ren, txhfifo_ren, txhfifo_wdata, txhfifo_wstatus,
  txhfifo_wen, xgmii_txd, xgmii_txc, status_txdfifo_udflow_tog,
  txsfifo_wen, txsfifo_wdata,
  // Inputs
  clk_xgmii_tx, reset_xgmii_tx_n, ctrl_tx_enable_ctx,
  status_local_fault_ctx, status_remote_fault_ctx, txdfifo_rdata,
  txdfifo_rstatus, txdfifo_rempty, txdfifo_ralmost_empty,
  txhfifo_rdata, txhfifo_rstatus, txhfifo_rempty,
  txhfifo_ralmost_empty, txhfifo_wfull, txhfifo_walmost_full
  );
`include "CRC32_D64.v"
`include "CRC32_D8.v"
`include "utils.v"

input         clk_xgmii_tx;
input         reset_xgmii_tx_n;

input         ctrl_tx_enable_ctx;

input         status_local_fault_ctx;
input         status_remote_fault_ctx;

input  [63:0] txdfifo_rdata;
input  [7:0]  txdfifo_rstatus;
input         txdfifo_rempty;
input         txdfifo_ralmost_empty;

input  [63:0] txhfifo_rdata;
input  [7:0]  txhfifo_rstatus;
input         txhfifo_rempty;
input         txhfifo_ralmost_empty;

input         txhfifo_wfull;
input         txhfifo_walmost_full;

output        txdfifo_ren;

output        txhfifo_ren;

output [63:0] txhfifo_wdata;
output [7:0]  txhfifo_wstatus;
output        txhfifo_wen;

output [63:0] xgmii_txd;
output [7:0]  xgmii_txc;

output        status_txdfifo_udflow_tog;

output        txsfifo_wen;
output [13:0] txsfifo_wdata;


/*AUTOREG*/
// Beginning of automatic regs (for this module's undeclared outputs)
reg                     status_txdfifo_udflow_tog;
reg                     txdfifo_ren;
reg                     txhfifo_ren;
reg [63:0]              txhfifo_wdata;
reg                     txhfifo_wen;
reg [7:0]               txhfifo_wstatus;
reg [13:0]              txsfifo_wdata;
reg                     txsfifo_wen;
reg [7:0]               xgmii_txc;
reg [63:0]              xgmii_txd;
// End of automatics

/*AUTOWIRE*/


reg   [63:0]    xgxs_txd;
reg   [7:0]     xgxs_txc;

reg   [63:0]    next_xgxs_txd;
reg   [7:0]     next_xgxs_txc;

reg   [2:0]     curr_state_enc;
reg   [2:0]     next_state_enc;

reg   [0:0]     curr_state_pad;
reg   [0:0]     next_state_pad;

reg             start_on_lane0;
reg             next_start_on_lane0;

reg   [2:0]     ifg_deficit;
reg   [2:0]     next_ifg_deficit;

reg             ifg_4b_add;
reg             next_ifg_4b_add;

reg             ifg_8b_add;
reg             next_ifg_8b_add;

reg             ifg_8b2_add;
reg             next_ifg_8b2_add;

reg   [7:0]     eop;
reg   [7:0]     next_eop;

reg   [63:32]   xgxs_txd_barrel;
reg   [7:4]     xgxs_txc_barrel;

reg   [63:0]    txhfifo_rdata_d1;

reg   [13:0]    add_cnt;
reg   [13:0]    byte_cnt;

reg   [31:0]    crc32_d64;
reg   [31:0]    crc32_d8;
reg   [31:0]    crc32_tx;

reg   [63:0]    shift_crc_data;
reg   [3:0]     shift_crc_eop;
reg   [3:0]     shift_crc_cnt;

reg   [31:0]    crc_data;

reg             frame_available;
reg             next_frame_available;

reg   [63:0]    next_txhfifo_wdata;
reg   [7:0]     next_txhfifo_wstatus;
reg             next_txhfifo_wen;

reg             txdfifo_ren_d1;

reg             frame_end;

parameter [2:0]
             SM_IDLE      = 3'd0,
             SM_PREAMBLE  = 3'd1,
             SM_TX        = 3'd2,
             SM_EOP       = 3'd3,
             SM_TERM      = 3'd4,
             SM_TERM_FAIL = 3'd5,
             SM_IFG       = 3'd6;

parameter [0:0]
             SM_PAD_EQ    = 1'd0,
             SM_PAD_PAD   = 1'd1;


//---
// RC layer

always @(posedge clk_xgmii_tx or negedge reset_xgmii_tx_n) begin

    if (reset_xgmii_tx_n == 1'b0) begin

        xgmii_txd <= {8{`IDLE}};
        xgmii_txc <= 8'hff;

    end
    else begin


        //---
        // RC Layer, insert local or remote fault messages based on status
        // of fault state-machine

        if (status_local_fault_ctx) begin

            // If local fault detected, send remote fault message to
            // link partner

            xgmii_txd <= {`REMOTE_FAULT, 8'h0, 8'h0, `SEQUENCE,
                          `REMOTE_FAULT, 8'h0, 8'h0, `SEQUENCE};
            xgmii_txc <= {4'b0001, 4'b0001};
        end
        else if (status_remote_fault_ctx) begin

            // If remote fault detected, inhibit transmission and send
            // idle codes

            xgmii_txd <= {8{`IDLE}};
            xgmii_txc <= 8'hff;
        end
        else begin
            xgmii_txd <= xgxs_txd;
            xgmii_txc <= xgxs_txc;
        end
    end

end


always @(posedge clk_xgmii_tx or negedge reset_xgmii_tx_n) begin

    if (reset_xgmii_tx_n == 1'b0) begin

        curr_state_enc <= SM_IDLE;

        start_on_lane0 <= 1'b1;
        ifg_deficit <= 3'b0;
        ifg_4b_add <= 1'b0;
        ifg_8b_add <= 1'b0;
        ifg_8b2_add <= 1'b0;

        eop <= 8'b0;

        txhfifo_rdata_d1 <= 64'b0;

        xgxs_txd_barrel <= {4{`IDLE}};
        xgxs_txc_barrel <= 4'hf;

        frame_available <= 1'b0;

        xgxs_txd <= {8{`IDLE}};
        xgxs_txc <= 8'hff;

        status_txdfifo_udflow_tog <= 1'b0;

        txsfifo_wen <= 1'b0;
        txsfifo_wdata <= 14'b0;

    end
    else begin

        curr_state_enc <= next_state_enc;

        start_on_lane0 <= next_start_on_lane0;
        ifg_deficit <= next_ifg_deficit;
        ifg_4b_add <= next_ifg_4b_add;
        ifg_8b_add <= next_ifg_8b_add;
        ifg_8b2_add <= next_ifg_8b2_add;

        eop <= next_eop;

        txhfifo_rdata_d1 <= txhfifo_rdata;

        xgxs_txd_barrel <= next_xgxs_txd[63:32];
        xgxs_txc_barrel <= next_xgxs_txc[7:4];

        frame_available <= next_frame_available;

        txsfifo_wen <= 1'b0;
        txsfifo_wdata <= byte_cnt;

        //---
        // Barrel shifter. Previous stage always align packet with LANE0.
        // This stage allow us to shift packet to align with LANE4 if needed
        // for correct inter frame gap (IFG).

        if (next_start_on_lane0) begin

            xgxs_txd <= next_xgxs_txd;
            xgxs_txc <= next_xgxs_txc;

        end
        else begin

            xgxs_txd <= {next_xgxs_txd[31:0], xgxs_txd_barrel};
            xgxs_txc <= {next_xgxs_txc[3:0], xgxs_txc_barrel};

        end

        //---
        // FIFO errors, used to generate interrupts.

        if (txdfifo_ren && txdfifo_rempty) begin
            status_txdfifo_udflow_tog <= ~status_txdfifo_udflow_tog;
        end

        //---
        // Frame count and size

        if (frame_end) begin
            txsfifo_wen <= 1'b1;
        end

    end

end

always @(/*AS*/crc32_tx or ctrl_tx_enable_ctx or curr_state_enc or eop
         or frame_available or ifg_4b_add or ifg_8b2_add or ifg_8b_add
         or ifg_deficit or start_on_lane0 or status_local_fault_ctx
         or status_remote_fault_ctx or txhfifo_ralmost_empty
         or txhfifo_rdata_d1 or txhfifo_rempty or txhfifo_rstatus) begin

    next_state_enc = curr_state_enc;

    next_start_on_lane0 = start_on_lane0;
    next_ifg_deficit = ifg_deficit;
    next_ifg_4b_add = ifg_4b_add;
    next_ifg_8b_add = ifg_8b_add;
    next_ifg_8b2_add = ifg_8b2_add;

    next_eop = eop;

    next_xgxs_txd = {8{`IDLE}};
    next_xgxs_txc = 8'hff;

    txhfifo_ren = 1'b0;

    next_frame_available = frame_available;

    case (curr_state_enc)

        SM_IDLE:
          begin

              // Wait for frame to be available. There should be a least N bytes in the
              // data fifo or a crc in the control fifo. The N bytes in the data fifo
              // give time to the enqueue engine to calculate crc and write it to the
              // control fifo. If crc is already in control fifo we can start transmitting
              // with no concern. Transmission is inhibited if local or remote faults
              // are detected.

              if (ctrl_tx_enable_ctx && frame_available &&
                  !status_local_fault_ctx && !status_remote_fault_ctx) begin

                  txhfifo_ren = 1'b1;
                  next_state_enc = SM_PREAMBLE;

              end
              else begin

                  next_frame_available = !txhfifo_ralmost_empty;
                  next_ifg_4b_add = 1'b0;

              end

          end

        SM_PREAMBLE:
         begin

             // On reading SOP from fifo, send SFD and preamble characters

             if (txhfifo_rstatus[`TXSTATUS_SOP]) begin

                 next_xgxs_txd = {`SFD, {6{`PREAMBLE}}, `START};
                 next_xgxs_txc = 8'h01;

                 txhfifo_ren = 1'b1;

                 next_state_enc = SM_TX;

             end
             else begin

                 next_frame_available = 1'b0;
                 next_state_enc = SM_IDLE;

             end


             // Depending on deficit idle count calculations, add 4 bytes
             // or IFG or not. This will determine on which lane start the
             // next frame.

             if (ifg_4b_add) begin
                 next_start_on_lane0 = 1'b0;
             end
             else begin
                 next_start_on_lane0 = 1'b1;
             end

          end

        SM_TX:
          begin

              next_xgxs_txd = txhfifo_rdata_d1;
              next_xgxs_txc = 8'h00;

              txhfifo_ren = 1'b1;


              // Wait for EOP indication to be read from the fifo, then
              // transition to next state.

              if (txhfifo_rstatus[`TXSTATUS_EOP]) begin

                  txhfifo_ren = 1'b0;
                  next_frame_available = !txhfifo_ralmost_empty;
                  next_state_enc = SM_EOP;

              end
              else if (txhfifo_rempty || txhfifo_rstatus[`TXSTATUS_SOP]) begin

                  // Failure condition, we did not see EOP and there
                  // is no more data in fifo or SOP, force end of packet transmit.

                  next_state_enc = SM_TERM_FAIL;

              end

              next_eop[0] = txhfifo_rstatus[2:0] == 3'd1;
              next_eop[1] = txhfifo_rstatus[2:0] == 3'd2;
              next_eop[2] = txhfifo_rstatus[2:0] == 3'd3;
              next_eop[3] = txhfifo_rstatus[2:0] == 3'd4;
              next_eop[4] = txhfifo_rstatus[2:0] == 3'd5;
              next_eop[5] = txhfifo_rstatus[2:0] == 3'd6;
              next_eop[6] = txhfifo_rstatus[2:0] == 3'd7;
              next_eop[7] = txhfifo_rstatus[2:0] == 3'd0;

          end

        SM_EOP:
          begin

              // Insert TERMINATE character in correct lane depending on position
              // of EOP read from fifo. Also insert CRC read from control fifo.

              if (eop[0]) begin
                  next_xgxs_txd = {{2{`IDLE}}, `TERMINATE,
                                   crc32_tx[31:0], txhfifo_rdata_d1[7:0]};
                  next_xgxs_txc = 8'b11100000;
              end

              if (eop[1]) begin
                  next_xgxs_txd = {`IDLE, `TERMINATE,
                                   crc32_tx[31:0], txhfifo_rdata_d1[15:0]};
                  next_xgxs_txc = 8'b11000000;
              end

              if (eop[2]) begin
                  next_xgxs_txd = {`TERMINATE, crc32_tx[31:0], txhfifo_rdata_d1[23:0]};
                  next_xgxs_txc = 8'b10000000;
              end

              if (eop[3]) begin
                  next_xgxs_txd = {crc32_tx[31:0], txhfifo_rdata_d1[31:0]};
                  next_xgxs_txc = 8'b00000000;
              end

              if (eop[4]) begin
                  next_xgxs_txd = {crc32_tx[23:0], txhfifo_rdata_d1[39:0]};
                  next_xgxs_txc = 8'b00000000;
              end

              if (eop[5]) begin
                  next_xgxs_txd = {crc32_tx[15:0], txhfifo_rdata_d1[47:0]};
                  next_xgxs_txc = 8'b00000000;
              end

              if (eop[6]) begin
                  next_xgxs_txd = {crc32_tx[7:0], txhfifo_rdata_d1[55:0]};
                  next_xgxs_txc = 8'b00000000;
              end

              if (eop[7]) begin
                  next_xgxs_txd = {txhfifo_rdata_d1[63:0]};
                  next_xgxs_txc = 8'b00000000;
              end

              if (!frame_available) begin

                  // If there is not another frame ready to be transmitted, interface
                  // will go idle and idle deficit idle count calculation is irrelevant.
                  // Set deficit to 0.

                  next_ifg_deficit = 3'b0;

              end
              else begin

                  // Idle deficit count calculated based on number of "wasted" bytes
                  // between TERMINATE and alignment of next frame in LANE0.

                  next_ifg_deficit = ifg_deficit +
                                     {2'b0, eop[0] | eop[4]} +
                                     {1'b0, eop[1] | eop[5], 1'b0} +
                                     {1'b0, eop[2] | eop[6],
                                      eop[2] | eop[6]};
              end

              // IFG corrections based on deficit count and previous starting lane
              // Calculated based on following table:
              //
              //                 DIC=0          DIC=1          DIC=2          DIC=3
              //              -------------  -------------  -------------  -------------
              // PktLen       IFG      Next  IFG      Next  IFG      Next  IFG      Next
              // Modulus      Length   DIC   Length   DIC   Length   DIC   Length   DIC
              // -----------------------------------------------------------------------
              //    0           12      0      12      1      12      2      12      3
              //    1           11      1      11      2      11      3      15      0
              //    2           10      2      10      3      14      0      14      1
              //    3            9      3      13      0      13      1      13      2
              //
              //
              // In logic it translates into adding 4, 8, or 12 bytes of IFG relative
              // to LANE0.
              //   IFG and Add columns assume no deficit applied
              //   IFG+DIC and Add+DIC assume deficit must be applied
              //
              //                        Start lane 0       Start lane 4
              // EOP Pads IFG  IFG+DIC	Add   Add+DIC	   Add    Add IFG
              // 0   3    11   15        8     12           12     16
              // 1   2    10   14        8     12           12     16
              // 2   1    9    13        8     12           12     16
              // 3   8    12   12        4     4            8      8
              // 4   7    11   15        4     8            8      12
              // 5   6    10   14        4     8            8      12
              // 6   5    9    13        4     8            8      12
              // 7   4    12   12        8     8            12     12

              if (!frame_available) begin

                  // If there is not another frame ready to be transmitted, interface
                  // will go idle and idle deficit idle count calculation is irrelevant.

                  next_ifg_4b_add = 1'b0;
                  next_ifg_8b_add = 1'b0;
                  next_ifg_8b2_add = 1'b0;

              end
              else if (next_ifg_deficit[2] == ifg_deficit[2]) begin

                  // Add 4 bytes IFG

                  next_ifg_4b_add = (eop[0] & !start_on_lane0) |
                                    (eop[1] & !start_on_lane0) |
                                    (eop[2] & !start_on_lane0) |
                                    (eop[3] & start_on_lane0) |
                                    (eop[4] & start_on_lane0) |
                                    (eop[5] & start_on_lane0) |
                                    (eop[6] & start_on_lane0) |
                                    (eop[7] & !start_on_lane0);

                  // Add 8 bytes IFG

                  next_ifg_8b_add = (eop[0]) |
                                    (eop[1]) |
                                    (eop[2]) |
                                    (eop[3] & !start_on_lane0) |
                                    (eop[4] & !start_on_lane0) |
                                    (eop[5] & !start_on_lane0) |
                                    (eop[6] & !start_on_lane0) |
                                    (eop[7]);

                  // Add another 8 bytes IFG

                  next_ifg_8b2_add = 1'b0;

              end
              else begin

                  // Add 4 bytes IFG

                  next_ifg_4b_add = (eop[0] & start_on_lane0) |
                                    (eop[1] & start_on_lane0) |
                                    (eop[2] & start_on_lane0) |
                                    (eop[3] &  start_on_lane0) |
                                    (eop[4] & !start_on_lane0) |
                                    (eop[5] & !start_on_lane0) |
                                    (eop[6] & !start_on_lane0) |
                                    (eop[7] & !start_on_lane0);

                  // Add 8 bytes IFG

                  next_ifg_8b_add = (eop[0]) |
                                    (eop[1]) |
                                    (eop[2]) |
                                    (eop[3] & !start_on_lane0) |
                                    (eop[4]) |
                                    (eop[5]) |
                                    (eop[6]) |
                                    (eop[7]);

                  // Add another 8 bytes IFG

                  next_ifg_8b2_add = (eop[0] & !start_on_lane0) |
                                     (eop[1] & !start_on_lane0) |
                                     (eop[2] & !start_on_lane0);

              end

              if (|eop[2:0]) begin

                  if (frame_available) begin

                      // Next state depends on number of IFG bytes to be inserted.
                      // Skip idle state if needed.

                      if (next_ifg_8b2_add) begin
                          next_state_enc = SM_IFG;
                      end
                      else if (next_ifg_8b_add) begin
                          next_state_enc = SM_IDLE;
                      end
                      else begin
                          txhfifo_ren = 1'b1;
                          next_state_enc = SM_PREAMBLE;
                      end

                  end
                  else begin
                      next_state_enc = SM_IFG;
                  end
              end

              if (|eop[7:3]) begin
                  next_state_enc = SM_TERM;
              end

          end

        SM_TERM:
          begin

              // Insert TERMINATE character in correct lane depending on position
              // of EOP read from fifo. Also insert CRC read from control fifo.

              if (eop[3]) begin
                  next_xgxs_txd = {{7{`IDLE}}, `TERMINATE};
                  next_xgxs_txc = 8'b11111111;
              end

              if (eop[4]) begin
                  next_xgxs_txd = {{6{`IDLE}}, `TERMINATE, crc32_tx[31:24]};
                  next_xgxs_txc = 8'b11111110;
              end

              if (eop[5]) begin
                  next_xgxs_txd = {{5{`IDLE}}, `TERMINATE, crc32_tx[31:16]};
                  next_xgxs_txc = 8'b11111100;
              end

              if (eop[6]) begin
                  next_xgxs_txd = {{4{`IDLE}}, `TERMINATE, crc32_tx[31:8]};
                  next_xgxs_txc = 8'b11111000;
              end

              if (eop[7]) begin
                  next_xgxs_txd = {{3{`IDLE}}, `TERMINATE, crc32_tx[31:0]};
                  next_xgxs_txc = 8'b11110000;
              end

              // Next state depends on number of IFG bytes to be inserted.
              // Skip idle state if needed.

              if (frame_available && !ifg_8b_add) begin
                  txhfifo_ren = 1'b1;
                  next_state_enc = SM_PREAMBLE;
              end
              else if (frame_available) begin
                  next_state_enc = SM_IDLE;
              end
              else begin
                  next_state_enc = SM_IFG;
              end

          end

        SM_TERM_FAIL:
          begin

              next_xgxs_txd = {{7{`IDLE}}, `TERMINATE};
              next_xgxs_txc = 8'b11111111;
              next_state_enc = SM_IFG;

          end

        SM_IFG:
          begin

              next_state_enc = SM_IDLE;

          end

        default:
          begin
              next_state_enc = SM_IDLE;
          end

    endcase

end


always @(/*AS*/crc32_d64 or next_txhfifo_wstatus or txhfifo_wen
         or txhfifo_wstatus) begin

    if (txhfifo_wen && txhfifo_wstatus[`TXSTATUS_SOP]) begin
        crc_data = 32'hffffffff;
    end
    else begin
        crc_data = crc32_d64;
    end

    if (next_txhfifo_wstatus[`TXSTATUS_EOP] && next_txhfifo_wstatus[2:0] != 3'b0) begin
        add_cnt = {11'b0, next_txhfifo_wstatus[2:0]};
    end
    else begin
        add_cnt = 14'd8;
    end

end

always @(/*AS*/byte_cnt or curr_state_pad or txdfifo_rdata
         or txdfifo_rempty or txdfifo_ren_d1 or txdfifo_rstatus
         or txhfifo_walmost_full) begin

    next_state_pad = curr_state_pad;

    next_txhfifo_wdata = txdfifo_rdata;
    next_txhfifo_wstatus = txdfifo_rstatus;

    txdfifo_ren = 1'b0;
    next_txhfifo_wen = 1'b0;

    case (curr_state_pad)

      SM_PAD_EQ: begin


          //---
          // If room availabe in hoding fifo and data available in
          // data fifo, transfer data words. If transmit state machine
          // is reading from fifo we can assume room will be available.

          if (!txhfifo_walmost_full) begin

              txdfifo_ren = !txdfifo_rempty;

          end


          //---
          // This logic dependent on read during previous cycle.

          if (txdfifo_ren_d1) begin

              next_txhfifo_wen = 1'b1;

              // On EOP, decide if padding is required for this packet.

              if (txdfifo_rstatus[`TXSTATUS_EOP]) begin

                  if (byte_cnt < 14'd60) begin

                      next_txhfifo_wstatus = `TXSTATUS_NONE;
                      txdfifo_ren = 1'b0;
                      next_state_pad = SM_PAD_PAD;

                  end
                  else if (byte_cnt == 14'd60 &&
                           (txdfifo_rstatus[2:0] == 3'd1 ||
                            txdfifo_rstatus[2:0] == 3'd2 ||
                            txdfifo_rstatus[2:0] == 3'd3)) begin

                      // Pad up to LANE3, keep the other 4 bytes for crc that will
                      // be inserted by dequeue engine.

                      next_txhfifo_wstatus[2:0] = 3'd4;

                      // Pad end bytes with zeros.

                      if (txdfifo_rstatus[2:0] == 3'd1)
                        next_txhfifo_wdata[31:8] = 24'b0;
                      if (txdfifo_rstatus[2:0] == 3'd2)
                        next_txhfifo_wdata[31:16] = 16'b0;
                      if (txdfifo_rstatus[2:0] == 3'd3)
                        next_txhfifo_wdata[31:24] = 8'b0;

                      txdfifo_ren = 1'b0;

                  end
                  else begin

                      txdfifo_ren = 1'b0;

                  end

              end

          end

      end

      SM_PAD_PAD: begin

          //---
          // Pad packet to 64 bytes by writting zeros to holding fifo.

          if (!txhfifo_walmost_full) begin

              next_txhfifo_wdata = 64'b0;
              next_txhfifo_wstatus = `TXSTATUS_NONE;
              next_txhfifo_wen = 1'b1;

              if (byte_cnt == 14'd60) begin


                  // Pad up to LANE3, keep the other 4 bytes for crc that will
                  // be inserted by dequeue engine.

                  next_txhfifo_wstatus[`TXSTATUS_EOP] = 1'b1;
                  next_txhfifo_wstatus[2:0] = 3'd4;

                  next_state_pad = SM_PAD_EQ;

              end

          end

      end

      default:
        begin
            next_state_pad = SM_PAD_EQ;
        end

    endcase

end


always @(posedge clk_xgmii_tx or negedge reset_xgmii_tx_n) begin

    if (reset_xgmii_tx_n == 1'b0) begin

        curr_state_pad <= SM_PAD_EQ;

        txdfifo_ren_d1 <= 1'b0;

        txhfifo_wdata <= 64'b0;
        txhfifo_wstatus <= 8'b0;
        txhfifo_wen <= 1'b0;

        byte_cnt <= 14'b0;

        shift_crc_data <= 64'b0;
        shift_crc_eop <= 4'b0;
        shift_crc_cnt <= 4'b0;

        crc32_d64 <= 32'b0;
        crc32_d8 <= 32'b0;
        crc32_tx <= 32'b0;

        frame_end <= 1'b0;

    end
    else begin

        curr_state_pad <= next_state_pad;

        txdfifo_ren_d1 <= txdfifo_ren;

        txhfifo_wdata <= next_txhfifo_wdata;
        txhfifo_wstatus <= next_txhfifo_wstatus;
        txhfifo_wen <= next_txhfifo_wen;

        frame_end <= 1'b0;

        //---
        // Reset byte count on SOP

        if (next_txhfifo_wen) begin

            if (next_txhfifo_wstatus[`TXSTATUS_SOP]) begin

                // Init byte count, 8-bytes + 4-bytes for CRC at the end of frame

                byte_cnt <= 14'd12;

            end
            else begin

                byte_cnt <= byte_cnt + add_cnt;

            end

            frame_end <= next_txhfifo_wstatus[`TXSTATUS_EOP];

        end


        //---
        // Calculate CRC as data is written to holding fifo. The holding fifo creates
        // a delay that allow the CRC calculation to complete before the end of the frame
        // is ready to be transmited.

        if (txhfifo_wen) begin

            crc32_d64 <= nextCRC32_D64(reverse_64b(txhfifo_wdata), crc_data);

        end

        if (txhfifo_wen && txhfifo_wstatus[`TXSTATUS_EOP]) begin

            // Last bytes calculated 8-bit at a time instead of 64-bit. Start
            // this process at the end of the frame.

            crc32_d8 <= crc32_d64;

            shift_crc_data <= txhfifo_wdata;
            shift_crc_cnt <= 4'd9;

            if (txhfifo_wstatus[2:0] == 3'b0) begin
              shift_crc_eop <= 4'd8;
            end
            else begin
                shift_crc_eop <= {1'b0, txhfifo_wstatus[2:0]};
            end

        end
        else if (shift_crc_eop != 4'b0) begin

            // Complete crc calculation 8-bit at a time until finished. This can
            // be 1 to 8 bytes long.

            crc32_d8 <= nextCRC32_D8(reverse_8b(shift_crc_data[7:0]), crc32_d8);

            shift_crc_data <= {8'b0, shift_crc_data[63:8]};
            shift_crc_eop <= shift_crc_eop - 4'd1;

        end


        //---
        // Update CRC register at the end of calculation. Always update after 8
        // cycles for deterministic results, even if a single byte was present in
        // last data word.

        if (shift_crc_cnt == 4'b1) begin

            crc32_tx <= ~reverse_32b(crc32_d8);

        end
        else begin

            shift_crc_cnt <= shift_crc_cnt - 4'd1;

        end

    end

end

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "tx_enqueue.v"                                    ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module tx_enqueue(/*AUTOARG*/
  // Outputs
  pkt_tx_full, txdfifo_wdata, txdfifo_wstatus, txdfifo_wen,
  status_txdfifo_ovflow_tog,
  // Inputs
  clk_156m25, reset_156m25_n, pkt_tx_data, pkt_tx_val, pkt_tx_sop,
  pkt_tx_eop, pkt_tx_mod, txdfifo_wfull, txdfifo_walmost_full
  );

`include "CRC32_D64.v"
`include "CRC32_D8.v"
`include "utils.v"

input         clk_156m25;
input         reset_156m25_n;

input  [63:0] pkt_tx_data;
input         pkt_tx_val;
input         pkt_tx_sop;
input         pkt_tx_eop;
input  [2:0]  pkt_tx_mod;

input         txdfifo_wfull;
input         txdfifo_walmost_full;

output        pkt_tx_full;

output [63:0] txdfifo_wdata;
output [7:0]  txdfifo_wstatus;
output        txdfifo_wen;

output        status_txdfifo_ovflow_tog;

/*AUTOREG*/
// Beginning of automatic regs (for this module's undeclared outputs)
reg                     status_txdfifo_ovflow_tog;
reg [63:0]              txdfifo_wdata;
reg                     txdfifo_wen;
reg [7:0]               txdfifo_wstatus;
// End of automatics

/*AUTOWIRE*/


reg             txd_ovflow;
reg             next_txd_ovflow;



// Full status if data fifo is almost full.
// Current packet can complete transfer since data input rate
// matches output rate. But next packet must wait for more headroom.

assign pkt_tx_full = txdfifo_walmost_full;



always @(posedge clk_156m25 or negedge reset_156m25_n) begin

    if (reset_156m25_n == 1'b0) begin

        txd_ovflow <= 1'b0;

        status_txdfifo_ovflow_tog <= 1'b0;

    end
    else begin

        txd_ovflow <= next_txd_ovflow;

        //---
        // FIFO errors, used to generate interrupts

        if (next_txd_ovflow && !txd_ovflow) begin
            status_txdfifo_ovflow_tog <= ~status_txdfifo_ovflow_tog;
        end

    end

end

always @(/*AS*/pkt_tx_data or pkt_tx_eop or pkt_tx_mod or pkt_tx_sop
         or pkt_tx_val or txd_ovflow or txdfifo_wfull) begin

    txdfifo_wstatus = `TXSTATUS_NONE;
    txdfifo_wen = pkt_tx_val;

    next_txd_ovflow = txd_ovflow;

    `ifdef BIGENDIAN
    txdfifo_wdata = {pkt_tx_data[7:0], pkt_tx_data[15:8], pkt_tx_data[23:16], pkt_tx_data[31:24],
                     pkt_tx_data[39:32], pkt_tx_data[47:40], pkt_tx_data[55:48],
                     pkt_tx_data[63:56]};
    `else
    txdfifo_wdata = pkt_tx_data;
    `endif

    // Write SOP marker to fifo.

    if (pkt_tx_val && pkt_tx_sop) begin

        txdfifo_wstatus[`TXSTATUS_SOP] = 1'b1;

    end


    // Write EOP marker to fifo.

    if (pkt_tx_val) begin

        if (pkt_tx_eop) begin
            txdfifo_wstatus[2:0] = pkt_tx_mod;
            txdfifo_wstatus[`TXSTATUS_EOP] = 1'b1;
        end

    end


    // Overflow indication

    if (pkt_tx_val) begin

        if (txdfifo_wfull) begin

            next_txd_ovflow = 1'b1;

        end
        else if (pkt_tx_sop) begin

            next_txd_ovflow = 1'b0;

        end
    end

end


endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "tx_hold_fifo.v"                                  ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module tx_hold_fifo(/*AUTOARG*/
  // Outputs
  txhfifo_wfull, txhfifo_walmost_full, txhfifo_rdata, txhfifo_rstatus,
  txhfifo_rempty, txhfifo_ralmost_empty,
  // Inputs
  clk_xgmii_tx, reset_xgmii_tx_n, txhfifo_wdata, txhfifo_wstatus,
  txhfifo_wen, txhfifo_ren
  );

input         clk_xgmii_tx;
input         reset_xgmii_tx_n;

input [63:0]  txhfifo_wdata;
input [7:0]   txhfifo_wstatus;
input         txhfifo_wen;

input         txhfifo_ren;

output        txhfifo_wfull;
output        txhfifo_walmost_full;

output [63:0] txhfifo_rdata;
output [7:0]  txhfifo_rstatus;
output        txhfifo_rempty;
output        txhfifo_ralmost_empty;

generic_fifo #(
  .DWIDTH (72),
  .AWIDTH (`TX_HOLD_FIFO_AWIDTH),
  .REGISTER_READ (1),
  .EARLY_READ (1),
  .CLOCK_CROSSING (0),
  .ALMOST_EMPTY_THRESH (7),
  .ALMOST_FULL_THRESH (4),
  .MEM_TYPE (`MEM_AUTO_SMALL)
)
fifo0(
    .wclk (clk_xgmii_tx),
    .wrst_n (reset_xgmii_tx_n),
    .wen (txhfifo_wen),
    .wdata ({txhfifo_wstatus, txhfifo_wdata}),
    .wfull (txhfifo_wfull),
    .walmost_full (txhfifo_walmost_full),

    .rclk (clk_xgmii_tx),
    .rrst_n (reset_xgmii_tx_n),
    .ren (txhfifo_ren),
    .rdata ({txhfifo_rstatus, txhfifo_rdata}),
    .rempty (txhfifo_rempty),
    .ralmost_empty (txhfifo_ralmost_empty)
);

endmodule

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "tx_hold_fifo.v"                                  ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module tx_stats_fifo(/*AUTOARG*/
  // Outputs
  txsfifo_rdata, txsfifo_rempty,
  // Inputs
  clk_xgmii_tx, reset_xgmii_tx_n, wb_clk_i, wb_rst_i, txsfifo_wdata,
  txsfifo_wen
  );

input         clk_xgmii_tx;
input         reset_xgmii_tx_n;
input         wb_clk_i;
input         wb_rst_i;

input [13:0]  txsfifo_wdata;
input         txsfifo_wen;

output [13:0] txsfifo_rdata;
output        txsfifo_rempty;

generic_fifo #(
  .DWIDTH (14),
  .AWIDTH (`TX_STAT_FIFO_AWIDTH),
  .REGISTER_READ (1),
  .EARLY_READ (1),
  .CLOCK_CROSSING (1),
  .ALMOST_EMPTY_THRESH (7),
  .ALMOST_FULL_THRESH (12),
  .MEM_TYPE (`MEM_AUTO_SMALL)
)
fifo0(
    .wclk (clk_xgmii_tx),
    .wrst_n (reset_xgmii_tx_n),
    .wen (txsfifo_wen),
    .wdata (txsfifo_wdata),
    .wfull (),
    .walmost_full (),

    .rclk (wb_clk_i),
    .rrst_n (~wb_rst_i),
    .ren (1'b1),
    .rdata (txsfifo_rdata),
    .rempty (txsfifo_rempty),
    .ralmost_empty ()
);

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "wishbone.v"                                      ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module wishbone_if(/*AUTOARG*/
  // Outputs
  wb_dat_o, wb_ack_o, wb_int_o, ctrl_tx_enable, clear_stats_tx_octets,
  clear_stats_tx_pkts, clear_stats_rx_octets, clear_stats_rx_pkts,
  // Inputs
  wb_clk_i, wb_rst_i, wb_adr_i, wb_dat_i, wb_we_i, wb_stb_i, wb_cyc_i,
  status_crc_error, status_fragment_error, status_lenght_error,
  status_txdfifo_ovflow, status_txdfifo_udflow, status_rxdfifo_ovflow,
  status_rxdfifo_udflow, status_pause_frame_rx, status_local_fault,
  status_remote_fault, stats_tx_octets, stats_tx_pkts,
  stats_rx_octets, stats_rx_pkts
  );


input         wb_clk_i;
input         wb_rst_i;

input  [7:0]  wb_adr_i;
input  [31:0] wb_dat_i;
input         wb_we_i;
input         wb_stb_i;
input         wb_cyc_i;

output [31:0] wb_dat_o;
output        wb_ack_o;
output        wb_int_o;

input         status_crc_error;
input         status_fragment_error;
input         status_lenght_error;

input         status_txdfifo_ovflow;

input         status_txdfifo_udflow;

input         status_rxdfifo_ovflow;

input         status_rxdfifo_udflow;

input         status_pause_frame_rx;

input         status_local_fault;
input         status_remote_fault;

input  [31:0] stats_tx_octets;
input  [31:0] stats_tx_pkts;

input  [31:0] stats_rx_octets;
input  [31:0] stats_rx_pkts;

output        ctrl_tx_enable;

output        clear_stats_tx_octets;
output        clear_stats_tx_pkts;
output        clear_stats_rx_octets;
output        clear_stats_rx_pkts;

/*AUTOREG*/
// Beginning of automatic regs (for this module's undeclared outputs)
reg                     clear_stats_rx_octets;
reg                     clear_stats_rx_pkts;
reg                     clear_stats_tx_octets;
reg                     clear_stats_tx_pkts;
reg [31:0]              wb_dat_o;
reg                     wb_int_o;
// End of automatics

reg [31:0]              next_wb_dat_o;
reg                     next_wb_int_o;

reg  [0:0]              cpureg_config0;
reg  [0:0]              next_cpureg_config0;

reg  [9:0]              cpureg_int_pending;
reg  [9:0]              next_cpureg_int_pending;

reg  [9:0]              cpureg_int_mask;
reg  [9:0]              next_cpureg_int_mask;

reg                     cpuack;
reg                     next_cpuack;

reg                     status_remote_fault_d1;
reg                     status_local_fault_d1;

/*AUTOWIRE*/

wire [9:0]             int_sources;


//---
// Source of interrupts, some are edge sensitive, others
// expect a pulse signal.

assign int_sources = {
                      status_lenght_error,
                      status_fragment_error,
                      status_crc_error,

                      status_pause_frame_rx,

                      status_remote_fault ^ status_remote_fault_d1,
                      status_local_fault ^ status_local_fault_d1,

                      status_rxdfifo_udflow,
                      status_rxdfifo_ovflow,
                      status_txdfifo_udflow,
                      status_txdfifo_ovflow
                      };

//---
// Config Register 0

assign ctrl_tx_enable = cpureg_config0[0];

//---
// Wishbone signals

assign wb_ack_o = cpuack && wb_stb_i;

always @(/*AS*/cpureg_config0 or cpureg_int_mask or cpureg_int_pending
         or int_sources or stats_rx_octets or stats_rx_pkts
         or stats_tx_octets or stats_tx_pkts or wb_adr_i or wb_cyc_i
         or wb_dat_i or wb_dat_o or wb_stb_i or wb_we_i) begin

    next_wb_dat_o = wb_dat_o;

    next_wb_int_o = |(cpureg_int_pending & cpureg_int_mask);

    next_cpureg_int_pending = cpureg_int_pending | int_sources;

    next_cpuack = wb_cyc_i && wb_stb_i;

    //---
    // Registers

    next_cpureg_config0 = cpureg_config0;
    next_cpureg_int_mask = cpureg_int_mask;

    //---
    // Clear on read signals

    clear_stats_tx_octets = 1'b0;
    clear_stats_tx_pkts = 1'b0;
    clear_stats_rx_octets = 1'b0;
    clear_stats_rx_pkts = 1'b0;

    //---
    // Read access

    if (wb_cyc_i && wb_stb_i && !wb_we_i) begin

        case ({wb_adr_i[7:2], 2'b0})

          `CPUREG_CONFIG0: begin
              next_wb_dat_o = {31'b0, cpureg_config0};
          end

          `CPUREG_INT_PENDING: begin
              next_wb_dat_o = {22'b0, cpureg_int_pending};
              next_cpureg_int_pending = int_sources;
              next_wb_int_o = 1'b0;
          end

          `CPUREG_INT_STATUS: begin
              next_wb_dat_o = {22'b0, int_sources};
          end

          `CPUREG_INT_MASK: begin
              next_wb_dat_o = {22'b0, cpureg_int_mask};
          end

          `CPUREG_STATSTXOCTETS: begin
              next_wb_dat_o = stats_tx_octets;
              clear_stats_tx_octets = 1'b1;
          end

          `CPUREG_STATSTXPKTS: begin
              next_wb_dat_o = stats_tx_pkts;
              clear_stats_tx_pkts = 1'b1;
          end

          `CPUREG_STATSRXOCTETS: begin
              next_wb_dat_o = stats_rx_octets;
              clear_stats_rx_octets = 1'b1;
          end

          `CPUREG_STATSRXPKTS: begin
              next_wb_dat_o = stats_rx_pkts;
              clear_stats_rx_pkts = 1'b1;
          end

          default: begin
          end

        endcase

    end

    //---
    // Write access

    if (wb_cyc_i && wb_stb_i && wb_we_i) begin

        case ({wb_adr_i[7:2], 2'b0})

          `CPUREG_CONFIG0: begin
              next_cpureg_config0 = wb_dat_i[0:0];
          end

          `CPUREG_INT_PENDING: begin
              next_cpureg_int_pending = wb_dat_i[9:0] | cpureg_int_pending | int_sources;
          end

          `CPUREG_INT_MASK: begin
              next_cpureg_int_mask = wb_dat_i[9:0];
          end

          default: begin
          end

        endcase

    end

end

always @(posedge wb_clk_i or posedge wb_rst_i) begin

    if (wb_rst_i == 1'b1) begin

        cpureg_config0 <= 1'h1;
        cpureg_int_pending <= 10'b0;
        cpureg_int_mask <= 10'b0;

        wb_dat_o <= 32'b0;
        wb_int_o <= 1'b0;

        cpuack <= 1'b0;

        status_remote_fault_d1 <= 1'b0;
        status_local_fault_d1 <= 1'b0;

    end
    else begin

        cpureg_config0 <= next_cpureg_config0;
        cpureg_int_pending <= next_cpureg_int_pending;
        cpureg_int_mask <= next_cpureg_int_mask;

        wb_dat_o <= next_wb_dat_o;
        wb_int_o <= next_wb_int_o;

        cpuack <= next_cpuack;

        status_remote_fault_d1 <= status_remote_fault;
        status_local_fault_d1 <= status_local_fault;

    end

end

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "xge_mac.v"                                       ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module xge_mac(/*AUTOARG*/
  // Outputs
  xgmii_txd, xgmii_txc, wb_int_o, wb_dat_o, wb_ack_o, pkt_tx_full,
  pkt_rx_val, pkt_rx_sop, pkt_rx_mod, pkt_rx_err, pkt_rx_eop,
  pkt_rx_data, pkt_rx_avail,
  // Inputs
  xgmii_rxd, xgmii_rxc, wb_we_i, wb_stb_i, wb_rst_i, wb_dat_i,
  wb_cyc_i, wb_clk_i, wb_adr_i, reset_xgmii_tx_n, reset_xgmii_rx_n,
  reset_156m25_n, pkt_tx_val, pkt_tx_sop, pkt_tx_mod, pkt_tx_eop,
  pkt_tx_data, pkt_rx_ren, clk_xgmii_tx, clk_xgmii_rx, clk_156m25
  );

/*AUTOINPUT*/
// Beginning of automatic inputs (from unused autoinst inputs)
input                   clk_156m25;             // To rx_dq0 of rx_dequeue.v, ...
input                   clk_xgmii_rx;           // To rx_eq0 of rx_enqueue.v, ...
input                   clk_xgmii_tx;           // To tx_dq0 of tx_dequeue.v, ...
input                   pkt_rx_ren;             // To rx_dq0 of rx_dequeue.v
input [63:0]            pkt_tx_data;            // To tx_eq0 of tx_enqueue.v
input                   pkt_tx_eop;             // To tx_eq0 of tx_enqueue.v
input [2:0]             pkt_tx_mod;             // To tx_eq0 of tx_enqueue.v
input                   pkt_tx_sop;             // To tx_eq0 of tx_enqueue.v
input                   pkt_tx_val;             // To tx_eq0 of tx_enqueue.v
input                   reset_156m25_n;         // To rx_dq0 of rx_dequeue.v, ...
input                   reset_xgmii_rx_n;       // To rx_eq0 of rx_enqueue.v, ...
input                   reset_xgmii_tx_n;       // To tx_dq0 of tx_dequeue.v, ...
input [7:0]             wb_adr_i;               // To wishbone_if0 of wishbone_if.v
input                   wb_clk_i;               // To sync_clk_wb0 of sync_clk_wb.v, ...
input                   wb_cyc_i;               // To wishbone_if0 of wishbone_if.v
input [31:0]            wb_dat_i;               // To wishbone_if0 of wishbone_if.v
input                   wb_rst_i;               // To sync_clk_wb0 of sync_clk_wb.v, ...
input                   wb_stb_i;               // To wishbone_if0 of wishbone_if.v
input                   wb_we_i;                // To wishbone_if0 of wishbone_if.v
input [7:0]             xgmii_rxc;              // To rx_eq0 of rx_enqueue.v
input [63:0]            xgmii_rxd;              // To rx_eq0 of rx_enqueue.v
// End of automatics

/*AUTOOUTPUT*/
// Beginning of automatic outputs (from unused autoinst outputs)
output                  pkt_rx_avail;           // From rx_dq0 of rx_dequeue.v
output [63:0]           pkt_rx_data;            // From rx_dq0 of rx_dequeue.v
output                  pkt_rx_eop;             // From rx_dq0 of rx_dequeue.v
output                  pkt_rx_err;             // From rx_dq0 of rx_dequeue.v
output [2:0]            pkt_rx_mod;             // From rx_dq0 of rx_dequeue.v
output                  pkt_rx_sop;             // From rx_dq0 of rx_dequeue.v
output                  pkt_rx_val;             // From rx_dq0 of rx_dequeue.v
output                  pkt_tx_full;            // From tx_eq0 of tx_enqueue.v
output                  wb_ack_o;               // From wishbone_if0 of wishbone_if.v
output [31:0]           wb_dat_o;               // From wishbone_if0 of wishbone_if.v
output                  wb_int_o;               // From wishbone_if0 of wishbone_if.v
output [7:0]            xgmii_txc;              // From tx_dq0 of tx_dequeue.v
output [63:0]           xgmii_txd;              // From tx_dq0 of tx_dequeue.v
// End of automatics

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire                    clear_stats_rx_octets;  // From wishbone_if0 of wishbone_if.v
wire                    clear_stats_rx_pkts;    // From wishbone_if0 of wishbone_if.v
wire                    clear_stats_tx_octets;  // From wishbone_if0 of wishbone_if.v
wire                    clear_stats_tx_pkts;    // From wishbone_if0 of wishbone_if.v
wire                    ctrl_tx_enable;         // From wishbone_if0 of wishbone_if.v
wire                    ctrl_tx_enable_ctx;     // From sync_clk_xgmii_tx0 of sync_clk_xgmii_tx.v
wire [1:0]              local_fault_msg_det;    // From rx_eq0 of rx_enqueue.v
wire [1:0]              remote_fault_msg_det;   // From rx_eq0 of rx_enqueue.v
wire                    rxdfifo_ralmost_empty;  // From rx_data_fifo0 of rx_data_fifo.v
wire [63:0]             rxdfifo_rdata;          // From rx_data_fifo0 of rx_data_fifo.v
wire                    rxdfifo_rempty;         // From rx_data_fifo0 of rx_data_fifo.v
wire                    rxdfifo_ren;            // From rx_dq0 of rx_dequeue.v
wire [7:0]              rxdfifo_rstatus;        // From rx_data_fifo0 of rx_data_fifo.v
wire [63:0]             rxdfifo_wdata;          // From rx_eq0 of rx_enqueue.v
wire                    rxdfifo_wen;            // From rx_eq0 of rx_enqueue.v
wire                    rxdfifo_wfull;          // From rx_data_fifo0 of rx_data_fifo.v
wire [7:0]              rxdfifo_wstatus;        // From rx_eq0 of rx_enqueue.v
wire                    rxhfifo_ralmost_empty;  // From rx_hold_fifo0 of rx_hold_fifo.v
wire [63:0]             rxhfifo_rdata;          // From rx_hold_fifo0 of rx_hold_fifo.v
wire                    rxhfifo_rempty;         // From rx_hold_fifo0 of rx_hold_fifo.v
wire                    rxhfifo_ren;            // From rx_eq0 of rx_enqueue.v
wire [7:0]              rxhfifo_rstatus;        // From rx_hold_fifo0 of rx_hold_fifo.v
wire [63:0]             rxhfifo_wdata;          // From rx_eq0 of rx_enqueue.v
wire                    rxhfifo_wen;            // From rx_eq0 of rx_enqueue.v
wire [7:0]              rxhfifo_wstatus;        // From rx_eq0 of rx_enqueue.v
wire [13:0]             rxsfifo_wdata;          // From rx_eq0 of rx_enqueue.v
wire                    rxsfifo_wen;            // From rx_eq0 of rx_enqueue.v
wire [31:0]             stats_rx_octets;        // From stats0 of stats.v
wire [31:0]             stats_rx_pkts;          // From stats0 of stats.v
wire [31:0]             stats_tx_octets;        // From stats0 of stats.v
wire [31:0]             stats_tx_pkts;          // From stats0 of stats.v
wire                    status_crc_error;       // From sync_clk_wb0 of sync_clk_wb.v
wire                    status_crc_error_tog;   // From rx_eq0 of rx_enqueue.v
wire                    status_fragment_error;  // From sync_clk_wb0 of sync_clk_wb.v
wire                    status_fragment_error_tog;// From rx_eq0 of rx_enqueue.v
wire                    status_lenght_error;    // From sync_clk_wb0 of sync_clk_wb.v
wire                    status_lenght_error_tog;// From rx_eq0 of rx_enqueue.v
wire                    status_local_fault;     // From sync_clk_wb0 of sync_clk_wb.v
wire                    status_local_fault_crx; // From fault_sm0 of fault_sm.v
wire                    status_local_fault_ctx; // From sync_clk_xgmii_tx0 of sync_clk_xgmii_tx.v
wire                    status_pause_frame_rx;  // From sync_clk_wb0 of sync_clk_wb.v
wire                    status_pause_frame_rx_tog;// From rx_eq0 of rx_enqueue.v
wire                    status_remote_fault;    // From sync_clk_wb0 of sync_clk_wb.v
wire                    status_remote_fault_crx;// From fault_sm0 of fault_sm.v
wire                    status_remote_fault_ctx;// From sync_clk_xgmii_tx0 of sync_clk_xgmii_tx.v
wire                    status_rxdfifo_ovflow;  // From sync_clk_wb0 of sync_clk_wb.v
wire                    status_rxdfifo_ovflow_tog;// From rx_eq0 of rx_enqueue.v
wire                    status_rxdfifo_udflow;  // From sync_clk_wb0 of sync_clk_wb.v
wire                    status_rxdfifo_udflow_tog;// From rx_dq0 of rx_dequeue.v
wire                    status_txdfifo_ovflow;  // From sync_clk_wb0 of sync_clk_wb.v
wire                    status_txdfifo_ovflow_tog;// From tx_eq0 of tx_enqueue.v
wire                    status_txdfifo_udflow;  // From sync_clk_wb0 of sync_clk_wb.v
wire                    status_txdfifo_udflow_tog;// From tx_dq0 of tx_dequeue.v
wire                    txdfifo_ralmost_empty;  // From tx_data_fifo0 of tx_data_fifo.v
wire [63:0]             txdfifo_rdata;          // From tx_data_fifo0 of tx_data_fifo.v
wire                    txdfifo_rempty;         // From tx_data_fifo0 of tx_data_fifo.v
wire                    txdfifo_ren;            // From tx_dq0 of tx_dequeue.v
wire [7:0]              txdfifo_rstatus;        // From tx_data_fifo0 of tx_data_fifo.v
wire                    txdfifo_walmost_full;   // From tx_data_fifo0 of tx_data_fifo.v
wire [63:0]             txdfifo_wdata;          // From tx_eq0 of tx_enqueue.v
wire                    txdfifo_wen;            // From tx_eq0 of tx_enqueue.v
wire                    txdfifo_wfull;          // From tx_data_fifo0 of tx_data_fifo.v
wire [7:0]              txdfifo_wstatus;        // From tx_eq0 of tx_enqueue.v
wire                    txhfifo_ralmost_empty;  // From tx_hold_fifo0 of tx_hold_fifo.v
wire [63:0]             txhfifo_rdata;          // From tx_hold_fifo0 of tx_hold_fifo.v
wire                    txhfifo_rempty;         // From tx_hold_fifo0 of tx_hold_fifo.v
wire                    txhfifo_ren;            // From tx_dq0 of tx_dequeue.v
wire [7:0]              txhfifo_rstatus;        // From tx_hold_fifo0 of tx_hold_fifo.v
wire                    txhfifo_walmost_full;   // From tx_hold_fifo0 of tx_hold_fifo.v
wire [63:0]             txhfifo_wdata;          // From tx_dq0 of tx_dequeue.v
wire                    txhfifo_wen;            // From tx_dq0 of tx_dequeue.v
wire                    txhfifo_wfull;          // From tx_hold_fifo0 of tx_hold_fifo.v
wire [7:0]              txhfifo_wstatus;        // From tx_dq0 of tx_dequeue.v
wire [13:0]             txsfifo_wdata;          // From tx_dq0 of tx_dequeue.v
wire                    txsfifo_wen;            // From tx_dq0 of tx_dequeue.v
// End of automatics

rx_enqueue rx_eq0(/*AUTOINST*/
                  // Outputs
                  .rxdfifo_wdata        (rxdfifo_wdata[63:0]),
                  .rxdfifo_wstatus      (rxdfifo_wstatus[7:0]),
                  .rxdfifo_wen          (rxdfifo_wen),
                  .rxhfifo_ren          (rxhfifo_ren),
                  .rxhfifo_wdata        (rxhfifo_wdata[63:0]),
                  .rxhfifo_wstatus      (rxhfifo_wstatus[7:0]),
                  .rxhfifo_wen          (rxhfifo_wen),
                  .local_fault_msg_det  (local_fault_msg_det[1:0]),
                  .remote_fault_msg_det (remote_fault_msg_det[1:0]),
                  .status_crc_error_tog (status_crc_error_tog),
                  .status_fragment_error_tog(status_fragment_error_tog),
                  .status_lenght_error_tog(status_lenght_error_tog),
                  .status_rxdfifo_ovflow_tog(status_rxdfifo_ovflow_tog),
                  .status_pause_frame_rx_tog(status_pause_frame_rx_tog),
                  .rxsfifo_wen          (rxsfifo_wen),
                  .rxsfifo_wdata        (rxsfifo_wdata[13:0]),
                  // Inputs
                  .clk_xgmii_rx         (clk_xgmii_rx),
                  .reset_xgmii_rx_n     (reset_xgmii_rx_n),
                  .xgmii_rxd            (xgmii_rxd[63:0]),
                  .xgmii_rxc            (xgmii_rxc[7:0]),
                  .rxdfifo_wfull        (rxdfifo_wfull),
                  .rxhfifo_rdata        (rxhfifo_rdata[63:0]),
                  .rxhfifo_rstatus      (rxhfifo_rstatus[7:0]),
                  .rxhfifo_rempty       (rxhfifo_rempty),
                  .rxhfifo_ralmost_empty(rxhfifo_ralmost_empty));

rx_dequeue rx_dq0(/*AUTOINST*/
                  // Outputs
                  .rxdfifo_ren          (rxdfifo_ren),
                  .pkt_rx_data          (pkt_rx_data[63:0]),
                  .pkt_rx_val           (pkt_rx_val),
                  .pkt_rx_sop           (pkt_rx_sop),
                  .pkt_rx_eop           (pkt_rx_eop),
                  .pkt_rx_err           (pkt_rx_err),
                  .pkt_rx_mod           (pkt_rx_mod[2:0]),
                  .pkt_rx_avail         (pkt_rx_avail),
                  .status_rxdfifo_udflow_tog(status_rxdfifo_udflow_tog),
                  // Inputs
                  .clk_156m25           (clk_156m25),
                  .reset_156m25_n       (reset_156m25_n),
                  .rxdfifo_rdata        (rxdfifo_rdata[63:0]),
                  .rxdfifo_rstatus      (rxdfifo_rstatus[7:0]),
                  .rxdfifo_rempty       (rxdfifo_rempty),
                  .rxdfifo_ralmost_empty(rxdfifo_ralmost_empty),
                  .pkt_rx_ren           (pkt_rx_ren));

rx_data_fifo rx_data_fifo0(/*AUTOINST*/
                           // Outputs
                           .rxdfifo_wfull       (rxdfifo_wfull),
                           .rxdfifo_rdata       (rxdfifo_rdata[63:0]),
                           .rxdfifo_rstatus     (rxdfifo_rstatus[7:0]),
                           .rxdfifo_rempty      (rxdfifo_rempty),
                           .rxdfifo_ralmost_empty(rxdfifo_ralmost_empty),
                           // Inputs
                           .clk_xgmii_rx        (clk_xgmii_rx),
                           .clk_156m25          (clk_156m25),
                           .reset_xgmii_rx_n    (reset_xgmii_rx_n),
                           .reset_156m25_n      (reset_156m25_n),
                           .rxdfifo_wdata       (rxdfifo_wdata[63:0]),
                           .rxdfifo_wstatus     (rxdfifo_wstatus[7:0]),
                           .rxdfifo_wen         (rxdfifo_wen),
                           .rxdfifo_ren         (rxdfifo_ren));

rx_hold_fifo rx_hold_fifo0(/*AUTOINST*/
                           // Outputs
                           .rxhfifo_rdata       (rxhfifo_rdata[63:0]),
                           .rxhfifo_rstatus     (rxhfifo_rstatus[7:0]),
                           .rxhfifo_rempty      (rxhfifo_rempty),
                           .rxhfifo_ralmost_empty(rxhfifo_ralmost_empty),
                           // Inputs
                           .clk_xgmii_rx        (clk_xgmii_rx),
                           .reset_xgmii_rx_n    (reset_xgmii_rx_n),
                           .rxhfifo_wdata       (rxhfifo_wdata[63:0]),
                           .rxhfifo_wstatus     (rxhfifo_wstatus[7:0]),
                           .rxhfifo_wen         (rxhfifo_wen),
                           .rxhfifo_ren         (rxhfifo_ren));

tx_enqueue tx_eq0 (/*AUTOINST*/
                   // Outputs
                   .pkt_tx_full         (pkt_tx_full),
                   .txdfifo_wdata       (txdfifo_wdata[63:0]),
                   .txdfifo_wstatus     (txdfifo_wstatus[7:0]),
                   .txdfifo_wen         (txdfifo_wen),
                   .status_txdfifo_ovflow_tog(status_txdfifo_ovflow_tog),
                   // Inputs
                   .clk_156m25          (clk_156m25),
                   .reset_156m25_n      (reset_156m25_n),
                   .pkt_tx_data         (pkt_tx_data[63:0]),
                   .pkt_tx_val          (pkt_tx_val),
                   .pkt_tx_sop          (pkt_tx_sop),
                   .pkt_tx_eop          (pkt_tx_eop),
                   .pkt_tx_mod          (pkt_tx_mod[2:0]),
                   .txdfifo_wfull       (txdfifo_wfull),
                   .txdfifo_walmost_full(txdfifo_walmost_full));

tx_dequeue tx_dq0(/*AUTOINST*/
                  // Outputs
                  .txdfifo_ren          (txdfifo_ren),
                  .txhfifo_ren          (txhfifo_ren),
                  .txhfifo_wdata        (txhfifo_wdata[63:0]),
                  .txhfifo_wstatus      (txhfifo_wstatus[7:0]),
                  .txhfifo_wen          (txhfifo_wen),
                  .xgmii_txd            (xgmii_txd[63:0]),
                  .xgmii_txc            (xgmii_txc[7:0]),
                  .status_txdfifo_udflow_tog(status_txdfifo_udflow_tog),
                  .txsfifo_wen          (txsfifo_wen),
                  .txsfifo_wdata        (txsfifo_wdata[13:0]),
                  // Inputs
                  .clk_xgmii_tx         (clk_xgmii_tx),
                  .reset_xgmii_tx_n     (reset_xgmii_tx_n),
                  .ctrl_tx_enable_ctx   (ctrl_tx_enable_ctx),
                  .status_local_fault_ctx(status_local_fault_ctx),
                  .status_remote_fault_ctx(status_remote_fault_ctx),
                  .txdfifo_rdata        (txdfifo_rdata[63:0]),
                  .txdfifo_rstatus      (txdfifo_rstatus[7:0]),
                  .txdfifo_rempty       (txdfifo_rempty),
                  .txdfifo_ralmost_empty(txdfifo_ralmost_empty),
                  .txhfifo_rdata        (txhfifo_rdata[63:0]),
                  .txhfifo_rstatus      (txhfifo_rstatus[7:0]),
                  .txhfifo_rempty       (txhfifo_rempty),
                  .txhfifo_ralmost_empty(txhfifo_ralmost_empty),
                  .txhfifo_wfull        (txhfifo_wfull),
                  .txhfifo_walmost_full (txhfifo_walmost_full));

tx_data_fifo tx_data_fifo0(/*AUTOINST*/
                           // Outputs
                           .txdfifo_wfull       (txdfifo_wfull),
                           .txdfifo_walmost_full(txdfifo_walmost_full),
                           .txdfifo_rdata       (txdfifo_rdata[63:0]),
                           .txdfifo_rstatus     (txdfifo_rstatus[7:0]),
                           .txdfifo_rempty      (txdfifo_rempty),
                           .txdfifo_ralmost_empty(txdfifo_ralmost_empty),
                           // Inputs
                           .clk_xgmii_tx        (clk_xgmii_tx),
                           .clk_156m25          (clk_156m25),
                           .reset_xgmii_tx_n    (reset_xgmii_tx_n),
                           .reset_156m25_n      (reset_156m25_n),
                           .txdfifo_wdata       (txdfifo_wdata[63:0]),
                           .txdfifo_wstatus     (txdfifo_wstatus[7:0]),
                           .txdfifo_wen         (txdfifo_wen),
                           .txdfifo_ren         (txdfifo_ren));

tx_hold_fifo tx_hold_fifo0(/*AUTOINST*/
                           // Outputs
                           .txhfifo_wfull       (txhfifo_wfull),
                           .txhfifo_walmost_full(txhfifo_walmost_full),
                           .txhfifo_rdata       (txhfifo_rdata[63:0]),
                           .txhfifo_rstatus     (txhfifo_rstatus[7:0]),
                           .txhfifo_rempty      (txhfifo_rempty),
                           .txhfifo_ralmost_empty(txhfifo_ralmost_empty),
                           // Inputs
                           .clk_xgmii_tx        (clk_xgmii_tx),
                           .reset_xgmii_tx_n    (reset_xgmii_tx_n),
                           .txhfifo_wdata       (txhfifo_wdata[63:0]),
                           .txhfifo_wstatus     (txhfifo_wstatus[7:0]),
                           .txhfifo_wen         (txhfifo_wen),
                           .txhfifo_ren         (txhfifo_ren));

fault_sm fault_sm0(/*AUTOINST*/
                   // Outputs
                   .status_local_fault_crx(status_local_fault_crx),
                   .status_remote_fault_crx(status_remote_fault_crx),
                   // Inputs
                   .clk_xgmii_rx        (clk_xgmii_rx),
                   .reset_xgmii_rx_n    (reset_xgmii_rx_n),
                   .local_fault_msg_det (local_fault_msg_det[1:0]),
                   .remote_fault_msg_det(remote_fault_msg_det[1:0]));

sync_clk_wb sync_clk_wb0(/*AUTOINST*/
                         // Outputs
                         .status_crc_error      (status_crc_error),
                         .status_fragment_error (status_fragment_error),
                         .status_lenght_error   (status_lenght_error),
                         .status_txdfifo_ovflow (status_txdfifo_ovflow),
                         .status_txdfifo_udflow (status_txdfifo_udflow),
                         .status_rxdfifo_ovflow (status_rxdfifo_ovflow),
                         .status_rxdfifo_udflow (status_rxdfifo_udflow),
                         .status_pause_frame_rx (status_pause_frame_rx),
                         .status_local_fault    (status_local_fault),
                         .status_remote_fault   (status_remote_fault),
                         // Inputs
                         .wb_clk_i              (wb_clk_i),
                         .wb_rst_i              (wb_rst_i),
                         .status_crc_error_tog  (status_crc_error_tog),
                         .status_fragment_error_tog(status_fragment_error_tog),
                         .status_lenght_error_tog(status_lenght_error_tog),
                         .status_txdfifo_ovflow_tog(status_txdfifo_ovflow_tog),
                         .status_txdfifo_udflow_tog(status_txdfifo_udflow_tog),
                         .status_rxdfifo_ovflow_tog(status_rxdfifo_ovflow_tog),
                         .status_rxdfifo_udflow_tog(status_rxdfifo_udflow_tog),
                         .status_pause_frame_rx_tog(status_pause_frame_rx_tog),
                         .status_local_fault_crx(status_local_fault_crx),
                         .status_remote_fault_crx(status_remote_fault_crx));

sync_clk_xgmii_tx sync_clk_xgmii_tx0(/*AUTOINST*/
                                     // Outputs
                                     .ctrl_tx_enable_ctx(ctrl_tx_enable_ctx),
                                     .status_local_fault_ctx(status_local_fault_ctx),
                                     .status_remote_fault_ctx(status_remote_fault_ctx),
                                     // Inputs
                                     .clk_xgmii_tx      (clk_xgmii_tx),
                                     .reset_xgmii_tx_n  (reset_xgmii_tx_n),
                                     .ctrl_tx_enable    (ctrl_tx_enable),
                                     .status_local_fault_crx(status_local_fault_crx),
                                     .status_remote_fault_crx(status_remote_fault_crx));

stats stats0(/*AUTOINST*/
             // Outputs
             .stats_rx_octets           (stats_rx_octets[31:0]),
             .stats_rx_pkts             (stats_rx_pkts[31:0]),
             .stats_tx_octets           (stats_tx_octets[31:0]),
             .stats_tx_pkts             (stats_tx_pkts[31:0]),
             // Inputs
             .clear_stats_rx_octets     (clear_stats_rx_octets),
             .clear_stats_rx_pkts       (clear_stats_rx_pkts),
             .clear_stats_tx_octets     (clear_stats_tx_octets),
             .clear_stats_tx_pkts       (clear_stats_tx_pkts),
             .clk_xgmii_rx              (clk_xgmii_rx),
             .clk_xgmii_tx              (clk_xgmii_tx),
             .reset_xgmii_rx_n          (reset_xgmii_rx_n),
             .reset_xgmii_tx_n          (reset_xgmii_tx_n),
             .rxsfifo_wdata             (rxsfifo_wdata[13:0]),
             .rxsfifo_wen               (rxsfifo_wen),
             .txsfifo_wdata             (txsfifo_wdata[13:0]),
             .txsfifo_wen               (txsfifo_wen),
             .wb_clk_i                  (wb_clk_i),
             .wb_rst_i                  (wb_rst_i));

//sync_clk_core sync_clk_core0(/*AUTOINST*/
//                             // Inputs
//                             .clk_xgmii_tx      (clk_xgmii_tx),
//                             .reset_xgmii_tx_n  (reset_xgmii_tx_n));

wishbone_if wishbone_if0(/*AUTOINST*/
                         // Outputs
                         .wb_dat_o              (wb_dat_o[31:0]),
                         .wb_ack_o              (wb_ack_o),
                         .wb_int_o              (wb_int_o),
                         .ctrl_tx_enable        (ctrl_tx_enable),
                         .clear_stats_tx_octets (clear_stats_tx_octets),
                         .clear_stats_tx_pkts   (clear_stats_tx_pkts),
                         .clear_stats_rx_octets (clear_stats_rx_octets),
                         .clear_stats_rx_pkts   (clear_stats_rx_pkts),
                         // Inputs
                         .wb_clk_i              (wb_clk_i),
                         .wb_rst_i              (wb_rst_i),
                         .wb_adr_i              (wb_adr_i[7:0]),
                         .wb_dat_i              (wb_dat_i[31:0]),
                         .wb_we_i               (wb_we_i),
                         .wb_stb_i              (wb_stb_i),
                         .wb_cyc_i              (wb_cyc_i),
                         .status_crc_error      (status_crc_error),
                         .status_fragment_error (status_fragment_error),
                         .status_lenght_error   (status_lenght_error),
                         .status_txdfifo_ovflow (status_txdfifo_ovflow),
                         .status_txdfifo_udflow (status_txdfifo_udflow),
                         .status_rxdfifo_ovflow (status_rxdfifo_ovflow),
                         .status_rxdfifo_udflow (status_rxdfifo_udflow),
                         .status_pause_frame_rx (status_pause_frame_rx),
                         .status_local_fault    (status_local_fault),
                         .status_remote_fault   (status_remote_fault),
                         .stats_tx_octets       (stats_tx_octets[31:0]),
                         .stats_tx_pkts         (stats_tx_pkts[31:0]),
                         .stats_rx_octets       (stats_rx_octets[31:0]),
                         .stats_rx_pkts         (stats_rx_pkts[31:0]));

endmodule
