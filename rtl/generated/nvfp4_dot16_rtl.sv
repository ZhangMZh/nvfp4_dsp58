// Generator : SpinalHDL v1.15.0    git head : 05a01af3d3345aa0afcaad8e0186dde13a359db2
// Component : nvfp4_dot16_rtl
// SPDX-License-Identifier: MIT
// Generated from rtl/spinal/; edit Scala and run make rtl-gen.

`timescale 1ns/1ps
module nvfp4_dot16_rtl (
  input  wire          ap_clk,
  input  wire          ap_rst,
  input  wire          ap_ce,
  input  wire [127:0]  input_dout,
  input  wire          input_empty_n,
  output wire          input_read,
  output wire [15:0]   output_din,
  input  wire          output_full_n,
  output wire          output_write
);

  wire                core_out_valid;
  wire       [12:0]   core_out_data;
  wire       [15:0]   _zz_output_din;
  wire                advance;

  assign _zz_output_din = {{3{core_out_data[12]}}, core_out_data};
  nvfp4_dot16 core (
    .clk       (ap_clk             ), //i
    .rst       (ap_rst             ), //i
    .ce        (advance            ), //i
    .in_valid  (input_empty_n      ), //i
    .in_data   (input_dout[127:0]  ), //i
    .out_valid (core_out_valid     ), //o
    .out_data  (core_out_data[12:0])  //o
  );
  assign advance = (((! ap_rst) && ap_ce) && ((! core_out_valid) || output_full_n));
  assign input_read = (advance && input_empty_n);
  assign output_write = ((((! ap_rst) && ap_ce) && core_out_valid) && output_full_n);
  assign output_din = _zz_output_din;

endmodule
