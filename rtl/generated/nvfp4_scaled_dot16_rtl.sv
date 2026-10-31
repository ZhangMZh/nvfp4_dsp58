// Generator : SpinalHDL v1.15.0    git head : 05a01af3d3345aa0afcaad8e0186dde13a359db2
// Component : nvfp4_scaled_dot16_rtl
// SPDX-License-Identifier: MIT
// Generated from rtl/spinal/; edit Scala and run cmake --build <build-dir> --target rtl-gen.

`timescale 1ns/1ps
module nvfp4_scaled_dot16_rtl (
  input  wire          ap_clk,
  input  wire          ap_rst,
  input  wire          ap_ce,
  input  wire [143:0]  input_dout,
  input  wire          input_empty_n,
  output wire          input_read,
  output wire [63:0]   output_din,
  input  wire          output_full_n,
  output wire          output_write
);

  wire                core_out_valid;
  wire       [47:0]   core_out_data;
  wire                core_out_invalid;
  wire                advance;

  nvfp4_scaled_dot16 core (
    .clk         (ap_clk             ), //i
    .rst         (ap_rst             ), //i
    .ce          (advance            ), //i
    .in_valid    (input_empty_n      ), //i
    .in_data     (input_dout[143:0]  ), //i
    .out_valid   (core_out_valid     ), //o
    .out_data    (core_out_data[47:0]), //o
    .out_invalid (core_out_invalid   )  //o
  );
  assign advance = (((! ap_rst) && ap_ce) && ((! core_out_valid) || output_full_n));
  assign input_read = (advance && input_empty_n);
  assign output_write = ((((! ap_rst) && ap_ce) && core_out_valid) && output_full_n);
  assign output_din = {{15'h0,core_out_invalid},core_out_data};

endmodule
