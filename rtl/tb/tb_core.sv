// SPDX-License-Identifier: MIT
`timescale 1ns/1ps
// Direct core arithmetic, latency, reset and clock-enable coverage.
module tb_core;
    reg clk = 0;
    always #1.666666 clk = ~clk;
    reg rst = 1, ce = 0, in_valid = 0;
    reg [127:0] in_data = 0;
    wire out_valid;
    wire signed [12:0] out_data;
    nvfp4_dot16 dut (.*);
    reg [143:0] vectors[0:16383];
    reg signed [12:0] expected[0:16383];
    integer accepted_at[0:16383];
    integer count, cycle, index = 0, head = 0, tail = 0, enabled_cycle = 0;
    integer seed = 55817, outputs = 0, held_checks = 0, reset_ce_checks = 0;
    integer empty_cycles = 0, latency_checks = 0, dropped = 0;
    reg previous_valid;
    reg signed [12:0] previous_data;
    string filename;
    initial begin
        if (!$value$plusargs("vectors=%s", filename) || !$value$plusargs("count=%d", count))
            $fatal(1, "Missing vectors/count");
        if (count > 16384)
            $fatal(1, "Too many vectors");
        $readmemh(filename, vectors, 0, count - 1);
        repeat (40) @(negedge clk);
        for (cycle = 0; cycle < 100000; cycle = cycle + 1) begin
            rst = (cycle == 0 || cycle == 311 || cycle == 997);
            ce = (cycle < 256 || (($random(seed) & 3) != 0));
            if (cycle == 0 || cycle == 311)
                ce = 0;
            if (cycle >= 600 && cycle < 700)
                ce = 0;
            in_valid = !rst && index < count && (cycle < 256 || (($random(seed) & 3) != 0));
            // The direct CE contract must ignore arbitrarily changing inputs while frozen.
            in_data = ce && in_valid ? vectors[index][127:0] :
                {$random(seed), $random(seed), $random(seed), $random(seed)};
            previous_valid = out_valid;
            previous_data = out_data;
            @(posedge clk);
            if (rst) begin
                dropped = dropped + tail - head;
                head = 0;
                tail = 0;
                if (cycle == 997) begin
                    index = 0;
                    outputs = 0;
                end
            end else if (ce) begin
                if (out_valid) begin
                    if (head == tail || out_data !== expected[head])
                        $fatal(1, "Core arithmetic/order mismatch cycle=%0d", cycle);
                    if (enabled_cycle - accepted_at[head] != 2)
                        $fatal(1, "Core enabled latency must be two cycles");
                    latency_checks = latency_checks + 1;
                    head = head + 1;
                    outputs = outputs + 1;
                end
                if (in_valid) begin
                    expected[tail] = vectors[index][140:128];
                    accepted_at[tail] = enabled_cycle;
                    tail = tail + 1;
                    index = index + 1;
                end
                if (cycle >= 32 && cycle < 256 && !(in_valid && out_valid))
                    $fatal(1, "Core II is not one");
                enabled_cycle = enabled_cycle + 1;
            end
            #0.1;
            if (rst) begin
                if (out_valid !== 0 || out_data !== 0)
                    $fatal(1, "Synchronous reset did not clear core state");
                if (!ce)
                    reset_ce_checks = reset_ce_checks + 1;
            end else if (!ce) begin
                if (out_valid !== previous_valid || out_data !== previous_data)
                    $fatal(1, "Core changed while CE was low");
                held_checks = held_checks + 1;
            end
            if (index == count && head == tail && !out_valid)
                empty_cycles = empty_cycles + 1;
            else
                empty_cycles = 0;
            if (empty_cycles == 32) begin
                if (outputs != count || held_checks < 100 || reset_ce_checks != 2 || dropped == 0)
                    $fatal(1, "Incomplete core coverage");
                $display("PASS core vectors=%0d latency_checks=%0d held_checks=%0d reset_ce_checks=%0d",
                         count, latency_checks, held_checks, reset_ce_checks);
                $finish;
            end
            @(negedge clk);
        end
        $fatal(1, "Core timeout");
    end
endmodule
