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

module td_fused_top_tdf4_dot_product (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_continue,
        ap_idle,
        ap_ready,
        ifmap_vec_0_address0,
        ifmap_vec_0_ce0,
        ifmap_vec_0_q0,
        ifmap_vec_1_address0,
        ifmap_vec_1_ce0,
        ifmap_vec_1_q0,
        ifmap_vec_2_address0,
        ifmap_vec_2_ce0,
        ifmap_vec_2_q0,
        ifmap_vec_3_address0,
        ifmap_vec_3_ce0,
        ifmap_vec_3_q0,
        weight_vecs_0_0_address0,
        weight_vecs_0_0_ce0,
        weight_vecs_0_0_q0,
        weight_vecs_0_1_address0,
        weight_vecs_0_1_ce0,
        weight_vecs_0_1_q0,
        weight_vecs_0_2_address0,
        weight_vecs_0_2_ce0,
        weight_vecs_0_2_q0,
        weight_vecs_0_3_address0,
        weight_vecs_0_3_ce0,
        weight_vecs_0_3_q0,
        weight_vecs_1_0_address0,
        weight_vecs_1_0_ce0,
        weight_vecs_1_0_q0,
        weight_vecs_1_1_address0,
        weight_vecs_1_1_ce0,
        weight_vecs_1_1_q0,
        weight_vecs_1_2_address0,
        weight_vecs_1_2_ce0,
        weight_vecs_1_2_q0,
        weight_vecs_1_3_address0,
        weight_vecs_1_3_ce0,
        weight_vecs_1_3_q0,
        weight_vecs_2_0_address0,
        weight_vecs_2_0_ce0,
        weight_vecs_2_0_q0,
        weight_vecs_2_1_address0,
        weight_vecs_2_1_ce0,
        weight_vecs_2_1_q0,
        weight_vecs_2_2_address0,
        weight_vecs_2_2_ce0,
        weight_vecs_2_2_q0,
        weight_vecs_2_3_address0,
        weight_vecs_2_3_ce0,
        weight_vecs_2_3_q0,
        weight_vecs_3_0_address0,
        weight_vecs_3_0_ce0,
        weight_vecs_3_0_q0,
        weight_vecs_3_1_address0,
        weight_vecs_3_1_ce0,
        weight_vecs_3_1_q0,
        weight_vecs_3_2_address0,
        weight_vecs_3_2_ce0,
        weight_vecs_3_2_q0,
        weight_vecs_3_3_address0,
        weight_vecs_3_3_ce0,
        weight_vecs_3_3_q0,
        products_0_0_address0,
        products_0_0_ce0,
        products_0_0_we0,
        products_0_0_d0,
        products_0_1_address0,
        products_0_1_ce0,
        products_0_1_we0,
        products_0_1_d0,
        products_0_2_address0,
        products_0_2_ce0,
        products_0_2_we0,
        products_0_2_d0,
        products_0_3_address0,
        products_0_3_ce0,
        products_0_3_we0,
        products_0_3_d0,
        products_1_0_address0,
        products_1_0_ce0,
        products_1_0_we0,
        products_1_0_d0,
        products_1_1_address0,
        products_1_1_ce0,
        products_1_1_we0,
        products_1_1_d0,
        products_1_2_address0,
        products_1_2_ce0,
        products_1_2_we0,
        products_1_2_d0,
        products_1_3_address0,
        products_1_3_ce0,
        products_1_3_we0,
        products_1_3_d0,
        products_2_0_address0,
        products_2_0_ce0,
        products_2_0_we0,
        products_2_0_d0,
        products_2_1_address0,
        products_2_1_ce0,
        products_2_1_we0,
        products_2_1_d0,
        products_2_2_address0,
        products_2_2_ce0,
        products_2_2_we0,
        products_2_2_d0,
        products_2_3_address0,
        products_2_3_ce0,
        products_2_3_we0,
        products_2_3_d0,
        products_3_0_address0,
        products_3_0_ce0,
        products_3_0_we0,
        products_3_0_d0,
        products_3_1_address0,
        products_3_1_ce0,
        products_3_1_we0,
        products_3_1_d0,
        products_3_2_address0,
        products_3_2_ce0,
        products_3_2_we0,
        products_3_2_d0,
        products_3_3_address0,
        products_3_3_ce0,
        products_3_3_we0,
        products_3_3_d0
);

parameter    ap_ST_fsm_state1 = 3'd1;
parameter    ap_ST_fsm_pp0_stage0 = 3'd2;
parameter    ap_ST_fsm_state11 = 3'd4;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
input   ap_continue;
output   ap_idle;
output   ap_ready;
output  [5:0] ifmap_vec_0_address0;
output   ifmap_vec_0_ce0;
input  [15:0] ifmap_vec_0_q0;
output  [5:0] ifmap_vec_1_address0;
output   ifmap_vec_1_ce0;
input  [15:0] ifmap_vec_1_q0;
output  [5:0] ifmap_vec_2_address0;
output   ifmap_vec_2_ce0;
input  [15:0] ifmap_vec_2_q0;
output  [5:0] ifmap_vec_3_address0;
output   ifmap_vec_3_ce0;
input  [15:0] ifmap_vec_3_q0;
output  [5:0] weight_vecs_0_0_address0;
output   weight_vecs_0_0_ce0;
input  [15:0] weight_vecs_0_0_q0;
output  [5:0] weight_vecs_0_1_address0;
output   weight_vecs_0_1_ce0;
input  [15:0] weight_vecs_0_1_q0;
output  [5:0] weight_vecs_0_2_address0;
output   weight_vecs_0_2_ce0;
input  [15:0] weight_vecs_0_2_q0;
output  [5:0] weight_vecs_0_3_address0;
output   weight_vecs_0_3_ce0;
input  [15:0] weight_vecs_0_3_q0;
output  [5:0] weight_vecs_1_0_address0;
output   weight_vecs_1_0_ce0;
input  [15:0] weight_vecs_1_0_q0;
output  [5:0] weight_vecs_1_1_address0;
output   weight_vecs_1_1_ce0;
input  [15:0] weight_vecs_1_1_q0;
output  [5:0] weight_vecs_1_2_address0;
output   weight_vecs_1_2_ce0;
input  [15:0] weight_vecs_1_2_q0;
output  [5:0] weight_vecs_1_3_address0;
output   weight_vecs_1_3_ce0;
input  [15:0] weight_vecs_1_3_q0;
output  [5:0] weight_vecs_2_0_address0;
output   weight_vecs_2_0_ce0;
input  [15:0] weight_vecs_2_0_q0;
output  [5:0] weight_vecs_2_1_address0;
output   weight_vecs_2_1_ce0;
input  [15:0] weight_vecs_2_1_q0;
output  [5:0] weight_vecs_2_2_address0;
output   weight_vecs_2_2_ce0;
input  [15:0] weight_vecs_2_2_q0;
output  [5:0] weight_vecs_2_3_address0;
output   weight_vecs_2_3_ce0;
input  [15:0] weight_vecs_2_3_q0;
output  [5:0] weight_vecs_3_0_address0;
output   weight_vecs_3_0_ce0;
input  [15:0] weight_vecs_3_0_q0;
output  [5:0] weight_vecs_3_1_address0;
output   weight_vecs_3_1_ce0;
input  [15:0] weight_vecs_3_1_q0;
output  [5:0] weight_vecs_3_2_address0;
output   weight_vecs_3_2_ce0;
input  [15:0] weight_vecs_3_2_q0;
output  [5:0] weight_vecs_3_3_address0;
output   weight_vecs_3_3_ce0;
input  [15:0] weight_vecs_3_3_q0;
output  [5:0] products_0_0_address0;
output   products_0_0_ce0;
output   products_0_0_we0;
output  [15:0] products_0_0_d0;
output  [5:0] products_0_1_address0;
output   products_0_1_ce0;
output   products_0_1_we0;
output  [15:0] products_0_1_d0;
output  [5:0] products_0_2_address0;
output   products_0_2_ce0;
output   products_0_2_we0;
output  [15:0] products_0_2_d0;
output  [5:0] products_0_3_address0;
output   products_0_3_ce0;
output   products_0_3_we0;
output  [15:0] products_0_3_d0;
output  [5:0] products_1_0_address0;
output   products_1_0_ce0;
output   products_1_0_we0;
output  [15:0] products_1_0_d0;
output  [5:0] products_1_1_address0;
output   products_1_1_ce0;
output   products_1_1_we0;
output  [15:0] products_1_1_d0;
output  [5:0] products_1_2_address0;
output   products_1_2_ce0;
output   products_1_2_we0;
output  [15:0] products_1_2_d0;
output  [5:0] products_1_3_address0;
output   products_1_3_ce0;
output   products_1_3_we0;
output  [15:0] products_1_3_d0;
output  [5:0] products_2_0_address0;
output   products_2_0_ce0;
output   products_2_0_we0;
output  [15:0] products_2_0_d0;
output  [5:0] products_2_1_address0;
output   products_2_1_ce0;
output   products_2_1_we0;
output  [15:0] products_2_1_d0;
output  [5:0] products_2_2_address0;
output   products_2_2_ce0;
output   products_2_2_we0;
output  [15:0] products_2_2_d0;
output  [5:0] products_2_3_address0;
output   products_2_3_ce0;
output   products_2_3_we0;
output  [15:0] products_2_3_d0;
output  [5:0] products_3_0_address0;
output   products_3_0_ce0;
output   products_3_0_we0;
output  [15:0] products_3_0_d0;
output  [5:0] products_3_1_address0;
output   products_3_1_ce0;
output   products_3_1_we0;
output  [15:0] products_3_1_d0;
output  [5:0] products_3_2_address0;
output   products_3_2_ce0;
output   products_3_2_we0;
output  [15:0] products_3_2_d0;
output  [5:0] products_3_3_address0;
output   products_3_3_ce0;
output   products_3_3_we0;
output  [15:0] products_3_3_d0;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg ifmap_vec_0_ce0;
reg ifmap_vec_1_ce0;
reg ifmap_vec_2_ce0;
reg ifmap_vec_3_ce0;
reg weight_vecs_0_0_ce0;
reg weight_vecs_0_1_ce0;
reg weight_vecs_0_2_ce0;
reg weight_vecs_0_3_ce0;
reg weight_vecs_1_0_ce0;
reg weight_vecs_1_1_ce0;
reg weight_vecs_1_2_ce0;
reg weight_vecs_1_3_ce0;
reg weight_vecs_2_0_ce0;
reg weight_vecs_2_1_ce0;
reg weight_vecs_2_2_ce0;
reg weight_vecs_2_3_ce0;
reg weight_vecs_3_0_ce0;
reg weight_vecs_3_1_ce0;
reg weight_vecs_3_2_ce0;
reg weight_vecs_3_3_ce0;
reg products_0_0_ce0;
reg products_0_0_we0;
reg products_0_1_ce0;
reg products_0_1_we0;
reg products_0_2_ce0;
reg products_0_2_we0;
reg products_0_3_ce0;
reg products_0_3_we0;
reg products_1_0_ce0;
reg products_1_0_we0;
reg products_1_1_ce0;
reg products_1_1_we0;
reg products_1_2_ce0;
reg products_1_2_we0;
reg products_1_3_ce0;
reg products_1_3_we0;
reg products_2_0_ce0;
reg products_2_0_we0;
reg products_2_1_ce0;
reg products_2_1_we0;
reg products_2_2_ce0;
reg products_2_2_we0;
reg products_2_3_ce0;
reg products_2_3_we0;
reg products_3_0_ce0;
reg products_3_0_we0;
reg products_3_1_ce0;
reg products_3_1_we0;
reg products_3_2_ce0;
reg products_3_2_we0;
reg products_3_3_ce0;
reg products_3_3_we0;

