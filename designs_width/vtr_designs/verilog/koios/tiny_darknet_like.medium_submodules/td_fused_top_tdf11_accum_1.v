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

module td_fused_top_tdf11_accum_1 (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_continue,
        ap_idle,
        ap_ready,
        accum_in_address0,
        accum_in_ce0,
        accum_in_q0,
        accum_in_address1,
        accum_in_ce1,
        accum_in_q1,
        accum_in1_address0,
        accum_in1_ce0,
        accum_in1_q0,
        accum_in1_address1,
        accum_in1_ce1,
        accum_in1_q1,
        accum_in2_address0,
        accum_in2_ce0,
        accum_in2_q0,
        accum_in2_address1,
        accum_in2_ce1,
        accum_in2_q1,
        accum_in3_address0,
        accum_in3_ce0,
        accum_in3_q0,
        accum_in3_address1,
        accum_in3_ce1,
        accum_in3_q1,
        accum_out_address0,
        accum_out_ce0,
        accum_out_we0,
        accum_out_d0,
        accum_out_address1,
        accum_out_ce1,
        accum_out_we1,
        accum_out_d1
);

parameter    ap_ST_fsm_state1 = 11'd1;
parameter    ap_ST_fsm_pp0_stage0 = 11'd2;
parameter    ap_ST_fsm_pp0_stage1 = 11'd4;
parameter    ap_ST_fsm_pp0_stage2 = 11'd8;
parameter    ap_ST_fsm_pp0_stage3 = 11'd16;
parameter    ap_ST_fsm_pp0_stage4 = 11'd32;
parameter    ap_ST_fsm_pp0_stage5 = 11'd64;
parameter    ap_ST_fsm_pp0_stage6 = 11'd128;
parameter    ap_ST_fsm_state18 = 11'd256;
parameter    ap_ST_fsm_pp1_stage0 = 11'd512;
parameter    ap_ST_fsm_state21 = 11'd1024;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
input   ap_continue;
output   ap_idle;
output   ap_ready;
output  [7:0] accum_in_address0;
output   accum_in_ce0;
input  [15:0] accum_in_q0;
output  [7:0] accum_in_address1;
output   accum_in_ce1;
input  [15:0] accum_in_q1;
output  [7:0] accum_in1_address0;
output   accum_in1_ce0;
input  [15:0] accum_in1_q0;
output  [7:0] accum_in1_address1;
output   accum_in1_ce1;
input  [15:0] accum_in1_q1;
output  [7:0] accum_in2_address0;
output   accum_in2_ce0;
input  [15:0] accum_in2_q0;
output  [7:0] accum_in2_address1;
output   accum_in2_ce1;
input  [15:0] accum_in2_q1;
output  [7:0] accum_in3_address0;
output   accum_in3_ce0;
input  [15:0] accum_in3_q0;
output  [7:0] accum_in3_address1;
output   accum_in3_ce1;
input  [15:0] accum_in3_q1;
output  [4:0] accum_out_address0;
output   accum_out_ce0;
output   accum_out_we0;
output  [15:0] accum_out_d0;
output  [4:0] accum_out_address1;
output   accum_out_ce1;
output   accum_out_we1;
output  [15:0] accum_out_d1;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg[7:0] accum_in_address0;
reg accum_in_ce0;
reg[7:0] accum_in_address1;
reg accum_in_ce1;
reg[7:0] accum_in1_address0;
reg accum_in1_ce0;
reg[7:0] accum_in1_address1;
reg accum_in1_ce1;
reg[7:0] accum_in2_address0;
reg accum_in2_ce0;
reg[7:0] accum_in2_address1;
reg accum_in2_ce1;
reg[7:0] accum_in3_address0;
reg accum_in3_ce0;
reg[7:0] accum_in3_address1;
reg accum_in3_ce1;
reg accum_out_ce0;
reg accum_out_we0;
reg accum_out_ce1;
reg accum_out_we1;

