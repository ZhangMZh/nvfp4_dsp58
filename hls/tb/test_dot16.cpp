// SPDX-License-Identifier: MIT
#include "nvfp4_dot16.hpp"
#include <fstream>
#include <iostream>
#include <string>

int main() {
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
        if (line.size() != 36)
            return 2;
        const ap_uint<144> value(line.c_str(), 16);
        nvfp4::block_pair packet = value.range(127, 0);
        nvfp4::dot_result expected = value.range(143, 128);
        input.write(packet);
        nvfp4_dot16_hls(input, output);
        if (output.read() != expected || !input.empty() || !output.empty()) {
            std::cerr << "Mismatch at vector " << count << '\n';
            return 3;
        }
        ++count;
    }
    if (count < 12000)
        return 4;
    std::cout << "PASS HLS vectors=" << count << '\n';
    return 0;
}
