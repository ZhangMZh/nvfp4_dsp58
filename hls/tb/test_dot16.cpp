// SPDX-License-Identifier: MIT
#include "nvfp4_dot16.hpp"
#include <fstream>
#include <iostream>
#include <string>

int main() {
    constexpr unsigned input_width = nvfp4::block_pair::width;
    constexpr unsigned output_width = nvfp4::dot_result::width;
#ifdef BLOCK_SCALING
    // Status is outside the signed result, including for negative values.
    const nvfp4::dot_result probe = (ap_uint<64>(1) << 49) - 1;
    if (nvfp4::result_value(probe) != -1 || !nvfp4::result_invalid(probe))
        return 5;
    const auto packed = nvfp4::pack(0x1234, 0x5678, 0x3c, 0xc0);
    if (packed.range(63, 0) != 0x1234 || packed.range(127, 64) != 0x5678 ||
        packed.range(143, 128) != 0xc03c)
        return 6;
    constexpr unsigned expected_count = 153355;
#else
    const auto packed = nvfp4::pack(0x1234, 0x5678);
    if (packed.range(63, 0) != 0x1234 || packed.range(127, 64) != 0x5678)
        return 6;
    constexpr unsigned expected_count = 12560;
#endif
    std::ifstream file("vectors.mem");
    if (!file) {
        std::cerr << "Missing vectors.mem\n";
        return 1;
    }
    hls::stream<nvfp4::block_pair> input;
    hls::stream<nvfp4::dot_result> output;
    unsigned count = 0;
    std::string line;
    while (file >> line) {
        if (line.size() != (input_width + output_width) / 4)
            return 2;
        const ap_uint<input_width + output_width> value(line.c_str(), 16);
        nvfp4::block_pair packet = value.range(input_width - 1, 0);
        nvfp4::dot_result expected = value.range(input_width + output_width - 1, input_width);
        input.write(packet);
#ifdef BLOCK_SCALING
        nvfp4_scaled_dot16_hls(input, output);
#else
        nvfp4_dot16_hls(input, output);
#endif
        if (output.read() != expected || !input.empty() || !output.empty()) {
            std::cerr << "Mismatch at vector " << count << '\n';
            return 3;
        }
        ++count;
    }
    if (count != expected_count)
        return 4;
    std::cout << "PASS HLS vectors=" << count << '\n';
    return 0;
}