reg    ap_done_reg;
  reg   [2:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg   [5:0] indvar_flatten17_reg_606;
reg   [1:0] ii_reg_617;
reg   [4:0] indvar_flatten_reg_629;
reg   [1:0] jj_reg_640;
reg   [4:0] ic_reg_651;
wire   [5:0] add_ln147_4_fu_726_p2;
wire    ap_CS_fsm_pp0_stage0;
reg    ap_enable_reg_pp0_iter0;
wire    ap_block_state2_pp0_stage0_iter0;
wire    ap_block_state3_pp0_stage0_iter1;
wire    ap_block_state4_pp0_stage0_iter2;
wire    ap_block_state5_pp0_stage0_iter3;
wire    ap_block_state6_pp0_stage0_iter4;
wire    ap_block_state7_pp0_stage0_iter5;
wire    ap_block_state8_pp0_stage0_iter6;
wire    ap_block_state9_pp0_stage0_iter7;
wire    ap_block_state10_pp0_stage0_iter8;
wire    ap_block_pp0_stage0_11001;
wire   [0:0] icmp_ln147_fu_732_p2;
reg   [0:0] icmp_ln147_reg_1098;
reg   [0:0] icmp_ln147_reg_1098_pp0_iter1_reg;
reg   [0:0] icmp_ln147_reg_1098_pp0_iter2_reg;
reg   [0:0] icmp_ln147_reg_1098_pp0_iter3_reg;
reg   [0:0] icmp_ln147_reg_1098_pp0_iter4_reg;
reg   [0:0] icmp_ln147_reg_1098_pp0_iter5_reg;
reg   [0:0] icmp_ln147_reg_1098_pp0_iter6_reg;
reg   [0:0] icmp_ln147_reg_1098_pp0_iter7_reg;
wire   [1:0] add_ln147_fu_738_p2;
reg   [1:0] add_ln147_reg_1102;
wire   [0:0] icmp_ln148_fu_744_p2;
reg   [0:0] icmp_ln148_reg_1108;
wire   [1:0] select_ln147_15_fu_750_p3;
reg   [1:0] select_ln147_15_reg_1117;
wire   [4:0] select_ln148_12_fu_764_p3;
wire   [1:0] select_ln148_10_fu_901_p3;
reg   [1:0] select_ln148_10_reg_1129;
reg    ap_enable_reg_pp0_iter1;
wire   [3:0] select_ln148_11_fu_929_p3;
reg   [3:0] select_ln148_11_reg_1134;
reg   [3:0] select_ln148_11_reg_1134_pp0_iter2_reg;
reg   [3:0] select_ln148_11_reg_1134_pp0_iter3_reg;
reg   [3:0] select_ln148_11_reg_1134_pp0_iter4_reg;
reg   [3:0] select_ln148_11_reg_1134_pp0_iter5_reg;
reg   [3:0] select_ln148_11_reg_1134_pp0_iter6_reg;
reg   [3:0] select_ln148_11_reg_1134_pp0_iter7_reg;
wire   [3:0] trunc_ln149_fu_937_p1;
reg   [3:0] trunc_ln149_reg_1142;
reg   [3:0] trunc_ln149_reg_1142_pp0_iter2_reg;
reg   [3:0] trunc_ln149_reg_1142_pp0_iter3_reg;
reg   [3:0] trunc_ln149_reg_1142_pp0_iter4_reg;
reg   [3:0] trunc_ln149_reg_1142_pp0_iter5_reg;
reg   [3:0] trunc_ln149_reg_1142_pp0_iter6_reg;
reg   [3:0] trunc_ln149_reg_1142_pp0_iter7_reg;
wire   [1:0] newIndex_fu_941_p4;
reg   [1:0] newIndex_reg_1149;
reg   [1:0] newIndex_reg_1149_pp0_iter2_reg;
reg   [1:0] newIndex_reg_1149_pp0_iter3_reg;
reg   [1:0] newIndex_reg_1149_pp0_iter4_reg;
reg   [1:0] newIndex_reg_1149_pp0_iter5_reg;
reg   [1:0] newIndex_reg_1149_pp0_iter6_reg;
reg   [1:0] newIndex_reg_1149_pp0_iter7_reg;
wire   [4:0] add_ln149_fu_983_p2;
reg   [15:0] ifmap_vec_0_load_reg_1259;
reg   [15:0] weight_vecs_0_0_load_reg_1267;
reg   [15:0] weight_vecs_1_0_load_reg_1272;
reg   [15:0] weight_vecs_2_0_load_reg_1277;
reg   [15:0] weight_vecs_3_0_load_reg_1282;
reg   [15:0] ifmap_vec_1_load_reg_1287;
reg   [15:0] weight_vecs_0_1_load_reg_1295;
reg   [15:0] weight_vecs_1_1_load_reg_1300;
reg   [15:0] weight_vecs_2_1_load_reg_1305;
reg   [15:0] weight_vecs_3_1_load_reg_1310;
reg   [15:0] ifmap_vec_2_load_reg_1315;
reg   [15:0] weight_vecs_0_2_load_reg_1323;
reg   [15:0] weight_vecs_1_2_load_reg_1328;
reg   [15:0] weight_vecs_2_2_load_reg_1333;
reg   [15:0] weight_vecs_3_2_load_reg_1338;
reg   [15:0] ifmap_vec_3_load_reg_1343;
reg   [15:0] weight_vecs_0_3_load_reg_1351;
reg   [15:0] weight_vecs_1_3_load_reg_1356;
reg   [15:0] weight_vecs_2_3_load_reg_1361;
reg   [15:0] weight_vecs_3_3_load_reg_1366;
wire   [15:0] grp_fu_662_p2;
reg   [15:0] mul_reg_1371;
wire   [15:0] grp_fu_666_p2;
reg   [15:0] mul_1_reg_1376;
wire   [15:0] grp_fu_670_p2;
reg   [15:0] mul_2_reg_1381;
wire   [15:0] grp_fu_674_p2;
reg   [15:0] mul_3_reg_1386;
wire   [15:0] grp_fu_678_p2;
reg   [15:0] mul27_1_reg_1391;
wire   [15:0] grp_fu_682_p2;
reg   [15:0] mul27_1_1_reg_1396;
wire   [15:0] grp_fu_686_p2;
reg   [15:0] mul27_1_2_reg_1401;
wire   [15:0] grp_fu_690_p2;
reg   [15:0] mul27_1_3_reg_1406;
wire   [15:0] grp_fu_694_p2;
reg   [15:0] mul27_2_reg_1411;
wire   [15:0] grp_fu_698_p2;
reg   [15:0] mul27_2_1_reg_1416;
wire   [15:0] grp_fu_702_p2;
reg   [15:0] mul27_2_2_reg_1421;
wire   [15:0] grp_fu_706_p2;
reg   [15:0] mul27_2_3_reg_1426;
wire   [15:0] grp_fu_710_p2;
reg   [15:0] mul27_3_reg_1431;
wire   [15:0] grp_fu_714_p2;
reg   [15:0] mul27_3_1_reg_1436;
wire   [15:0] grp_fu_718_p2;
reg   [15:0] mul27_3_2_reg_1441;
wire   [15:0] grp_fu_722_p2;
reg   [15:0] mul27_3_3_reg_1446;
reg    ap_block_state1;
wire    ap_block_pp0_stage0_subdone;
reg    ap_condition_pp0_flush_enable;
reg    ap_enable_reg_pp0_iter2;
reg    ap_condition_pp0_exit_iter1_state3;
reg    ap_enable_reg_pp0_iter3;
reg    ap_enable_reg_pp0_iter4;
reg    ap_enable_reg_pp0_iter5;
reg    ap_enable_reg_pp0_iter6;
reg    ap_enable_reg_pp0_iter7;
reg    ap_enable_reg_pp0_iter8;
reg   [1:0] ap_phi_mux_ii_phi_fu_621_p4;
wire    ap_block_pp0_stage0;
reg   [1:0] ap_phi_mux_jj_phi_fu_644_p4;
wire   [63:0] tmp_115_fu_959_p1;
wire   [63:0] zext_ln153_fu_995_p1;
wire   [63:0] zext_ln153_6_fu_1025_p1;
wire   [63:0] zext_ln153_7_fu_1055_p1;
wire   [63:0] zext_ln153_8_fu_1085_p1;
wire   [4:0] add_ln148_4_fu_758_p2;
wire   [3:0] shl_ln_fu_776_p3;
wire   [3:0] zext_ln150_fu_772_p1;
wire   [3:0] sub_ln150_fu_784_p2;
wire   [3:0] zext_ln150_4_fu_790_p1;
wire   [3:0] tmp_fu_817_p3;
wire   [4:0] tmp_cast_fu_824_p1;
wire   [4:0] select_ln147_18_cast_fu_814_p1;
wire   [4:0] empty_111_fu_828_p2;
wire   [3:0] shl_ln150_mid1_fu_841_p3;
wire   [3:0] zext_ln150_8_fu_838_p1;
wire   [3:0] sub_ln150_4_fu_848_p2;
wire   [3:0] add_ln150_fu_794_p2;
wire   [0:0] tmp_57_fu_868_p3;
wire   [0:0] xor_ln149_fu_876_p2;
wire   [1:0] select_ln147_fu_800_p3;
wire   [0:0] or_ln147_fu_882_p2;
wire   [4:0] select_ln147_14_fu_807_p3;
wire   [1:0] add_ln148_fu_887_p2;
wire   [5:0] sext_ln150_fu_834_p1;
wire   [5:0] select_ln148_13_cast_fu_909_p1;
wire   [3:0] select_ln147_16_fu_854_p3;
wire   [3:0] zext_ln150_9_fu_919_p1;
wire   [3:0] select_ln147_17_fu_861_p3;
wire   [3:0] add_ln150_4_fu_923_p2;
wire   [4:0] select_ln148_fu_893_p3;
wire   [5:0] empty_112_fu_913_p2;
wire   [7:0] tmp_58_fu_951_p3;
wire   [5:0] lshr_ln_fu_989_p3;
wire   [3:0] or_ln150_fu_1003_p2;
wire   [1:0] tmp_s_fu_1008_p4;
wire   [5:0] lshr_ln153_6_fu_1018_p3;
wire   [3:0] or_ln150_3_fu_1033_p2;
wire   [1:0] tmp_36_fu_1038_p4;
wire   [5:0] lshr_ln153_7_fu_1048_p3;
wire   [3:0] or_ln150_4_fu_1063_p2;
wire   [1:0] tmp_37_fu_1068_p4;
wire   [5:0] lshr_ln153_8_fu_1078_p3;
wire    ap_CS_fsm_state11;
reg   [2:0] ap_NS_fsm;
reg    ap_idle_pp0;
wire    ap_enable_pp0;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_done_reg = 1'b0;
#0 ap_CS_fsm = 3'd1;
#0 ap_enable_reg_pp0_iter0 = 1'b0;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter2 = 1'b0;
#0 ap_enable_reg_pp0_iter3 = 1'b0;
#0 ap_enable_reg_pp0_iter4 = 1'b0;
#0 ap_enable_reg_pp0_iter5 = 1'b0;
#0 ap_enable_reg_pp0_iter6 = 1'b0;
#0 ap_enable_reg_pp0_iter7 = 1'b0;
#0 ap_enable_reg_pp0_iter8 = 1'b0;
end

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U476(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_0_load_reg_1259),
    .din1(weight_vecs_0_0_load_reg_1267),
    .dout(grp_fu_662_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U477(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_0_load_reg_1259),
    .din1(weight_vecs_1_0_load_reg_1272),
    .dout(grp_fu_666_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U478(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_0_load_reg_1259),
    .din1(weight_vecs_2_0_load_reg_1277),
    .dout(grp_fu_670_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U479(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_0_load_reg_1259),
    .din1(weight_vecs_3_0_load_reg_1282),
    .dout(grp_fu_674_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U480(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_1_load_reg_1287),
    .din1(weight_vecs_0_1_load_reg_1295),
    .dout(grp_fu_678_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U481(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_1_load_reg_1287),
    .din1(weight_vecs_1_1_load_reg_1300),
    .dout(grp_fu_682_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U482(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_1_load_reg_1287),
    .din1(weight_vecs_2_1_load_reg_1305),
    .dout(grp_fu_686_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U483(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_1_load_reg_1287),
    .din1(weight_vecs_3_1_load_reg_1310),
    .dout(grp_fu_690_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U484(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_2_load_reg_1315),
    .din1(weight_vecs_0_2_load_reg_1323),
    .dout(grp_fu_694_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U485(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_2_load_reg_1315),
    .din1(weight_vecs_1_2_load_reg_1328),
    .dout(grp_fu_698_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U486(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_2_load_reg_1315),
    .din1(weight_vecs_2_2_load_reg_1333),
    .dout(grp_fu_702_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U487(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_2_load_reg_1315),
    .din1(weight_vecs_3_2_load_reg_1338),
    .dout(grp_fu_706_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U488(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_3_load_reg_1343),
    .din1(weight_vecs_0_3_load_reg_1351),
    .dout(grp_fu_710_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U489(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_3_load_reg_1343),
    .din1(weight_vecs_1_3_load_reg_1356),
    .dout(grp_fu_714_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U490(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_3_load_reg_1343),
    .din1(weight_vecs_2_3_load_reg_1361),
    .dout(grp_fu_718_p2)
);

td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1 #(
    .ID( 1 ),
    .NUM_STAGE( 5 ),
    .din0_WIDTH( 16 ),
    .din1_WIDTH( 16 ),
    .dout_WIDTH( 16 ))
hmul_16ns_16ns_16_5_max_dsp_1_U491(
    .clk(ap_clk),
    .reset(ap_rst),
    .ce(1'b1),
    .din0(ifmap_vec_3_load_reg_1343),
    .din1(weight_vecs_3_3_load_reg_1366),
    .dout(grp_fu_722_p2)
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
        end else if ((1'b1 == ap_CS_fsm_state11)) begin
            ap_done_reg <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter0 <= 1'b0;
    end else begin
        if ((1'b1 == ap_condition_pp0_flush_enable)) begin
            ap_enable_reg_pp0_iter0 <= 1'b0;
        end else if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
            ap_enable_reg_pp0_iter0 <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter1 <= ap_enable_reg_pp0_iter0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter2 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            if ((1'b1 == ap_condition_pp0_exit_iter1_state3)) begin
                ap_enable_reg_pp0_iter2 <= ap_enable_reg_pp0_iter0;
            end else if ((1'b1 == 1'b1)) begin
                ap_enable_reg_pp0_iter2 <= ap_enable_reg_pp0_iter1;
            end
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter3 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter3 <= ap_enable_reg_pp0_iter2;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter4 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter4 <= ap_enable_reg_pp0_iter3;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter5 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter5 <= ap_enable_reg_pp0_iter4;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter6 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter6 <= ap_enable_reg_pp0_iter5;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter7 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter7 <= ap_enable_reg_pp0_iter6;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter8 <= 1'b0;
    end else begin
        if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
            ap_enable_reg_pp0_iter8 <= ap_enable_reg_pp0_iter7;
        end else if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
            ap_enable_reg_pp0_iter8 <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (icmp_ln147_reg_1098 == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ic_reg_651 <= add_ln149_fu_983_p2;
    end else if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        ic_reg_651 <= 5'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (icmp_ln147_reg_1098 == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ii_reg_617 <= select_ln147_15_reg_1117;
    end else if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        ii_reg_617 <= 2'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln147_fu_732_p2 == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        indvar_flatten17_reg_606 <= add_ln147_4_fu_726_p2;
    end else if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        indvar_flatten17_reg_606 <= 6'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln147_fu_732_p2 == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        indvar_flatten_reg_629 <= select_ln148_12_fu_764_p3;
    end else if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        indvar_flatten_reg_629 <= 5'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((ap_enable_reg_pp0_iter2 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter1_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        jj_reg_640 <= select_ln148_10_reg_1129;
    end else if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
        jj_reg_640 <= 2'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln147_fu_732_p2 == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        add_ln147_reg_1102 <= add_ln147_fu_738_p2;
        icmp_ln148_reg_1108 <= icmp_ln148_fu_744_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        icmp_ln147_reg_1098 <= icmp_ln147_fu_732_p2;
        icmp_ln147_reg_1098_pp0_iter1_reg <= icmp_ln147_reg_1098;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b0 == ap_block_pp0_stage0_11001)) begin
        icmp_ln147_reg_1098_pp0_iter2_reg <= icmp_ln147_reg_1098_pp0_iter1_reg;
        icmp_ln147_reg_1098_pp0_iter3_reg <= icmp_ln147_reg_1098_pp0_iter2_reg;
        icmp_ln147_reg_1098_pp0_iter4_reg <= icmp_ln147_reg_1098_pp0_iter3_reg;
        icmp_ln147_reg_1098_pp0_iter5_reg <= icmp_ln147_reg_1098_pp0_iter4_reg;
        icmp_ln147_reg_1098_pp0_iter6_reg <= icmp_ln147_reg_1098_pp0_iter5_reg;
        icmp_ln147_reg_1098_pp0_iter7_reg <= icmp_ln147_reg_1098_pp0_iter6_reg;
        newIndex_reg_1149_pp0_iter2_reg <= newIndex_reg_1149;
        newIndex_reg_1149_pp0_iter3_reg <= newIndex_reg_1149_pp0_iter2_reg;
        newIndex_reg_1149_pp0_iter4_reg <= newIndex_reg_1149_pp0_iter3_reg;
        newIndex_reg_1149_pp0_iter5_reg <= newIndex_reg_1149_pp0_iter4_reg;
        newIndex_reg_1149_pp0_iter6_reg <= newIndex_reg_1149_pp0_iter5_reg;
        newIndex_reg_1149_pp0_iter7_reg <= newIndex_reg_1149_pp0_iter6_reg;
        select_ln148_11_reg_1134_pp0_iter2_reg <= select_ln148_11_reg_1134;
        select_ln148_11_reg_1134_pp0_iter3_reg <= select_ln148_11_reg_1134_pp0_iter2_reg;
        select_ln148_11_reg_1134_pp0_iter4_reg <= select_ln148_11_reg_1134_pp0_iter3_reg;
        select_ln148_11_reg_1134_pp0_iter5_reg <= select_ln148_11_reg_1134_pp0_iter4_reg;
        select_ln148_11_reg_1134_pp0_iter6_reg <= select_ln148_11_reg_1134_pp0_iter5_reg;
        select_ln148_11_reg_1134_pp0_iter7_reg <= select_ln148_11_reg_1134_pp0_iter6_reg;
        trunc_ln149_reg_1142_pp0_iter2_reg <= trunc_ln149_reg_1142;
        trunc_ln149_reg_1142_pp0_iter3_reg <= trunc_ln149_reg_1142_pp0_iter2_reg;
        trunc_ln149_reg_1142_pp0_iter4_reg <= trunc_ln149_reg_1142_pp0_iter3_reg;
        trunc_ln149_reg_1142_pp0_iter5_reg <= trunc_ln149_reg_1142_pp0_iter4_reg;
        trunc_ln149_reg_1142_pp0_iter6_reg <= trunc_ln149_reg_1142_pp0_iter5_reg;
        trunc_ln149_reg_1142_pp0_iter7_reg <= trunc_ln149_reg_1142_pp0_iter6_reg;
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln147_reg_1098_pp0_iter1_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        ifmap_vec_0_load_reg_1259 <= ifmap_vec_0_q0;
        ifmap_vec_1_load_reg_1287 <= ifmap_vec_1_q0;
        ifmap_vec_2_load_reg_1315 <= ifmap_vec_2_q0;
        ifmap_vec_3_load_reg_1343 <= ifmap_vec_3_q0;
        weight_vecs_0_0_load_reg_1267 <= weight_vecs_0_0_q0;
        weight_vecs_0_1_load_reg_1295 <= weight_vecs_0_1_q0;
        weight_vecs_0_2_load_reg_1323 <= weight_vecs_0_2_q0;
        weight_vecs_0_3_load_reg_1351 <= weight_vecs_0_3_q0;
        weight_vecs_1_0_load_reg_1272 <= weight_vecs_1_0_q0;
        weight_vecs_1_1_load_reg_1300 <= weight_vecs_1_1_q0;
        weight_vecs_1_2_load_reg_1328 <= weight_vecs_1_2_q0;
        weight_vecs_1_3_load_reg_1356 <= weight_vecs_1_3_q0;
        weight_vecs_2_0_load_reg_1277 <= weight_vecs_2_0_q0;
        weight_vecs_2_1_load_reg_1305 <= weight_vecs_2_1_q0;
        weight_vecs_2_2_load_reg_1333 <= weight_vecs_2_2_q0;
        weight_vecs_2_3_load_reg_1361 <= weight_vecs_2_3_q0;
        weight_vecs_3_0_load_reg_1282 <= weight_vecs_3_0_q0;
        weight_vecs_3_1_load_reg_1310 <= weight_vecs_3_1_q0;
        weight_vecs_3_2_load_reg_1338 <= weight_vecs_3_2_q0;
        weight_vecs_3_3_load_reg_1366 <= weight_vecs_3_3_q0;
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln147_reg_1098_pp0_iter6_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        mul27_1_1_reg_1396 <= grp_fu_682_p2;
        mul27_1_2_reg_1401 <= grp_fu_686_p2;
        mul27_1_3_reg_1406 <= grp_fu_690_p2;
        mul27_1_reg_1391 <= grp_fu_678_p2;
        mul27_2_1_reg_1416 <= grp_fu_698_p2;
        mul27_2_2_reg_1421 <= grp_fu_702_p2;
        mul27_2_3_reg_1426 <= grp_fu_706_p2;
        mul27_2_reg_1411 <= grp_fu_694_p2;
        mul27_3_1_reg_1436 <= grp_fu_714_p2;
        mul27_3_2_reg_1441 <= grp_fu_718_p2;
        mul27_3_3_reg_1446 <= grp_fu_722_p2;
        mul27_3_reg_1431 <= grp_fu_710_p2;
        mul_1_reg_1376 <= grp_fu_666_p2;
        mul_2_reg_1381 <= grp_fu_670_p2;
        mul_3_reg_1386 <= grp_fu_674_p2;
        mul_reg_1371 <= grp_fu_662_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln147_reg_1098 == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        newIndex_reg_1149 <= {{select_ln148_fu_893_p3[3:2]}};
        select_ln148_11_reg_1134 <= select_ln148_11_fu_929_p3;
        trunc_ln149_reg_1142 <= trunc_ln149_fu_937_p1;
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln147_fu_732_p2 == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        select_ln147_15_reg_1117 <= select_ln147_15_fu_750_p3;
    end
end

always @ (posedge ap_clk) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (icmp_ln147_reg_1098 == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        select_ln148_10_reg_1129 <= select_ln148_10_fu_901_p3;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (ap_enable_reg_pp0_iter0 == 1'b0))) begin
        ap_condition_pp0_exit_iter1_state3 = 1'b1;
    end else begin
        ap_condition_pp0_exit_iter1_state3 = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln147_fu_732_p2 == 1'd1) & (1'b0 == ap_block_pp0_stage0_subdone) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_condition_pp0_flush_enable = 1'b1;
    end else begin
        ap_condition_pp0_flush_enable = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state11)) begin
        ap_done = 1'b1;
    end else begin
        ap_done = ap_done_reg;
    end
end

always @ (*) begin
    if (((ap_start == 1'b0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b0) & (ap_enable_reg_pp0_iter7 == 1'b0) & (ap_enable_reg_pp0_iter6 == 1'b0) & (ap_enable_reg_pp0_iter5 == 1'b0) & (ap_enable_reg_pp0_iter4 == 1'b0) & (ap_enable_reg_pp0_iter3 == 1'b0) & (ap_enable_reg_pp0_iter2 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (icmp_ln147_reg_1098 == 1'd0) & (1'b0 == ap_block_pp0_stage0) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ap_phi_mux_ii_phi_fu_621_p4 = select_ln147_15_reg_1117;
    end else begin
        ap_phi_mux_ii_phi_fu_621_p4 = ii_reg_617;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter2 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter1_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0))) begin
        ap_phi_mux_jj_phi_fu_644_p4 = select_ln148_10_reg_1129;
    end else begin
        ap_phi_mux_jj_phi_fu_644_p4 = jj_reg_640;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state11)) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ifmap_vec_0_ce0 = 1'b1;
    end else begin
        ifmap_vec_0_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ifmap_vec_1_ce0 = 1'b1;
    end else begin
        ifmap_vec_1_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ifmap_vec_2_ce0 = 1'b1;
    end else begin
        ifmap_vec_2_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        ifmap_vec_3_ce0 = 1'b1;
    end else begin
        ifmap_vec_3_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_0_0_ce0 = 1'b1;
    end else begin
        products_0_0_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_0_0_we0 = 1'b1;
    end else begin
        products_0_0_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_0_1_ce0 = 1'b1;
    end else begin
        products_0_1_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_0_1_we0 = 1'b1;
    end else begin
        products_0_1_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_0_2_ce0 = 1'b1;
    end else begin
        products_0_2_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_0_2_we0 = 1'b1;
    end else begin
        products_0_2_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_0_3_ce0 = 1'b1;
    end else begin
        products_0_3_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_0_3_we0 = 1'b1;
    end else begin
        products_0_3_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_1_0_ce0 = 1'b1;
    end else begin
        products_1_0_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_1_0_we0 = 1'b1;
    end else begin
        products_1_0_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_1_1_ce0 = 1'b1;
    end else begin
        products_1_1_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_1_1_we0 = 1'b1;
    end else begin
        products_1_1_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_1_2_ce0 = 1'b1;
    end else begin
        products_1_2_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_1_2_we0 = 1'b1;
    end else begin
        products_1_2_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_1_3_ce0 = 1'b1;
    end else begin
        products_1_3_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_1_3_we0 = 1'b1;
    end else begin
        products_1_3_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_2_0_ce0 = 1'b1;
    end else begin
        products_2_0_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_2_0_we0 = 1'b1;
    end else begin
        products_2_0_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_2_1_ce0 = 1'b1;
    end else begin
        products_2_1_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_2_1_we0 = 1'b1;
    end else begin
        products_2_1_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_2_2_ce0 = 1'b1;
    end else begin
        products_2_2_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_2_2_we0 = 1'b1;
    end else begin
        products_2_2_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_2_3_ce0 = 1'b1;
    end else begin
        products_2_3_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_2_3_we0 = 1'b1;
    end else begin
        products_2_3_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_3_0_ce0 = 1'b1;
    end else begin
        products_3_0_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_3_0_we0 = 1'b1;
    end else begin
        products_3_0_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_3_1_ce0 = 1'b1;
    end else begin
        products_3_1_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_3_1_we0 = 1'b1;
    end else begin
        products_3_1_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_3_2_ce0 = 1'b1;
    end else begin
        products_3_2_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_3_2_we0 = 1'b1;
    end else begin
        products_3_2_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_3_3_ce0 = 1'b1;
    end else begin
        products_3_3_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter8 == 1'b1) & (icmp_ln147_reg_1098_pp0_iter7_reg == 1'd0) & (1'b0 == ap_block_pp0_stage0_11001))) begin
        products_3_3_we0 = 1'b1;
    end else begin
        products_3_3_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_0_0_ce0 = 1'b1;
    end else begin
        weight_vecs_0_0_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_0_1_ce0 = 1'b1;
    end else begin
        weight_vecs_0_1_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_0_2_ce0 = 1'b1;
    end else begin
        weight_vecs_0_2_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_0_3_ce0 = 1'b1;
    end else begin
        weight_vecs_0_3_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_1_0_ce0 = 1'b1;
    end else begin
        weight_vecs_1_0_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_1_1_ce0 = 1'b1;
    end else begin
        weight_vecs_1_1_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_1_2_ce0 = 1'b1;
    end else begin
        weight_vecs_1_2_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_1_3_ce0 = 1'b1;
    end else begin
        weight_vecs_1_3_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_2_0_ce0 = 1'b1;
    end else begin
        weight_vecs_2_0_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_2_1_ce0 = 1'b1;
    end else begin
        weight_vecs_2_1_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_2_2_ce0 = 1'b1;
    end else begin
        weight_vecs_2_2_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_2_3_ce0 = 1'b1;
    end else begin
        weight_vecs_2_3_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_3_0_ce0 = 1'b1;
    end else begin
        weight_vecs_3_0_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_3_1_ce0 = 1'b1;
    end else begin
        weight_vecs_3_1_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_3_2_ce0 = 1'b1;
    end else begin
        weight_vecs_3_2_ce0 = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        weight_vecs_3_3_ce0 = 1'b1;
    end else begin
        weight_vecs_3_3_ce0 = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if ((~((ap_start == 1'b0) | (ap_done_reg == 1'b1)) & (1'b1 == ap_CS_fsm_state1))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_pp0_stage0 : begin
            if ((~((ap_enable_reg_pp0_iter2 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_subdone) & (ap_enable_reg_pp0_iter0 == 1'b0) & (1'b1 == ap_CS_fsm_pp0_stage0)) & ~((ap_enable_reg_pp0_iter8 == 1'b1) & (ap_enable_reg_pp0_iter7 == 1'b0) & (1'b0 == ap_block_pp0_stage0_subdone)))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else if ((((ap_enable_reg_pp0_iter8 == 1'b1) & (ap_enable_reg_pp0_iter7 == 1'b0) & (1'b0 == ap_block_pp0_stage0_subdone)) | ((ap_enable_reg_pp0_iter2 == 1'b0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b0 == ap_block_pp0_stage0_subdone) & (ap_enable_reg_pp0_iter0 == 1'b0) & (1'b1 == ap_CS_fsm_pp0_stage0)))) begin
                ap_NS_fsm = ap_ST_fsm_state11;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end
        end
        ap_ST_fsm_state11 : begin
            ap_NS_fsm = ap_ST_fsm_state1;
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign add_ln147_4_fu_726_p2 = (indvar_flatten17_reg_606 + 6'd1);

assign add_ln147_fu_738_p2 = (ap_phi_mux_ii_phi_fu_621_p4 + 2'd1);

assign add_ln148_4_fu_758_p2 = (indvar_flatten_reg_629 + 5'd1);

assign add_ln148_fu_887_p2 = (select_ln147_fu_800_p3 + 2'd1);

assign add_ln149_fu_983_p2 = (select_ln148_fu_893_p3 + 5'd4);

assign add_ln150_4_fu_923_p2 = (select_ln147_16_fu_854_p3 + zext_ln150_9_fu_919_p1);

assign add_ln150_fu_794_p2 = (sub_ln150_fu_784_p2 + zext_ln150_4_fu_790_p1);

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state11 = ap_CS_fsm[32'd2];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_subdone = ~(1'b1 == 1'b1);

always @ (*) begin
    ap_block_state1 = ((ap_start == 1'b0) | (ap_done_reg == 1'b1));
end

assign ap_block_state10_pp0_stage0_iter8 = ~(1'b1 == 1'b1);

assign ap_block_state2_pp0_stage0_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state3_pp0_stage0_iter1 = ~(1'b1 == 1'b1);

assign ap_block_state4_pp0_stage0_iter2 = ~(1'b1 == 1'b1);

assign ap_block_state5_pp0_stage0_iter3 = ~(1'b1 == 1'b1);

assign ap_block_state6_pp0_stage0_iter4 = ~(1'b1 == 1'b1);

assign ap_block_state7_pp0_stage0_iter5 = ~(1'b1 == 1'b1);

assign ap_block_state8_pp0_stage0_iter6 = ~(1'b1 == 1'b1);

assign ap_block_state9_pp0_stage0_iter7 = ~(1'b1 == 1'b1);

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign empty_111_fu_828_p2 = (tmp_cast_fu_824_p1 - select_ln147_18_cast_fu_814_p1);

assign empty_112_fu_913_p2 = ((sext_ln150_fu_834_p1) + (select_ln148_13_cast_fu_909_p1));

assign icmp_ln147_fu_732_p2 = ((indvar_flatten17_reg_606 == 6'd36) ? 1'b1 : 1'b0);

assign icmp_ln148_fu_744_p2 = ((indvar_flatten_reg_629 == 5'd12) ? 1'b1 : 1'b0);

assign ifmap_vec_0_address0 = tmp_115_fu_959_p1;

assign ifmap_vec_1_address0 = tmp_115_fu_959_p1;

assign ifmap_vec_2_address0 = tmp_115_fu_959_p1;

assign ifmap_vec_3_address0 = tmp_115_fu_959_p1;

assign lshr_ln153_6_fu_1018_p3 = {{select_ln148_11_reg_1134_pp0_iter7_reg}, {tmp_s_fu_1008_p4}};

assign lshr_ln153_7_fu_1048_p3 = {{select_ln148_11_reg_1134_pp0_iter7_reg}, {tmp_36_fu_1038_p4}};

assign lshr_ln153_8_fu_1078_p3 = {{select_ln148_11_reg_1134_pp0_iter7_reg}, {tmp_37_fu_1068_p4}};

assign lshr_ln_fu_989_p3 = {{select_ln148_11_reg_1134_pp0_iter7_reg}, {newIndex_reg_1149_pp0_iter7_reg}};

assign newIndex_fu_941_p4 = {{select_ln148_fu_893_p3[3:2]}};

assign or_ln147_fu_882_p2 = (xor_ln149_fu_876_p2 | icmp_ln148_reg_1108);

assign or_ln150_3_fu_1033_p2 = (trunc_ln149_reg_1142_pp0_iter7_reg | 4'd2);

assign or_ln150_4_fu_1063_p2 = (trunc_ln149_reg_1142_pp0_iter7_reg | 4'd3);

assign or_ln150_fu_1003_p2 = (trunc_ln149_reg_1142_pp0_iter7_reg | 4'd1);

assign products_0_0_address0 = zext_ln153_fu_995_p1;

assign products_0_0_d0 = mul_reg_1371;

assign products_0_1_address0 = zext_ln153_6_fu_1025_p1;

assign products_0_1_d0 = mul27_1_reg_1391;

assign products_0_2_address0 = zext_ln153_7_fu_1055_p1;

assign products_0_2_d0 = mul27_2_reg_1411;

assign products_0_3_address0 = zext_ln153_8_fu_1085_p1;

assign products_0_3_d0 = mul27_3_reg_1431;

assign products_1_0_address0 = zext_ln153_fu_995_p1;

assign products_1_0_d0 = mul_1_reg_1376;

assign products_1_1_address0 = zext_ln153_6_fu_1025_p1;

assign products_1_1_d0 = mul27_1_1_reg_1396;

assign products_1_2_address0 = zext_ln153_7_fu_1055_p1;

assign products_1_2_d0 = mul27_2_1_reg_1416;

assign products_1_3_address0 = zext_ln153_8_fu_1085_p1;

assign products_1_3_d0 = mul27_3_1_reg_1436;

assign products_2_0_address0 = zext_ln153_fu_995_p1;

assign products_2_0_d0 = mul_2_reg_1381;

assign products_2_1_address0 = zext_ln153_6_fu_1025_p1;

assign products_2_1_d0 = mul27_1_2_reg_1401;

assign products_2_2_address0 = zext_ln153_7_fu_1055_p1;

assign products_2_2_d0 = mul27_2_2_reg_1421;

assign products_2_3_address0 = zext_ln153_8_fu_1085_p1;

assign products_2_3_d0 = mul27_3_2_reg_1441;

assign products_3_0_address0 = zext_ln153_fu_995_p1;

assign products_3_0_d0 = mul_3_reg_1386;

assign products_3_1_address0 = zext_ln153_6_fu_1025_p1;

assign products_3_1_d0 = mul27_1_3_reg_1406;

assign products_3_2_address0 = zext_ln153_7_fu_1055_p1;

assign products_3_2_d0 = mul27_2_3_reg_1426;

assign products_3_3_address0 = zext_ln153_8_fu_1085_p1;

assign products_3_3_d0 = mul27_3_3_reg_1446;

assign select_ln147_14_fu_807_p3 = ((icmp_ln148_reg_1108[0:0] == 1'b1) ? 5'd0 : ic_reg_651);

assign select_ln147_15_fu_750_p3 = ((icmp_ln148_fu_744_p2[0:0] == 1'b1) ? add_ln147_fu_738_p2 : ap_phi_mux_ii_phi_fu_621_p4);

assign select_ln147_16_fu_854_p3 = ((icmp_ln148_reg_1108[0:0] == 1'b1) ? sub_ln150_4_fu_848_p2 : sub_ln150_fu_784_p2);

assign select_ln147_17_fu_861_p3 = ((icmp_ln148_reg_1108[0:0] == 1'b1) ? sub_ln150_4_fu_848_p2 : add_ln150_fu_794_p2);

assign select_ln147_18_cast_fu_814_p1 = select_ln147_15_reg_1117;

assign select_ln147_fu_800_p3 = ((icmp_ln148_reg_1108[0:0] == 1'b1) ? 2'd0 : ap_phi_mux_jj_phi_fu_644_p4);

assign select_ln148_10_fu_901_p3 = ((or_ln147_fu_882_p2[0:0] == 1'b1) ? select_ln147_fu_800_p3 : add_ln148_fu_887_p2);

assign select_ln148_11_fu_929_p3 = ((or_ln147_fu_882_p2[0:0] == 1'b1) ? select_ln147_17_fu_861_p3 : add_ln150_4_fu_923_p2);

assign select_ln148_12_fu_764_p3 = ((icmp_ln148_fu_744_p2[0:0] == 1'b1) ? 5'd1 : add_ln148_4_fu_758_p2);

assign select_ln148_13_cast_fu_909_p1 = select_ln148_10_fu_901_p3;

assign select_ln148_fu_893_p3 = ((or_ln147_fu_882_p2[0:0] == 1'b1) ? select_ln147_14_fu_807_p3 : 5'd0);

assign sext_ln150_fu_834_p1 = (empty_111_fu_828_p2);

assign shl_ln150_mid1_fu_841_p3 = {{add_ln147_reg_1102}, {2'd0}};

assign shl_ln_fu_776_p3 = {{ii_reg_617}, {2'd0}};

assign sub_ln150_4_fu_848_p2 = (shl_ln150_mid1_fu_841_p3 - zext_ln150_8_fu_838_p1);

assign sub_ln150_fu_784_p2 = (shl_ln_fu_776_p3 - zext_ln150_fu_772_p1);

assign tmp_115_fu_959_p1 = (tmp_58_fu_951_p3);

assign tmp_36_fu_1038_p4 = {{or_ln150_3_fu_1033_p2[3:2]}};

assign tmp_37_fu_1068_p4 = {{or_ln150_4_fu_1063_p2[3:2]}};

assign tmp_57_fu_868_p3 = ic_reg_651[32'd4];

assign tmp_58_fu_951_p3 = {{empty_112_fu_913_p2}, {newIndex_fu_941_p4}};

assign tmp_cast_fu_824_p1 = tmp_fu_817_p3;

assign tmp_fu_817_p3 = {{select_ln147_15_reg_1117}, {2'd0}};

assign tmp_s_fu_1008_p4 = {{or_ln150_fu_1003_p2[3:2]}};

assign trunc_ln149_fu_937_p1 = select_ln148_fu_893_p3[3:0];

assign weight_vecs_0_0_address0 = tmp_115_fu_959_p1;

assign weight_vecs_0_1_address0 = tmp_115_fu_959_p1;

assign weight_vecs_0_2_address0 = tmp_115_fu_959_p1;

assign weight_vecs_0_3_address0 = tmp_115_fu_959_p1;

assign weight_vecs_1_0_address0 = tmp_115_fu_959_p1;

assign weight_vecs_1_1_address0 = tmp_115_fu_959_p1;

assign weight_vecs_1_2_address0 = tmp_115_fu_959_p1;

assign weight_vecs_1_3_address0 = tmp_115_fu_959_p1;

assign weight_vecs_2_0_address0 = tmp_115_fu_959_p1;

assign weight_vecs_2_1_address0 = tmp_115_fu_959_p1;

assign weight_vecs_2_2_address0 = tmp_115_fu_959_p1;

assign weight_vecs_2_3_address0 = tmp_115_fu_959_p1;

assign weight_vecs_3_0_address0 = tmp_115_fu_959_p1;

assign weight_vecs_3_1_address0 = tmp_115_fu_959_p1;

assign weight_vecs_3_2_address0 = tmp_115_fu_959_p1;

assign weight_vecs_3_3_address0 = tmp_115_fu_959_p1;

assign xor_ln149_fu_876_p2 = (tmp_57_fu_868_p3 ^ 1'd1);

assign zext_ln150_4_fu_790_p1 = ap_phi_mux_jj_phi_fu_644_p4;

assign zext_ln150_8_fu_838_p1 = add_ln147_reg_1102;

assign zext_ln150_9_fu_919_p1 = add_ln148_fu_887_p2;

assign zext_ln150_fu_772_p1 = ii_reg_617;

assign zext_ln153_6_fu_1025_p1 = lshr_ln153_6_fu_1018_p3;

assign zext_ln153_7_fu_1055_p1 = lshr_ln153_7_fu_1048_p3;

assign zext_ln153_8_fu_1085_p1 = lshr_ln153_8_fu_1078_p3;

assign zext_ln153_fu_995_p1 = lshr_ln_fu_989_p3;

endmodule //td_fused_top_tdf4_dot_product

module td_fused_top_hmul_16ns_16ns_16_5_max_dsp_1
#(parameter
    ID         = 31,
    NUM_STAGE  = 5,
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
td_fused_top_ap_hmul_3_max_dsp_16 td_fused_top_ap_hmul_3_max_dsp_16_u (
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
module td_fused_top_ap_hmul_3_max_dsp_16 (
   input  wire        aclk,
   input  wire        aclken,
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
   multiply_fp u_mult_fp (
      .a(a_reg), 
      .b(b_reg), 
      .out(res)
   );
`else
FPMult_16 u_FPMult (.clk(), .rst(1'b0), .a(a_reg), .b(b_reg), .result(res), .flags());
`endif

   assign m_axis_result_tdata = res_reg;

endmodule
module FPMult_16(
		clk,
		rst,
		a,
		b,
		result,
		flags
    );
	
	// Input Ports
	input clk ;							// Clock
	input rst ;							// Reset signal
	input [`DWIDTH-1:0] a;					// Input A, a 32-bit floating point number
	input [`DWIDTH-1:0] b;					// Input B, a 32-bit floating point number
	
	// Output ports
	output [`DWIDTH-1:0] result ;					// Product, result of the operation, 32-bit FP number
	output [4:0] flags ;				// Flags indicating exceptions according to IEEE754
	
	// Internal signals
	wire [31:0] Z_int ;				// Product, result of the operation, 32-bit FP number
	wire [4:0] Flags_int ;			// Flags indicating exceptions according to IEEE754
	
	wire Sa ;							// A's sign
	wire Sb ;							// B's sign
	wire Sp ;							// Product sign
	wire [`EXPONENT-1:0] Ea ;					// A's exponent
	wire [`EXPONENT-1:0] Eb ;					// B's exponent
	wire [2*`MANTISSA+1:0] Mp ;					// Product mantissa
	wire [4:0] InputExc ;			// Exceptions in inputs
	wire [`MANTISSA-1:0] NormM ;				// Normalized mantissa
	wire [`EXPONENT:0] NormE ;				// Normalized exponent
	wire [`MANTISSA:0] RoundM ;				// Normalized mantissa
	wire [`EXPONENT:0] RoundE ;				// Normalized exponent
	wire [`MANTISSA:0] RoundMP ;				// Normalized mantissa
	wire [`EXPONENT:0] RoundEP ;				// Normalized exponent
	wire GRS ;

	//reg [63:0] pipe_0;			// Pipeline register Input->Prep
	reg [2*`DWIDTH-1:0] pipe_0;			// Pipeline register Input->Prep

	//reg [92:0] pipe_1;			// Pipeline register Prep->Execute
	reg [3*`MANTISSA+2*`EXPONENT+7:0] pipe_1;			// Pipeline register Prep->Execute

	//reg [38:0] pipe_2;			// Pipeline register Execute->Normalize
	reg [`MANTISSA+`EXPONENT+7:0] pipe_2;			// Pipeline register Execute->Normalize
	
	//reg [72:0] pipe_3;			// Pipeline register Normalize->Round
	reg [2*`MANTISSA+2*`EXPONENT+10:0] pipe_3;			// Pipeline register Normalize->Round

	//reg [36:0] pipe_4;			// Pipeline register Round->Output
	reg [`DWIDTH+4:0] pipe_4;			// Pipeline register Round->Output
	
	assign result = pipe_4[`DWIDTH+4:5] ;
	assign flags = pipe_4[4:0] ;
	
	// Prepare the operands for alignment and check for exceptions
	FPMult_PrepModule PrepModule(clk, rst, pipe_0[2*`DWIDTH-1:`DWIDTH], pipe_0[`DWIDTH-1:0], Sa, Sb, Ea[`EXPONENT-1:0], Eb[`EXPONENT-1:0], Mp[2*`MANTISSA+1:0], InputExc[4:0]) ;

	// Perform (unsigned) mantissa multiplication
	FPMult_ExecuteModule ExecuteModule(pipe_1[3*`MANTISSA+`EXPONENT*2+7:2*`MANTISSA+2*`EXPONENT+8], pipe_1[2*`MANTISSA+2*`EXPONENT+7:2*`MANTISSA+7], pipe_1[2*`MANTISSA+6:5], pipe_1[2*`MANTISSA+2*`EXPONENT+6:2*`MANTISSA+`EXPONENT+7], pipe_1[2*`MANTISSA+`EXPONENT+6:2*`MANTISSA+7], pipe_1[2*`MANTISSA+2*`EXPONENT+8], pipe_1[2*`MANTISSA+2*`EXPONENT+7], Sp, NormE[`EXPONENT:0], NormM[`MANTISSA-1:0], GRS) ;

	// Round result and if necessary, perform a second (post-rounding) normalization step
	FPMult_NormalizeModule NormalizeModule(pipe_2[`MANTISSA-1:0], pipe_2[`MANTISSA+`EXPONENT:`MANTISSA], RoundE[`EXPONENT:0], RoundEP[`EXPONENT:0], RoundM[`MANTISSA:0], RoundMP[`MANTISSA:0]) ;		

	// Round result and if necessary, perform a second (post-rounding) normalization step
	//FPMult_RoundModule RoundModule(pipe_3[47:24], pipe_3[23:0], pipe_3[65:57], pipe_3[56:48], pipe_3[66], pipe_3[67], pipe_3[72:68], Z_int[31:0], Flags_int[4:0]) ;		
	FPMult_RoundModule RoundModule(pipe_3[2*`MANTISSA+1:`MANTISSA+1], pipe_3[`MANTISSA:0], pipe_3[2*`MANTISSA+2*`EXPONENT+3:2*`MANTISSA+`EXPONENT+3], pipe_3[2*`MANTISSA+`EXPONENT+2:2*`MANTISSA+2], pipe_3[2*`MANTISSA+2*`EXPONENT+4], pipe_3[2*`MANTISSA+2*`EXPONENT+5], pipe_3[2*`MANTISSA+2*`EXPONENT+10:2*`MANTISSA+2*`EXPONENT+6], Z_int[`DWIDTH-1:0], Flags_int[4:0]) ;		

	always @ (*) begin	
		if(rst) begin
			pipe_0 = 0;
			pipe_1 = 0;
			pipe_2 = 0; 
			pipe_3 = 0;
			pipe_4 = 0;
		end 
		else begin		
			/* PIPE 0
				[63:32] A
				[31:0] B
			*/
      pipe_0 = {a, b} ;

			/* PIPE 1
				[70] Sa
				[69] Sb
				[68:61] Ea
				[60:53] Eb
				[52:5] Mp
				[4:0] InputExc
			*/
			//pipe_1 <= {pipe_0[`DWIDTH+`MANTISSA-1:`DWIDTH], pipe_0[`MANTISSA_MUL_SPLIT_LSB-1:0], Sa, Sb, Ea[`EXPONENT-1:0], Eb[`EXPONENT-1:0], Mp[2*`MANTISSA-1:0], InputExc[4:0]} ;
			pipe_1 = {pipe_0[`DWIDTH+`MANTISSA-1:`DWIDTH], pipe_0[8:0], Sa, Sb, Ea[`EXPONENT-1:0], Eb[`EXPONENT-1:0], Mp[2*`MANTISSA+1:0], InputExc[4:0]} ;
			/* PIPE 2
				[38:34] InputExc
				[33] GRS
				[32] Sp
				[31:23] NormE
				[22:0] NormM
			*/
			pipe_2 = {pipe_1[4:0], GRS, Sp, NormE[`EXPONENT:0], NormM[`MANTISSA-1:0]} ;
			/* PIPE 3
				[72:68] InputExc
				[67] GRS
				[66] Sp	
				[65:57] RoundE
				[56:48] RoundEP
				[47:24] RoundM
				[23:0] RoundMP
			*/
			pipe_3 = {pipe_2[`EXPONENT+`MANTISSA+7:`EXPONENT+`MANTISSA+1], RoundE[`EXPONENT:0], RoundEP[`EXPONENT:0], RoundM[`MANTISSA:0], RoundMP[`MANTISSA:0]} ;
			/* PIPE 4
				[36:5] Z
				[4:0] Flags
			*/				
			pipe_4 = {Z_int[`DWIDTH-1:0], Flags_int[4:0]} ;
		end
	end
		
endmodule
module FPMult_RoundModule(
		RoundM,
		RoundMP,
		RoundE,
		RoundEP,
		Sp,
		GRS,
		InputExc,
		Z,
		Flags
    );

	// Input Ports
	input [`MANTISSA:0] RoundM ;									// Normalized mantissa
	input [`MANTISSA:0] RoundMP ;									// Normalized exponent
	input [`EXPONENT:0] RoundE ;									// Normalized mantissa + 1
	input [`EXPONENT:0] RoundEP ;									// Normalized exponent + 1
	input Sp ;												// Product sign
	input GRS ;
	input [4:0] InputExc ;
	
	// Output Ports
	output [`DWIDTH-1:0] Z ;										// Final product
	output [4:0] Flags ;
	
	// Internal Signals
	wire [`EXPONENT:0] FinalE ;									// Rounded exponent
	wire [`MANTISSA:0] FinalM;
	wire [`MANTISSA:0] PreShiftM;
	
	assign PreShiftM = GRS ? RoundMP : RoundM ;	// Round up if R and (G or S)
	
	// Post rounding normalization (potential one bit shift> use shifted mantissa if there is overflow)
	assign FinalM = (PreShiftM[`MANTISSA] ? {1'b0, PreShiftM[`MANTISSA:1]} : PreShiftM[`MANTISSA:0]) ;
	
	assign FinalE = (PreShiftM[`MANTISSA] ? RoundEP : RoundE) ; // Increment exponent if a shift was done
	
	assign Z = {Sp, FinalE[`EXPONENT-1:0], FinalM[`MANTISSA-1:0]} ;   // Putting the pieces together
	assign Flags = InputExc[4:0];

endmodule
module FPMult_NormalizeModule(
		NormM,
		NormE,
		RoundE,
		RoundEP,
		RoundM,
		RoundMP
    );

	// Input Ports
	input [`MANTISSA-1:0] NormM ;									// Normalized mantissa
	input [`EXPONENT:0] NormE ;									// Normalized exponent

	// Output Ports
	output [`EXPONENT:0] RoundE ;
	output [`EXPONENT:0] RoundEP ;
	output [`MANTISSA:0] RoundM ;
	output [`MANTISSA:0] RoundMP ; 
	
	assign RoundE = NormE - 15 ;
	assign RoundEP = NormE - 14 ;
	assign RoundM = NormM ;
	assign RoundMP = NormM ;

endmodule
module FPMult_ExecuteModule(
		a,
		b,
		MpC,
		Ea,
		Eb,
		Sa,
		Sb,
		Sp,
		NormE,
		NormM,
		GRS
    );

	// Input ports
	input [`MANTISSA-1:0] a ;
	input [2*`EXPONENT:0] b ;
	input [2*`MANTISSA+1:0] MpC ;
	input [`EXPONENT-1:0] Ea ;						// A's exponent
	input [`EXPONENT-1:0] Eb ;						// B's exponent
	input Sa ;								// A's sign
	input Sb ;								// B's sign
	
	// Output ports
	output Sp ;								// Product sign
	output [`EXPONENT:0] NormE ;													// Normalized exponent
	output [`MANTISSA-1:0] NormM ;												// Normalized mantissa
	output GRS ;
	
	wire [2*`MANTISSA+1:0] Mp ;
	
	assign Sp = (Sa ^ Sb) ;												// Equal signs give a positive product
	
   // wire [`ACTUAL_MANTISSA-1:0] inp_a;
   // wire [`ACTUAL_MANTISSA-1:0] inp_b;
   // assign inp_a = {1'b1, a};
   // assign inp_b = {{(`MANTISSA-`MANTISSA_MUL_SPLIT_LSB){1'b0}}, 1'b0, b};
   // DW02_mult #(`ACTUAL_MANTISSA,`ACTUAL_MANTISSA) u_mult(.A(inp_a), .B(inp_b), .TC(1'b0), .PRODUCT(Mp_temp));
   // DW01_add #(2*`ACTUAL_MANTISSA) u_add(.A(Mp_temp), .B(MpC<<`MANTISSA_MUL_SPLIT_LSB), .CI(1'b0), .SUM(Mp), .CO());

	//assign Mp = (MpC<<(2*`EXPONENT+1)) + ({4'b0001, a[`MANTISSA-1:0]}*{1'b0, b[2*`EXPONENT:0]}) ;
	assign Mp = MpC;


	assign NormM = (Mp[2*`MANTISSA+1] ? Mp[2*`MANTISSA:`MANTISSA+1] : Mp[2*`MANTISSA-1:`MANTISSA]); 	// Check for overflow
	assign NormE = (Ea + Eb + Mp[2*`MANTISSA+1]);								// If so, increment exponent
	
	assign GRS = ((Mp[`MANTISSA]&(Mp[`MANTISSA+1]))|(|Mp[`MANTISSA-1:0])) ;
	
endmodule
module FPMult_PrepModule (
		clk,
		rst,
		a,
		b,
		Sa,
		Sb,
		Ea,
		Eb,
		Mp,
		InputExc
	);
	
	// Input ports
	input clk ;
	input rst ;
	input [`DWIDTH-1:0] a ;								// Input A, a 32-bit floating point number
	input [`DWIDTH-1:0] b ;								// Input B, a 32-bit floating point number
	
	// Output ports
	output Sa ;										// A's sign
	output Sb ;										// B's sign
	output [`EXPONENT-1:0] Ea ;								// A's exponent
	output [`EXPONENT-1:0] Eb ;								// B's exponent
	output [2*`MANTISSA+1:0] Mp ;							// Mantissa product
	output [4:0] InputExc ;						// Input numbers are exceptions
	
	// Internal signals							// If signal is high...
	wire ANaN ;										// A is a signalling NaN
	wire BNaN ;										// B is a signalling NaN
	wire AInf ;										// A is infinity
	wire BInf ;										// B is infinity
    wire [`MANTISSA-1:0] Ma;
    wire [`MANTISSA-1:0] Mb;
	
	assign ANaN = &(a[`DWIDTH-2:`MANTISSA]) &  |(a[`DWIDTH-2:`MANTISSA]) ;			// All one exponent and not all zero mantissa - NaN
	assign BNaN = &(b[`DWIDTH-2:`MANTISSA]) &  |(b[`MANTISSA-1:0]);			// All one exponent and not all zero mantissa - NaN
	assign AInf = &(a[`DWIDTH-2:`MANTISSA]) & ~|(a[`DWIDTH-2:`MANTISSA]) ;		// All one exponent and all zero mantissa - Infinity
	assign BInf = &(b[`DWIDTH-2:`MANTISSA]) & ~|(b[`DWIDTH-2:`MANTISSA]) ;		// All one exponent and all zero mantissa - Infinity
	
	// Check for any exceptions and put all flags into exception vector
	assign InputExc = {(ANaN | BNaN | AInf | BInf), ANaN, BNaN, AInf, BInf} ;
	//assign InputExc = {(ANaN | ANaN | BNaN |BNaN), ANaN, ANaN, BNaN,BNaN} ;
	
	// Take input numbers apart
	assign Sa = a[`DWIDTH-1] ;							// A's sign
	assign Sb = b[`DWIDTH-1] ;							// B's sign
	assign Ea = a[`DWIDTH-2:`MANTISSA];						// Store A's exponent in Ea, unless A is an exception
	assign Eb = b[`DWIDTH-2:`MANTISSA];						// Store B's exponent in Eb, unless B is an exception	
//    assign Ma = a[`MANTISSA_MSB:`MANTISSA_LSB];
  //  assign Mb = b[`MANTISSA_MSB:`MANTISSA_LSB];
	


	//assign Mp = ({4'b0001, a[`MANTISSA-1:0]}*{4'b0001, b[`MANTISSA-1:9]}) ;
	assign Mp = ({1'b1,a[`MANTISSA-1:0]}*{1'b1, b[`MANTISSA-1:0]}) ;

	
    //We multiply part of the mantissa here
    //Full mantissa of A
    //Bits MANTISSA_MUL_SPLIT_MSB:MANTISSA_MUL_SPLIT_LSB of B
   // wire [`ACTUAL_MANTISSA-1:0] inp_A;
   // wire [`ACTUAL_MANTISSA-1:0] inp_B;
   // assign inp_A = {1'b1, Ma};
   // assign inp_B = {{(`MANTISSA-(`MANTISSA_MUL_SPLIT_MSB-`MANTISSA_MUL_SPLIT_LSB+1)){1'b0}}, 1'b1, Mb[`MANTISSA_MUL_SPLIT_MSB:`MANTISSA_MUL_SPLIT_LSB]};
   // DW02_mult #(`ACTUAL_MANTISSA,`ACTUAL_MANTISSA) u_mult(.A(inp_A), .B(inp_B), .TC(1'b0), .PRODUCT(Mp));
endmodule



