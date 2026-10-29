# NVFP4 Dot16 on Versal DSP58

A fixed, two-cycle 16-element E2M1 dot product using **four DSP58s and four LUT
product functions**, with initiation interval **II=1**:

\[
Q=\sum_{i=0}^{15}q(a_i)q(b_i),\qquad q(x)=2x_{\mathrm{E2M1}}.
\]

The exact signed integer `Q` lies in `[-2304,2304]`. The unscaled E2M1 dot product
is `Q/4`; NVFP4 block/global scaling and cross-block accumulation remain external.

## Datapath

The positive codes decode to `q={0,1,2,3,4,6,8,12}`; both zero encodings map to zero.
Each group of four pairs uses one DSP58 INT8 Dot3 for its first three products
and one LUT function for its fourth. Four functions do not mean four LUT cells.

1. DSP AREG/BREG capture the decoded operands. A 10-bit fabric register captures
   the fourth product's complemented magnitude and sign.
2. DSP PREG captures each four-product sum, including the LUT product through
   C/CARRYIN. Two combinational fabric adder levels then produce the 13-bit `Q`.

All four DSPs use `OPMODE=0x185`, `PCIN=0`, `AREG=BREG=PREG=1` and
`CREG=CARRYINREG=MREG=0`. There is no DSP cascade or final output register.
Backpressure freezes both stages; bubbles advance and synchronous reset discards
in-flight packets. The output adder must meet timing to the downstream register.

## Interfaces

| Module | Role |
| --- | --- |
| `nvfp4_dot16` | Datapath with clock enable and input/output valid |
| `nvfp4_dot16_axis` | Native AXI4-Stream IP top |
| `nvfp4_dot16_rtl` | FIFO adapter for the same core in HLS |
| `nvfp4_dot16_hls` | HLS DATAFLOW integration example |

Native AXIS uses `ap_clk` and synchronous active-high `ap_rst`:

- Input: `s_axis_tdata[127:0]={b[63:0],a[63:0]}`; element `i` occupies `[4*i+:4]`.
- Output: `m_axis_tdata[15:0]`, signed `Q` extended to 16 bits.
- Transfer: `tvalid && tready`; hold valid/data while stalled. No TLAST or AXI-Lite.
- Unstalled input-to-output handshake latency: two clocks; II=1.

The [HLS API](hls/include/nvfp4_dot16.hpp) uses a 128-bit input stream and signed
16-bit output stream. `model.cpp` is the C simulation model; synthesis uses the
same RTL core through a generated blackbox descriptor (latency 2, II=1).
The HLS example adds ingress/egress tasks, two depth-2 FIFOs and AXIS buffering,
uses `ap_ctrl_none` and active-low `ap_rst_n`, and disables start-token propagation.
Its measured unstalled external latency is six clocks, with II=1.

## Build and validation

Reference tests require Python 3.9+ and Make. Hardware flows require a configured,
licensed Vivado/Vitis 2025.1 environment, GCC and UNISIM.

```sh
make test
make rtl-sim rtl-impl
make hls-cosim
make rtl-ip hls-ip
make ip-check
make dist
```

Defaults: `BUILD_DIR=build`, `PART=xcv80-lsva4737-2MHP-e-S`,
`CLOCK_NS=3.333333`. Use separate build directories per configuration; do not run
the same target concurrently in one directory. `hls-cosim` includes C simulation,
synthesis, random-stall co-simulation and independent generated-AXIS simulation.
`hls-csim` and `hls-synth` are also available.

12,560 golden blocks cover every code pair at every position, signed zero,
extremes, cancellation and seeded random inputs. Scoreboards check reset, stalls,
bubbles, draining, latency and II=1; FIFO tests also pause CE.

`rtl-impl` routes two designs concurrently: `internal/` contains the standalone
core; `integration/` adds a two-slot registered FIFO at each AXIS boundary. The
fixture adds two clocks and checks setup/hold through all six data/valid/ready
ports, including the output sum. Standalone OOC excludes external paths and cannot
by itself establish output-adder timing. Both flows use 100 ps setup/hold
uncertainty. Board-level timing remains outside these checks.

Validated on 2026-10-29 with Vivado/Vitis 2025.1, the default V80 part and 300 MHz.
Routed utilization and measured unstalled handshake latency (all II=1):

| Design | DSP58 | LUT | FF | Setup slack | Hold slack | Clocks |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Native RTL OOC | 4 | 142 | 42 | +1.663 ns | +0.090 ns | 2 |
| RTL + boundary FIFOs | 4 | 238 | 338 | +0.842 ns | +0.078 ns | 4 |

The second row includes both fixture FIFOs and covers the output-adder path.
Functional simulation, HLS C/RTL co-simulation and both physical checks passed.
Reports and source-hash receipts are under `build/production-tree2/`.

## Layout and packages

- `rtl/{src,tb,scripts}`: production RTL, scoreboard/fixture, Vivado flows.
- `hls/{include,src,tb,scripts}`: C++ API/model/wrapper and Vitis flows.
- `tests/`, `scripts/`: independent integer oracle, unit tests and build runner.
- `build/`: generated reports, logs, artifacts and source-hash receipts.

IP archives are `rtl-ip/nvfp4_dot16_axis.zip` and
`hls-ip/project/solution/impl/ip/*.zip` under
`BUILD_DIR`. `ip-check` relocates both packages, verifies file references and RTL
hashes, then imports each through Vivado IP Catalog and checks its structure and
internal OOC timing. Core interface timing is checked by `rtl-impl`.
HLS export applies a process-local workaround for 2025.1 without changing
the installed tools. `dist/nvfp4_dsp58-source.tar.gz` contains the main project sources;
generated artifacts and AMD libraries are excluded.

## License

Licensed under the [MIT License](LICENSE).
