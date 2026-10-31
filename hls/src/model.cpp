// SPDX-License-Identifier: MIT
#include "nvfp4_dot16.hpp"

namespace {
int decode(unsigned code) {
    const unsigned exponent = (code >> 1) & 3;
    const unsigned fraction = code & 1;
    const int value = exponent == 0 ? fraction : (2 + fraction) << (exponent - 1);
    return code & 8 ? -value : value;
}
#ifdef BLOCK_SCALING
ap_int<19> decode_scale(unsigned code) {
    const unsigned exponent = (code >> 3) & 15;
    const unsigned fraction = code & 7;
    const int magnitude = exponent == 0 ? fraction : (8 + fraction) << (exponent - 1);
    return code & 128 ? -magnitude : magnitude;
}
#endif
} // namespace

#ifdef BLOCK_SCALING
void nvfp4_scaled_dot16_rtl(hls::stream<nvfp4::block_pair> &input, hls::stream<nvfp4::dot_result> &output) {
#else
void nvfp4_dot16_rtl(hls::stream<nvfp4::block_pair> &input, hls::stream<nvfp4::dot_result> &output) {
#endif
    const nvfp4::block_pair packet = input.read();
    int sum = 0;
    for (int i = 0; i < 16; ++i) {
        const unsigned a = packet.range(i * 4 + 3, i * 4).to_uint();
        const unsigned b = packet.range(64 + i * 4 + 3, 64 + i * 4).to_uint();
        sum += decode(a) * decode(b);
    }
#ifdef BLOCK_SCALING
    const unsigned scale_a = packet.range(135, 128).to_uint();
    const unsigned scale_b = packet.range(143, 136).to_uint();
    const bool invalid = (scale_a & 127) == 127 || (scale_b & 127) == 127;
    nvfp4::dot_result word = 0;
    word[48] = invalid;
    if (!invalid) {
        const ap_int<51> product = ap_int<13>(sum) * decode_scale(scale_a) * decode_scale(scale_b);
        word.range(47, 0) = product.range(47, 0);
    }
    output.write(word);
#else
    output.write(nvfp4::dot_result(sum));
#endif
}
