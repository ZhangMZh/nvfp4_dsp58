// SPDX-License-Identifier: MIT
`timescale 1ns/1ps

// Two slots decouple both forward data/valid and reverse ready paths.
// No combinational path crosses from one external interface to the other.
module nvfp4_dot16_fifo2 #(
    parameter integer WIDTH = 128
) (
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] s_data,
    input wire s_valid,
    output wire s_ready,
    output wire [WIDTH-1:0] m_data,
    output wire m_valid,
    input wire m_ready
);
    (* ram_style = "registers" *) reg [WIDTH-1:0] storage[0:1];
    reg write_pointer, read_pointer;
    reg [1:0] count;
    assign s_ready = !rst && count != 2;
    assign m_valid = !rst && count != 0;
    assign m_data = storage[read_pointer];
    wire push = s_valid && s_ready;
    wire pop = m_valid && m_ready;
    always @(posedge clk) begin
        if (rst) begin
            storage[0] <= 0;
            storage[1] <= 0;
            write_pointer <= 0;
            read_pointer <= 0;
            count <= 0;
        end else begin
            if (push) begin
                storage[write_pointer] <= s_data;
                write_pointer <= !write_pointer;
            end
            if (pop)
                read_pointer <= !read_pointer;
            case ({push, pop})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end
endmodule

// Synthesizable integration fixture: FIFO -> selected-mode core -> FIFO.
// Both FIFOs add one unstalled handshake cycle; core latency is unchanged.
`ifdef BLOCK_SCALING
module nvfp4_scaled_dot16_fixture #(
    parameter integer INPUT_WIDTH = 144, OUTPUT_WIDTH = 64
`else
module nvfp4_dot16_fixture #(
    parameter integer INPUT_WIDTH = 128, OUTPUT_WIDTH = 16
`endif
) (
    input wire ap_clk,
    input wire ap_rst,
    input wire [INPUT_WIDTH-1:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output wire s_axis_tready,
    output wire [OUTPUT_WIDTH-1:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready
);
    wire [INPUT_WIDTH-1:0] core_input;
    wire input_valid, input_ready;
    wire [OUTPUT_WIDTH-1:0] core_output;
    wire output_valid, output_ready;
    (* keep_hierarchy = "yes" *) nvfp4_dot16_fifo2 #(.WIDTH(INPUT_WIDTH)) upstream (
        .clk(ap_clk),
        .rst(ap_rst),
        .s_data(s_axis_tdata),
        .s_valid(s_axis_tvalid),
        .s_ready(s_axis_tready),
        .m_data(core_input),
        .m_valid(input_valid),
        .m_ready(input_ready)
    );
`ifdef BLOCK_SCALING
    (* keep_hierarchy = "yes" *) nvfp4_scaled_dot16_axis dut (
`else
    (* keep_hierarchy = "yes" *) nvfp4_dot16_axis dut (
`endif
        .ap_clk(ap_clk),
        .ap_rst(ap_rst),
        .s_axis_tdata(core_input),
        .s_axis_tvalid(input_valid),
        .s_axis_tready(input_ready),
        .m_axis_tdata(core_output),
        .m_axis_tvalid(output_valid),
        .m_axis_tready(output_ready)
    );
    (* keep_hierarchy = "yes" *) nvfp4_dot16_fifo2 #(.WIDTH(OUTPUT_WIDTH)) downstream (
        .clk(ap_clk),
        .rst(ap_rst),
        .s_data(core_output),
        .s_valid(output_valid),
        .s_ready(output_ready),
        .m_data(m_axis_tdata),
        .m_valid(m_axis_tvalid),
        .m_ready(m_axis_tready)
    );
endmodule