reg    ap_done_reg;
  reg   [10:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg   [9:0] x_reg_447;
reg   [15:0] psum_4_05_reg_459;
reg   [15:0] psum_3_04_reg_471;
reg   [15:0] psum_2_03_reg_483;
reg   [15:0] psum_1_02_reg_495;
reg   [15:0] psum_0_01_reg_507;
reg   [15:0] psum_9_010_reg_519;
reg   [15:0] psum_8_09_reg_531;
reg   [15:0] psum_7_08_reg_543;
reg   [15:0] psum_6_07_reg_555;
reg   [15:0] psum_5_06_reg_567;
reg   [15:0] psum_31_032_reg_579;
reg   [15:0] psum_30_031_reg_591;
reg   [15:0] psum_29_030_reg_603;
reg   [15:0] psum_28_029_reg_615;
reg   [15:0] psum_27_028_reg_627;
reg   [15:0] psum_26_027_reg_639;
reg   [15:0] psum_25_026_reg_651;
reg   [15:0] psum_24_025_reg_663;
reg   [15:0] psum_23_024_reg_675;
reg   [15:0] psum_22_023_reg_687;
reg   [15:0] psum_21_022_reg_699;
reg   [15:0] psum_20_021_reg_711;
reg   [15:0] psum_19_020_reg_723;
reg   [15:0] psum_18_019_reg_735;
reg   [15:0] psum_17_018_reg_747;
reg   [15:0] psum_16_017_reg_759;
reg   [15:0] psum_15_016_reg_771;
reg   [15:0] psum_14_015_reg_783;
reg   [15:0] psum_13_014_reg_795;
reg   [15:0] psum_12_013_reg_807;
reg   [15:0] psum_11_012_reg_819;
reg   [15:0] psum_10_011_reg_831;
reg   [5:0] q_reg_843;
wire   [0:0] icmp_ln132_fu_960_p2;
reg   [0:0] icmp_ln132_reg_1322;
wire    ap_CS_fsm_pp0_stage0;
wire    ap_block_state2_pp0_stage0_iter0;
wire    ap_block_state9_pp0_stage0_iter1;
wire    ap_block_state16_pp0_stage0_iter2;
wire    ap_block_pp0_stage0_11001;
reg   [0:0] icmp_ln132_reg_1322_pp0_iter1_reg;
reg   [0:0] icmp_ln132_reg_1322_pp0_iter2_reg;
wire   [7:0] lshr_ln_fu_966_p4;
reg   [7:0] lshr_ln_reg_1326;
reg   [15:0] accum_in_load_reg_1376;
wire    ap_CS_fsm_pp0_stage1;
reg    ap_enable_reg_pp0_iter0;
wire    ap_block_state3_pp0_stage1_iter0;
wire    ap_block_state10_pp0_stage1_iter1;
wire    ap_block_state17_pp0_stage1_iter2;
wire    ap_block_pp0_stage1_11001;
reg   [15:0] accum_in1_load_reg_1381;
reg   [15:0] accum_in2_load_reg_1386;
reg   [15:0] accum_in3_load_reg_1391;
reg   [15:0] accum_in_load_50_reg_1396;
reg   [15:0] accum_in1_load_29_reg_1401;
reg   [15:0] accum_in2_load_15_reg_1406;
reg   [15:0] accum_in3_load_15_reg_1411;
reg   [15:0] accum_in_load_51_reg_1456;
wire    ap_CS_fsm_pp0_stage2;
wire    ap_block_state4_pp0_stage2_iter0;
wire    ap_block_state11_pp0_stage2_iter1;
wire    ap_block_pp0_stage2_11001;
reg   [15:0] accum_in1_load_30_reg_1461;
reg   [15:0] accum_in2_load_16_reg_1466;
reg   [15:0] accum_in3_load_16_reg_1471;
reg   [15:0] accum_in_load_52_reg_1476;
reg   [15:0] accum_in1_load_31_reg_1481;
reg   [15:0] accum_in2_load_17_reg_1486;
reg   [15:0] accum_in3_load_17_reg_1491;
reg   [15:0] accum_in_load_53_reg_1536;
wire    ap_CS_fsm_pp0_stage3;
wire    ap_block_state5_pp0_stage3_iter0;
wire    ap_block_state12_pp0_stage3_iter1;
wire    ap_block_pp0_stage3_11001;
reg   [15:0] accum_in1_load_32_reg_1541;
reg   [15:0] accum_in2_load_18_reg_1546;
reg   [15:0] accum_in3_load_18_reg_1551;
reg   [15:0] accum_in_load_54_reg_1556;
reg   [15:0] accum_in1_load_33_reg_1561;
reg   [15:0] accum_in2_load_19_reg_1566;
reg   [15:0] accum_in3_load_19_reg_1571;
reg   [15:0] accum_in_load_55_reg_1616;
wire    ap_CS_fsm_pp0_stage4;
wire    ap_block_state6_pp0_stage4_iter0;
wire    ap_block_state13_pp0_stage4_iter1;
wire    ap_block_pp0_stage4_11001;
reg   [15:0] accum_in1_load_34_reg_1621;
reg   [15:0] accum_in2_load_20_reg_1626;
reg   [15:0] accum_in3_load_20_reg_1631;
reg   [15:0] accum_in_load_56_reg_1636;
reg   [15:0] accum_in1_load_35_reg_1641;
reg   [15:0] accum_in2_load_21_reg_1646;
reg   [15:0] accum_in3_load_21_reg_1651;
wire   [9:0] add_ln132_fu_1076_p2;
reg   [9:0] add_ln132_reg_1656;
wire    ap_CS_fsm_pp0_stage6;
wire    ap_block_state8_pp0_stage6_iter0;
wire    ap_block_state15_pp0_stage6_iter1;
wire    ap_block_pp0_stage6_11001;
wire   [15:0] grp_fu_908_p2;
reg    ap_enable_reg_pp0_iter1;
wire   [15:0] grp_fu_913_p2;
wire   [15:0] grp_fu_918_p2;
wire   [15:0] grp_fu_923_p2;
wire   [15:0] grp_fu_928_p2;
wire    ap_CS_fsm_pp0_stage5;
wire    ap_block_state7_pp0_stage5_iter0;
wire    ap_block_state14_pp0_stage5_iter1;
wire    ap_block_pp0_stage5_11001;
reg    ap_enable_reg_pp0_iter2;
wire   [0:0] tmp_fu_1082_p3;
reg   [0:0] tmp_reg_1821;
wire    ap_CS_fsm_pp1_stage0;
wire    ap_block_state19_pp1_stage0_iter0;
wire    ap_block_state20_pp1_stage0_iter1;
wire    ap_block_pp1_stage0_11001;
wire   [4:0] trunc_ln140_fu_1095_p1;
wire   [5:0] add_ln140_fu_1099_p2;
reg    ap_enable_reg_pp1_iter0;
wire   [4:0] or_ln140_fu_1105_p2;
reg   [4:0] or_ln140_reg_1834;
wire   [15:0] select_ln152_39_fu_1271_p3;
reg   [15:0] select_ln152_39_reg_1842;
reg    ap_block_state1;
wire    ap_block_pp0_stage4_subdone;
reg    ap_condition_pp0_exit_iter0_state6;
wire    ap_block_pp0_stage6_subdone;
wire    ap_block_pp0_stage1_subdone;
wire    ap_CS_fsm_state18;
wire    ap_block_pp1_stage0_subdone;
reg    ap_condition_pp1_exit_iter0_state19;
reg    ap_enable_reg_pp1_iter1;
reg   [9:0] ap_phi_mux_x_phi_fu_451_p4;
wire    ap_block_pp0_stage0;
wire    ap_block_pp0_stage2;
wire   [15:0] ap_phi_mux_psum_9_010_phi_fu_523_p4;
wire    ap_block_pp0_stage3;
wire   [15:0] ap_phi_mux_psum_8_09_phi_fu_535_p4;
wire   [15:0] ap_phi_mux_psum_7_08_phi_fu_547_p4;
wire   [15:0] ap_phi_mux_psum_6_07_phi_fu_559_p4;
wire   [15:0] ap_phi_mux_psum_5_06_phi_fu_571_p4;
wire   [15:0] ap_phi_mux_psum_31_032_phi_fu_583_p4;
wire    ap_block_pp0_stage1;
wire   [15:0] ap_phi_mux_psum_30_031_phi_fu_595_p4;
wire   [15:0] ap_phi_mux_psum_29_030_phi_fu_607_p4;
wire   [15:0] ap_phi_mux_psum_28_029_phi_fu_619_p4;
wire   [15:0] ap_phi_mux_psum_27_028_phi_fu_631_p4;
wire   [15:0] ap_phi_mux_psum_26_027_phi_fu_643_p4;
wire   [15:0] ap_phi_mux_psum_25_026_phi_fu_655_p4;
wire   [15:0] ap_phi_mux_psum_24_025_phi_fu_667_p4;
wire    ap_block_pp0_stage6;
wire   [15:0] ap_phi_mux_psum_23_024_phi_fu_679_p4;
wire   [15:0] ap_phi_mux_psum_22_023_phi_fu_691_p4;
wire   [15:0] ap_phi_mux_psum_21_022_phi_fu_703_p4;
wire   [15:0] ap_phi_mux_psum_20_021_phi_fu_715_p4;
wire   [15:0] ap_phi_mux_psum_19_020_phi_fu_727_p4;
wire    ap_block_pp0_stage5;
wire   [15:0] ap_phi_mux_psum_18_019_phi_fu_739_p4;
wire   [15:0] ap_phi_mux_psum_17_018_phi_fu_751_p4;
wire   [15:0] ap_phi_mux_psum_16_017_phi_fu_763_p4;
wire   [15:0] ap_phi_mux_psum_15_016_phi_fu_775_p4;
wire   [15:0] ap_phi_mux_psum_14_015_phi_fu_787_p4;
wire    ap_block_pp0_stage4;
wire   [15:0] ap_phi_mux_psum_13_014_phi_fu_799_p4;
wire   [15:0] ap_phi_mux_psum_12_013_phi_fu_811_p4;
wire   [15:0] ap_phi_mux_psum_11_012_phi_fu_823_p4;
wire   [15:0] ap_phi_mux_psum_10_011_phi_fu_835_p4;
reg   [15:0] ap_phi_mux_phi_ln152_phi_fu_857_p32;
wire   [15:0] ap_phi_reg_pp1_iter0_phi_ln152_reg_854;
wire   [63:0] zext_ln136_fu_976_p1;
wire   [63:0] zext_ln136_27_fu_990_p1;
wire   [63:0] zext_ln136_28_fu_1003_p1;
wire   [63:0] zext_ln136_29_fu_1016_p1;
wire   [63:0] zext_ln136_30_fu_1029_p1;
wire   [63:0] zext_ln136_31_fu_1042_p1;
wire   [63:0] zext_ln136_32_fu_1055_p1;
wire   [63:0] zext_ln136_33_fu_1068_p1;
wire   [63:0] zext_ln140_fu_1090_p1;
wire    ap_block_pp1_stage0;
wire   [63:0] zext_ln140_3_fu_1279_p1;
reg   [15:0] grp_fu_908_p0;
reg   [15:0] grp_fu_908_p1;
reg   [15:0] grp_fu_913_p0;
reg   [15:0] grp_fu_913_p1;
reg   [15:0] grp_fu_918_p0;
reg   [15:0] grp_fu_918_p1;
reg   [15:0] grp_fu_923_p0;
reg   [15:0] grp_fu_923_p1;
reg   [15:0] grp_fu_928_p0;
reg   [15:0] grp_fu_928_p1;
wire   [7:0] or_ln136_fu_984_p2;
wire   [7:0] or_ln136_25_fu_998_p2;
wire   [7:0] or_ln136_26_fu_1011_p2;
wire   [7:0] or_ln136_27_fu_1024_p2;
wire   [7:0] or_ln136_28_fu_1037_p2;
wire   [7:0] or_ln136_29_fu_1050_p2;
wire   [7:0] or_ln136_30_fu_1063_p2;
wire   [0:0] icmp_ln152_fu_1111_p2;
wire   [0:0] icmp_ln152_29_fu_1125_p2;
wire   [15:0] select_ln152_fu_1117_p3;
wire   [0:0] icmp_ln152_30_fu_1139_p2;
wire   [15:0] select_ln152_29_fu_1131_p3;
wire   [0:0] icmp_ln152_31_fu_1153_p2;
wire   [15:0] select_ln152_30_fu_1145_p3;
wire   [0:0] icmp_ln152_32_fu_1167_p2;
wire   [15:0] select_ln152_31_fu_1159_p3;
wire   [0:0] icmp_ln152_33_fu_1181_p2;
wire   [15:0] select_ln152_32_fu_1173_p3;
wire   [0:0] icmp_ln152_34_fu_1195_p2;
wire   [15:0] select_ln152_33_fu_1187_p3;
wire   [0:0] icmp_ln152_35_fu_1209_p2;
wire   [15:0] select_ln152_34_fu_1201_p3;
wire   [0:0] icmp_ln152_36_fu_1223_p2;
wire   [15:0] select_ln152_35_fu_1215_p3;
wire   [0:0] icmp_ln152_37_fu_1237_p2;
wire   [15:0] select_ln152_36_fu_1229_p3;
wire   [0:0] icmp_ln152_38_fu_1251_p2;
wire   [15:0] select_ln152_37_fu_1243_p3;
wire   [0:0] icmp_ln152_39_fu_1265_p2;
wire   [15:0] select_ln152_38_fu_1257_p3;
wire   [0:0] icmp_ln152_40_fu_1283_p2;
wire   [0:0] icmp_ln152_41_fu_1295_p2;
wire   [15:0] select_ln152_40_fu_1288_p3;
wire   [0:0] icmp_ln152_42_fu_1308_p2;
wire   [15:0] select_ln152_41_fu_1300_p3;
wire    ap_CS_fsm_state21;
reg   [10:0] ap_NS_fsm;
wire    ap_block_pp0_stage0_subdone;
wire    ap_block_pp0_stage2_subdone;
wire    ap_block_pp0_stage3_subdone;
wire    ap_block_pp0_stage5_subdone;
reg    ap_idle_pp0;
wire    ap_enable_pp0;
reg    ap_idle_pp1;
wire    ap_enable_pp1;
reg    ap_condition_1097;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_done_reg = 1'b0;
#0 ap_CS_fsm = 11'd1;
#0 ap_enable_reg_pp0_iter0 = 1'b0;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter2 = 1'b0;
#0 ap_enable_reg_pp1_iter0 = 1'b0;
#0 ap_enable_reg_pp1_iter1 = 1'b0;
end

td_fused_top_hadd_16ns_16ns_16_8_full_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 8 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hadd_16ns_16ns_16_8_full_dsp_1_U1697(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(grp_fu_908_p0),
    .din1(grp_fu_908_p1),
    .dout(grp_fu_908_p2)
);

td_fused_top_hadd_16ns_16ns_16_8_full_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 8 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hadd_16ns_16ns_16_8_full_dsp_1_U1698(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(grp_fu_913_p0),
    .din1(grp_fu_913_p1),
    .dout(grp_fu_913_p2)
);

td_fused_top_hadd_16ns_16ns_16_8_full_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 8 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hadd_16ns_16ns_16_8_full_dsp_1_U1699(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(grp_fu_918_p0),
    .din1(grp_fu_918_p1),
    .dout(grp_fu_918_p2)
);

td_fused_top_hadd_16ns_16ns_16_8_full_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 8 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hadd_16ns_16ns_16_8_full_dsp_1_U1700(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(grp_fu_923_p0),
    .din1(grp_fu_923_p1),
    .dout(grp_fu_923_p2)
);

td_fused_top_hadd_16ns_16ns_16_8_full_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 8 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hadd_16ns_16ns_16_8_full_dsp_1_U1701(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(grp_fu_928_p0),
    .din1(grp_fu_928_p1),
    .dout(grp_fu_928_p2)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_done_reg <= 1'b0;
    end else begin
        if ((ap_continue == 1'b1)) begin
            ap_done_reg <= 1'b0;
        end else if ((1'b1 == ap_CS_fsm_state21)) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter0 <= 1'b0;
    end else begin
        if (((1'b1 == ap_condition_pp0_exit_iter0_state6) & (1'b1 == ap_CS_fsm_pp0_stage4) & (1'b0 == ap_block_pp0_stage4_subdone))) begin
            ap_enable_reg_pp0_iter0 <= 1'b0;
        end else if ((~((ap_done_reg == 1'b1) | (ap_start == 1'b0)) & (1'b1 == ap_CS_fsm_state1))) begin
            ap_enable_reg_pp0_iter0 <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if (((1'b1 == ap_CS_fsm_pp0_stage6) & (1'b0 == ap_block_pp0_stage6_subdone))) begin
            ap_enable_reg_pp0_iter1 <= ap_enable_reg_pp0_iter0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter2 <= 1'b0;
    end else begin
        if ((((ap_enable_reg_pp0_iter1 == 1'b0) & (1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1_subdone)) | ((1'b1 == ap_CS_fsm_pp0_stage6) & (1'b0 == ap_block_pp0_stage6_subdone)))) begin
            ap_enable_reg_pp0_iter2 <= ap_enable_reg_pp0_iter1;
        end else if ((~((ap_done_reg == 1'b1) | (ap_start == 1'b0)) & (1'b1 == ap_CS_fsm_state1))) begin
            ap_enable_reg_pp0_iter2 <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp1_iter0 <= 1'b0;
    end else begin
        if (((1'b1 == ap_condition_pp1_exit_iter0_state19) & (1'b1 == ap_CS_fsm_pp1_stage0) & (1'b0 == ap_block_pp1_stage0_subdone))) begin
            ap_enable_reg_pp1_iter0 <= 1'b0;
        end else if ((1'b1 == ap_CS_fsm_state18)) begin
            ap_enable_reg_pp1_iter0 <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp1_iter1 <= 1'b0;
    end else begin
        if (((1'b1 == ap_condition_pp1_exit_iter0_state19) & (1'b0 == ap_block_pp1_stage0_subdone))) begin
            ap_enable_reg_pp1_iter1 <= (1'b1 ^ ap_condition_pp1_exit_iter0_state19);
        end else if ((1'b0 == ap_block_pp1_stage0_subdone)) begin
            ap_enable_reg_pp1_iter1 <= ap_enable_reg_pp1_iter0;
        end else if ((1'b1 == ap_CS_fsm_state18)) begin
            ap_enable_reg_pp1_iter1 <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state18)) begin
        q_reg_843 <= 6'd0;
    end else if (((ap_enable_reg_pp1_iter0 == 1'b1) & (tmp_fu_1082_p3 == 1'd0) & (1'b1 == ap_CS_fsm_pp1_stage0) & (1'b0 == ap_block_pp1_stage0_11001))) begin
        q_reg_843 <= add_ln140_fu_1099_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0_11001) & (icmp_ln132_reg_1322 == 1'd1))) begin
        x_reg_447 <= add_ln132_reg_1656;
    end else if ((~((ap_done_reg == 1'b1) | (ap_start == 1'b0)) & (1'b1 == ap_CS_fsm_state1))) begin
        x_reg_447 <= 10'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage1_11001) & (icmp_ln132_reg_1322 == 1'd1))) begin
        accum_in1_load_29_reg_1401 <= accum_in1_q0;
        accum_in1_load_reg_1381 <= accum_in1_q1;
        accum_in2_load_15_reg_1406 <= accum_in2_q0;
        accum_in2_load_reg_1386 <= accum_in2_q1;
        accum_in3_load_15_reg_1411 <= accum_in3_q0;
        accum_in3_load_reg_1391 <= accum_in3_q1;
        accum_in_load_50_reg_1396 <= accum_in_q0;
        accum_in_load_reg_1376 <= accum_in_q1;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2_11001) & (icmp_ln132_reg_1322 == 1'd1))) begin
        accum_in1_load_30_reg_1461 <= accum_in1_q1;
        accum_in1_load_31_reg_1481 <= accum_in1_q0;
        accum_in2_load_16_reg_1466 <= accum_in2_q1;
        accum_in2_load_17_reg_1486 <= accum_in2_q0;
        accum_in3_load_16_reg_1471 <= accum_in3_q1;
        accum_in3_load_17_reg_1491 <= accum_in3_q0;
        accum_in_load_51_reg_1456 <= accum_in_q1;
        accum_in_load_52_reg_1476 <= accum_in_q0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3_11001) & (icmp_ln132_reg_1322 == 1'd1))) begin
        accum_in1_load_32_reg_1541 <= accum_in1_q1;
        accum_in1_load_33_reg_1561 <= accum_in1_q0;
        accum_in2_load_18_reg_1546 <= accum_in2_q1;
        accum_in2_load_19_reg_1566 <= accum_in2_q0;
        accum_in3_load_18_reg_1551 <= accum_in3_q1;
        accum_in3_load_19_reg_1571 <= accum_in3_q0;
        accum_in_load_53_reg_1536 <= accum_in_q1;
        accum_in_load_54_reg_1556 <= accum_in_q0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_pp0_stage4) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage4_11001) & (icmp_ln132_reg_1322 == 1'd1))) begin
        accum_in1_load_34_reg_1621 <= accum_in1_q1;
        accum_in1_load_35_reg_1641 <= accum_in1_q0;
        accum_in2_load_20_reg_1626 <= accum_in2_q1;
        accum_in2_load_21_reg_1646 <= accum_in2_q0;
        accum_in3_load_20_reg_1631 <= accum_in3_q1;
        accum_in3_load_21_reg_1651 <= accum_in3_q0;
        accum_in_load_55_reg_1616 <= accum_in_q1;
        accum_in_load_56_reg_1636 <= accum_in_q0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_pp0_stage6) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage6_11001) & (icmp_ln132_reg_1322 == 1'd1))) begin
        add_ln132_reg_1656 <= add_ln132_fu_1076_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        icmp_ln132_reg_1322 <= icmp_ln132_fu_960_p2;
        icmp_ln132_reg_1322_pp0_iter1_reg <= icmp_ln132_reg_1322;
        icmp_ln132_reg_1322_pp0_iter2_reg <= icmp_ln132_reg_1322_pp0_iter1_reg;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0_11001) & (icmp_ln132_fu_960_p2 == 1'd1))) begin
        lshr_ln_reg_1326 <= {{ap_phi_mux_x_phi_fu_451_p4[9:2]}};
    end
end

always @ (posedge ap_clk) begin
    if (((tmp_fu_1082_p3 == 1'd0) & (1'b1 == ap_CS_fsm_pp1_stage0) & (1'b0 == ap_block_pp1_stage0_11001))) begin
        or_ln140_reg_1834[4 : 1] <= or_ln140_fu_1105_p2[4 : 1];
        select_ln152_39_reg_1842 <= select_ln152_39_fu_1271_p3;
    end
end

always @ (posedge ap_clk) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage2) & (icmp_ln132_reg_1322_pp0_iter1_reg == 1'd1) & (1'b0 == ap_block_pp0_stage2_11001))) begin
        psum_0_01_reg_507 <= grp_fu_908_p2;
        psum_1_02_reg_495 <= grp_fu_913_p2;
        psum_2_03_reg_483 <= grp_fu_918_p2;
        psum_3_04_reg_471 <= grp_fu_923_p2;
        psum_4_05_reg_459 <= grp_fu_928_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage4) & (icmp_ln132_reg_1322_pp0_iter1_reg == 1'd1) & (1'b0 == ap_block_pp0_stage4_11001))) begin
        psum_10_011_reg_831 <= grp_fu_908_p2;
        psum_11_012_reg_819 <= grp_fu_913_p2;
        psum_12_013_reg_807 <= grp_fu_918_p2;
        psum_13_014_reg_795 <= grp_fu_923_p2;
        psum_14_015_reg_783 <= grp_fu_928_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage5) & (icmp_ln132_reg_1322_pp0_iter1_reg == 1'd1) & (1'b0 == ap_block_pp0_stage5_11001))) begin
        psum_15_016_reg_771 <= grp_fu_908_p2;
        psum_16_017_reg_759 <= grp_fu_913_p2;
        psum_17_018_reg_747 <= grp_fu_918_p2;
        psum_18_019_reg_735 <= grp_fu_923_p2;
        psum_19_020_reg_723 <= grp_fu_928_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage6) & (icmp_ln132_reg_1322_pp0_iter1_reg == 1'd1) & (1'b0 == ap_block_pp0_stage6_11001))) begin
        psum_20_021_reg_711 <= grp_fu_908_p2;
        psum_21_022_reg_699 <= grp_fu_913_p2;
        psum_22_023_reg_687 <= grp_fu_918_p2;
        psum_23_024_reg_675 <= grp_fu_923_p2;
        psum_24_025_reg_663 <= grp_fu_928_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((ap_enable_reg_pp0_iter2 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (icmp_ln132_reg_1322_pp0_iter1_reg == 1'd1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        psum_25_026_reg_651 <= grp_fu_908_p2;
        psum_26_027_reg_639 <= grp_fu_913_p2;
        psum_27_028_reg_627 <= grp_fu_918_p2;
        psum_28_029_reg_615 <= grp_fu_923_p2;
        psum_29_030_reg_603 <= grp_fu_928_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((ap_enable_reg_pp0_iter2 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1) & (icmp_ln132_reg_1322_pp0_iter2_reg == 1'd1) & (1'b0 == ap_block_pp0_stage1_11001))) begin
        psum_30_031_reg_591 <= grp_fu_908_p2;
        psum_31_032_reg_579 <= grp_fu_913_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage3) & (icmp_ln132_reg_1322_pp0_iter1_reg == 1'd1) & (1'b0 == ap_block_pp0_stage3_11001))) begin
        psum_5_06_reg_567 <= grp_fu_908_p2;
        psum_6_07_reg_555 <= grp_fu_913_p2;
        psum_7_08_reg_543 <= grp_fu_918_p2;
        psum_8_09_reg_531 <= grp_fu_923_p2;
        psum_9_010_reg_519 <= grp_fu_928_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_pp1_stage0) & (1'b0 == ap_block_pp1_stage0_11001))) begin
        tmp_reg_1821 <= q_reg_843[32'd5];
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter0 == 1'b1)) begin
        if (((1'b1 == ap_CS_fsm_pp0_stage3) & (1'b0 == ap_block_pp0_stage3))) begin
            accum_in1_address0 = zext_ln136_33_fu_1068_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (1'b0 == ap_block_pp0_stage2))) begin
            accum_in1_address0 = zext_ln136_31_fu_1042_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1))) begin
            accum_in1_address0 = zext_ln136_29_fu_1016_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
            accum_in1_address0 = zext_ln136_27_fu_990_p1;
        end else begin
            accum_in1_address0 = 'bx;
        end
    end else begin
        accum_in1_address0 = 'bx;
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter0 == 1'b1)) begin
        if (((1'b1 == ap_CS_fsm_pp0_stage3) & (1'b0 == ap_block_pp0_stage3))) begin
            accum_in1_address1 = zext_ln136_32_fu_1055_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (1'b0 == ap_block_pp0_stage2))) begin
            accum_in1_address1 = zext_ln136_30_fu_1029_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1))) begin
            accum_in1_address1 = zext_ln136_28_fu_1003_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
            accum_in1_address1 = zext_ln136_fu_976_p1;
        end else begin
            accum_in1_address1 = 'bx;
        end
    end else begin
        accum_in1_address1 = 'bx;
    end
end

always @ (*) begin
    if ((((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage1_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001)))) begin
        accum_in1_ce0 = 1'b1;
    end else begin
        accum_in1_ce0 = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage1_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001)))) begin
        accum_in1_ce1 = 1'b1;
    end else begin
        accum_in1_ce1 = 1'b0;
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter0 == 1'b1)) begin
        if (((1'b1 == ap_CS_fsm_pp0_stage3) & (1'b0 == ap_block_pp0_stage3))) begin
            accum_in2_address0 = zext_ln136_33_fu_1068_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (1'b0 == ap_block_pp0_stage2))) begin
            accum_in2_address0 = zext_ln136_31_fu_1042_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1))) begin
            accum_in2_address0 = zext_ln136_29_fu_1016_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
            accum_in2_address0 = zext_ln136_27_fu_990_p1;
        end else begin
            accum_in2_address0 = 'bx;
        end
    end else begin
        accum_in2_address0 = 'bx;
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter0 == 1'b1)) begin
        if (((1'b1 == ap_CS_fsm_pp0_stage3) & (1'b0 == ap_block_pp0_stage3))) begin
            accum_in2_address1 = zext_ln136_32_fu_1055_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (1'b0 == ap_block_pp0_stage2))) begin
            accum_in2_address1 = zext_ln136_30_fu_1029_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1))) begin
            accum_in2_address1 = zext_ln136_28_fu_1003_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
            accum_in2_address1 = zext_ln136_fu_976_p1;
        end else begin
            accum_in2_address1 = 'bx;
        end
    end else begin
        accum_in2_address1 = 'bx;
    end
end

always @ (*) begin
    if ((((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage1_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001)))) begin
        accum_in2_ce0 = 1'b1;
    end else begin
        accum_in2_ce0 = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage1_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001)))) begin
        accum_in2_ce1 = 1'b1;
    end else begin
        accum_in2_ce1 = 1'b0;
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter0 == 1'b1)) begin
        if (((1'b1 == ap_CS_fsm_pp0_stage3) & (1'b0 == ap_block_pp0_stage3))) begin
            accum_in3_address0 = zext_ln136_33_fu_1068_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (1'b0 == ap_block_pp0_stage2))) begin
            accum_in3_address0 = zext_ln136_31_fu_1042_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1))) begin
            accum_in3_address0 = zext_ln136_29_fu_1016_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
            accum_in3_address0 = zext_ln136_27_fu_990_p1;
        end else begin
            accum_in3_address0 = 'bx;
        end
    end else begin
        accum_in3_address0 = 'bx;
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter0 == 1'b1)) begin
        if (((1'b1 == ap_CS_fsm_pp0_stage3) & (1'b0 == ap_block_pp0_stage3))) begin
            accum_in3_address1 = zext_ln136_32_fu_1055_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (1'b0 == ap_block_pp0_stage2))) begin
            accum_in3_address1 = zext_ln136_30_fu_1029_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1))) begin
            accum_in3_address1 = zext_ln136_28_fu_1003_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
            accum_in3_address1 = zext_ln136_fu_976_p1;
        end else begin
            accum_in3_address1 = 'bx;
        end
    end else begin
        accum_in3_address1 = 'bx;
    end
