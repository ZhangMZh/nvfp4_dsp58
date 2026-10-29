// SPDX-License-Identifier: MIT
#include "nvfp4_dot16.hpp"

namespace {
void ingress(hls::stream<nvfp4::block_pair> &input, hls::stream<nvfp4::block_pair> &packets) {
#pragma HLS INLINE off
#pragma HLS PIPELINE II = 1
    packets.write(input.read());
}

void egress(hls::stream<nvfp4::dot_result> &results, hls::stream<nvfp4::dot_result> &output) {
#pragma HLS INLINE off
#pragma HLS PIPELINE II = 1
    output.write(results.read());
}
} // namespace

void nvfp4_dot16_hls(hls::stream<nvfp4::block_pair> &input, hls::stream<nvfp4::dot_result> &output) {
#pragma HLS INTERFACE axis port = input
#pragma HLS INTERFACE axis port = output
#pragma HLS INTERFACE ap_ctrl_none port = return
#pragma HLS DATAFLOW disable_start_propagation
    // RTL blackboxes require internal FIFO channels, not top-level AXIS ports.
    hls::stream<nvfp4::block_pair> packets("packets");
    hls::stream<nvfp4::dot_result> results("results");
#pragma HLS STREAM variable = packets depth = 2
#pragma HLS STREAM variable = results depth = 2
    ingress(input, packets);
    nvfp4_dot16_rtl(packets, results);
    egress(results, output);
}
