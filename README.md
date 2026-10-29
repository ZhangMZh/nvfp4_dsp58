# NVFP4 Dot16 on Versal DSP58

[中文](README.zh-CN.md)

A fixed 16-element E2M1 dot product using **four DSP58s and four LUT product
functions**. Each accepted input beat produces the exact integer

\[
Q=\sum_{i=0}^{15}q(a_i)q(b_i),\qquad q(x)=2x_{\mathrm{E2M1}}.
\]

The unscaled E2M1 dot product is `Q/4`. NVFP4 block/global scales and cross-block
accumulation are external to this IP.

## Datapath

The positive codes decode to `q={0,1,2,3,4,6,8,12}`; both zero encodings map to
zero. The result fits signed 13 bits: `Q ∈ [-2304,2304]`.

| DSP | Native INT8 Dot3 positions | LUT position | Registered result |
| --- | --- | --- | --- |
| 0 | 0, 1, 2 | 3 | `S0` |
| 1 | 4, 5, 6 | 7 | `S0+S1` |
| 2 | 8, 9, 10 | 11 | `S0+S1+S2` |
| 3 | 12, 13, 14 | 15 | `Q` |

`Sg` is the sum of the four products in group `g`. The fourth product uses a
6-bit lookup address and an 8-bit unsigned magnitude `m`. For sign XOR `s`,
`C=sign_extend(({0,m}) XOR {9{s}})` and `CARRYIN=s` implement the signed product
inside the DSP adder. Four LUT functions do not mean four physical LUT cells.

The DSPs reduce through the full 58-bit PCOUT→PCIN cascade, with no P feedback.
DSP0 uses `OPMODE=0x185`; DSP1–3 use `0x195`. All use `AREG=BREG=PREG=1` and
`CREG=CARRYINREG=MREG=0`. The C/sign input has a 10-bit fabric register aligned
with AREG/BREG. This register placement and disabled SRL extraction address
hold timing in the validated V80 configuration.

One decode stage, DSP input registers and four cascaded P registers form six
pipeline stages. Groups 0–3 have 0/1/2/3 extra input-alignment stages. Backpressure
freezes the entire core; input bubbles advance so the final packet can drain.
Synchronous reset discards in-flight packets.

## Interfaces

| Module | Role |
| --- | --- |
| `nvfp4_dot16` | Datapath with clock enable and input/output valid |
| `nvfp4_dot16_axis` | Standalone RTL AXI4-Stream IP top |
| `nvfp4_dot16_rtl` | FIFO adapter for the HLS RTL blackbox |
| `nvfp4_dot16_hls` | HLS AXI4-Stream integration example |

The native AXIS top uses `ap_clk` and synchronous active-high `ap_rst`:

- Input: `s_axis_tdata[127:0]={b[63:0],a[63:0]}`; element `i` occupies `[4*i+:4]`.
- Output: `m_axis_tdata[15:0]`, with signed `Q[12:0]` extended to 16 bits.
- Transfer: `tvalid && tready`; hold valid/data while stalled. No TLAST or AXI-Lite.
- Without stalls: six clocks between input/output handshakes, II=1.

The HLS API is in [nvfp4_dot16.hpp](hls/include/nvfp4_dot16.hpp). A blackbox call
consumes one `hls::stream<ap_uint<128>>` item and produces one
`hls::stream<ap_int<16>>` item. The build script generates and registers the
blackbox JSON; `model.cpp` supplies C simulation behavior.

The HLS example connects the blackbox through two depth-2 internal FIFOs and
DATAFLOW ingress/egress tasks. It uses `ap_ctrl_none` and disables start-token
propagation so FIFO handshakes alone control draining. Its generated AXIS top
uses active-low `ap_rst_n` and adds interface buffering; it does not instantiate
`nvfp4_dot16_axis`.

## Build and layout

Reference tests require Python 3.9+ and Make. Hardware flows require a configured
Vivado/Vitis 2025.1 environment, GCC and the installed UNISIM library.

```sh
make test
make rtl-sim rtl-impl rtl-ip
make hls-csim hls-synth hls-cosim hls-ip
make ip-check
make dist
```

`BUILD_DIR=build`, `PART=xcv80-lsva4737-2MHP-e-S`, and `CLOCK_NS=3.333333` are the
defaults. Use a separate build directory per configuration and avoid concurrent
runs of the same target there. `ip-check` requires both IP packages first.

| Directory | Contents |
| --- | --- |
| `rtl/{src,tb,scripts}` | RTL, scoreboard, Vivado implementation/packaging |
| `hls/{include,src,tb,scripts}` | C++ API/model/wrapper, testbench, Vitis flow |
| `tests/`, `scripts/` | Integer oracle, unit tests, build runner |
| `build/` | Generated logs, reports, source-hash receipts and artifacts |

Outputs under `BUILD_DIR`:

- RTL IP: `rtl-ip/nvfp4_dot16_axis.zip`
- HLS IP: `hls-ip/project/solution/impl/ip/nvfp4_org_hls_nvfp4_dot16_hls_1_0.zip`
- Sources: `dist/nvfp4_dsp58-source.tar.gz`

`ip-check` relocates each package, checks file references and handwritten RTL
hashes, then imports and implements it through Vivado IP Catalog. The HLS Tcl
flow includes a process-local export workaround for 2025.1; it does not modify
the installed tools. Generated files and AMD libraries are excluded from the
source archive.

## Validation

12,560 golden blocks cover every code pair at every position, signed zero,
extremes, cancellation and seeded random inputs. RTL/FIFO/HLS AXIS scoreboards
check latency, II=1, stalls, draining and reset; FIFO tests also pause CE.
HLS C simulation and random-stall co-simulation use the same golden vectors.

Validated on 2026-10-29 with Vivado/Vitis 2025.1 and the default V80 part:

| Implementation | DSP58 | LUT | FF | Setup slack | Hold slack | AXIS latency | II |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Native RTL AXIS | 4 | 119 | 436 | 1.523 ns | 0.004 ns | 6 clocks | 1 |
| HLS AXIS example | 4 | 323 | 1024 | 1.049 ns | 0.003 ns | 10 clocks | 1 |

These are routed resources and measured unstalled handshake latencies. HLS
numbers include FIFOs and AXIS register slices. Timing uses 3.333333 ns and
100 ps user uncertainty for both setup and hold. OOC checks cover internal
paths; external I/O timing belongs to the integrating design. No board test
is included.

Both relocated IPs passed routing, DSP-mode/cascade checks and internal timing,
with no unresolved blackboxes, unconstrained internal endpoints, DRC errors or
critical warnings. Ordinary CREG/MREG pipelining and OOC external-load warnings
remain. Reports and per-target receipts are under `BUILD_DIR`.

## References

[AMD DSP58](https://docs.amd.com/r/en-US/am004-versal-dsp-engine/Dot-Product-Unit),
[NVIDIA NVFP4](https://docs.nvidia.com/deeplearning/transformer-engine/features/low_precision_training/nvfp4/nvfp4.html).

## License

Licensed under the [MIT License](LICENSE).