end

always @ (*) begin
    if ((((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage1_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001)))) begin
        accum_in3_ce0 = 1'b1;
    end else begin
        accum_in3_ce0 = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage1_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001)))) begin
        accum_in3_ce1 = 1'b1;
    end else begin
        accum_in3_ce1 = 1'b0;
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter0 == 1'b1)) begin
        if (((1'b1 == ap_CS_fsm_pp0_stage3) & (1'b0 == ap_block_pp0_stage3))) begin
            accum_in_address0 = zext_ln136_33_fu_1068_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (1'b0 == ap_block_pp0_stage2))) begin
            accum_in_address0 = zext_ln136_31_fu_1042_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1))) begin
            accum_in_address0 = zext_ln136_29_fu_1016_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
            accum_in_address0 = zext_ln136_27_fu_990_p1;
        end else begin
            accum_in_address0 = 'bx;
        end
    end else begin
        accum_in_address0 = 'bx;
    end
end

always @ (*) begin
    if ((ap_enable_reg_pp0_iter0 == 1'b1)) begin
        if (((1'b1 == ap_CS_fsm_pp0_stage3) & (1'b0 == ap_block_pp0_stage3))) begin
            accum_in_address1 = zext_ln136_32_fu_1055_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (1'b0 == ap_block_pp0_stage2))) begin
            accum_in_address1 = zext_ln136_30_fu_1029_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1))) begin
            accum_in_address1 = zext_ln136_28_fu_1003_p1;
        end else if (((1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
            accum_in_address1 = zext_ln136_fu_976_p1;
        end else begin
            accum_in_address1 = 'bx;
        end
    end else begin
        accum_in_address1 = 'bx;
    end
end

always @ (*) begin
    if ((((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage1_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001)))) begin
        accum_in_ce0 = 1'b1;
    end else begin
        accum_in_ce0 = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage1) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage1_11001)) | ((1'b1 == ap_CS_fsm_pp0_stage0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001)))) begin
        accum_in_ce1 = 1'b1;
    end else begin
        accum_in_ce1 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp1_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp1_stage0) & (1'b0 == ap_block_pp1_stage0_11001))) begin
        accum_out_ce0 = 1'b1;
    end else begin
        accum_out_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp1_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp1_stage0) & (1'b0 == ap_block_pp1_stage0_11001))) begin
        accum_out_ce1 = 1'b1;
    end else begin
        accum_out_ce1 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp1_iter1 == 1'b1) & (tmp_reg_1821 == 1'd0) & (1'b1 == ap_CS_fsm_pp1_stage0) & (1'b0 == ap_block_pp1_stage0_11001))) begin
        accum_out_we0 = 1'b1;
    end else begin
        accum_out_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp1_iter0 == 1'b1) & (tmp_fu_1082_p3 == 1'd0) & (1'b1 == ap_CS_fsm_pp1_stage0) & (1'b0 == ap_block_pp1_stage0_11001))) begin
        accum_out_we1 = 1'b1;
    end else begin
        accum_out_we1 = 1'b0;
    end
end

always @ (*) begin
    if ((icmp_ln132_reg_1322 == 1'd0)) begin
        ap_condition_pp0_exit_iter0_state6 = 1'b1;
    end else begin
        ap_condition_pp0_exit_iter0_state6 = 1'b0;
    end
end

always @ (*) begin
    if ((tmp_fu_1082_p3 == 1'd1)) begin
        ap_condition_pp1_exit_iter0_state19 = 1'b1;
    end else begin
        ap_condition_pp1_exit_iter0_state19 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state21)) begin
        ap_done = 1'b1;
    end else begin
        ap_done = ap_done_reg;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b0))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter2 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp1_iter1 == 1'b0) & (ap_enable_reg_pp1_iter0 == 1'b0))) begin
        ap_idle_pp1 = 1'b1;
    end else begin
        ap_idle_pp1 = 1'b0;
    end
end

