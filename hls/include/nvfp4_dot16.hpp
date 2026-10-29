// SPDX-License-Identifier: MIT
#pragma once
#include <ap_int.h>
#include <hls_stream.h>

namespace nvfp4 {
using block_pair = ap_uint<128>;
using dot_result = ap_int<16>;

// Low nibble is element zero. Upper 64 bits contain b, lower 64 bits a.
inline block_pair pack(ap_uint<64> a, ap_uint<64> b) {
    block_pair value = 0;
    value.range(63, 0) = a;
    value.range(127, 64) = b;
    return value;
}
} // namespace nvfp4

// One call consumes one block pair and produces the exact, unscaled Q.
// Synthesized as the supplied RTL blackbox, with II=1 and six-cycle latency.
void nvfp4_dot16_rtl(hls::stream<nvfp4::block_pair> &input, hls::stream<nvfp4::dot_result> &output);

// Free-running AXI4-Stream integration example.
void nvfp4_dot16_hls(hls::stream<nvfp4::block_pair> &input, hls::stream<nvfp4::dot_result> &output);
