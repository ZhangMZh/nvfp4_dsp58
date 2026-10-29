// SPDX-License-Identifier: MIT
`timescale 1ns/1ps
// Exact sum of 16 q(a)*q(b), where q(E2M1) = 2*E2M1.
// Two enabled register stages; the output adder is combinational.
// CE freezes all DSP results and valid, holding the output under backpressure.
module nvfp4_dot16 (
    input wire clk,
    input wire rst,
    input wire ce,
    input wire in_valid,
    input wire [127:0] in_data,
    output wire out_valid,
    output wire signed [12:0] out_data
);
    function automatic [4:0] decode(input [3:0] code);
        begin
            case (code)
                4'h0, 4'h8: decode = 5'sd0;
                4'h1: decode = 5'sd1;
                4'h9: decode = -5'sd1;
                4'h2: decode = 5'sd2;
                4'ha: decode = -5'sd2;
                4'h3: decode = 5'sd3;
                4'hb: decode = -5'sd3;
                4'h4: decode = 5'sd4;
                4'hc: decode = -5'sd4;
                4'h5: decode = 5'sd6;
                4'hd: decode = -5'sd6;
                4'h6: decode = 5'sd8;
                4'he: decode = -5'sd8;
                4'h7: decode = 5'sd12;
                4'hf: decode = -5'sd12;
                default: decode = 5'bx;
            endcase
        end
    endfunction

    // Six address bits, eight result bits: four instances, not four LUT cells.
    // A constant truth table prevents inference of a fifth DSP multiplier.
    function automatic [7:0] magnitude_product(input [5:0] address);
        begin
            case (address)
                6'h00: magnitude_product = 0;
                6'h01: magnitude_product = 0;
                6'h02: magnitude_product = 0;
                6'h03: magnitude_product = 0;
                6'h04: magnitude_product = 0;
                6'h05: magnitude_product = 0;
                6'h06: magnitude_product = 0;
                6'h07: magnitude_product = 0;
                6'h08: magnitude_product = 0;
                6'h09: magnitude_product = 1;
                6'h0a: magnitude_product = 2;
                6'h0b: magnitude_product = 3;
                6'h0c: magnitude_product = 4;
                6'h0d: magnitude_product = 6;
                6'h0e: magnitude_product = 8;
                6'h0f: magnitude_product = 12;
                6'h10: magnitude_product = 0;
                6'h11: magnitude_product = 2;
                6'h12: magnitude_product = 4;
                6'h13: magnitude_product = 6;
                6'h14: magnitude_product = 8;
                6'h15: magnitude_product = 12;
                6'h16: magnitude_product = 16;
                6'h17: magnitude_product = 24;
                6'h18: magnitude_product = 0;
                6'h19: magnitude_product = 3;
                6'h1a: magnitude_product = 6;
                6'h1b: magnitude_product = 9;
                6'h1c: magnitude_product = 12;
                6'h1d: magnitude_product = 18;
                6'h1e: magnitude_product = 24;
                6'h1f: magnitude_product = 36;
                6'h20: magnitude_product = 0;
                6'h21: magnitude_product = 4;
                6'h22: magnitude_product = 8;
                6'h23: magnitude_product = 12;
                6'h24: magnitude_product = 16;
                6'h25: magnitude_product = 24;
                6'h26: magnitude_product = 32;
                6'h27: magnitude_product = 48;
                6'h28: magnitude_product = 0;
                6'h29: magnitude_product = 6;
                6'h2a: magnitude_product = 12;
                6'h2b: magnitude_product = 18;
                6'h2c: magnitude_product = 24;
                6'h2d: magnitude_product = 36;
                6'h2e: magnitude_product = 48;
                6'h2f: magnitude_product = 72;
                6'h30: magnitude_product = 0;
                6'h31: magnitude_product = 8;
                6'h32: magnitude_product = 16;
                6'h33: magnitude_product = 24;
                6'h34: magnitude_product = 32;
                6'h35: magnitude_product = 48;
                6'h36: magnitude_product = 64;
                6'h37: magnitude_product = 96;
                6'h38: magnitude_product = 0;
                6'h39: magnitude_product = 12;
                6'h3a: magnitude_product = 24;
                6'h3b: magnitude_product = 36;
                6'h3c: magnitude_product = 48;
                6'h3d: magnitude_product = 72;
                6'h3e: magnitude_product = 96;
                6'h3f: magnitude_product = 144;
                default: magnitude_product = 8'bx;
            endcase
        end
    endfunction

    (* shreg_extract = "no" *) reg [1:0] valid_pipe;
    always @(posedge clk) begin
        if (rst)
            valid_pipe <= 2'b0;
        else if (ce)
            valid_pipe <= {valid_pipe[0], in_valid};
    end
    assign out_valid = valid_pipe[1];
    wire [57:0] result[0:3];

    for (genvar g = 0; g < 4; g = g + 1) begin : groups
        wire [15:0] a = in_data[g * 16 +: 16];
        wire [15:0] b = in_data[64 + g * 16 +: 16];
        wire [7:0] mag = magnitude_product({a[14:12], b[14:12]});
        wire sign4 = a[15] ^ b[15];
        wire [8:0] complement = {1'b0, mag} ^ {9{sign4}};
        wire [26:0] a_port;
        wire [23:0] b_port;
        for (genvar k = 0; k < 3; k = k + 1) begin : terms
            wire [4:0] av = decode(a[k * 4 +: 4]);
            wire [4:0] bv = decode(b[k * 4 +: 4]);
            assign a_port[k * 9 +: 9] = {{4{av[4]}}, av};
            assign b_port[k * 8 +: 8] = {{3{bv[4]}}, bv};
        end
        // Fabric placement permits hold repair; aligned with DSP AREG/BREG.
        (* dont_touch = "yes" *) reg [9:0] fourth_pipe;
        always @(posedge clk) begin
            if (rst)
                fourth_pipe <= 10'b0;
            else if (ce)
                fourth_pipe <= {sign4, complement};
        end
        wire [8:0] c_small = fourth_pipe[8:0];
        DSP58 #(
            .DSP_MODE("INT8"),
            .USE_SIMD("ONE58"),
            .AREG(1),
            .ACASCREG(1),
            .BREG(1),
            .BCASCREG(1),
            .CREG(0),
            .CARRYINREG(0),
            .MREG(0),
            .PREG(1),
            .OPMODEREG(0),
            .CARRYINSELREG(0),
            .ALUMODEREG(0),
            .ADREG(0),
            .DREG(0),
            .INMODEREG(0)
        ) dsp (
            .CLK(clk),
            .A({{7{a_port[26]}}, a_port}),
            .B(b_port),
            .C({{49{c_small[8]}}, c_small}),
            .D(27'b0),
            .PCIN(58'b0),
            .PCOUT(),
            .P(result[g]),
            .OPMODE(9'h185),
            .ALUMODE(4'b0),
            .INMODE(5'b0),
            .NEGATE(3'b0),
            .CARRYIN(fourth_pipe[9]),
            .CARRYINSEL(3'b0),
            .CARRYCASCIN(1'b0),
            .ACIN(34'b0),
            .BCIN(24'b0),
            .MULTSIGNIN(1'b0),
            .CEA1(ce),
            .CEA2(ce),
            .CEB1(ce),
            .CEB2(ce),
            .CEAD(ce),
            .CEALUMODE(ce),
            .CEC(ce),
            .CECARRYIN(ce),
            .CECTRL(ce),
            .CED(ce),
            .CEINMODE(ce),
            .CEM(ce),
            .CEP(ce),
            .RSTA(rst),
            .RSTB(rst),
            .RSTC(rst),
            .RSTD(rst),
            .RSTM(rst),
            .RSTP(rst),
            .RSTCTRL(rst),
            .RSTALUMODE(rst),
            .RSTINMODE(rst),
            .RSTALLCARRYIN(rst),
            .ASYNC_RST(1'b0)
        );
    end

    // Four-term sums fit signed 11 bits; pair sums fit 12, and Q fits 13.
    wire signed [10:0] s0 = result[0][10:0];
    wire signed [10:0] s1 = result[1][10:0];
    wire signed [10:0] s2 = result[2][10:0];
    wire signed [10:0] s3 = result[3][10:0];
    (* use_dsp = "no" *) wire signed [11:0] pair_left = {s0[10], s0} + {s1[10], s1};
    (* use_dsp = "no" *) wire signed [11:0] pair_right = {s2[10], s2} + {s3[10], s3};
    (* use_dsp = "no" *) wire signed [12:0] total =
        {pair_left[11], pair_left} + {pair_right[11], pair_right};
    assign out_data = total;
endmodule