always @ (*) begin
    if ((tmp_fu_1082_p3 == 1'd0)) begin
        if ((trunc_ln140_fu_1095_p1 == 5'd0)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_0_01_reg_507;
        end else if ((1'b1 == ap_condition_1097)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_30_031_reg_591;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd28)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_28_029_reg_615;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd26)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_26_027_reg_639;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd24)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_24_025_reg_663;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd22)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_22_023_reg_687;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd20)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_20_021_reg_711;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd18)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_18_019_reg_735;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd16)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_16_017_reg_759;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd14)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_14_015_reg_783;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd12)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_12_013_reg_807;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd10)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_10_011_reg_831;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd8)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_8_09_reg_531;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd6)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_6_07_reg_555;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd4)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_4_05_reg_459;
        end else if ((trunc_ln140_fu_1095_p1 == 5'd2)) begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = psum_2_03_reg_483;
        end else begin
            ap_phi_mux_phi_ln152_phi_fu_857_p32 = ap_phi_reg_pp1_iter0_phi_ln152_reg_854;
        end
    end else begin
        ap_phi_mux_phi_ln152_phi_fu_857_p32 = ap_phi_reg_pp1_iter0_phi_ln152_reg_854;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0) & (icmp_ln132_reg_1322 == 1'd1))) begin
        ap_phi_mux_x_phi_fu_451_p4 = add_ln132_reg_1656;
    end else begin
        ap_phi_mux_x_phi_fu_451_p4 = x_reg_447;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state21)) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1))) begin
        grp_fu_908_p0 = ap_phi_mux_psum_30_031_phi_fu_595_p4;
    end else if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
        grp_fu_908_p0 = ap_phi_mux_psum_25_026_phi_fu_655_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage6) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage6))) begin
        grp_fu_908_p0 = ap_phi_mux_psum_20_021_phi_fu_715_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage5) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage5))) begin
        grp_fu_908_p0 = ap_phi_mux_psum_15_016_phi_fu_775_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage4) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage4))) begin
        grp_fu_908_p0 = ap_phi_mux_psum_10_011_phi_fu_835_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3))) begin
        grp_fu_908_p0 = ap_phi_mux_psum_5_06_phi_fu_571_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2))) begin
        grp_fu_908_p0 = grp_fu_908_p2;
    end else begin
        grp_fu_908_p0 = 'bx;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1))) begin
        grp_fu_908_p1 = accum_in2_load_21_reg_1646;
    end else if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
        grp_fu_908_p1 = accum_in1_load_34_reg_1621;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage6) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage6))) begin
        grp_fu_908_p1 = accum_in_load_54_reg_1556;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage5) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage5))) begin
        grp_fu_908_p1 = accum_in3_load_17_reg_1491;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage4) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage4))) begin
        grp_fu_908_p1 = accum_in2_load_16_reg_1466;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3))) begin
        grp_fu_908_p1 = accum_in1_load_29_reg_1401;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2))) begin
        grp_fu_908_p1 = accum_in_load_reg_1376;
    end else begin
        grp_fu_908_p1 = 'bx;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1))) begin
        grp_fu_913_p0 = ap_phi_mux_psum_31_032_phi_fu_583_p4;
    end else if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
        grp_fu_913_p0 = ap_phi_mux_psum_26_027_phi_fu_643_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage6) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage6))) begin
        grp_fu_913_p0 = ap_phi_mux_psum_21_022_phi_fu_703_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage5) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage5))) begin
        grp_fu_913_p0 = ap_phi_mux_psum_16_017_phi_fu_763_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage4) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage4))) begin
        grp_fu_913_p0 = ap_phi_mux_psum_11_012_phi_fu_823_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3))) begin
        grp_fu_913_p0 = ap_phi_mux_psum_6_07_phi_fu_559_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2))) begin
        grp_fu_913_p0 = grp_fu_913_p2;
    end else begin
        grp_fu_913_p0 = 'bx;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1))) begin
        grp_fu_913_p1 = accum_in3_load_21_reg_1651;
    end else if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
        grp_fu_913_p1 = accum_in2_load_20_reg_1626;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage6) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage6))) begin
        grp_fu_913_p1 = accum_in1_load_33_reg_1561;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage5) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage5))) begin
        grp_fu_913_p1 = accum_in_load_53_reg_1536;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage4) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage4))) begin
        grp_fu_913_p1 = accum_in3_load_16_reg_1471;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3))) begin
        grp_fu_913_p1 = accum_in2_load_15_reg_1406;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2))) begin
        grp_fu_913_p1 = accum_in1_load_reg_1381;
    end else begin
        grp_fu_913_p1 = 'bx;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
        grp_fu_918_p0 = ap_phi_mux_psum_27_028_phi_fu_631_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage6) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage6))) begin
        grp_fu_918_p0 = ap_phi_mux_psum_22_023_phi_fu_691_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage5) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage5))) begin
        grp_fu_918_p0 = ap_phi_mux_psum_17_018_phi_fu_751_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage4) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage4))) begin
        grp_fu_918_p0 = ap_phi_mux_psum_12_013_phi_fu_811_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3))) begin
        grp_fu_918_p0 = ap_phi_mux_psum_7_08_phi_fu_547_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2))) begin
        grp_fu_918_p0 = grp_fu_918_p2;
    end else begin
        grp_fu_918_p0 = 'bx;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
        grp_fu_918_p1 = accum_in3_load_20_reg_1631;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage6) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage6))) begin
        grp_fu_918_p1 = accum_in2_load_19_reg_1566;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage5) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage5))) begin
        grp_fu_918_p1 = accum_in1_load_32_reg_1541;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage4) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage4))) begin
        grp_fu_918_p1 = accum_in_load_52_reg_1476;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3))) begin
        grp_fu_918_p1 = accum_in3_load_15_reg_1411;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2))) begin
        grp_fu_918_p1 = accum_in2_load_reg_1386;
    end else begin
        grp_fu_918_p1 = 'bx;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
        grp_fu_923_p0 = ap_phi_mux_psum_28_029_phi_fu_619_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage6) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage6))) begin
        grp_fu_923_p0 = ap_phi_mux_psum_23_024_phi_fu_679_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage5) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage5))) begin
        grp_fu_923_p0 = ap_phi_mux_psum_18_019_phi_fu_739_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage4) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage4))) begin
        grp_fu_923_p0 = ap_phi_mux_psum_13_014_phi_fu_799_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3))) begin
        grp_fu_923_p0 = ap_phi_mux_psum_8_09_phi_fu_535_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2))) begin
        grp_fu_923_p0 = grp_fu_923_p2;
    end else begin
        grp_fu_923_p0 = 'bx;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
        grp_fu_923_p1 = accum_in_load_56_reg_1636;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage6) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage6))) begin
        grp_fu_923_p1 = accum_in3_load_19_reg_1571;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage5) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage5))) begin
        grp_fu_923_p1 = accum_in2_load_18_reg_1546;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage4) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage4))) begin
        grp_fu_923_p1 = accum_in1_load_31_reg_1481;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3))) begin
        grp_fu_923_p1 = accum_in_load_51_reg_1456;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2))) begin
        grp_fu_923_p1 = accum_in3_load_reg_1391;
    end else begin
        grp_fu_923_p1 = 'bx;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
        grp_fu_928_p0 = ap_phi_mux_psum_29_030_phi_fu_607_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage6) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage6))) begin
        grp_fu_928_p0 = ap_phi_mux_psum_24_025_phi_fu_667_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage5) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage5))) begin
        grp_fu_928_p0 = ap_phi_mux_psum_19_020_phi_fu_727_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage4) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage4))) begin
        grp_fu_928_p0 = ap_phi_mux_psum_14_015_phi_fu_787_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3))) begin
        grp_fu_928_p0 = ap_phi_mux_psum_9_010_phi_fu_523_p4;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2))) begin
        grp_fu_928_p0 = grp_fu_928_p2;
    end else begin
        grp_fu_928_p0 = 'bx;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (1'b0 == ap_block_pp0_stage0))) begin
        grp_fu_928_p1 = accum_in1_load_35_reg_1641;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage6) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage6))) begin
        grp_fu_928_p1 = accum_in_load_55_reg_1616;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage5) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage5))) begin
        grp_fu_928_p1 = accum_in3_load_18_reg_1551;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage4) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage4))) begin
        grp_fu_928_p1 = accum_in2_load_17_reg_1486;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage3) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage3))) begin
        grp_fu_928_p1 = accum_in1_load_30_reg_1461;
    end else if (((1'b1 == ap_CS_fsm_pp0_stage2) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage2))) begin
        grp_fu_928_p1 = accum_in_load_50_reg_1396;
    end else begin
        grp_fu_928_p1 = 'bx;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if ((~((ap_done_reg == 1'b1) | (ap_start == 1'b0)) & (1'b1 == ap_CS_fsm_state1))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_pp0_stage0 : begin
            if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end
        end
        ap_ST_fsm_pp0_stage1 : begin
            if ((~((ap_enable_reg_pp0_iter2 == 1'b1) & (ap_enable_reg_pp0_iter1 == 1'b0) & (1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1_subdone)) & (1'b0 == ap_block_pp0_stage1_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end else if (((ap_enable_reg_pp0_iter2 == 1'b1) & (ap_enable_reg_pp0_iter1 == 1'b0) & (1'b1 == ap_CS_fsm_pp0_stage1) & (1'b0 == ap_block_pp0_stage1_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_state18;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end
        end
        ap_ST_fsm_pp0_stage2 : begin
            if ((1'b0 == ap_block_pp0_stage2_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end
        end
        ap_ST_fsm_pp0_stage3 : begin
            if ((1'b0 == ap_block_pp0_stage3_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end
        end
        ap_ST_fsm_pp0_stage4 : begin
            if ((~((ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage4_subdone) & (icmp_ln132_reg_1322 == 1'd0)) & (1'b0 == ap_block_pp0_stage4_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end else if (((ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b0 == ap_block_pp0_stage4_subdone) & (icmp_ln132_reg_1322 == 1'd0))) begin
                ap_NS_fsm = ap_ST_fsm_state18;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end
        end
        ap_ST_fsm_pp0_stage5 : begin
            if ((1'b0 == ap_block_pp0_stage5_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage6;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end
        end
        ap_ST_fsm_pp0_stage6 : begin
            if ((1'b0 == ap_block_pp0_stage6_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage6;
            end
        end
        ap_ST_fsm_state18 : begin
            ap_NS_fsm = ap_ST_fsm_pp1_stage0;
        end
        ap_ST_fsm_pp1_stage0 : begin
            if (~((ap_enable_reg_pp1_iter0 == 1'b1) & (tmp_fu_1082_p3 == 1'd1) & (1'b0 == ap_block_pp1_stage0_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_pp1_stage0;
            end else if (((ap_enable_reg_pp1_iter0 == 1'b1) & (tmp_fu_1082_p3 == 1'd1) & (1'b0 == ap_block_pp1_stage0_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_state21;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp1_stage0;
            end
        end
        ap_ST_fsm_state21 : begin
            ap_NS_fsm = ap_ST_fsm_state1;
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign accum_out_address0 = zext_ln140_3_fu_1279_p1;

assign accum_out_address1 = zext_ln140_fu_1090_p1;

assign accum_out_d0 = ((icmp_ln152_42_fu_1308_p2[0:0] == 1'b1) ? psum_29_030_reg_603 : select_ln152_41_fu_1300_p3);

assign accum_out_d1 = ap_phi_mux_phi_ln152_phi_fu_857_p32;

assign add_ln132_fu_1076_p2 = (x_reg_447 + 10'd32);

assign add_ln140_fu_1099_p2 = (q_reg_843 + 6'd2);

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_pp0_stage1 = ap_CS_fsm[32'd2];

assign ap_CS_fsm_pp0_stage2 = ap_CS_fsm[32'd3];

assign ap_CS_fsm_pp0_stage3 = ap_CS_fsm[32'd4];

assign ap_CS_fsm_pp0_stage4 = ap_CS_fsm[32'd5];

assign ap_CS_fsm_pp0_stage5 = ap_CS_fsm[32'd6];

assign ap_CS_fsm_pp0_stage6 = ap_CS_fsm[32'd7];

assign ap_CS_fsm_pp1_stage0 = ap_CS_fsm[32'd9];

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state18 = ap_CS_fsm[32'd8];

assign ap_CS_fsm_state21 = ap_CS_fsm[32'd10];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage1 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage1_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage1_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage2 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage2_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage2_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage6_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp1_stage0 = ~(1'b1 == 1'b1);

assign ap_block_pp1_stage0_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp1_stage0_subdone = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_state1 = ((ap_done_reg == 1'b1) | (ap_start == 1'b0));
end

assign ap_block_state10_pp0_stage1_iter1 = ~(1'b1 == 1'b1);

assign ap_block_state11_pp0_stage2_iter1 = ~(1'b1 == 1'b1);

assign ap_block_state12_pp0_stage3_iter1 = ~(1'b1 == 1'b1);

assign ap_block_state13_pp0_stage4_iter1 = ~(1'b1 == 1'b1);

assign ap_block_state14_pp0_stage5_iter1 = ~(1'b1 == 1'b1);

assign ap_block_state15_pp0_stage6_iter1 = ~(1'b1 == 1'b1);

assign ap_block_state16_pp0_stage0_iter2 = ~(1'b1 == 1'b1);

assign ap_block_state17_pp0_stage1_iter2 = ~(1'b1 == 1'b1);

assign ap_block_state19_pp1_stage0_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state20_pp1_stage0_iter1 = ~(1'b1 == 1'b1);

assign ap_block_state2_pp0_stage0_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state3_pp0_stage1_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state4_pp0_stage2_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state5_pp0_stage3_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state6_pp0_stage4_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state7_pp0_stage5_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state8_pp0_stage6_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state9_pp0_stage0_iter1 = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_condition_1097 = (~(trunc_ln140_fu_1095_p1 == 5'd0) & ~(trunc_ln140_fu_1095_p1 == 5'd28) & ~(trunc_ln140_fu_1095_p1 == 5'd26) & ~(trunc_ln140_fu_1095_p1 == 5'd24) & ~(trunc_ln140_fu_1095_p1 == 5'd22) & ~(trunc_ln140_fu_1095_p1 == 5'd20) & ~(trunc_ln140_fu_1095_p1 == 5'd18) & ~(trunc_ln140_fu_1095_p1 == 5'd16) & ~(trunc_ln140_fu_1095_p1 == 5'd14) & ~(trunc_ln140_fu_1095_p1 == 5'd12) & ~(trunc_ln140_fu_1095_p1 == 5'd10) & ~(trunc_ln140_fu_1095_p1 == 5'd8) & ~(trunc_ln140_fu_1095_p1 == 5'd6) & ~(trunc_ln140_fu_1095_p1 == 5'd4) & ~(trunc_ln140_fu_1095_p1 == 5'd2));
end

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign ap_enable_pp1 = (ap_idle_pp1 ^ 1'b1);

assign ap_phi_mux_psum_10_011_phi_fu_835_p4 = grp_fu_908_p2;

assign ap_phi_mux_psum_11_012_phi_fu_823_p4 = grp_fu_913_p2;

assign ap_phi_mux_psum_12_013_phi_fu_811_p4 = grp_fu_918_p2;

assign ap_phi_mux_psum_13_014_phi_fu_799_p4 = grp_fu_923_p2;

assign ap_phi_mux_psum_14_015_phi_fu_787_p4 = grp_fu_928_p2;

assign ap_phi_mux_psum_15_016_phi_fu_775_p4 = grp_fu_908_p2;

assign ap_phi_mux_psum_16_017_phi_fu_763_p4 = grp_fu_913_p2;

assign ap_phi_mux_psum_17_018_phi_fu_751_p4 = grp_fu_918_p2;

assign ap_phi_mux_psum_18_019_phi_fu_739_p4 = grp_fu_923_p2;

assign ap_phi_mux_psum_19_020_phi_fu_727_p4 = grp_fu_928_p2;

assign ap_phi_mux_psum_20_021_phi_fu_715_p4 = grp_fu_908_p2;

assign ap_phi_mux_psum_21_022_phi_fu_703_p4 = grp_fu_913_p2;

assign ap_phi_mux_psum_22_023_phi_fu_691_p4 = grp_fu_918_p2;

assign ap_phi_mux_psum_23_024_phi_fu_679_p4 = grp_fu_923_p2;

assign ap_phi_mux_psum_24_025_phi_fu_667_p4 = grp_fu_928_p2;

assign ap_phi_mux_psum_25_026_phi_fu_655_p4 = grp_fu_908_p2;

assign ap_phi_mux_psum_26_027_phi_fu_643_p4 = grp_fu_913_p2;

assign ap_phi_mux_psum_27_028_phi_fu_631_p4 = grp_fu_918_p2;

assign ap_phi_mux_psum_28_029_phi_fu_619_p4 = grp_fu_923_p2;

assign ap_phi_mux_psum_29_030_phi_fu_607_p4 = grp_fu_928_p2;

assign ap_phi_mux_psum_30_031_phi_fu_595_p4 = grp_fu_908_p2;

assign ap_phi_mux_psum_31_032_phi_fu_583_p4 = grp_fu_913_p2;

assign ap_phi_mux_psum_5_06_phi_fu_571_p4 = grp_fu_908_p2;

assign ap_phi_mux_psum_6_07_phi_fu_559_p4 = grp_fu_913_p2;

assign ap_phi_mux_psum_7_08_phi_fu_547_p4 = grp_fu_918_p2;

assign ap_phi_mux_psum_8_09_phi_fu_535_p4 = grp_fu_923_p2;

assign ap_phi_mux_psum_9_010_phi_fu_523_p4 = grp_fu_928_p2;

assign ap_phi_reg_pp1_iter0_phi_ln152_reg_854 = 'bx;

assign icmp_ln132_fu_960_p2 = ((ap_phi_mux_x_phi_fu_451_p4 < 10'd576) ? 1'b1 : 1'b0);

assign icmp_ln152_29_fu_1125_p2 = ((or_ln140_fu_1105_p2 == 5'd3) ? 1'b1 : 1'b0);

assign icmp_ln152_30_fu_1139_p2 = ((or_ln140_fu_1105_p2 == 5'd5) ? 1'b1 : 1'b0);

assign icmp_ln152_31_fu_1153_p2 = ((or_ln140_fu_1105_p2 == 5'd7) ? 1'b1 : 1'b0);

assign icmp_ln152_32_fu_1167_p2 = ((or_ln140_fu_1105_p2 == 5'd9) ? 1'b1 : 1'b0);

assign icmp_ln152_33_fu_1181_p2 = ((or_ln140_fu_1105_p2 == 5'd11) ? 1'b1 : 1'b0);

assign icmp_ln152_34_fu_1195_p2 = ((or_ln140_fu_1105_p2 == 5'd13) ? 1'b1 : 1'b0);

assign icmp_ln152_35_fu_1209_p2 = ((or_ln140_fu_1105_p2 == 5'd15) ? 1'b1 : 1'b0);

assign icmp_ln152_36_fu_1223_p2 = ((or_ln140_fu_1105_p2 == 5'd17) ? 1'b1 : 1'b0);

assign icmp_ln152_37_fu_1237_p2 = ((or_ln140_fu_1105_p2 == 5'd19) ? 1'b1 : 1'b0);

assign icmp_ln152_38_fu_1251_p2 = ((or_ln140_fu_1105_p2 == 5'd21) ? 1'b1 : 1'b0);

assign icmp_ln152_39_fu_1265_p2 = ((or_ln140_fu_1105_p2 == 5'd23) ? 1'b1 : 1'b0);

assign icmp_ln152_40_fu_1283_p2 = ((or_ln140_reg_1834 == 5'd25) ? 1'b1 : 1'b0);

assign icmp_ln152_41_fu_1295_p2 = ((or_ln140_reg_1834 == 5'd27) ? 1'b1 : 1'b0);

assign icmp_ln152_42_fu_1308_p2 = ((or_ln140_reg_1834 == 5'd29) ? 1'b1 : 1'b0);

assign icmp_ln152_fu_1111_p2 = ((or_ln140_fu_1105_p2 == 5'd1) ? 1'b1 : 1'b0);

assign lshr_ln_fu_966_p4 = {{ap_phi_mux_x_phi_fu_451_p4[9:2]}};

assign or_ln136_25_fu_998_p2 = (lshr_ln_reg_1326 | 8'd2);

assign or_ln136_26_fu_1011_p2 = (lshr_ln_reg_1326 | 8'd3);

assign or_ln136_27_fu_1024_p2 = (lshr_ln_reg_1326 | 8'd4);

assign or_ln136_28_fu_1037_p2 = (lshr_ln_reg_1326 | 8'd5);

assign or_ln136_29_fu_1050_p2 = (lshr_ln_reg_1326 | 8'd6);

assign or_ln136_30_fu_1063_p2 = (lshr_ln_reg_1326 | 8'd7);

assign or_ln136_fu_984_p2 = (lshr_ln_fu_966_p4 | 8'd1);

assign or_ln140_fu_1105_p2 = (trunc_ln140_fu_1095_p1 | 5'd1);

assign select_ln152_29_fu_1131_p3 = ((icmp_ln152_29_fu_1125_p2[0:0] == 1'b1) ? psum_3_04_reg_471 : select_ln152_fu_1117_p3);

assign select_ln152_30_fu_1145_p3 = ((icmp_ln152_30_fu_1139_p2[0:0] == 1'b1) ? psum_5_06_reg_567 : select_ln152_29_fu_1131_p3);

assign select_ln152_31_fu_1159_p3 = ((icmp_ln152_31_fu_1153_p2[0:0] == 1'b1) ? psum_7_08_reg_543 : select_ln152_30_fu_1145_p3);

assign select_ln152_32_fu_1173_p3 = ((icmp_ln152_32_fu_1167_p2[0:0] == 1'b1) ? psum_9_010_reg_519 : select_ln152_31_fu_1159_p3);

assign select_ln152_33_fu_1187_p3 = ((icmp_ln152_33_fu_1181_p2[0:0] == 1'b1) ? psum_11_012_reg_819 : select_ln152_32_fu_1173_p3);

assign select_ln152_34_fu_1201_p3 = ((icmp_ln152_34_fu_1195_p2[0:0] == 1'b1) ? psum_13_014_reg_795 : select_ln152_33_fu_1187_p3);

assign select_ln152_35_fu_1215_p3 = ((icmp_ln152_35_fu_1209_p2[0:0] == 1'b1) ? psum_15_016_reg_771 : select_ln152_34_fu_1201_p3);

assign select_ln152_36_fu_1229_p3 = ((icmp_ln152_36_fu_1223_p2[0:0] == 1'b1) ? psum_17_018_reg_747 : select_ln152_35_fu_1215_p3);

assign select_ln152_37_fu_1243_p3 = ((icmp_ln152_37_fu_1237_p2[0:0] == 1'b1) ? psum_19_020_reg_723 : select_ln152_36_fu_1229_p3);

assign select_ln152_38_fu_1257_p3 = ((icmp_ln152_38_fu_1251_p2[0:0] == 1'b1) ? psum_21_022_reg_699 : select_ln152_37_fu_1243_p3);

assign select_ln152_39_fu_1271_p3 = ((icmp_ln152_39_fu_1265_p2[0:0] == 1'b1) ? psum_23_024_reg_675 : select_ln152_38_fu_1257_p3);

assign select_ln152_40_fu_1288_p3 = ((icmp_ln152_40_fu_1283_p2[0:0] == 1'b1) ? psum_25_026_reg_651 : select_ln152_39_reg_1842);

assign select_ln152_41_fu_1300_p3 = ((icmp_ln152_41_fu_1295_p2[0:0] == 1'b1) ? psum_27_028_reg_627 : select_ln152_40_fu_1288_p3);

assign select_ln152_fu_1117_p3 = ((icmp_ln152_fu_1111_p2[0:0] == 1'b1) ? psum_1_02_reg_495 : psum_31_032_reg_579);

assign tmp_fu_1082_p3 = q_reg_843[32'd5];

assign trunc_ln140_fu_1095_p1 = q_reg_843[4:0];

assign zext_ln136_27_fu_990_p1 = or_ln136_fu_984_p2;

assign zext_ln136_28_fu_1003_p1 = or_ln136_25_fu_998_p2;

assign zext_ln136_29_fu_1016_p1 = or_ln136_26_fu_1011_p2;

assign zext_ln136_30_fu_1029_p1 = or_ln136_27_fu_1024_p2;

assign zext_ln136_31_fu_1042_p1 = or_ln136_28_fu_1037_p2;

assign zext_ln136_32_fu_1055_p1 = or_ln136_29_fu_1050_p2;

assign zext_ln136_33_fu_1068_p1 = or_ln136_30_fu_1063_p2;

assign zext_ln136_fu_976_p1 = lshr_ln_fu_966_p4;

assign zext_ln140_3_fu_1279_p1 = or_ln140_reg_1834;

assign zext_ln140_fu_1090_p1 = q_reg_843;

always @ (posedge ap_clk) begin
    or_ln140_reg_1834[0] <= 1'b1;
end

endmodule //td_fused_top_tdf11_accum_1

module td_fused_top_hadd_16ns_16ns_16_8_full_dsp_1
#(parameter
    ID         = 45,
    NUM_STAGE  = 8,
    din0_WIDTH = 16,
    din1_WIDTH = 16,
    dout_WIDTH = 16
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  ce,
    input  wire [din0_WIDTH-1:0] din0,
    input  wire [din1_WIDTH-1:0] din1,
    output wire [dout_WIDTH-1:0] dout
);
//------------------------Local signal-------------------
wire                  aclk;
wire                  aclken;
wire                  a_tvalid;
wire [15:0]           a_tdata;
wire                  b_tvalid;
wire [15:0]           b_tdata;
wire                  r_tvalid;
wire [15:0]           r_tdata;
reg  [din0_WIDTH-1:0] din0_buf1;
reg  [din1_WIDTH-1:0] din1_buf1;
reg                   ce_r;
wire [dout_WIDTH-1:0] dout_i;
reg  [dout_WIDTH-1:0] dout_r;
//------------------------Instantiation------------------
td_fused_top_ap_hadd_6_full_dsp_16 td_fused_top_ap_hadd_6_full_dsp_16_u (
    .aclk                 ( aclk ),
    .aclken               ( aclken ),
    .s_axis_a_tvalid      ( a_tvalid ),
    .s_axis_a_tdata       ( a_tdata ),
    .s_axis_b_tvalid      ( b_tvalid ),
    .s_axis_b_tdata       ( b_tdata ),
    .m_axis_result_tvalid ( r_tvalid ),
    .m_axis_result_tdata  ( r_tdata )
);
//------------------------Body---------------------------
assign aclk     = clk;
assign aclken   = ce_r;
assign a_tvalid = 1'b1;
assign a_tdata  = din0_buf1;
assign b_tvalid = 1'b1;
assign b_tdata  = din1_buf1;
assign dout_i   = r_tdata;

always @(posedge clk) begin
    if (ce) begin
        din0_buf1 <= din0;
        din1_buf1 <= din1;
    end
end

always @ (posedge clk) begin
    ce_r <= ce;
end

always @ (posedge clk) begin
    if (ce_r) begin
        dout_r <= dout_i;
    end
end

assign dout = ce_r?dout_i:dout_r;
endmodule

module td_fused_top_ap_hadd_6_full_dsp_16 (
   input  wire        aclk,
   input wire         aclken,
   input  wire        s_axis_a_tvalid,
   input  wire [15:0] s_axis_a_tdata,
   input  wire        s_axis_b_tvalid,
   input  wire [15:0] s_axis_b_tdata,
   output wire        m_axis_result_tvalid,
   output wire [15:0] m_axis_result_tdata
);

   reg [15:0] a_reg, b_reg, res, res_reg;

   always @(posedge aclk) begin
      if (aclken) begin
         a_reg <= s_axis_a_tdata;     
         b_reg <= s_axis_b_tdata;     
         res_reg <= res;
      end
   end

`ifdef complex_dsp
   adder_fp u_add_fp (
      .a(a_reg), 
      .b(b_reg), 
      .out(res)
   );
`else
FPAddSub u_FPAddSub (.clk(), .rst(1'b0), .a(a_reg), .b(b_reg), .operation(1'b0), .result(res), .flags());
`endif

   assign m_axis_result_tdata = res_reg;

endmodule
module FPAddSub(
		clk,
		rst,
		a,
		b,
		operation,			// 0 add, 1 sub
		result,
		flags
	);
	
	// Clock and reset
	input clk ;										// Clock signal
	input rst ;										// Reset (active high, resets pipeline registers)
	
	// Input ports
	input [`DWIDTH-1:0] a ;								// Input A, a 32-bit floating point number
	input [`DWIDTH-1:0] b ;								// Input B, a 32-bit floating point number
	input operation ;								// Operation select signal
	
	// Output ports
	output [`DWIDTH-1:0] result ;						// Result of the operation
	output [4:0] flags ;							// Flags indicating exceptions according to IEEE754
	
	// Pipeline Registers
	//reg [79:0] pipe_1;							// Pipeline register PreAlign->Align1
	reg [`DWIDTH*2+15:0] pipe_1;							// Pipeline register PreAlign->Align1

	//reg [67:0] pipe_2;							// Pipeline register Align1->Align3
	reg [`MANTISSA*2+`EXPONENT+13:0] pipe_2;							// Pipeline register Align1->Align3

	//reg [76:0] pipe_3;	68						// Pipeline register Align1->Align3
	reg [`MANTISSA*2+`EXPONENT+14:0] pipe_3;							// Pipeline register Align1->Align3

	//reg [69:0] pipe_4;							// Pipeline register Align3->Execute
	reg [`MANTISSA*2+`EXPONENT+15:0] pipe_4;							// Pipeline register Align3->Execute

	//reg [51:0] pipe_5;							// Pipeline register Execute->Normalize
	reg [`DWIDTH+`EXPONENT+11:0] pipe_5;							// Pipeline register Execute->Normalize

	//reg [56:0] pipe_6;							// Pipeline register Nomalize->NormalizeShift1
	reg [`DWIDTH+`EXPONENT+16:0] pipe_6;							// Pipeline register Nomalize->NormalizeShift1

	//reg [56:0] pipe_7;							// Pipeline register NormalizeShift2->NormalizeShift3
	reg [`DWIDTH+`EXPONENT+16:0] pipe_7;							// Pipeline register NormalizeShift2->NormalizeShift3

	//reg [54:0] pipe_8;							// Pipeline register NormalizeShift3->Round
	reg [`EXPONENT*2+`MANTISSA+15:0] pipe_8;							// Pipeline register NormalizeShift3->Round

	//reg [40:0] pipe_9;							// Pipeline register NormalizeShift3->Round
	reg [`DWIDTH+8:0] pipe_9;							// Pipeline register NormalizeShift3->Round
	
	// Internal wires between modules
	wire [`DWIDTH-2:0] Aout_0 ;							// A - sign
	wire [`DWIDTH-2:0] Bout_0 ;							// B - sign
	wire Opout_0 ;									// A's sign
	wire Sa_0 ;										// A's sign
	wire Sb_0 ;										// B's sign
	wire MaxAB_1 ;									// Indicates the larger of A and B(0/A, 1/B)
	wire [`EXPONENT-1:0] CExp_1 ;							// Common Exponent
	wire [4:0] Shift_1 ;							// Number of steps to smaller mantissa shift right (align)
	wire [`MANTISSA-1:0] Mmax_1 ;							// Larger mantissa
	wire [4:0] InputExc_0 ;						// Input numbers are exceptions
	wire [9:0] ShiftDet_0 ;
	wire [`MANTISSA-1:0] MminS_1 ;						// Smaller mantissa after 0/16 shift
	wire [`MANTISSA:0] MminS_2 ;						// Smaller mantissa after 0/4/8/12 shift
	wire [`MANTISSA:0] Mmin_3 ;							// Smaller mantissa after 0/1/2/3 shift
	wire [`DWIDTH:0] Sum_4 ;
	wire PSgn_4 ;
	wire Opr_4 ;
	wire [4:0] Shift_5 ;							// Number of steps to shift sum left (normalize)
	wire [`DWIDTH:0] SumS_5 ;							// Sum after 0/16 shift
	wire [`DWIDTH:0] SumS_6 ;							// Sum after 0/16 shift
	wire [`DWIDTH:0] SumS_7 ;							// Sum after 0/16 shift
	wire [`MANTISSA-1:0] NormM_8 ;						// Normalized mantissa
	wire [`EXPONENT:0] NormE_8;							// Adjusted exponent
	wire ZeroSum_8 ;								// Zero flag
	wire NegE_8 ;									// Flag indicating negative exponent
	wire R_8 ;										// Round bit
	wire S_8 ;										// Final sticky bit
	wire FG_8 ;										// Final sticky bit
	wire [`DWIDTH-1:0] P_int ;
	wire EOF ;
	
	// Prepare the operands for alignment and check for exceptions
	FPAddSub_PrealignModule PrealignModule
	(	// Inputs
		a, b, operation,
		// Outputs
		Sa_0, Sb_0, ShiftDet_0[9:0], InputExc_0[4:0], Aout_0[`DWIDTH-2:0], Bout_0[`DWIDTH-2:0], Opout_0) ;
		
	// Prepare the operands for alignment and check for exceptions
	FPAddSub_AlignModule AlignModule
	(	// Inputs
		pipe_1[14+2*`DWIDTH:16+`DWIDTH], pipe_1[15+`DWIDTH:17], pipe_1[14:5],
		// Outputs
		CExp_1[`EXPONENT-1:0], MaxAB_1, Shift_1[4:0], MminS_1[`MANTISSA-1:0], Mmax_1[`MANTISSA-1:0]) ;	

	// Alignment Shift Stage 1
	FPAddSub_AlignShift1 AlignShift1
	(  // Inputs
		pipe_2[`MANTISSA-1:0], pipe_2[2*`MANTISSA+9:2*`MANTISSA+7],
		// Outputs
		MminS_2[`MANTISSA:0]) ;

	// Alignment Shift Stage 3 and compution of guard and sticky bits
	FPAddSub_AlignShift2 AlignShift2  
	(  // Inputs
		pipe_3[`MANTISSA:0], pipe_3[2*`MANTISSA+7:2*`MANTISSA+6],
		// Outputs
		Mmin_3[`MANTISSA:0]) ;
						
	// Perform mantissa addition
	FPAddSub_ExecutionModule ExecutionModule
	(  // Inputs
		pipe_4[`MANTISSA*2+5:`MANTISSA+6], pipe_4[`MANTISSA:0], pipe_4[`MANTISSA*2+`EXPONENT+13], pipe_4[`MANTISSA*2+`EXPONENT+12], pipe_4[`MANTISSA*2+`EXPONENT+11], pipe_4[`MANTISSA*2+`EXPONENT+14],
		// Outputs
		Sum_4[`DWIDTH:0], PSgn_4, Opr_4) ;
	
	// Prepare normalization of result
	FPAddSub_NormalizeModule NormalizeModule
	(  // Inputs
		pipe_5[`DWIDTH:0], 
		// Outputs
		SumS_5[`DWIDTH:0], Shift_5[4:0]) ;
					
	// Normalization Shift Stage 1
	FPAddSub_NormalizeShift1 NormalizeShift1
	(  // Inputs
		pipe_6[`DWIDTH:0], pipe_6[`DWIDTH+`EXPONENT+14:`DWIDTH+`EXPONENT+11],
		// Outputs
		SumS_7[`DWIDTH:0]) ;
		
	// Normalization Shift Stage 3 and final guard, sticky and round bits
	FPAddSub_NormalizeShift2 NormalizeShift2
	(  // Inputs
		pipe_7[`DWIDTH:0], pipe_7[`DWIDTH+`EXPONENT+5:`DWIDTH+6], pipe_7[`DWIDTH+`EXPONENT+15:`DWIDTH+`EXPONENT+11],
		// Outputs
		NormM_8[`MANTISSA-1:0], NormE_8[`EXPONENT:0], ZeroSum_8, NegE_8, R_8, S_8, FG_8) ;

	// Round and put result together
	FPAddSub_RoundModule RoundModule
	(  // Inputs
		 pipe_8[3], pipe_8[4+`EXPONENT:4], pipe_8[`EXPONENT+`MANTISSA+4:5+`EXPONENT], pipe_8[1], pipe_8[0], pipe_8[`EXPONENT*2+`MANTISSA+15], pipe_8[`EXPONENT*2+`MANTISSA+12], pipe_8[`EXPONENT*2+`MANTISSA+11], pipe_8[`EXPONENT*2+`MANTISSA+14], pipe_8[`EXPONENT*2+`MANTISSA+10], 
		// Outputs
		P_int[`DWIDTH-1:0], EOF) ;
	
	// Check for exceptions
	FPAddSub_ExceptionModule Exceptionmodule
	(  // Inputs
		pipe_9[8+`DWIDTH:9], pipe_9[8], pipe_9[7], pipe_9[6], pipe_9[5:1], pipe_9[0], 
		// Outputs
		result[`DWIDTH-1:0], flags[4:0]) ;			
	
	always @ (*) begin	
		if(rst) begin
			pipe_1 = 0;
			pipe_2 = 0;
			pipe_3 = 0;
			pipe_4 = 0;
			pipe_5 = 0;
			pipe_6 = 0;
			pipe_7 = 0;
			pipe_8 = 0;
			pipe_9 = 0;
		end 
		else begin
		
			pipe_1 = {Opout_0, Aout_0[`DWIDTH-2:0], Bout_0[`DWIDTH-2:0], Sa_0, Sb_0, ShiftDet_0[9:0], InputExc_0[4:0]} ;	
			// PIPE_2 :
			//[67] operation
			//[66] Sa_0
			//[65] Sb_0
			//[64] MaxAB_0
			//[63:56] CExp_0
			//[55:51] Shift_0
			//[50:28] Mmax_0
			//[27:23] InputExc_0
			//[22:0] MminS_1
			//
			pipe_2 = {pipe_1[`DWIDTH*2+15], pipe_1[16:15], MaxAB_1, CExp_1[`EXPONENT-1:0], Shift_1[4:0], Mmax_1[`MANTISSA-1:0], pipe_1[4:0], MminS_1[`MANTISSA-1:0]} ;	
			// PIPE_3 :
			//[68] operation
			//[67] Sa_0
			//[66] Sb_0
			//[65] MaxAB_0
			//[64:57] CExp_0
			//[56:52] Shift_0
			//[51:29] Mmax_0
			//[28:24] InputExc_0
			//[23:0] MminS_1
			//
			pipe_3 = {pipe_2[`MANTISSA*2+`EXPONENT+13:`MANTISSA], MminS_2[`MANTISSA:0]} ;	
			// PIPE_4 :
			//[68] operation
			//[67] Sa_0
			//[66] Sb_0
			//[65] MaxAB_0
			//[64:57] CExp_0
			//[56:52] Shift_0
			//[51:29] Mmax_0
			//[28:24] InputExc_0
			//[23:0] Mmin_3
			//					
			pipe_4 = {pipe_3[`MANTISSA*2+`EXPONENT+14:`MANTISSA+1], Mmin_3[`MANTISSA:0]} ;	
			// PIPE_5 :
			//[51] operation
			//[50] PSgn_4
			//[49] Opr_4
			//[48] Sa_0
			//[47] Sb_0
			//[46] MaxAB_0
			//[45:38] CExp_0
			//[37:33] InputExc_0
			//[32:0] Sum_4
			//					
			pipe_5 = {pipe_4[2*`MANTISSA+`EXPONENT+14], PSgn_4, Opr_4, pipe_4[2*`MANTISSA+`EXPONENT+13:2*`MANTISSA+11], pipe_4[`MANTISSA+5:`MANTISSA+1], Sum_4[`DWIDTH:0]} ;
			// PIPE_6 :
			//[56] operation
			//[55:51] Shift_5
			//[50] PSgn_4
			//[49] Opr_4
			//[48] Sa_0
			//[47] Sb_0
			//[46] MaxAB_0
			//[45:38] CExp_0
			//[37:33] InputExc_0
			//[32:0] Sum_4
			//					
			pipe_6 = {pipe_5[`EXPONENT+`EXPONENT+11], Shift_5[4:0], pipe_5[`DWIDTH+`EXPONENT+10:`DWIDTH+1], SumS_5[`DWIDTH:0]} ;	
			// pipe_7 :
			//[56] operation
			//[55:51] Shift_5
			//[50] PSgn_4
			//[49] Opr_4
			//[48] Sa_0
			//[47] Sb_0
			//[46] MaxAB_0
			//[45:38] CExp_0
			//[37:33] InputExc_0
			//[32:0] Sum_4
			//						
			pipe_7 = {pipe_6[`DWIDTH+`EXPONENT+16:`DWIDTH+1], SumS_7[`DWIDTH:0]} ;	
			// pipe_8:
			//[54] FG_8 
			//[53] operation
			//[52] PSgn_4
			//[51] Sa_0
			//[50] Sb_0
			//[49] MaxAB_0
			//[48:41] CExp_0
			//[40:36] InputExc_8
			//[35:13] NormM_8 
			//[12:4] NormE_8
			//[3] ZeroSum_8
			//[2] NegE_8
			//[1] R_8
			//[0] S_8
			//				
			pipe_8 = {FG_8, pipe_7[`DWIDTH+`EXPONENT+16], pipe_7[`DWIDTH+`EXPONENT+10], pipe_7[`DWIDTH+`EXPONENT+8:`DWIDTH+1], NormM_8[`MANTISSA-1:0], NormE_8[`EXPONENT:0], ZeroSum_8, NegE_8, R_8, S_8} ;	
			// pipe_9:
			//[40:9] P_int
			//[8] NegE_8
			//[7] R_8
			//[6] S_8
			//[5:1] InputExc_8
			//[0] EOF
			//				
			pipe_9 = {P_int[`DWIDTH-1:0], pipe_8[2], pipe_8[1], pipe_8[0], pipe_8[`EXPONENT+`MANTISSA+9:`EXPONENT+`MANTISSA+5], EOF} ;	
		end
	end		
	
endmodule
module FPAddSub_ExceptionModule(
		Z,
		NegE,
		R,
		S,
		InputExc,
		EOF,
		P,
		Flags
    );
	 
	// Input ports
	input [`DWIDTH-1:0] Z	;					// Final product
	input NegE ;						// Negative exponent?
	input R ;							// Round bit
	input S ;							// Sticky bit
	input [4:0] InputExc ;			// Exceptions in inputs A and B
	input EOF ;
	
	// Output ports
	output [`DWIDTH-1:0] P ;					// Final result
	output [4:0] Flags ;				// Exception flags
	
	// Internal signals
	wire Overflow ;					// Overflow flag
	wire Underflow ;					// Underflow flag
	wire DivideByZero ;				// Divide-by-Zero flag (always 0 in Add/Sub)
	wire Invalid ;						// Invalid inputs or result
	wire Inexact ;						// Result is inexact because of rounding
	
	// Exception flags
	
	// Result is too big to be represented
	assign Overflow = EOF | InputExc[1] | InputExc[0] ;
	
	// Result is too small to be represented
	assign Underflow = NegE & (R | S);
	
	// Infinite result computed exactly from finite operands
	assign DivideByZero = &(Z[`MANTISSA+`EXPONENT-1:`MANTISSA]) & ~|(Z[`MANTISSA+`EXPONENT-1:`MANTISSA]) & ~InputExc[1] & ~InputExc[0];
	
	// Invalid inputs or operation
	assign Invalid = |(InputExc[4:2]) ;
	
	// Inexact answer due to rounding, overflow or underflow
	assign Inexact = (R | S) | Overflow | Underflow;
	
	// Put pieces together to form final result
	assign P = Z ;
	
	// Collect exception flags	
	assign Flags = {Overflow, Underflow, DivideByZero, Invalid, Inexact} ; 	
	
endmodule
module FPAddSub_RoundModule(
		ZeroSum,
		NormE,
		NormM,
		R,
		S,
		G,
		Sa,
		Sb,
		Ctrl,
		MaxAB,
		Z,
		EOF
    );

	// Input ports
	input ZeroSum ;					// Sum is zero
	input [`EXPONENT:0] NormE ;				// Normalized exponent
	input [`MANTISSA-1:0] NormM ;				// Normalized mantissa
	input R ;							// Round bit
	input S ;							// Sticky bit
	input G ;
	input Sa ;							// A's sign bit
	input Sb ;							// B's sign bit
	input Ctrl ;						// Control bit (operation)
	input MaxAB ;
	
	// Output ports
	output [`DWIDTH-1:0] Z ;					// Final result
	output EOF ;
	
	// Internal signals
	wire [`MANTISSA:0] RoundUpM ;			// Rounded up sum with room for overflow
	wire [`MANTISSA-1:0] RoundM ;				// The final rounded sum
	wire [`EXPONENT:0] RoundE ;				// Rounded exponent (note extra bit due to poential overflow	)
	wire RoundUp ;						// Flag indicating that the sum should be rounded up
        wire FSgn;
	wire ExpAdd ;						// May have to add 1 to compensate for overflow 
	wire RoundOF ;						// Rounding overflow
	
	// The cases where we need to round upwards (= adding one) in Round to nearest, tie to even
	assign RoundUp = (G & ((R | S) | NormM[0])) ;
	
	// Note that in the other cases (rounding down), the sum is already 'rounded'
	assign RoundUpM = (NormM + 1) ;								// The sum, rounded up by 1
	assign RoundM = (RoundUp ? RoundUpM[`MANTISSA-1:0] : NormM) ; 	// Compute final mantissa	
	assign RoundOF = RoundUp & RoundUpM[`MANTISSA] ; 				// Check for overflow when rounding up

	// Calculate post-rounding exponent
	assign ExpAdd = (RoundOF ? 1'b1 : 1'b0) ; 				// Add 1 to exponent to compensate for overflow
	assign RoundE = ZeroSum ? 5'b00000 : (NormE + ExpAdd) ; 							// Final exponent

	// If zero, need to determine sign according to rounding
	assign FSgn = (ZeroSum & (Sa ^ Sb)) | (ZeroSum ? (Sa & Sb & ~Ctrl) : ((~MaxAB & Sa) | ((Ctrl ^ Sb) & (MaxAB | Sa)))) ;

	// Assign final result
	assign Z = {FSgn, RoundE[`EXPONENT-1:0], RoundM[`MANTISSA-1:0]} ;
	
	// Indicate exponent overflow
	assign EOF = RoundE[`EXPONENT];
	
endmodule
module FPAddSub_NormalizeShift2(
		PSSum,
		CExp,
		Shift,
		NormM,
		NormE,
		ZeroSum,
		NegE,
		R,
		S,
		FG
	);
	
	// Input ports
	input [`DWIDTH:0] PSSum ;					// The Pre-Shift-Sum
	input [`EXPONENT-1:0] CExp ;
	input [4:0] Shift ;					// Amount to be shifted

	// Output ports
	output [`MANTISSA-1:0] NormM ;				// Normalized mantissa
	output [`EXPONENT:0] NormE ;					// Adjusted exponent
	output ZeroSum ;						// Zero flag
	output NegE ;							// Flag indicating negative exponent
	output R ;								// Round bit
	output S ;								// Final sticky bit
	output FG ;

	// Internal signals
	wire MSBShift ;						// Flag indicating that a second shift is needed
	wire [`EXPONENT:0] ExpOF ;					// MSB set in sum indicates overflow
	wire [`EXPONENT:0] ExpOK ;					// MSB not set, no adjustment
	
	// Calculate normalized exponent and mantissa, check for all-zero sum
	assign MSBShift = PSSum[`DWIDTH] ;		// Check MSB in unnormalized sum
	assign ZeroSum = ~|PSSum ;			// Check for all zero sum
	assign ExpOK = CExp - Shift ;		// Adjust exponent for new normalized mantissa
	assign NegE = ExpOK[`EXPONENT] ;			// Check for exponent overflow
	assign ExpOF = CExp - Shift + 1'b1 ;		// If MSB set, add one to exponent(x2)
	assign NormE = MSBShift ? ExpOF : ExpOK ;			// Check for exponent overflow
	assign NormM = PSSum[`DWIDTH-1:`EXPONENT+1] ;		// The new, normalized mantissa
	
	// Also need to compute sticky and round bits for the rounding stage
	assign FG = PSSum[`EXPONENT] ; 
	assign R = PSSum[`EXPONENT-1] ;
	assign S = |PSSum[`EXPONENT-2:0] ;
	
endmodule
module FPAddSub_NormalizeShift1(
		MminP,
		Shift,
		Mmin
	);
	
	// Input ports
	input [`DWIDTH:0] MminP ;						// Smaller mantissa after 16|12|8|4 shift
	input [3:0] Shift ;						// Shift amount
	
	// Output ports
	output [`DWIDTH:0] Mmin ;						// The smaller mantissa
	
	reg	  [`DWIDTH:0]		Lvl2;
	wire    [2*`DWIDTH+1:0]    Stage1;	
	reg	  [`DWIDTH:0]		Lvl3;
	wire    [2*`DWIDTH+1:0]    Stage2;	
	integer           i;               	// Loop variable
	
	assign Stage1 = {MminP, MminP};

	always @(*) begin    					// Rotate {0 | 4 | 8 | 12} bits
	  case (Shift[3:2])
			// Rotate by 0
			2'b00: //Lvl2 <= Stage1[`DWIDTH:0];       		
      begin Lvl2 = Stage1[`DWIDTH:0];  end
			// Rotate by 4
			2'b01: //begin for (i=2*`DWIDTH+1; i>=`DWIDTH+1; i=i-1) begin Lvl2[i-33] <= Stage1[i-4]; end Lvl2[3:0] <= 0; end
      begin Lvl2[`DWIDTH: (`DWIDTH-4)] = Stage1[3:0]; Lvl2[`DWIDTH-4-1:0] = Stage1[`DWIDTH-4]; end
			// Rotate by 8
			2'b10: //begin for (i=2*`DWIDTH+1; i>=`DWIDTH+1; i=i-1) begin Lvl2[i-33] <= Stage1[i-8]; end Lvl2[7:0] <= 0; end
      begin Lvl2[`DWIDTH: (`DWIDTH-8)] = Stage1[3:0]; Lvl2[`DWIDTH-8-1:0] = Stage1[`DWIDTH-8]; end
			// Rotate by 12
			2'b11: //begin for (i=2*`DWIDTH+1; i>=`DWIDTH+1; i=i-1) begin Lvl2[i-33] <= Stage1[i-12]; end Lvl2[11:0] <= 0; end
      begin Lvl2[`DWIDTH: (`DWIDTH-12)] = Stage1[3:0]; Lvl2[`DWIDTH-12-1:0] = Stage1[`DWIDTH-12]; end
	  endcase
	end
	
	assign Stage2 = {Lvl2, Lvl2};

	always @(*) begin   				 		// Rotate {0 | 1 | 2 | 3} bits
	  case (Shift[1:0])
			// Rotate by 0
			2'b00:  //Lvl3 <= Stage2[`DWIDTH:0];
      begin Lvl3 = Stage2[`DWIDTH:0]; end
			// Rotate by 1
			2'b01: //begin for (i=2*`DWIDTH+1; i>=`DWIDTH+1; i=i-1) begin Lvl3[i-`DWIDTH-1] <= Stage2[i-1]; end Lvl3[0] <= 0; end 
      begin Lvl3[`DWIDTH: (`DWIDTH-1)] = Stage2[3:0]; Lvl3[`DWIDTH-1-1:0] = Stage2[`DWIDTH-1]; end
			// Rotate by 2
			2'b10: //begin for (i=2*`DWIDTH+1; i>=`DWIDTH+1; i=i-1) begin Lvl3[i-`DWIDTH-1] <= Stage2[i-2]; end Lvl3[1:0] <= 0; end
      begin Lvl3[`DWIDTH: (`DWIDTH-2)] = Stage2[3:0]; Lvl3[`DWIDTH-2-1:0] = Stage2[`DWIDTH-2]; end
			// Rotate by 3
			2'b11: //begin for (i=2*`DWIDTH+1; i>=`DWIDTH+1; i=i-1) begin Lvl3[i-`DWIDTH-1] <= Stage2[i-3]; end Lvl3[2:0] <= 0; end
      begin Lvl3[`DWIDTH: (`DWIDTH-3)] = Stage2[3:0]; Lvl3[`DWIDTH-3-1:0] = Stage2[`DWIDTH-3]; end
	  endcase
	end
	
	// Assign outputs
	assign Mmin = Lvl3;						// Take out smaller mantissa			
	
endmodule
module FPAddSub_NormalizeModule(
		Sum,
		Mmin,
		Shift
    );

	// Input ports
	input [`DWIDTH:0] Sum ;					// Mantissa sum including hidden 1 and GRS
	
	// Output ports
	output [`DWIDTH:0] Mmin ;					// Mantissa after 16|0 shift
	output [4:0] Shift ;					// Shift amount
	
	// Determine normalization shift amount by finding leading nought
	assign Shift =  ( 
		Sum[16] ? 5'b00000 :	 
		Sum[15] ? 5'b00001 : 
		Sum[14] ? 5'b00010 : 
		Sum[13] ? 5'b00011 : 
		Sum[12] ? 5'b00100 : 
		Sum[11] ? 5'b00101 : 
		Sum[10] ? 5'b00110 : 
		Sum[9] ? 5'b00111 :
		Sum[8] ? 5'b01000 :
		Sum[7] ? 5'b01001 :
		Sum[6] ? 5'b01010 :
		Sum[5] ? 5'b01011 :
		Sum[4] ? 5'b01100 : 5'b01101
	//	Sum[19] ? 5'b01101 :
	//	Sum[18] ? 5'b01110 :
	//	Sum[17] ? 5'b01111 :
	//	Sum[16] ? 5'b10000 :
	//	Sum[15] ? 5'b10001 :
	//	Sum[14] ? 5'b10010 :
	//	Sum[13] ? 5'b10011 :
	//	Sum[12] ? 5'b10100 :
	//	Sum[11] ? 5'b10101 :
	//	Sum[10] ? 5'b10110 :
	//	Sum[9] ? 5'b10111 :
	//	Sum[8] ? 5'b11000 :
	//	Sum[7] ? 5'b11001 : 5'b11010
	);
	
	reg	  [`DWIDTH:0]		Lvl1;
	
	always @(*) begin
		// Rotate by 16?
		Lvl1 <= Shift[4] ? {Sum[8:0], 8'b00000000} : Sum; 
	end
	
	// Assign outputs
	assign Mmin = Lvl1;						// Take out smaller mantissa

endmodule
module FPAddSub_ExecutionModule(
		Mmax,
		Mmin,
		Sa,
		Sb,
		MaxAB,
		OpMode,
		Sum,
		PSgn,
		Opr
    );

	// Input ports
	input [`MANTISSA-1:0] Mmax ;					// The larger mantissa
	input [`MANTISSA:0] Mmin ;					// The smaller mantissa
	input Sa ;								// Sign bit of larger number
	input Sb ;								// Sign bit of smaller number
	input MaxAB ;							// Indicates the larger number (0/A, 1/B)
	input OpMode ;							// Operation to be performed (0/Add, 1/Sub)
	
	// Output ports
	output [`DWIDTH:0] Sum ;					// The result of the operation
	output PSgn ;							// The sign for the result
	output Opr ;							// The effective (performed) operation

	assign Opr = (OpMode^Sa^Sb); 		// Resolve sign to determine operation

	// Perform effective operation
	assign Sum = (OpMode^Sa^Sb) ? ({1'b1, Mmax, 5'b00000} - {Mmin, 5'b00000}) : ({1'b1, Mmax, 5'b00000} + {Mmin, 5'b00000}) ;
	
	// Assign result sign
	assign PSgn = (MaxAB ? Sb : Sa) ;

endmodule
module FPAddSub_AlignShift2(
		MminP,
		Shift,
		Mmin
	);
	
	// Input ports
	input [`MANTISSA:0] MminP ;						// Smaller mantissa after 16|12|8|4 shift
	input [1:0] Shift ;						// Shift amount
	
	// Output ports
	output [`MANTISSA:0] Mmin ;						// The smaller mantissa
	
	// Internal Signal
	reg	  [`MANTISSA:0]		Lvl3;
	wire    [2*`MANTISSA+1:0]    Stage2;	
	integer           j;               // Loop variable
	
	assign Stage2 = {11'b0, MminP};

	always @(*) begin    // Rotate {0 | 1 | 2 | 3} bits
	  case (Shift[1:0])
			// Rotate by 0
			2'b00:  Lvl3 <= Stage2[`MANTISSA:0];   
			// Rotate by 1
			2'b01:  begin for (j=0; j<=`MANTISSA; j=j+1)  begin Lvl3[j] <= Stage2[j+1]; end /*Lvl3[`MANTISSA] <= 0; */end 
			// Rotate by 2
			2'b10:  begin for (j=0; j<=`MANTISSA; j=j+1)  begin Lvl3[j] <= Stage2[j+2]; end /*Lvl3[`MANTISSA:`MANTISSA-1] <= 0;*/ end 
			// Rotate by 3
			2'b11:  begin for (j=0; j<=`MANTISSA; j=j+1)  begin Lvl3[j] <= Stage2[j+3]; end /*Lvl3[`MANTISSA:`MANTISSA-2] <= 0;*/ end 	  
	  endcase
	end
	
	// Assign output
	assign Mmin = Lvl3;						// Take out smaller mantissa				

endmodule
module FPAddSub_AlignShift1(
		MminP,
		Shift,
		Mmin
	);
	
	// Input ports
	input [`MANTISSA-1:0] MminP ;						// Smaller mantissa after 16|12|8|4 shift
	input [2:0] Shift ;						// Shift amount
	
	// Output ports
	output [`MANTISSA:0] Mmin ;						// The smaller mantissa
	
	// Internal signals
	reg	  [`MANTISSA:0]		Lvl1;
	reg	  [`MANTISSA:0]		Lvl2;
	wire    [2*`MANTISSA+1:0]    Stage1;	
	integer           i;                // Loop variable
	
	always @(*) begin						
		// Rotate by 16?
		//Lvl1 <= Shift[2] ? {17'b00000000000000001, MminP[22:16]} : {1'b1, MminP}; 
		Lvl1 <= Shift[2] ? {11'b0000000000} : {1'b1, MminP}; 
		
	end
	
	assign Stage1 = { 11'b0, Lvl1};
	
	always @(*) begin    					// Rotate {0 | 4 | 8 | 12} bits
	  case (Shift[1:0])
			// Rotate by 0	
			2'b00:  Lvl2 <= Stage1[`MANTISSA:0];       			
			// Rotate by 4	
			2'b01:  begin for (i=0; i<=`MANTISSA; i=i+1) begin Lvl2[i] <= Stage1[i+4]; end /*Lvl2[`MANTISSA:`MANTISSA-3] <= 0;*/ end
			// Rotate by 8
			2'b10:  begin for (i=0; i<=`MANTISSA; i=i+1) begin Lvl2[i] <= Stage1[i+8]; end /*Lvl2[`MANTISSA:`MANTISSA-7] <= 0;*/ end
			// Rotate by 12	
			2'b11: Lvl2[`MANTISSA: 0] <= 0; 
			//2'b11:  begin for (i=0; i<=`MANTISSA; i=i+1) begin Lvl2[i] <= Stage1[i+12]; end Lvl2[`MANTISSA:`MANTISSA-12] <= 0; end
	  endcase
	end
	
	// Assign output to next shift stage
	assign Mmin = Lvl2;
	
endmodule
module FPAddSub_AlignModule (
		A,
		B,
		ShiftDet,
		CExp,
		MaxAB,
		Shift,
		Mmin,
		Mmax
	);
	
	// Input ports
	input [`DWIDTH-2:0] A ;								// Input A, a 32-bit floating point number
	input [`DWIDTH-2:0] B ;								// Input B, a 32-bit floating point number
	input [9:0] ShiftDet ;
	
	// Output ports
	output [`EXPONENT-1:0] CExp ;							// Common Exponent
	output MaxAB ;									// Incidates larger of A and B (0/A, 1/B)
	output [4:0] Shift ;							// Number of steps to smaller mantissa shift right
	output [`MANTISSA-1:0] Mmin ;							// Smaller mantissa 
	output [`MANTISSA-1:0] Mmax ;							// Larger mantissa
	
	// Internal signals
	//wire BOF ;										// Check for shifting overflow if B is larger
	//wire AOF ;										// Check for shifting overflow if A is larger
	
	assign MaxAB = (A[`DWIDTH-2:0] < B[`DWIDTH-2:0]) ;	
	//assign BOF = ShiftDet[9:5] < 25 ;		// Cannot shift more than 25 bits
	//assign AOF = ShiftDet[4:0] < 25 ;		// Cannot shift more than 25 bits
	
	// Determine final shift value
	//assign Shift = MaxAB ? (BOF ? ShiftDet[9:5] : 5'b11001) : (AOF ? ShiftDet[4:0] : 5'b11001) ;
	
	assign Shift = MaxAB ? ShiftDet[9:5] : ShiftDet[4:0] ;
	
	// Take out smaller mantissa and append shift space
	assign Mmin = MaxAB ? A[`MANTISSA-1:0] : B[`MANTISSA-1:0] ; 
	
	// Take out larger mantissa	
	assign Mmax = MaxAB ? B[`MANTISSA-1:0]: A[`MANTISSA-1:0] ;	
	
	// Common exponent
	assign CExp = (MaxAB ? B[`MANTISSA+`EXPONENT-1:`MANTISSA] : A[`MANTISSA+`EXPONENT-1:`MANTISSA]) ;		
	
endmodule
module FPAddSub_PrealignModule(
		A,
		B,
		operation,
		Sa,
		Sb,
		ShiftDet,
		InputExc,
		Aout,
		Bout,
		Opout
	);
	
	// Input ports
	input [`DWIDTH-1:0] A ;										// Input A, a 32-bit floating point number
	input [`DWIDTH-1:0] B ;										// Input B, a 32-bit floating point number
	input operation ;
	
	// Output ports
	output Sa ;												// A's sign
	output Sb ;												// B's sign
	output [9:0] ShiftDet ;
	output [4:0] InputExc ;								// Input numbers are exceptions
	output [`DWIDTH-2:0] Aout ;
	output [`DWIDTH-2:0] Bout ;
	output Opout ;
	
	// Internal signals									// If signal is high...
	wire ANaN ;												// A is a NaN (Not-a-Number)
	wire BNaN ;												// B is a NaN
	wire AInf ;												// A is infinity
	wire BInf ;												// B is infinity
	wire [`EXPONENT-1:0] DAB ;										// ExpA - ExpB					
	wire [`EXPONENT-1:0] DBA ;										// ExpB - ExpA	
	
	assign ANaN = &(A[`DWIDTH-2:`DWIDTH-1-`EXPONENT]) & |(A[`MANTISSA-1:0]) ;		// All one exponent and not all zero mantissa - NaN
	assign BNaN = &(B[`DWIDTH-2:`DWIDTH-1-`EXPONENT]) & |(B[`MANTISSA-1:0]);		// All one exponent and not all zero mantissa - NaN
	assign AInf = &(A[`DWIDTH-2:`DWIDTH-1-`EXPONENT]) & ~|(A[`MANTISSA-1:0]) ;	// All one exponent and all zero mantissa - Infinity
	assign BInf = &(B[`DWIDTH-2:`DWIDTH-1-`EXPONENT]) & ~|(B[`MANTISSA-1:0]) ;	// All one exponent and all zero mantissa - Infinity
	
	// Put all flags into exception vector
	assign InputExc = {(ANaN | BNaN | AInf | BInf), ANaN, BNaN, AInf, BInf} ;
	
	//assign DAB = (A[30:23] - B[30:23]) ;
	//assign DBA = (B[30:23] - A[30:23]) ;
	assign DAB = (A[`DWIDTH-2:`MANTISSA] + ~(B[`DWIDTH-2:`MANTISSA]) + 1) ;
	assign DBA = (B[`DWIDTH-2:`MANTISSA] + ~(A[`DWIDTH-2:`MANTISSA]) + 1) ;
	
	assign Sa = A[`DWIDTH-1] ;									// A's sign bit
	assign Sb = B[`DWIDTH-1] ;									// B's sign	bit
	assign ShiftDet = {DBA[4:0], DAB[4:0]} ;		// Shift data
	assign Opout = operation ;
	assign Aout = A[`DWIDTH-2:0] ;
	assign Bout = B[`DWIDTH-2:0] ;
	
endmodule












