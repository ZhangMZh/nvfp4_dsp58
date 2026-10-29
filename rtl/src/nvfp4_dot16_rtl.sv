// SPDX-License-Identifier: MIT
`timescale 1ns/1ps
// Vitis HLS RTL-blackbox FIFO adapter. All transfers are qualified by ap_ce.
module nvfp4_dot16_rtl (
    input wire ap_clk, ap_rst, ap_ce,
    input wire [127:0] input_dout,
    input wire input_empty_n,
    output wire input_read,
    output wire [15:0] output_din,
    input wire output_full_n,
    output wire output_write
);
    wire valid;
    wire signed [12:0] q;
    wire advance = !ap_rst && ap_ce && (!valid || output_full_n);
    assign input_read = advance && input_empty_n;
    assign output_write = !ap_rst && ap_ce && valid && output_full_n;
    assign output_din = {{3{q[12]}}, q};
    nvfp4_dot16 core (
        .clk(ap_clk),
        .rst(ap_rst),
        .ce(advance),
        .in_valid(input_empty_n),
        .in_data(input_dout),
        .out_valid(valid),
        .out_data(q)
    );
endmodule
