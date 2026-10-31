// Generator : SpinalHDL v1.15.0    git head : 05a01af3d3345aa0afcaad8e0186dde13a359db2
// Component : nvfp4_scaled_dot16
// SPDX-License-Identifier: MIT
// Generated from rtl/spinal/; edit Scala and run cmake --build <build-dir> --target rtl-gen.

`timescale 1ns/1ps
module nvfp4_scaled_dot16 (
  input  wire          clk,
  input  wire          rst,
  input  wire          ce,
  input  wire          in_valid,
  input  wire [143:0]  in_data,
  output wire          out_valid,
  output wire [47:0]   out_data,
  output wire          out_invalid
);

  wire       [33:0]   pipeline_groups_0_dsp_A;
  wire       [57:0]   pipeline_groups_0_dsp_C;
  wire                pipeline_groups_0_dsp_CARRYIN;
  wire       [33:0]   pipeline_groups_1_dsp_A;
  wire       [57:0]   pipeline_groups_1_dsp_C;
  wire                pipeline_groups_1_dsp_CARRYIN;
  wire       [33:0]   pipeline_groups_2_dsp_A;
  wire       [57:0]   pipeline_groups_2_dsp_C;
  wire                pipeline_groups_2_dsp_CARRYIN;
  wire       [33:0]   pipeline_groups_3_dsp_A;
  wire       [57:0]   pipeline_groups_3_dsp_C;
  wire                pipeline_groups_3_dsp_CARRYIN;
  wire       [57:0]   pipeline_groups_0_dsp_P;
  wire       [57:0]   pipeline_groups_1_dsp_P;
  wire       [57:0]   pipeline_groups_2_dsp_P;
  wire       [57:0]   pipeline_groups_3_dsp_P;
  wire       [8:0]    _zz_pipeline_groups_0_a_port_3;
  wire       [7:0]    _zz_pipeline_groups_0_b_port_3;
  wire       [8:0]    _zz_pipeline_groups_0_a_port_4;
  wire       [7:0]    _zz_pipeline_groups_0_b_port_4;
  wire       [8:0]    _zz_pipeline_groups_0_a_port_5;
  wire       [7:0]    _zz_pipeline_groups_0_b_port_5;
  wire       [33:0]   _zz_A;
  wire       [26:0]   _zz_A_1;
  wire       [57:0]   _zz_C;
  wire       [8:0]    _zz_C_1;
  wire       [8:0]    _zz_pipeline_groups_1_a_port_3;
  wire       [7:0]    _zz_pipeline_groups_1_b_port_3;
  wire       [8:0]    _zz_pipeline_groups_1_a_port_4;
  wire       [7:0]    _zz_pipeline_groups_1_b_port_4;
  wire       [8:0]    _zz_pipeline_groups_1_a_port_5;
  wire       [7:0]    _zz_pipeline_groups_1_b_port_5;
  wire       [33:0]   _zz_A_2;
  wire       [26:0]   _zz_A_3;
  wire       [57:0]   _zz_C_2;
  wire       [8:0]    _zz_C_3;
  wire       [8:0]    _zz_pipeline_groups_2_a_port_3;
  wire       [7:0]    _zz_pipeline_groups_2_b_port_3;
  wire       [8:0]    _zz_pipeline_groups_2_a_port_4;
  wire       [7:0]    _zz_pipeline_groups_2_b_port_4;
  wire       [8:0]    _zz_pipeline_groups_2_a_port_5;
  wire       [7:0]    _zz_pipeline_groups_2_b_port_5;
  wire       [33:0]   _zz_A_4;
  wire       [26:0]   _zz_A_5;
  wire       [57:0]   _zz_C_4;
  wire       [8:0]    _zz_C_5;
  wire       [8:0]    _zz_pipeline_groups_3_a_port_3;
  wire       [7:0]    _zz_pipeline_groups_3_b_port_3;
  wire       [8:0]    _zz_pipeline_groups_3_a_port_4;
  wire       [7:0]    _zz_pipeline_groups_3_b_port_4;
  wire       [8:0]    _zz_pipeline_groups_3_a_port_5;
  wire       [7:0]    _zz_pipeline_groups_3_b_port_5;
  wire       [33:0]   _zz_A_6;
  wire       [26:0]   _zz_A_7;
  wire       [57:0]   _zz_C_6;
  wire       [8:0]    _zz_C_7;
  wire       [11:0]   _zz_pipeline_pair_left;
  wire       [11:0]   _zz_pipeline_pair_left_1;
  wire       [11:0]   _zz_pipeline_pair_right;
  wire       [11:0]   _zz_pipeline_pair_right_1;
  wire       [12:0]   _zz_pipeline_total;
  wire       [12:0]   _zz_pipeline_total_1;
  wire       [3:0]    _zz_pipeline_scaling_scales_0_magnitude;
  wire       [4:0]    _zz_pipeline_scaling_scales_0_mantissa;
  wire       [4:0]    _zz_pipeline_scaling_scales_0_signed_mantissa;
  wire       [3:0]    _zz_pipeline_scaling_scales_0_shift;
  wire       [3:0]    _zz_pipeline_scaling_scales_1_magnitude;
  wire       [4:0]    _zz_pipeline_scaling_scales_1_mantissa;
  wire       [4:0]    _zz_pipeline_scaling_scales_1_signed_mantissa;
  wire       [3:0]    _zz_pipeline_scaling_scales_1_shift;
  wire       [4:0]    _zz_pipeline_scaling_h2;
  wire       [4:0]    _zz_pipeline_scaling_h2_1;
  wire       [47:0]   _zz_pipeline_scaling_shifted5;
  (* shreg_extract = "no" *) reg        [1:0]    pipeline_valid_pipe;
  wire       [15:0]   pipeline_groups_0_a;
  wire       [15:0]   pipeline_groups_0_b;
  reg        [26:0]   pipeline_groups_0_a_port;
  reg        [23:0]   pipeline_groups_0_b_port;
  wire       [3:0]    switch_Dot16_l12;
  reg        [4:0]    _zz_pipeline_groups_0_a_port;
  wire       [3:0]    switch_Dot16_l12_1;
  reg        [4:0]    _zz_pipeline_groups_0_b_port;
  wire       [3:0]    switch_Dot16_l12_2;
  reg        [4:0]    _zz_pipeline_groups_0_a_port_1;
  wire       [3:0]    switch_Dot16_l12_3;
  reg        [4:0]    _zz_pipeline_groups_0_b_port_1;
  wire       [3:0]    switch_Dot16_l12_4;
  reg        [4:0]    _zz_pipeline_groups_0_a_port_2;
  wire       [3:0]    switch_Dot16_l12_5;
  reg        [4:0]    _zz_pipeline_groups_0_b_port_2;
  reg        [7:0]    pipeline_groups_0_magnitude;
  wire       [5:0]    switch_Dot16_l26;
  wire                pipeline_groups_0_sign;
  wire       [8:0]    pipeline_groups_0_complement;
  (* dont_touch = "yes" *) reg        [9:0]    pipeline_groups_0_fourth_pipe;
  wire       [10:0]   pipeline_groups_0_sum;
  wire       [15:0]   pipeline_groups_1_a;
  wire       [15:0]   pipeline_groups_1_b;
  reg        [26:0]   pipeline_groups_1_a_port;
  reg        [23:0]   pipeline_groups_1_b_port;
  wire       [3:0]    switch_Dot16_l12_6;
  reg        [4:0]    _zz_pipeline_groups_1_a_port;
  wire       [3:0]    switch_Dot16_l12_7;
  reg        [4:0]    _zz_pipeline_groups_1_b_port;
  wire       [3:0]    switch_Dot16_l12_8;
  reg        [4:0]    _zz_pipeline_groups_1_a_port_1;
  wire       [3:0]    switch_Dot16_l12_9;
  reg        [4:0]    _zz_pipeline_groups_1_b_port_1;
  wire       [3:0]    switch_Dot16_l12_10;
  reg        [4:0]    _zz_pipeline_groups_1_a_port_2;
  wire       [3:0]    switch_Dot16_l12_11;
  reg        [4:0]    _zz_pipeline_groups_1_b_port_2;
  reg        [7:0]    pipeline_groups_1_magnitude;
  wire       [5:0]    switch_Dot16_l26_1;
  wire                pipeline_groups_1_sign;
  wire       [8:0]    pipeline_groups_1_complement;
  (* dont_touch = "yes" *) reg        [9:0]    pipeline_groups_1_fourth_pipe;
  wire       [10:0]   pipeline_groups_1_sum;
  wire       [15:0]   pipeline_groups_2_a;
  wire       [15:0]   pipeline_groups_2_b;
  reg        [26:0]   pipeline_groups_2_a_port;
  reg        [23:0]   pipeline_groups_2_b_port;
  wire       [3:0]    switch_Dot16_l12_12;
  reg        [4:0]    _zz_pipeline_groups_2_a_port;
  wire       [3:0]    switch_Dot16_l12_13;
  reg        [4:0]    _zz_pipeline_groups_2_b_port;
  wire       [3:0]    switch_Dot16_l12_14;
  reg        [4:0]    _zz_pipeline_groups_2_a_port_1;
  wire       [3:0]    switch_Dot16_l12_15;
  reg        [4:0]    _zz_pipeline_groups_2_b_port_1;
  wire       [3:0]    switch_Dot16_l12_16;
  reg        [4:0]    _zz_pipeline_groups_2_a_port_2;
  wire       [3:0]    switch_Dot16_l12_17;
  reg        [4:0]    _zz_pipeline_groups_2_b_port_2;
  reg        [7:0]    pipeline_groups_2_magnitude;
  wire       [5:0]    switch_Dot16_l26_2;
  wire                pipeline_groups_2_sign;
  wire       [8:0]    pipeline_groups_2_complement;
  (* dont_touch = "yes" *) reg        [9:0]    pipeline_groups_2_fourth_pipe;
  wire       [10:0]   pipeline_groups_2_sum;
  wire       [15:0]   pipeline_groups_3_a;
  wire       [15:0]   pipeline_groups_3_b;
  reg        [26:0]   pipeline_groups_3_a_port;
  reg        [23:0]   pipeline_groups_3_b_port;
  wire       [3:0]    switch_Dot16_l12_18;
  reg        [4:0]    _zz_pipeline_groups_3_a_port;
  wire       [3:0]    switch_Dot16_l12_19;
  reg        [4:0]    _zz_pipeline_groups_3_b_port;
  wire       [3:0]    switch_Dot16_l12_20;
  reg        [4:0]    _zz_pipeline_groups_3_a_port_1;
  wire       [3:0]    switch_Dot16_l12_21;
  reg        [4:0]    _zz_pipeline_groups_3_b_port_1;
  wire       [3:0]    switch_Dot16_l12_22;
  reg        [4:0]    _zz_pipeline_groups_3_a_port_2;
  wire       [3:0]    switch_Dot16_l12_23;
  reg        [4:0]    _zz_pipeline_groups_3_b_port_2;
  reg        [7:0]    pipeline_groups_3_magnitude;
  wire       [5:0]    switch_Dot16_l26_3;
  wire                pipeline_groups_3_sign;
  wire       [8:0]    pipeline_groups_3_complement;
  (* dont_touch = "yes" *) reg        [9:0]    pipeline_groups_3_fourth_pipe;
  wire       [10:0]   pipeline_groups_3_sum;
  (* use_dsp = "no" *) wire       [11:0]   pipeline_pair_left;
  (* use_dsp = "no" *) wire       [11:0]   pipeline_pair_right;
  (* use_dsp = "no" *) wire       [12:0]   pipeline_total;
  wire       [7:0]    pipeline_scaling_scales_0_code;
  wire       [3:0]    pipeline_scaling_scales_0_exponent;
  wire       [2:0]    pipeline_scaling_scales_0_fraction;
  wire                pipeline_scaling_scales_0_invalid;
  reg        [3:0]    pipeline_scaling_scales_0_magnitude;
  wire                when_Dot16_l103;
  wire       [4:0]    pipeline_scaling_scales_0_mantissa;
  wire       [4:0]    pipeline_scaling_scales_0_signed_mantissa;
  wire       [3:0]    pipeline_scaling_scales_0_shift;
  (* shreg_extract = "no" *) reg        [4:0]    pipeline_scaling_scales_0_m1;
  (* shreg_extract = "no" *) reg        [3:0]    pipeline_scaling_scales_0_h1;
  (* shreg_extract = "no" *) reg                 pipeline_scaling_scales_0_invalid1;
  wire       [7:0]    pipeline_scaling_scales_1_code;
  wire       [3:0]    pipeline_scaling_scales_1_exponent;
  wire       [2:0]    pipeline_scaling_scales_1_fraction;
  wire                pipeline_scaling_scales_1_invalid;
  reg        [3:0]    pipeline_scaling_scales_1_magnitude;
  wire                when_Dot16_l103_1;
  wire       [4:0]    pipeline_scaling_scales_1_mantissa;
  wire       [4:0]    pipeline_scaling_scales_1_signed_mantissa;
  wire       [3:0]    pipeline_scaling_scales_1_shift;
  (* shreg_extract = "no" *) reg        [4:0]    pipeline_scaling_scales_1_m1;
  (* shreg_extract = "no" *) reg        [3:0]    pipeline_scaling_scales_1_h1;
  (* shreg_extract = "no" *) reg                 pipeline_scaling_scales_1_invalid1;
  (* use_dsp = "no" *) wire       [9:0]    pipeline_scaling_mantissa_product;
  (* shreg_extract = "no" *) reg        [8:0]    pipeline_scaling_k2;
  (* shreg_extract = "no" *) reg        [4:0]    pipeline_scaling_h2;
  (* shreg_extract = "no" *) reg                 pipeline_scaling_invalid2;
  (* shreg_extract = "no" *) reg        [12:0]   pipeline_scaling_q3;
  (* shreg_extract = "no" *) reg        [8:0]    pipeline_scaling_k3;
  (* shreg_extract = "no" *) reg        [4:0]    pipeline_scaling_h3;
  (* shreg_extract = "no" *) reg                 pipeline_scaling_invalid3;
  (* use_dsp = "yes" *) wire       [21:0]   pipeline_scaling_product;
  (* shreg_extract = "no" *) reg        [19:0]   pipeline_scaling_p4;
  (* shreg_extract = "no" *) reg        [4:0]    pipeline_scaling_h4;
  (* shreg_extract = "no" *) reg                 pipeline_scaling_invalid4;
  (* shreg_extract = "no" , dont_touch = "yes" *) reg        [47:0]   pipeline_scaling_shifted5;
  (* shreg_extract = "no" *) reg                 _zz_out_invalid;
  (* shreg_extract = "no" *) reg                 _zz_out_valid;
  (* shreg_extract = "no" *) reg                 _zz_out_valid_1;
  (* shreg_extract = "no" *) reg                 _zz_out_valid_2;

  assign _zz_pipeline_groups_0_a_port_3 = {{4{_zz_pipeline_groups_0_a_port[4]}}, _zz_pipeline_groups_0_a_port};
  assign _zz_pipeline_groups_0_b_port_3 = {{3{_zz_pipeline_groups_0_b_port[4]}}, _zz_pipeline_groups_0_b_port};
  assign _zz_pipeline_groups_0_a_port_4 = {{4{_zz_pipeline_groups_0_a_port_1[4]}}, _zz_pipeline_groups_0_a_port_1};
  assign _zz_pipeline_groups_0_b_port_4 = {{3{_zz_pipeline_groups_0_b_port_1[4]}}, _zz_pipeline_groups_0_b_port_1};
  assign _zz_pipeline_groups_0_a_port_5 = {{4{_zz_pipeline_groups_0_a_port_2[4]}}, _zz_pipeline_groups_0_a_port_2};
  assign _zz_pipeline_groups_0_b_port_5 = {{3{_zz_pipeline_groups_0_b_port_2[4]}}, _zz_pipeline_groups_0_b_port_2};
  assign _zz_A_1 = pipeline_groups_0_a_port;
  assign _zz_A = {{7{_zz_A_1[26]}}, _zz_A_1};
  assign _zz_C_1 = pipeline_groups_0_fourth_pipe[8 : 0];
  assign _zz_C = {{49{_zz_C_1[8]}}, _zz_C_1};
  assign _zz_pipeline_groups_1_a_port_3 = {{4{_zz_pipeline_groups_1_a_port[4]}}, _zz_pipeline_groups_1_a_port};
  assign _zz_pipeline_groups_1_b_port_3 = {{3{_zz_pipeline_groups_1_b_port[4]}}, _zz_pipeline_groups_1_b_port};
  assign _zz_pipeline_groups_1_a_port_4 = {{4{_zz_pipeline_groups_1_a_port_1[4]}}, _zz_pipeline_groups_1_a_port_1};
  assign _zz_pipeline_groups_1_b_port_4 = {{3{_zz_pipeline_groups_1_b_port_1[4]}}, _zz_pipeline_groups_1_b_port_1};
  assign _zz_pipeline_groups_1_a_port_5 = {{4{_zz_pipeline_groups_1_a_port_2[4]}}, _zz_pipeline_groups_1_a_port_2};
  assign _zz_pipeline_groups_1_b_port_5 = {{3{_zz_pipeline_groups_1_b_port_2[4]}}, _zz_pipeline_groups_1_b_port_2};
  assign _zz_A_3 = pipeline_groups_1_a_port;
  assign _zz_A_2 = {{7{_zz_A_3[26]}}, _zz_A_3};
  assign _zz_C_3 = pipeline_groups_1_fourth_pipe[8 : 0];
  assign _zz_C_2 = {{49{_zz_C_3[8]}}, _zz_C_3};
  assign _zz_pipeline_groups_2_a_port_3 = {{4{_zz_pipeline_groups_2_a_port[4]}}, _zz_pipeline_groups_2_a_port};
  assign _zz_pipeline_groups_2_b_port_3 = {{3{_zz_pipeline_groups_2_b_port[4]}}, _zz_pipeline_groups_2_b_port};
  assign _zz_pipeline_groups_2_a_port_4 = {{4{_zz_pipeline_groups_2_a_port_1[4]}}, _zz_pipeline_groups_2_a_port_1};
  assign _zz_pipeline_groups_2_b_port_4 = {{3{_zz_pipeline_groups_2_b_port_1[4]}}, _zz_pipeline_groups_2_b_port_1};
  assign _zz_pipeline_groups_2_a_port_5 = {{4{_zz_pipeline_groups_2_a_port_2[4]}}, _zz_pipeline_groups_2_a_port_2};
  assign _zz_pipeline_groups_2_b_port_5 = {{3{_zz_pipeline_groups_2_b_port_2[4]}}, _zz_pipeline_groups_2_b_port_2};
  assign _zz_A_5 = pipeline_groups_2_a_port;
  assign _zz_A_4 = {{7{_zz_A_5[26]}}, _zz_A_5};
  assign _zz_C_5 = pipeline_groups_2_fourth_pipe[8 : 0];
  assign _zz_C_4 = {{49{_zz_C_5[8]}}, _zz_C_5};
  assign _zz_pipeline_groups_3_a_port_3 = {{4{_zz_pipeline_groups_3_a_port[4]}}, _zz_pipeline_groups_3_a_port};
  assign _zz_pipeline_groups_3_b_port_3 = {{3{_zz_pipeline_groups_3_b_port[4]}}, _zz_pipeline_groups_3_b_port};
  assign _zz_pipeline_groups_3_a_port_4 = {{4{_zz_pipeline_groups_3_a_port_1[4]}}, _zz_pipeline_groups_3_a_port_1};
  assign _zz_pipeline_groups_3_b_port_4 = {{3{_zz_pipeline_groups_3_b_port_1[4]}}, _zz_pipeline_groups_3_b_port_1};
  assign _zz_pipeline_groups_3_a_port_5 = {{4{_zz_pipeline_groups_3_a_port_2[4]}}, _zz_pipeline_groups_3_a_port_2};
  assign _zz_pipeline_groups_3_b_port_5 = {{3{_zz_pipeline_groups_3_b_port_2[4]}}, _zz_pipeline_groups_3_b_port_2};
  assign _zz_A_7 = pipeline_groups_3_a_port;
  assign _zz_A_6 = {{7{_zz_A_7[26]}}, _zz_A_7};
  assign _zz_C_7 = pipeline_groups_3_fourth_pipe[8 : 0];
  assign _zz_C_6 = {{49{_zz_C_7[8]}}, _zz_C_7};
  assign _zz_pipeline_pair_left = {{1{pipeline_groups_0_sum[10]}}, pipeline_groups_0_sum};
  assign _zz_pipeline_pair_left_1 = {{1{pipeline_groups_1_sum[10]}}, pipeline_groups_1_sum};
  assign _zz_pipeline_pair_right = {{1{pipeline_groups_2_sum[10]}}, pipeline_groups_2_sum};
  assign _zz_pipeline_pair_right_1 = {{1{pipeline_groups_3_sum[10]}}, pipeline_groups_3_sum};
  assign _zz_pipeline_total = {{1{pipeline_pair_left[11]}}, pipeline_pair_left};
  assign _zz_pipeline_total_1 = {{1{pipeline_pair_right[11]}}, pipeline_pair_right};
  assign _zz_pipeline_scaling_scales_0_magnitude = {1'd0, pipeline_scaling_scales_0_fraction};
  assign _zz_pipeline_scaling_scales_0_mantissa = {1'd0, pipeline_scaling_scales_0_magnitude};
  assign _zz_pipeline_scaling_scales_0_signed_mantissa = (- pipeline_scaling_scales_0_mantissa);
  assign _zz_pipeline_scaling_scales_0_shift = (pipeline_scaling_scales_0_exponent - 4'b0001);
  assign _zz_pipeline_scaling_scales_1_magnitude = {1'd0, pipeline_scaling_scales_1_fraction};
  assign _zz_pipeline_scaling_scales_1_mantissa = {1'd0, pipeline_scaling_scales_1_magnitude};
  assign _zz_pipeline_scaling_scales_1_signed_mantissa = (- pipeline_scaling_scales_1_mantissa);
  assign _zz_pipeline_scaling_scales_1_shift = (pipeline_scaling_scales_1_exponent - 4'b0001);
  assign _zz_pipeline_scaling_h2 = {1'd0, pipeline_scaling_scales_0_h1};
  assign _zz_pipeline_scaling_h2_1 = {1'd0, pipeline_scaling_scales_1_h1};
  assign _zz_pipeline_scaling_shifted5 = {{28{pipeline_scaling_p4[19]}}, pipeline_scaling_p4};
  DSP58 #(
    .DSP_MODE      ("INT8" ),
    .USE_SIMD      ("ONE58"),
    .AREG          (1      ),
    .ACASCREG      (1      ),
    .BREG          (1      ),
    .BCASCREG      (1      ),
    .PREG          (1      ),
    .CREG          (0      ),
    .CARRYINREG    (0      ),
    .MREG          (0      ),
    .OPMODEREG     (0      ),
    .CARRYINSELREG (0      ),
    .ALUMODEREG    (0      ),
    .ADREG         (0      ),
    .DREG          (0      ),
    .INMODEREG     (0      )
  ) pipeline_groups_0_dsp (
    .CLK           (clk                           ), //i
    .A             (pipeline_groups_0_dsp_A[33:0] ), //i
    .B             (pipeline_groups_0_b_port[23:0]), //i
    .C             (pipeline_groups_0_dsp_C[57:0] ), //i
    .D             (27'h0                         ), //i
    .PCIN          (58'h0                         ), //i
    .P             (pipeline_groups_0_dsp_P[57:0] ), //o
    .OPMODE        (9'h185                        ), //i
    .ALUMODE       (4'b0000                       ), //i
    .INMODE        (5'h0                          ), //i
    .NEGATE        (3'b000                        ), //i
    .CARRYIN       (pipeline_groups_0_dsp_CARRYIN ), //i
    .CARRYINSEL    (3'b000                        ), //i
    .CARRYCASCIN   (1'b0                          ), //i
    .ACIN          (34'h0                         ), //i
    .BCIN          (24'h0                         ), //i
    .MULTSIGNIN    (1'b0                          ), //i
    .CEA1          (ce                            ), //i
    .CEA2          (ce                            ), //i
    .CEB1          (ce                            ), //i
    .CEB2          (ce                            ), //i
    .CEAD          (ce                            ), //i
    .CEALUMODE     (ce                            ), //i
    .CEC           (ce                            ), //i
    .CECARRYIN     (ce                            ), //i
    .CECTRL        (ce                            ), //i
    .CED           (ce                            ), //i
    .CEINMODE      (ce                            ), //i
    .CEM           (ce                            ), //i
    .CEP           (ce                            ), //i
    .RSTA          (rst                           ), //i
    .RSTB          (rst                           ), //i
    .RSTC          (rst                           ), //i
    .RSTD          (rst                           ), //i
    .RSTM          (rst                           ), //i
    .RSTP          (rst                           ), //i
    .RSTCTRL       (rst                           ), //i
    .RSTALUMODE    (rst                           ), //i
    .RSTINMODE     (rst                           ), //i
    .RSTALLCARRYIN (rst                           ), //i
    .ASYNC_RST     (1'b0                          )  //i
  );
  DSP58 #(
    .DSP_MODE      ("INT8" ),
    .USE_SIMD      ("ONE58"),
    .AREG          (1      ),
    .ACASCREG      (1      ),
    .BREG          (1      ),
    .BCASCREG      (1      ),
    .PREG          (1      ),
    .CREG          (0      ),
    .CARRYINREG    (0      ),
    .MREG          (0      ),
    .OPMODEREG     (0      ),
    .CARRYINSELREG (0      ),
    .ALUMODEREG    (0      ),
    .ADREG         (0      ),
    .DREG          (0      ),
    .INMODEREG     (0      )
  ) pipeline_groups_1_dsp (
    .CLK           (clk                           ), //i
    .A             (pipeline_groups_1_dsp_A[33:0] ), //i
    .B             (pipeline_groups_1_b_port[23:0]), //i
    .C             (pipeline_groups_1_dsp_C[57:0] ), //i
    .D             (27'h0                         ), //i
    .PCIN          (58'h0                         ), //i
    .P             (pipeline_groups_1_dsp_P[57:0] ), //o
    .OPMODE        (9'h185                        ), //i
    .ALUMODE       (4'b0000                       ), //i
    .INMODE        (5'h0                          ), //i
    .NEGATE        (3'b000                        ), //i
    .CARRYIN       (pipeline_groups_1_dsp_CARRYIN ), //i
    .CARRYINSEL    (3'b000                        ), //i
    .CARRYCASCIN   (1'b0                          ), //i
    .ACIN          (34'h0                         ), //i
    .BCIN          (24'h0                         ), //i
    .MULTSIGNIN    (1'b0                          ), //i
    .CEA1          (ce                            ), //i
    .CEA2          (ce                            ), //i
    .CEB1          (ce                            ), //i
    .CEB2          (ce                            ), //i
    .CEAD          (ce                            ), //i
    .CEALUMODE     (ce                            ), //i
    .CEC           (ce                            ), //i
    .CECARRYIN     (ce                            ), //i
    .CECTRL        (ce                            ), //i
    .CED           (ce                            ), //i
    .CEINMODE      (ce                            ), //i
    .CEM           (ce                            ), //i
    .CEP           (ce                            ), //i
    .RSTA          (rst                           ), //i
    .RSTB          (rst                           ), //i
    .RSTC          (rst                           ), //i
    .RSTD          (rst                           ), //i
    .RSTM          (rst                           ), //i
    .RSTP          (rst                           ), //i
    .RSTCTRL       (rst                           ), //i
    .RSTALUMODE    (rst                           ), //i
    .RSTINMODE     (rst                           ), //i
    .RSTALLCARRYIN (rst                           ), //i
    .ASYNC_RST     (1'b0                          )  //i
  );
  DSP58 #(
    .DSP_MODE      ("INT8" ),
    .USE_SIMD      ("ONE58"),
    .AREG          (1      ),
    .ACASCREG      (1      ),
    .BREG          (1      ),
    .BCASCREG      (1      ),
    .PREG          (1      ),
    .CREG          (0      ),
    .CARRYINREG    (0      ),
    .MREG          (0      ),
    .OPMODEREG     (0      ),
    .CARRYINSELREG (0      ),
    .ALUMODEREG    (0      ),
    .ADREG         (0      ),
    .DREG          (0      ),
    .INMODEREG     (0      )
  ) pipeline_groups_2_dsp (
    .CLK           (clk                           ), //i
    .A             (pipeline_groups_2_dsp_A[33:0] ), //i
    .B             (pipeline_groups_2_b_port[23:0]), //i
    .C             (pipeline_groups_2_dsp_C[57:0] ), //i
    .D             (27'h0                         ), //i
    .PCIN          (58'h0                         ), //i
    .P             (pipeline_groups_2_dsp_P[57:0] ), //o
    .OPMODE        (9'h185                        ), //i
    .ALUMODE       (4'b0000                       ), //i
    .INMODE        (5'h0                          ), //i
    .NEGATE        (3'b000                        ), //i
    .CARRYIN       (pipeline_groups_2_dsp_CARRYIN ), //i
    .CARRYINSEL    (3'b000                        ), //i
    .CARRYCASCIN   (1'b0                          ), //i
    .ACIN          (34'h0                         ), //i
    .BCIN          (24'h0                         ), //i
    .MULTSIGNIN    (1'b0                          ), //i
    .CEA1          (ce                            ), //i
    .CEA2          (ce                            ), //i
    .CEB1          (ce                            ), //i
    .CEB2          (ce                            ), //i
    .CEAD          (ce                            ), //i
    .CEALUMODE     (ce                            ), //i
    .CEC           (ce                            ), //i
    .CECARRYIN     (ce                            ), //i
    .CECTRL        (ce                            ), //i
    .CED           (ce                            ), //i
    .CEINMODE      (ce                            ), //i
    .CEM           (ce                            ), //i
    .CEP           (ce                            ), //i
    .RSTA          (rst                           ), //i
    .RSTB          (rst                           ), //i
    .RSTC          (rst                           ), //i
    .RSTD          (rst                           ), //i
    .RSTM          (rst                           ), //i
    .RSTP          (rst                           ), //i
    .RSTCTRL       (rst                           ), //i
    .RSTALUMODE    (rst                           ), //i
    .RSTINMODE     (rst                           ), //i
    .RSTALLCARRYIN (rst                           ), //i
    .ASYNC_RST     (1'b0                          )  //i
  );
  DSP58 #(
    .DSP_MODE      ("INT8" ),
    .USE_SIMD      ("ONE58"),
    .AREG          (1      ),
    .ACASCREG      (1      ),
    .BREG          (1      ),
    .BCASCREG      (1      ),
    .PREG          (1      ),
    .CREG          (0      ),
    .CARRYINREG    (0      ),
    .MREG          (0      ),
    .OPMODEREG     (0      ),
    .CARRYINSELREG (0      ),
    .ALUMODEREG    (0      ),
    .ADREG         (0      ),
    .DREG          (0      ),
    .INMODEREG     (0      )
  ) pipeline_groups_3_dsp (
    .CLK           (clk                           ), //i
    .A             (pipeline_groups_3_dsp_A[33:0] ), //i
    .B             (pipeline_groups_3_b_port[23:0]), //i
    .C             (pipeline_groups_3_dsp_C[57:0] ), //i
    .D             (27'h0                         ), //i
    .PCIN          (58'h0                         ), //i
    .P             (pipeline_groups_3_dsp_P[57:0] ), //o
    .OPMODE        (9'h185                        ), //i
    .ALUMODE       (4'b0000                       ), //i
    .INMODE        (5'h0                          ), //i
    .NEGATE        (3'b000                        ), //i
    .CARRYIN       (pipeline_groups_3_dsp_CARRYIN ), //i
    .CARRYINSEL    (3'b000                        ), //i
    .CARRYCASCIN   (1'b0                          ), //i
    .ACIN          (34'h0                         ), //i
    .BCIN          (24'h0                         ), //i
    .MULTSIGNIN    (1'b0                          ), //i
    .CEA1          (ce                            ), //i
    .CEA2          (ce                            ), //i
    .CEB1          (ce                            ), //i
    .CEB2          (ce                            ), //i
    .CEAD          (ce                            ), //i
    .CEALUMODE     (ce                            ), //i
    .CEC           (ce                            ), //i
    .CECARRYIN     (ce                            ), //i
    .CECTRL        (ce                            ), //i
    .CED           (ce                            ), //i
    .CEINMODE      (ce                            ), //i
    .CEM           (ce                            ), //i
    .CEP           (ce                            ), //i
    .RSTA          (rst                           ), //i
    .RSTB          (rst                           ), //i
    .RSTC          (rst                           ), //i
    .RSTD          (rst                           ), //i
    .RSTM          (rst                           ), //i
    .RSTP          (rst                           ), //i
    .RSTCTRL       (rst                           ), //i
    .RSTALUMODE    (rst                           ), //i
    .RSTINMODE     (rst                           ), //i
    .RSTALLCARRYIN (rst                           ), //i
    .ASYNC_RST     (1'b0                          )  //i
  );
  assign pipeline_groups_0_a = in_data[15 : 0];
  assign pipeline_groups_0_b = in_data[79 : 64];
  assign switch_Dot16_l12 = pipeline_groups_0_a[3 : 0];
  always @(*) begin
    _zz_pipeline_groups_0_a_port = 5'bxxxxx;
    case(switch_Dot16_l12)
      4'b0000 : begin
        _zz_pipeline_groups_0_a_port = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_0_a_port = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_0_a_port = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_0_a_port = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_0_a_port = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_0_a_port = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_0_a_port = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_0_a_port = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_0_a_port = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_0_a_port = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_0_a_port = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_0_a_port = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_0_a_port = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_0_a_port = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_0_a_port = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_0_a_port = 5'h14;
      end
    endcase
  end

  always @(*) begin
    pipeline_groups_0_a_port[8 : 0] = _zz_pipeline_groups_0_a_port_3;
    pipeline_groups_0_a_port[17 : 9] = _zz_pipeline_groups_0_a_port_4;
    pipeline_groups_0_a_port[26 : 18] = _zz_pipeline_groups_0_a_port_5;
  end

  assign switch_Dot16_l12_1 = pipeline_groups_0_b[3 : 0];
  always @(*) begin
    _zz_pipeline_groups_0_b_port = 5'bxxxxx;
    case(switch_Dot16_l12_1)
      4'b0000 : begin
        _zz_pipeline_groups_0_b_port = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_0_b_port = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_0_b_port = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_0_b_port = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_0_b_port = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_0_b_port = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_0_b_port = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_0_b_port = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_0_b_port = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_0_b_port = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_0_b_port = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_0_b_port = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_0_b_port = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_0_b_port = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_0_b_port = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_0_b_port = 5'h14;
      end
    endcase
  end

  always @(*) begin
    pipeline_groups_0_b_port[7 : 0] = _zz_pipeline_groups_0_b_port_3;
    pipeline_groups_0_b_port[15 : 8] = _zz_pipeline_groups_0_b_port_4;
    pipeline_groups_0_b_port[23 : 16] = _zz_pipeline_groups_0_b_port_5;
  end

  assign switch_Dot16_l12_2 = pipeline_groups_0_a[7 : 4];
  always @(*) begin
    _zz_pipeline_groups_0_a_port_1 = 5'bxxxxx;
    case(switch_Dot16_l12_2)
      4'b0000 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_0_a_port_1 = 5'h14;
      end
    endcase
  end

  assign switch_Dot16_l12_3 = pipeline_groups_0_b[7 : 4];
  always @(*) begin
    _zz_pipeline_groups_0_b_port_1 = 5'bxxxxx;
    case(switch_Dot16_l12_3)
      4'b0000 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_0_b_port_1 = 5'h14;
      end
    endcase
  end

  assign switch_Dot16_l12_4 = pipeline_groups_0_a[11 : 8];
  always @(*) begin
    _zz_pipeline_groups_0_a_port_2 = 5'bxxxxx;
    case(switch_Dot16_l12_4)
      4'b0000 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_0_a_port_2 = 5'h14;
      end
    endcase
  end

  assign switch_Dot16_l12_5 = pipeline_groups_0_b[11 : 8];
  always @(*) begin
    _zz_pipeline_groups_0_b_port_2 = 5'bxxxxx;
    case(switch_Dot16_l12_5)
      4'b0000 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_0_b_port_2 = 5'h14;
      end
    endcase
  end

  always @(*) begin
    pipeline_groups_0_magnitude = 8'bxxxxxxxx;
    case(switch_Dot16_l26)
      6'h0 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h01 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h02 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h03 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h04 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h05 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h06 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h07 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h08 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h09 : begin
        pipeline_groups_0_magnitude = 8'h01;
      end
      6'h0a : begin
        pipeline_groups_0_magnitude = 8'h02;
      end
      6'h0b : begin
        pipeline_groups_0_magnitude = 8'h03;
      end
      6'h0c : begin
        pipeline_groups_0_magnitude = 8'h04;
      end
      6'h0d : begin
        pipeline_groups_0_magnitude = 8'h06;
      end
      6'h0e : begin
        pipeline_groups_0_magnitude = 8'h08;
      end
      6'h0f : begin
        pipeline_groups_0_magnitude = 8'h0c;
      end
      6'h10 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h11 : begin
        pipeline_groups_0_magnitude = 8'h02;
      end
      6'h12 : begin
        pipeline_groups_0_magnitude = 8'h04;
      end
      6'h13 : begin
        pipeline_groups_0_magnitude = 8'h06;
      end
      6'h14 : begin
        pipeline_groups_0_magnitude = 8'h08;
      end
      6'h15 : begin
        pipeline_groups_0_magnitude = 8'h0c;
      end
      6'h16 : begin
        pipeline_groups_0_magnitude = 8'h10;
      end
      6'h17 : begin
        pipeline_groups_0_magnitude = 8'h18;
      end
      6'h18 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h19 : begin
        pipeline_groups_0_magnitude = 8'h03;
      end
      6'h1a : begin
        pipeline_groups_0_magnitude = 8'h06;
      end
      6'h1b : begin
        pipeline_groups_0_magnitude = 8'h09;
      end
      6'h1c : begin
        pipeline_groups_0_magnitude = 8'h0c;
      end
      6'h1d : begin
        pipeline_groups_0_magnitude = 8'h12;
      end
      6'h1e : begin
        pipeline_groups_0_magnitude = 8'h18;
      end
      6'h1f : begin
        pipeline_groups_0_magnitude = 8'h24;
      end
      6'h20 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h21 : begin
        pipeline_groups_0_magnitude = 8'h04;
      end
      6'h22 : begin
        pipeline_groups_0_magnitude = 8'h08;
      end
      6'h23 : begin
        pipeline_groups_0_magnitude = 8'h0c;
      end
      6'h24 : begin
        pipeline_groups_0_magnitude = 8'h10;
      end
      6'h25 : begin
        pipeline_groups_0_magnitude = 8'h18;
      end
      6'h26 : begin
        pipeline_groups_0_magnitude = 8'h20;
      end
      6'h27 : begin
        pipeline_groups_0_magnitude = 8'h30;
      end
      6'h28 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h29 : begin
        pipeline_groups_0_magnitude = 8'h06;
      end
      6'h2a : begin
        pipeline_groups_0_magnitude = 8'h0c;
      end
      6'h2b : begin
        pipeline_groups_0_magnitude = 8'h12;
      end
      6'h2c : begin
        pipeline_groups_0_magnitude = 8'h18;
      end
      6'h2d : begin
        pipeline_groups_0_magnitude = 8'h24;
      end
      6'h2e : begin
        pipeline_groups_0_magnitude = 8'h30;
      end
      6'h2f : begin
        pipeline_groups_0_magnitude = 8'h48;
      end
      6'h30 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h31 : begin
        pipeline_groups_0_magnitude = 8'h08;
      end
      6'h32 : begin
        pipeline_groups_0_magnitude = 8'h10;
      end
      6'h33 : begin
        pipeline_groups_0_magnitude = 8'h18;
      end
      6'h34 : begin
        pipeline_groups_0_magnitude = 8'h20;
      end
      6'h35 : begin
        pipeline_groups_0_magnitude = 8'h30;
      end
      6'h36 : begin
        pipeline_groups_0_magnitude = 8'h40;
      end
      6'h37 : begin
        pipeline_groups_0_magnitude = 8'h60;
      end
      6'h38 : begin
        pipeline_groups_0_magnitude = 8'h0;
      end
      6'h39 : begin
        pipeline_groups_0_magnitude = 8'h0c;
      end
      6'h3a : begin
        pipeline_groups_0_magnitude = 8'h18;
      end
      6'h3b : begin
        pipeline_groups_0_magnitude = 8'h24;
      end
      6'h3c : begin
        pipeline_groups_0_magnitude = 8'h30;
      end
      6'h3d : begin
        pipeline_groups_0_magnitude = 8'h48;
      end
      6'h3e : begin
        pipeline_groups_0_magnitude = 8'h60;
      end
      default : begin
        pipeline_groups_0_magnitude = 8'h90;
      end
    endcase
  end

  assign switch_Dot16_l26 = {pipeline_groups_0_a[14 : 12],pipeline_groups_0_b[14 : 12]};
  assign pipeline_groups_0_sign = (pipeline_groups_0_a[15] ^ pipeline_groups_0_b[15]);
  assign pipeline_groups_0_complement = ({1'b0,pipeline_groups_0_magnitude} ^ (pipeline_groups_0_sign ? 9'h1ff : 9'h0));
  assign pipeline_groups_0_dsp_A = _zz_A;
  assign pipeline_groups_0_dsp_C = _zz_C;
  assign pipeline_groups_0_dsp_CARRYIN = pipeline_groups_0_fourth_pipe[9];
  assign pipeline_groups_0_sum = pipeline_groups_0_dsp_P[10 : 0];
  assign pipeline_groups_1_a = in_data[31 : 16];
  assign pipeline_groups_1_b = in_data[95 : 80];
  assign switch_Dot16_l12_6 = pipeline_groups_1_a[3 : 0];
  always @(*) begin
    _zz_pipeline_groups_1_a_port = 5'bxxxxx;
    case(switch_Dot16_l12_6)
      4'b0000 : begin
        _zz_pipeline_groups_1_a_port = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_1_a_port = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_1_a_port = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_1_a_port = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_1_a_port = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_1_a_port = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_1_a_port = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_1_a_port = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_1_a_port = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_1_a_port = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_1_a_port = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_1_a_port = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_1_a_port = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_1_a_port = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_1_a_port = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_1_a_port = 5'h14;
      end
    endcase
  end

  always @(*) begin
    pipeline_groups_1_a_port[8 : 0] = _zz_pipeline_groups_1_a_port_3;
    pipeline_groups_1_a_port[17 : 9] = _zz_pipeline_groups_1_a_port_4;
    pipeline_groups_1_a_port[26 : 18] = _zz_pipeline_groups_1_a_port_5;
  end

  assign switch_Dot16_l12_7 = pipeline_groups_1_b[3 : 0];
  always @(*) begin
    _zz_pipeline_groups_1_b_port = 5'bxxxxx;
    case(switch_Dot16_l12_7)
      4'b0000 : begin
        _zz_pipeline_groups_1_b_port = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_1_b_port = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_1_b_port = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_1_b_port = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_1_b_port = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_1_b_port = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_1_b_port = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_1_b_port = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_1_b_port = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_1_b_port = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_1_b_port = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_1_b_port = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_1_b_port = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_1_b_port = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_1_b_port = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_1_b_port = 5'h14;
      end
    endcase
  end

  always @(*) begin
    pipeline_groups_1_b_port[7 : 0] = _zz_pipeline_groups_1_b_port_3;
    pipeline_groups_1_b_port[15 : 8] = _zz_pipeline_groups_1_b_port_4;
    pipeline_groups_1_b_port[23 : 16] = _zz_pipeline_groups_1_b_port_5;
  end

  assign switch_Dot16_l12_8 = pipeline_groups_1_a[7 : 4];
  always @(*) begin
    _zz_pipeline_groups_1_a_port_1 = 5'bxxxxx;
    case(switch_Dot16_l12_8)
      4'b0000 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_1_a_port_1 = 5'h14;
      end
    endcase
  end

  assign switch_Dot16_l12_9 = pipeline_groups_1_b[7 : 4];
  always @(*) begin
    _zz_pipeline_groups_1_b_port_1 = 5'bxxxxx;
    case(switch_Dot16_l12_9)
      4'b0000 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_1_b_port_1 = 5'h14;
      end
    endcase
  end

  assign switch_Dot16_l12_10 = pipeline_groups_1_a[11 : 8];
  always @(*) begin
    _zz_pipeline_groups_1_a_port_2 = 5'bxxxxx;
    case(switch_Dot16_l12_10)
      4'b0000 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_1_a_port_2 = 5'h14;
      end
    endcase
  end

  assign switch_Dot16_l12_11 = pipeline_groups_1_b[11 : 8];
  always @(*) begin
    _zz_pipeline_groups_1_b_port_2 = 5'bxxxxx;
    case(switch_Dot16_l12_11)
      4'b0000 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_1_b_port_2 = 5'h14;
      end
    endcase
  end

  always @(*) begin
    pipeline_groups_1_magnitude = 8'bxxxxxxxx;
    case(switch_Dot16_l26_1)
      6'h0 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h01 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h02 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h03 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h04 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h05 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h06 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h07 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h08 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h09 : begin
        pipeline_groups_1_magnitude = 8'h01;
      end
      6'h0a : begin
        pipeline_groups_1_magnitude = 8'h02;
      end
      6'h0b : begin
        pipeline_groups_1_magnitude = 8'h03;
      end
      6'h0c : begin
        pipeline_groups_1_magnitude = 8'h04;
      end
      6'h0d : begin
        pipeline_groups_1_magnitude = 8'h06;
      end
      6'h0e : begin
        pipeline_groups_1_magnitude = 8'h08;
      end
      6'h0f : begin
        pipeline_groups_1_magnitude = 8'h0c;
      end
      6'h10 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h11 : begin
        pipeline_groups_1_magnitude = 8'h02;
      end
      6'h12 : begin
        pipeline_groups_1_magnitude = 8'h04;
      end
      6'h13 : begin
        pipeline_groups_1_magnitude = 8'h06;
      end
      6'h14 : begin
        pipeline_groups_1_magnitude = 8'h08;
      end
      6'h15 : begin
        pipeline_groups_1_magnitude = 8'h0c;
      end
      6'h16 : begin
        pipeline_groups_1_magnitude = 8'h10;
      end
      6'h17 : begin
        pipeline_groups_1_magnitude = 8'h18;
      end
      6'h18 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h19 : begin
        pipeline_groups_1_magnitude = 8'h03;
      end
      6'h1a : begin
        pipeline_groups_1_magnitude = 8'h06;
      end
      6'h1b : begin
        pipeline_groups_1_magnitude = 8'h09;
      end
      6'h1c : begin
        pipeline_groups_1_magnitude = 8'h0c;
      end
      6'h1d : begin
        pipeline_groups_1_magnitude = 8'h12;
      end
      6'h1e : begin
        pipeline_groups_1_magnitude = 8'h18;
      end
      6'h1f : begin
        pipeline_groups_1_magnitude = 8'h24;
      end
      6'h20 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h21 : begin
        pipeline_groups_1_magnitude = 8'h04;
      end
      6'h22 : begin
        pipeline_groups_1_magnitude = 8'h08;
      end
      6'h23 : begin
        pipeline_groups_1_magnitude = 8'h0c;
      end
      6'h24 : begin
        pipeline_groups_1_magnitude = 8'h10;
      end
      6'h25 : begin
        pipeline_groups_1_magnitude = 8'h18;
      end
      6'h26 : begin
        pipeline_groups_1_magnitude = 8'h20;
      end
      6'h27 : begin
        pipeline_groups_1_magnitude = 8'h30;
      end
      6'h28 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h29 : begin
        pipeline_groups_1_magnitude = 8'h06;
      end
      6'h2a : begin
        pipeline_groups_1_magnitude = 8'h0c;
      end
      6'h2b : begin
        pipeline_groups_1_magnitude = 8'h12;
      end
      6'h2c : begin
        pipeline_groups_1_magnitude = 8'h18;
      end
      6'h2d : begin
        pipeline_groups_1_magnitude = 8'h24;
      end
      6'h2e : begin
        pipeline_groups_1_magnitude = 8'h30;
      end
      6'h2f : begin
        pipeline_groups_1_magnitude = 8'h48;
      end
      6'h30 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h31 : begin
        pipeline_groups_1_magnitude = 8'h08;
      end
      6'h32 : begin
        pipeline_groups_1_magnitude = 8'h10;
      end
      6'h33 : begin
        pipeline_groups_1_magnitude = 8'h18;
      end
      6'h34 : begin
        pipeline_groups_1_magnitude = 8'h20;
      end
      6'h35 : begin
        pipeline_groups_1_magnitude = 8'h30;
      end
      6'h36 : begin
        pipeline_groups_1_magnitude = 8'h40;
      end
      6'h37 : begin
        pipeline_groups_1_magnitude = 8'h60;
      end
      6'h38 : begin
        pipeline_groups_1_magnitude = 8'h0;
      end
      6'h39 : begin
        pipeline_groups_1_magnitude = 8'h0c;
      end
      6'h3a : begin
        pipeline_groups_1_magnitude = 8'h18;
      end
      6'h3b : begin
        pipeline_groups_1_magnitude = 8'h24;
      end
      6'h3c : begin
        pipeline_groups_1_magnitude = 8'h30;
      end
      6'h3d : begin
        pipeline_groups_1_magnitude = 8'h48;
      end
      6'h3e : begin
        pipeline_groups_1_magnitude = 8'h60;
      end
      default : begin
        pipeline_groups_1_magnitude = 8'h90;
      end
    endcase
  end

  assign switch_Dot16_l26_1 = {pipeline_groups_1_a[14 : 12],pipeline_groups_1_b[14 : 12]};
  assign pipeline_groups_1_sign = (pipeline_groups_1_a[15] ^ pipeline_groups_1_b[15]);
  assign pipeline_groups_1_complement = ({1'b0,pipeline_groups_1_magnitude} ^ (pipeline_groups_1_sign ? 9'h1ff : 9'h0));
  assign pipeline_groups_1_dsp_A = _zz_A_2;
  assign pipeline_groups_1_dsp_C = _zz_C_2;
  assign pipeline_groups_1_dsp_CARRYIN = pipeline_groups_1_fourth_pipe[9];
  assign pipeline_groups_1_sum = pipeline_groups_1_dsp_P[10 : 0];
  assign pipeline_groups_2_a = in_data[47 : 32];
  assign pipeline_groups_2_b = in_data[111 : 96];
  assign switch_Dot16_l12_12 = pipeline_groups_2_a[3 : 0];
  always @(*) begin
    _zz_pipeline_groups_2_a_port = 5'bxxxxx;
    case(switch_Dot16_l12_12)
      4'b0000 : begin
        _zz_pipeline_groups_2_a_port = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_2_a_port = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_2_a_port = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_2_a_port = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_2_a_port = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_2_a_port = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_2_a_port = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_2_a_port = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_2_a_port = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_2_a_port = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_2_a_port = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_2_a_port = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_2_a_port = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_2_a_port = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_2_a_port = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_2_a_port = 5'h14;
      end
    endcase
  end

  always @(*) begin
    pipeline_groups_2_a_port[8 : 0] = _zz_pipeline_groups_2_a_port_3;
    pipeline_groups_2_a_port[17 : 9] = _zz_pipeline_groups_2_a_port_4;
    pipeline_groups_2_a_port[26 : 18] = _zz_pipeline_groups_2_a_port_5;
  end

  assign switch_Dot16_l12_13 = pipeline_groups_2_b[3 : 0];
  always @(*) begin
    _zz_pipeline_groups_2_b_port = 5'bxxxxx;
    case(switch_Dot16_l12_13)
      4'b0000 : begin
        _zz_pipeline_groups_2_b_port = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_2_b_port = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_2_b_port = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_2_b_port = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_2_b_port = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_2_b_port = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_2_b_port = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_2_b_port = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_2_b_port = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_2_b_port = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_2_b_port = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_2_b_port = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_2_b_port = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_2_b_port = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_2_b_port = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_2_b_port = 5'h14;
      end
    endcase
  end

  always @(*) begin
    pipeline_groups_2_b_port[7 : 0] = _zz_pipeline_groups_2_b_port_3;
    pipeline_groups_2_b_port[15 : 8] = _zz_pipeline_groups_2_b_port_4;
    pipeline_groups_2_b_port[23 : 16] = _zz_pipeline_groups_2_b_port_5;
  end

  assign switch_Dot16_l12_14 = pipeline_groups_2_a[7 : 4];
  always @(*) begin
    _zz_pipeline_groups_2_a_port_1 = 5'bxxxxx;
    case(switch_Dot16_l12_14)
      4'b0000 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_2_a_port_1 = 5'h14;
      end
    endcase
  end

  assign switch_Dot16_l12_15 = pipeline_groups_2_b[7 : 4];
  always @(*) begin
    _zz_pipeline_groups_2_b_port_1 = 5'bxxxxx;
    case(switch_Dot16_l12_15)
      4'b0000 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_2_b_port_1 = 5'h14;
      end
    endcase
  end

  assign switch_Dot16_l12_16 = pipeline_groups_2_a[11 : 8];
  always @(*) begin
    _zz_pipeline_groups_2_a_port_2 = 5'bxxxxx;
    case(switch_Dot16_l12_16)
      4'b0000 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_2_a_port_2 = 5'h14;
      end
    endcase
  end

  assign switch_Dot16_l12_17 = pipeline_groups_2_b[11 : 8];
  always @(*) begin
    _zz_pipeline_groups_2_b_port_2 = 5'bxxxxx;
    case(switch_Dot16_l12_17)
      4'b0000 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_2_b_port_2 = 5'h14;
      end
    endcase
  end

  always @(*) begin
    pipeline_groups_2_magnitude = 8'bxxxxxxxx;
    case(switch_Dot16_l26_2)
      6'h0 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h01 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h02 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h03 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h04 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h05 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h06 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h07 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h08 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h09 : begin
        pipeline_groups_2_magnitude = 8'h01;
      end
      6'h0a : begin
        pipeline_groups_2_magnitude = 8'h02;
      end
      6'h0b : begin
        pipeline_groups_2_magnitude = 8'h03;
      end
      6'h0c : begin
        pipeline_groups_2_magnitude = 8'h04;
      end
      6'h0d : begin
        pipeline_groups_2_magnitude = 8'h06;
      end
      6'h0e : begin
        pipeline_groups_2_magnitude = 8'h08;
      end
      6'h0f : begin
        pipeline_groups_2_magnitude = 8'h0c;
      end
      6'h10 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h11 : begin
        pipeline_groups_2_magnitude = 8'h02;
      end
      6'h12 : begin
        pipeline_groups_2_magnitude = 8'h04;
      end
      6'h13 : begin
        pipeline_groups_2_magnitude = 8'h06;
      end
      6'h14 : begin
        pipeline_groups_2_magnitude = 8'h08;
      end
      6'h15 : begin
        pipeline_groups_2_magnitude = 8'h0c;
      end
      6'h16 : begin
        pipeline_groups_2_magnitude = 8'h10;
      end
      6'h17 : begin
        pipeline_groups_2_magnitude = 8'h18;
      end
      6'h18 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h19 : begin
        pipeline_groups_2_magnitude = 8'h03;
      end
      6'h1a : begin
        pipeline_groups_2_magnitude = 8'h06;
      end
      6'h1b : begin
        pipeline_groups_2_magnitude = 8'h09;
      end
      6'h1c : begin
        pipeline_groups_2_magnitude = 8'h0c;
      end
      6'h1d : begin
        pipeline_groups_2_magnitude = 8'h12;
      end
      6'h1e : begin
        pipeline_groups_2_magnitude = 8'h18;
      end
      6'h1f : begin
        pipeline_groups_2_magnitude = 8'h24;
      end
      6'h20 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h21 : begin
        pipeline_groups_2_magnitude = 8'h04;
      end
      6'h22 : begin
        pipeline_groups_2_magnitude = 8'h08;
      end
      6'h23 : begin
        pipeline_groups_2_magnitude = 8'h0c;
      end
      6'h24 : begin
        pipeline_groups_2_magnitude = 8'h10;
      end
      6'h25 : begin
        pipeline_groups_2_magnitude = 8'h18;
      end
      6'h26 : begin
        pipeline_groups_2_magnitude = 8'h20;
      end
      6'h27 : begin
        pipeline_groups_2_magnitude = 8'h30;
      end
      6'h28 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h29 : begin
        pipeline_groups_2_magnitude = 8'h06;
      end
      6'h2a : begin
        pipeline_groups_2_magnitude = 8'h0c;
      end
      6'h2b : begin
        pipeline_groups_2_magnitude = 8'h12;
      end
      6'h2c : begin
        pipeline_groups_2_magnitude = 8'h18;
      end
      6'h2d : begin
        pipeline_groups_2_magnitude = 8'h24;
      end
      6'h2e : begin
        pipeline_groups_2_magnitude = 8'h30;
      end
      6'h2f : begin
        pipeline_groups_2_magnitude = 8'h48;
      end
      6'h30 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h31 : begin
        pipeline_groups_2_magnitude = 8'h08;
      end
      6'h32 : begin
        pipeline_groups_2_magnitude = 8'h10;
      end
      6'h33 : begin
        pipeline_groups_2_magnitude = 8'h18;
      end
      6'h34 : begin
        pipeline_groups_2_magnitude = 8'h20;
      end
      6'h35 : begin
        pipeline_groups_2_magnitude = 8'h30;
      end
      6'h36 : begin
        pipeline_groups_2_magnitude = 8'h40;
      end
      6'h37 : begin
        pipeline_groups_2_magnitude = 8'h60;
      end
      6'h38 : begin
        pipeline_groups_2_magnitude = 8'h0;
      end
      6'h39 : begin
        pipeline_groups_2_magnitude = 8'h0c;
      end
      6'h3a : begin
        pipeline_groups_2_magnitude = 8'h18;
      end
      6'h3b : begin
        pipeline_groups_2_magnitude = 8'h24;
      end
      6'h3c : begin
        pipeline_groups_2_magnitude = 8'h30;
      end
      6'h3d : begin
        pipeline_groups_2_magnitude = 8'h48;
      end
      6'h3e : begin
        pipeline_groups_2_magnitude = 8'h60;
      end
      default : begin
        pipeline_groups_2_magnitude = 8'h90;
      end
    endcase
  end

  assign switch_Dot16_l26_2 = {pipeline_groups_2_a[14 : 12],pipeline_groups_2_b[14 : 12]};
  assign pipeline_groups_2_sign = (pipeline_groups_2_a[15] ^ pipeline_groups_2_b[15]);
  assign pipeline_groups_2_complement = ({1'b0,pipeline_groups_2_magnitude} ^ (pipeline_groups_2_sign ? 9'h1ff : 9'h0));
  assign pipeline_groups_2_dsp_A = _zz_A_4;
  assign pipeline_groups_2_dsp_C = _zz_C_4;
  assign pipeline_groups_2_dsp_CARRYIN = pipeline_groups_2_fourth_pipe[9];
  assign pipeline_groups_2_sum = pipeline_groups_2_dsp_P[10 : 0];
  assign pipeline_groups_3_a = in_data[63 : 48];
  assign pipeline_groups_3_b = in_data[127 : 112];
  assign switch_Dot16_l12_18 = pipeline_groups_3_a[3 : 0];
  always @(*) begin
    _zz_pipeline_groups_3_a_port = 5'bxxxxx;
    case(switch_Dot16_l12_18)
      4'b0000 : begin
        _zz_pipeline_groups_3_a_port = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_3_a_port = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_3_a_port = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_3_a_port = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_3_a_port = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_3_a_port = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_3_a_port = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_3_a_port = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_3_a_port = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_3_a_port = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_3_a_port = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_3_a_port = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_3_a_port = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_3_a_port = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_3_a_port = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_3_a_port = 5'h14;
      end
    endcase
  end

  always @(*) begin
    pipeline_groups_3_a_port[8 : 0] = _zz_pipeline_groups_3_a_port_3;
    pipeline_groups_3_a_port[17 : 9] = _zz_pipeline_groups_3_a_port_4;
    pipeline_groups_3_a_port[26 : 18] = _zz_pipeline_groups_3_a_port_5;
  end

  assign switch_Dot16_l12_19 = pipeline_groups_3_b[3 : 0];
  always @(*) begin
    _zz_pipeline_groups_3_b_port = 5'bxxxxx;
    case(switch_Dot16_l12_19)
      4'b0000 : begin
        _zz_pipeline_groups_3_b_port = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_3_b_port = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_3_b_port = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_3_b_port = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_3_b_port = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_3_b_port = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_3_b_port = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_3_b_port = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_3_b_port = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_3_b_port = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_3_b_port = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_3_b_port = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_3_b_port = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_3_b_port = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_3_b_port = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_3_b_port = 5'h14;
      end
    endcase
  end

  always @(*) begin
    pipeline_groups_3_b_port[7 : 0] = _zz_pipeline_groups_3_b_port_3;
    pipeline_groups_3_b_port[15 : 8] = _zz_pipeline_groups_3_b_port_4;
    pipeline_groups_3_b_port[23 : 16] = _zz_pipeline_groups_3_b_port_5;
  end

  assign switch_Dot16_l12_20 = pipeline_groups_3_a[7 : 4];
  always @(*) begin
    _zz_pipeline_groups_3_a_port_1 = 5'bxxxxx;
    case(switch_Dot16_l12_20)
      4'b0000 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_3_a_port_1 = 5'h14;
      end
    endcase
  end

  assign switch_Dot16_l12_21 = pipeline_groups_3_b[7 : 4];
  always @(*) begin
    _zz_pipeline_groups_3_b_port_1 = 5'bxxxxx;
    case(switch_Dot16_l12_21)
      4'b0000 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_3_b_port_1 = 5'h14;
      end
    endcase
  end

  assign switch_Dot16_l12_22 = pipeline_groups_3_a[11 : 8];
  always @(*) begin
    _zz_pipeline_groups_3_a_port_2 = 5'bxxxxx;
    case(switch_Dot16_l12_22)
      4'b0000 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_3_a_port_2 = 5'h14;
      end
    endcase
  end

  assign switch_Dot16_l12_23 = pipeline_groups_3_b[11 : 8];
  always @(*) begin
    _zz_pipeline_groups_3_b_port_2 = 5'bxxxxx;
    case(switch_Dot16_l12_23)
      4'b0000 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h0;
      end
      4'b0001 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h01;
      end
      4'b0010 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h02;
      end
      4'b0011 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h03;
      end
      4'b0100 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h04;
      end
      4'b0101 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h06;
      end
      4'b0110 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h08;
      end
      4'b0111 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h0c;
      end
      4'b1000 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h0;
      end
      4'b1001 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h1f;
      end
      4'b1010 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h1e;
      end
      4'b1011 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h1d;
      end
      4'b1100 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h1c;
      end
      4'b1101 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h1a;
      end
      4'b1110 : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h18;
      end
      default : begin
        _zz_pipeline_groups_3_b_port_2 = 5'h14;
      end
    endcase
  end

  always @(*) begin
    pipeline_groups_3_magnitude = 8'bxxxxxxxx;
    case(switch_Dot16_l26_3)
      6'h0 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h01 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h02 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h03 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h04 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h05 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h06 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h07 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h08 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h09 : begin
        pipeline_groups_3_magnitude = 8'h01;
      end
      6'h0a : begin
        pipeline_groups_3_magnitude = 8'h02;
      end
      6'h0b : begin
        pipeline_groups_3_magnitude = 8'h03;
      end
      6'h0c : begin
        pipeline_groups_3_magnitude = 8'h04;
      end
      6'h0d : begin
        pipeline_groups_3_magnitude = 8'h06;
      end
      6'h0e : begin
        pipeline_groups_3_magnitude = 8'h08;
      end
      6'h0f : begin
        pipeline_groups_3_magnitude = 8'h0c;
      end
      6'h10 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h11 : begin
        pipeline_groups_3_magnitude = 8'h02;
      end
      6'h12 : begin
        pipeline_groups_3_magnitude = 8'h04;
      end
      6'h13 : begin
        pipeline_groups_3_magnitude = 8'h06;
      end
      6'h14 : begin
        pipeline_groups_3_magnitude = 8'h08;
      end
      6'h15 : begin
        pipeline_groups_3_magnitude = 8'h0c;
      end
      6'h16 : begin
        pipeline_groups_3_magnitude = 8'h10;
      end
      6'h17 : begin
        pipeline_groups_3_magnitude = 8'h18;
      end
      6'h18 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h19 : begin
        pipeline_groups_3_magnitude = 8'h03;
      end
      6'h1a : begin
        pipeline_groups_3_magnitude = 8'h06;
      end
      6'h1b : begin
        pipeline_groups_3_magnitude = 8'h09;
      end
      6'h1c : begin
        pipeline_groups_3_magnitude = 8'h0c;
      end
      6'h1d : begin
        pipeline_groups_3_magnitude = 8'h12;
      end
      6'h1e : begin
        pipeline_groups_3_magnitude = 8'h18;
      end
      6'h1f : begin
        pipeline_groups_3_magnitude = 8'h24;
      end
      6'h20 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h21 : begin
        pipeline_groups_3_magnitude = 8'h04;
      end
      6'h22 : begin
        pipeline_groups_3_magnitude = 8'h08;
      end
      6'h23 : begin
        pipeline_groups_3_magnitude = 8'h0c;
      end
      6'h24 : begin
        pipeline_groups_3_magnitude = 8'h10;
      end
      6'h25 : begin
        pipeline_groups_3_magnitude = 8'h18;
      end
      6'h26 : begin
        pipeline_groups_3_magnitude = 8'h20;
      end
      6'h27 : begin
        pipeline_groups_3_magnitude = 8'h30;
      end
      6'h28 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h29 : begin
        pipeline_groups_3_magnitude = 8'h06;
      end
      6'h2a : begin
        pipeline_groups_3_magnitude = 8'h0c;
      end
      6'h2b : begin
        pipeline_groups_3_magnitude = 8'h12;
      end
      6'h2c : begin
        pipeline_groups_3_magnitude = 8'h18;
      end
      6'h2d : begin
        pipeline_groups_3_magnitude = 8'h24;
      end
      6'h2e : begin
        pipeline_groups_3_magnitude = 8'h30;
      end
      6'h2f : begin
        pipeline_groups_3_magnitude = 8'h48;
      end
      6'h30 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h31 : begin
        pipeline_groups_3_magnitude = 8'h08;
      end
      6'h32 : begin
        pipeline_groups_3_magnitude = 8'h10;
      end
      6'h33 : begin
        pipeline_groups_3_magnitude = 8'h18;
      end
      6'h34 : begin
        pipeline_groups_3_magnitude = 8'h20;
      end
      6'h35 : begin
        pipeline_groups_3_magnitude = 8'h30;
      end
      6'h36 : begin
        pipeline_groups_3_magnitude = 8'h40;
      end
      6'h37 : begin
        pipeline_groups_3_magnitude = 8'h60;
      end
      6'h38 : begin
        pipeline_groups_3_magnitude = 8'h0;
      end
      6'h39 : begin
        pipeline_groups_3_magnitude = 8'h0c;
      end
      6'h3a : begin
        pipeline_groups_3_magnitude = 8'h18;
      end
      6'h3b : begin
        pipeline_groups_3_magnitude = 8'h24;
      end
      6'h3c : begin
        pipeline_groups_3_magnitude = 8'h30;
      end
      6'h3d : begin
        pipeline_groups_3_magnitude = 8'h48;
      end
      6'h3e : begin
        pipeline_groups_3_magnitude = 8'h60;
      end
      default : begin
        pipeline_groups_3_magnitude = 8'h90;
      end
    endcase
  end

  assign switch_Dot16_l26_3 = {pipeline_groups_3_a[14 : 12],pipeline_groups_3_b[14 : 12]};
  assign pipeline_groups_3_sign = (pipeline_groups_3_a[15] ^ pipeline_groups_3_b[15]);
  assign pipeline_groups_3_complement = ({1'b0,pipeline_groups_3_magnitude} ^ (pipeline_groups_3_sign ? 9'h1ff : 9'h0));
  assign pipeline_groups_3_dsp_A = _zz_A_6;
  assign pipeline_groups_3_dsp_C = _zz_C_6;
  assign pipeline_groups_3_dsp_CARRYIN = pipeline_groups_3_fourth_pipe[9];
  assign pipeline_groups_3_sum = pipeline_groups_3_dsp_P[10 : 0];
  assign pipeline_pair_left = ($signed(_zz_pipeline_pair_left) + $signed(_zz_pipeline_pair_left_1));
  assign pipeline_pair_right = ($signed(_zz_pipeline_pair_right) + $signed(_zz_pipeline_pair_right_1));
  assign pipeline_total = ($signed(_zz_pipeline_total) + $signed(_zz_pipeline_total_1));
  assign pipeline_scaling_scales_0_code = in_data[135 : 128];
  assign pipeline_scaling_scales_0_exponent = pipeline_scaling_scales_0_code[6 : 3];
  assign pipeline_scaling_scales_0_fraction = pipeline_scaling_scales_0_code[2 : 0];
  assign pipeline_scaling_scales_0_invalid = (pipeline_scaling_scales_0_code[6 : 0] == 7'h7f);
  always @(*) begin
    pipeline_scaling_scales_0_magnitude = (4'b1000 | _zz_pipeline_scaling_scales_0_magnitude);
    if(when_Dot16_l103) begin
      pipeline_scaling_scales_0_magnitude = {1'd0, pipeline_scaling_scales_0_fraction};
    end
    if(pipeline_scaling_scales_0_invalid) begin
      pipeline_scaling_scales_0_magnitude = 4'b0000;
    end
  end

  assign when_Dot16_l103 = (pipeline_scaling_scales_0_exponent == 4'b0000);
  assign pipeline_scaling_scales_0_mantissa = _zz_pipeline_scaling_scales_0_mantissa;
  assign pipeline_scaling_scales_0_signed_mantissa = (pipeline_scaling_scales_0_code[7] ? _zz_pipeline_scaling_scales_0_signed_mantissa : pipeline_scaling_scales_0_mantissa);
  assign pipeline_scaling_scales_0_shift = ((pipeline_scaling_scales_0_exponent == 4'b0000) ? 4'b0000 : _zz_pipeline_scaling_scales_0_shift);
  assign pipeline_scaling_scales_1_code = in_data[143 : 136];
  assign pipeline_scaling_scales_1_exponent = pipeline_scaling_scales_1_code[6 : 3];
  assign pipeline_scaling_scales_1_fraction = pipeline_scaling_scales_1_code[2 : 0];
  assign pipeline_scaling_scales_1_invalid = (pipeline_scaling_scales_1_code[6 : 0] == 7'h7f);
  always @(*) begin
    pipeline_scaling_scales_1_magnitude = (4'b1000 | _zz_pipeline_scaling_scales_1_magnitude);
    if(when_Dot16_l103_1) begin
      pipeline_scaling_scales_1_magnitude = {1'd0, pipeline_scaling_scales_1_fraction};
    end
    if(pipeline_scaling_scales_1_invalid) begin
      pipeline_scaling_scales_1_magnitude = 4'b0000;
    end
  end

  assign when_Dot16_l103_1 = (pipeline_scaling_scales_1_exponent == 4'b0000);
  assign pipeline_scaling_scales_1_mantissa = _zz_pipeline_scaling_scales_1_mantissa;
  assign pipeline_scaling_scales_1_signed_mantissa = (pipeline_scaling_scales_1_code[7] ? _zz_pipeline_scaling_scales_1_signed_mantissa : pipeline_scaling_scales_1_mantissa);
  assign pipeline_scaling_scales_1_shift = ((pipeline_scaling_scales_1_exponent == 4'b0000) ? 4'b0000 : _zz_pipeline_scaling_scales_1_shift);
  assign pipeline_scaling_mantissa_product = ($signed(pipeline_scaling_scales_0_m1) * $signed(pipeline_scaling_scales_1_m1));
  assign pipeline_scaling_product = ($signed(pipeline_scaling_q3) * $signed(pipeline_scaling_k3));
  assign out_data = pipeline_scaling_shifted5;
  assign out_invalid = _zz_out_invalid;
  assign out_valid = _zz_out_valid_2;
  always @(posedge clk) begin
    if(rst) begin
      pipeline_valid_pipe <= 2'b00;
      pipeline_groups_0_fourth_pipe <= 10'h0;
      pipeline_groups_1_fourth_pipe <= 10'h0;
      pipeline_groups_2_fourth_pipe <= 10'h0;
      pipeline_groups_3_fourth_pipe <= 10'h0;
      pipeline_scaling_scales_0_m1 <= 5'h0;
      pipeline_scaling_scales_0_h1 <= 4'b0000;
      pipeline_scaling_scales_0_invalid1 <= 1'b0;
      pipeline_scaling_scales_1_m1 <= 5'h0;
      pipeline_scaling_scales_1_h1 <= 4'b0000;
      pipeline_scaling_scales_1_invalid1 <= 1'b0;
      pipeline_scaling_k2 <= 9'h0;
      pipeline_scaling_h2 <= 5'h0;
      pipeline_scaling_invalid2 <= 1'b0;
      pipeline_scaling_q3 <= 13'h0;
      pipeline_scaling_k3 <= 9'h0;
      pipeline_scaling_h3 <= 5'h0;
      pipeline_scaling_invalid3 <= 1'b0;
      pipeline_scaling_p4 <= 20'h0;
      pipeline_scaling_h4 <= 5'h0;
      pipeline_scaling_invalid4 <= 1'b0;
      pipeline_scaling_shifted5 <= 48'h0;
      _zz_out_invalid <= 1'b0;
      _zz_out_valid <= 1'b0;
      _zz_out_valid_1 <= 1'b0;
      _zz_out_valid_2 <= 1'b0;
    end else begin
      if(ce) begin
        pipeline_valid_pipe <= {pipeline_valid_pipe[0],in_valid};
      end
      if(ce) begin
        pipeline_groups_0_fourth_pipe <= {pipeline_groups_0_sign,pipeline_groups_0_complement};
      end
      if(ce) begin
        pipeline_groups_1_fourth_pipe <= {pipeline_groups_1_sign,pipeline_groups_1_complement};
      end
      if(ce) begin
        pipeline_groups_2_fourth_pipe <= {pipeline_groups_2_sign,pipeline_groups_2_complement};
      end
      if(ce) begin
        pipeline_groups_3_fourth_pipe <= {pipeline_groups_3_sign,pipeline_groups_3_complement};
      end
      if(ce) begin
        pipeline_scaling_scales_0_m1 <= pipeline_scaling_scales_0_signed_mantissa;
      end
      if(ce) begin
        pipeline_scaling_scales_0_h1 <= pipeline_scaling_scales_0_shift;
      end
      if(ce) begin
        pipeline_scaling_scales_0_invalid1 <= pipeline_scaling_scales_0_invalid;
      end
      if(ce) begin
        pipeline_scaling_scales_1_m1 <= pipeline_scaling_scales_1_signed_mantissa;
      end
      if(ce) begin
        pipeline_scaling_scales_1_h1 <= pipeline_scaling_scales_1_shift;
      end
      if(ce) begin
        pipeline_scaling_scales_1_invalid1 <= pipeline_scaling_scales_1_invalid;
      end
      if(ce) begin
        pipeline_scaling_k2 <= pipeline_scaling_mantissa_product[8:0];
      end
      if(ce) begin
        pipeline_scaling_h2 <= (_zz_pipeline_scaling_h2 + _zz_pipeline_scaling_h2_1);
      end
      if(ce) begin
        pipeline_scaling_invalid2 <= (pipeline_scaling_scales_0_invalid1 || pipeline_scaling_scales_1_invalid1);
      end
      if(ce) begin
        pipeline_scaling_q3 <= pipeline_total;
      end
      if(ce) begin
        pipeline_scaling_k3 <= pipeline_scaling_k2;
      end
      if(ce) begin
        pipeline_scaling_h3 <= pipeline_scaling_h2;
      end
      if(ce) begin
        pipeline_scaling_invalid3 <= pipeline_scaling_invalid2;
      end
      if(ce) begin
        pipeline_scaling_p4 <= pipeline_scaling_product[19:0];
      end
      if(ce) begin
        pipeline_scaling_h4 <= pipeline_scaling_h3;
      end
      if(ce) begin
        pipeline_scaling_invalid4 <= pipeline_scaling_invalid3;
      end
      if(ce) begin
        pipeline_scaling_shifted5 <= ($signed(_zz_pipeline_scaling_shifted5) <<< pipeline_scaling_h4);
      end
      if(ce) begin
        _zz_out_invalid <= pipeline_scaling_invalid4;
      end
      if(ce) begin
        _zz_out_valid <= pipeline_valid_pipe[1];
      end
      if(ce) begin
        _zz_out_valid_1 <= _zz_out_valid;
      end
      if(ce) begin
        _zz_out_valid_2 <= _zz_out_valid_1;
      end
    end
  end


endmodule
