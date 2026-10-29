// SPDX-License-Identifier: MIT
#include "nvfp4_dot16.hpp"

namespace {
int decode(unsigned code) {
    const unsigned exponent = (code >> 1) & 3;
    const unsigned fraction = code & 1;
    const int value = exponent == 0 ? fraction : (2 + fraction) << (exponent - 1);
    return code & 8 ? -value : value;
}
} // namespace

void nvfp4_dot16_rtl(hls::stream<nvfp4::block_pair> &input, hls::stream<nvfp4::dot_result> &output) {
    const nvfp4::block_pair packet = input.read();
    int sum = 0;
    for (int i = 0; i < 16; ++i) {
        const unsigned a = packet.range(i * 4 + 3, i * 4).to_uint();
        const unsigned b = packet.range(64 + i * 4 + 3, 64 + i * 4).to_uint();
        sum += decode(a) * decode(b);
    }
    output.write(nvfp4::dot_result(sum));
}
