// SPDX-License-Identifier: MIT
`timescale 1ns/1ps
// One 128-bit beat contains {b[63:0], a[63:0]}; one 16-bit beat returns Q.
module nvfp4_dot16_axis (
    input wire ap_clk,
    input wire ap_rst,
    input wire [127:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output wire s_axis_tready,
    output wire [15:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready
);
    wire valid;
    wire signed [12:0] q;
    wire advance = !ap_rst && (!valid || m_axis_tready);
    assign s_axis_tready = advance;
    assign m_axis_tvalid = !ap_rst && valid;
    assign m_axis_tdata = {{3{q[12]}}, q};
    nvfp4_dot16 core (
        .clk(ap_clk),
        .rst(ap_rst),
        .ce(advance),
        .in_valid(s_axis_tvalid),
        .in_data(s_axis_tdata),
        .out_valid(valid),
        .out_data(q)
    );
endmodule
