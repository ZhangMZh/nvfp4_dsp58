// Generator : SpinalHDL v1.15.0    git head : 05a01af3d3345aa0afcaad8e0186dde13a359db2
// Component : nvfp4_dot16_axis
// SPDX-License-Identifier: MIT
// Generated from rtl/spinal/; edit Scala and run cmake --build <build-dir> --target rtl-gen.

`timescale 1ns/1ps
module nvfp4_dot16_axis (
  input  wire          ap_clk,
  input  wire          ap_rst,
  input  wire [127:0]  s_axis_tdata,
  input  wire          s_axis_tvalid,
  output wire          s_axis_tready,
  output wire [15:0]   m_axis_tdata,
  output wire          m_axis_tvalid,
  input  wire          m_axis_tready
);

  wire                core_out_valid;
  wire       [12:0]   core_out_data;
  wire       [15:0]   _zz_m_axis_tdata;
  wire                advance;

  assign _zz_m_axis_tdata = {{3{core_out_data[12]}}, core_out_data};
  nvfp4_dot16 core (
    .clk       (ap_clk             ), //i
    .rst       (ap_rst             ), //i
    .ce        (advance            ), //i
    .in_valid  (s_axis_tvalid      ), //i
    .in_data   (s_axis_tdata[127:0]), //i
    .out_valid (core_out_valid     ), //o
    .out_data  (core_out_data[12:0])  //o
  );
  assign advance = ((! ap_rst) && ((! core_out_valid) || m_axis_tready));
  assign s_axis_tready = advance;
  assign m_axis_tvalid = ((! ap_rst) && core_out_valid);
  assign m_axis_tdata = _zz_m_axis_tdata;

endmodule
