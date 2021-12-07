//////////////////////////////////////////////////////////////////////////////////
// Company:         
// Engineer:        IK
// 
// Create Date:     
// Design Name:     
// Module Name:     clk_module
// Project Name:    
// Target Devices:  
// Tool versions:   
// Description:     
//                  
//                  
// Revision: 
// Revision 0.01 - File Created, 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module clk_module
(
    // CLK-in
    input   i_clk_200,
    // CLK-out
    output  o_clk_50,
    // ??
    input   i_arst,
    output  o_locked
);
//////////////////////////////////////////////////////////////////////////////////
    // ??
    wire [15:0] do_unused;
    wire        drdy_unused;
    wire        psdone_unused;
    wire        clkfbout_clk_wiz_0;
    wire        clkfbout_buf_clk_wiz_0;
    wire        clkfboutb_unused;
    wire clkout0b_unused;
    wire clkout1_unused;
    wire clkout1b_unused;
    wire clkout2_unused;
    wire clkout2b_unused;
    wire clkout3_unused;
    wire clkout3b_unused;
    wire clkout4_unused;
    wire clkout5_unused;
    wire clkout6_unused;
    wire        clkfbstopped_unused;
    wire        clkinstopped_unused;
    
//////////////////////////////////////////////////////////////////////////////////
//
// 
//
MMCME2_ADV #
(
    .BANDWIDTH            ("OPTIMIZED"),
    .COMPENSATION         ("ZHOLD"),
    
    .DIVCLK_DIVIDE        (1),
    
    .CLKFBOUT_MULT_F      (5.000),
    .CLKFBOUT_PHASE       (0.000),
    
    .CLKOUT0_DIVIDE_F     (20.000), // out-freq: 50MHz
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    
    .CLKIN1_PERIOD        (5.000),  // in-freq: 200MHz
    .REF_JITTER1          (0.010)
)
mmcm_adv_inst
(
    // Output clocks
    .CLKFBOUT            (clkfbout_clk_wiz_0),
    .CLKFBOUTB           (clkfboutb_unused),
    .CLKOUT0             (clk_out1_clk_wiz_0),
    .CLKOUT0B            (clkout0b_unused),
    .CLKOUT1             (clkout1_unused),
    .CLKOUT1B            (clkout1b_unused),
    .CLKOUT2             (clkout2_unused),
    .CLKOUT2B            (clkout2b_unused),
    .CLKOUT3             (clkout3_unused),
    .CLKOUT3B            (clkout3b_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
    .CLKOUT6             (clkout6_unused),
     // Input clock control
    .CLKFBIN             (clkfbout_buf_clk_wiz_0),
    .CLKIN1              (i_clk_200),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (psdone_unused),
    // Other control and status signals
    .LOCKED              (o_locked),
    .CLKINSTOPPED        (clkinstopped_unused),
    .CLKFBSTOPPED        (clkfbstopped_unused),
    .PWRDWN              (1'b0),
    .RST                 (i_arst)
);
//////////////////////////////////////////////////////////////////////////////////
//
// CLK buffering
//
BUFG    clkf_buf
(
.O      (clkfbout_buf_clk_wiz_0),
.I      (clkfbout_clk_wiz_0)
);

BUFG    clkout1_buf
(
.O      (o_clk_50),
.I      (clk_out1_clk_wiz_0)
);
//////////////////////////////////////////////////////////////////////////////////
endmodule
