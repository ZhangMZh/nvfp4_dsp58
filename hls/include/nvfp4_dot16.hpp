// SPDX-License-Identifier: MIT
#pragma once
#include <ap_int.h>
#include <hls_stream.h>

// Select the C++ interface matching the generated RTL family; undefined means unscaled.
namespace nvfp4 {
#ifdef BLOCK_SCALING
using block_pair = ap_uint<144>;
using dot_result = ap_uint<64>;
constexpr unsigned fraction_bits = 20;
#else
using block_pair = ap_uint<128>;
using dot_result = ap_int<16>;
#endif

// Low nibble is element zero. Bits 127:64 contain b, bits 63:0 contain a.
#ifdef BLOCK_SCALING
inline block_pair pack(ap_uint<64> a, ap_uint<64> b, ap_uint<8> scale_a, ap_uint<8> scale_b) {
#else
inline block_pair pack(ap_uint<64> a, ap_uint<64> b) {
#endif
    block_pair value = 0;
    value.range(63, 0) = a;
    value.range(127, 64) = b;
#ifdef BLOCK_SCALING
    value.range(135, 128) = scale_a;
    value.range(143, 136) = scale_b;
#endif
    return value;
}

#ifdef BLOCK_SCALING
// Status is outside the signed 48-bit result; bits 63:49 are zero.
inline ap_int<48> result_value(dot_result word) {
    return ap_int<48>(word.range(47, 0));
}

inline bool result_invalid(dot_result word) {
    return word[48];
}
#endif
} // namespace nvfp4

// One input/output transaction per call. RTL blackbox: II=1, latency 2 or 5.
// Unscaled: signed Q. Scaled: signed result / 2^20 and invalid in bit 48.
// Either NaN scale produces zero and invalid, with the ordinary latency.
#ifdef BLOCK_SCALING
void nvfp4_scaled_dot16_rtl(hls::stream<nvfp4::block_pair> &input, hls::stream<nvfp4::dot_result> &output);
#else
void nvfp4_dot16_rtl(hls::stream<nvfp4::block_pair> &input, hls::stream<nvfp4::dot_result> &output);
#endif

// Free-running AXI4-Stream integration example.
#ifdef BLOCK_SCALING
void nvfp4_scaled_dot16_hls(hls::stream<nvfp4::block_pair> &input, hls::stream<nvfp4::dot_result> &output);
#else
void nvfp4_dot16_hls(hls::stream<nvfp4::block_pair> &input, hls::stream<nvfp4::dot_result> &output);
#endif
