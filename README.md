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

CMake 3.20+ and Python 3.9+ are required; Ninja is the recommended build backend.
Hardware flows require a configured, licensed Vivado/Vitis 2025.1 environment,
GCC and UNISIM.

```sh
cmake -S . -B build/cmake -G Ninja
ctest --test-dir build/cmake --output-on-failure
```

The maintained hardware source is SpinalHDL under `rtl/spinal/src/`. The three generated
SystemVerilog modules are checked in under `rtl/generated/`, so simulation,
implementation and IP consumers do not need Scala. Edit the Scala sources and
run `rtl-gen` to update the generated RTL before building.

Generation requires JDK 21 and sbt 1.10.2. The project pins Scala 2.13.14 and
SpinalHDL 1.15.0 (core, library and compiler plugin); sbt downloads dependencies
on first use. Install tools and configure any required network proxy externally.
There is no separate smoke-test project or Verilator requirement.

```sh
cmake -S . -B build/cmake -DSBT=/path/to/sbt  # optional tool override
cmake --build build/cmake --target rtl-gen  # update rtl/generated/*.sv
```

`SBT` defaults to `sbt` on PATH. Tool logs are saved in each target's output
directory; failures print the log tail. No timestamp, local Git revision or absolute source
path is embedded in the generated HDL. The generator preserves the core's signed
13-bit public output declaration, which Spinal otherwise emits as an unsigned
vector with signed casts inside the module.

```sh
cmake --build build/cmake --target rtl-sim --parallel 2
cmake --build build/cmake --target rtl-impl --parallel 2
cmake --build build/cmake --target hls-cosim
cmake --build build/cmake --target ip-check --parallel 2
cmake --build build/cmake --target dist
```

Select the build directory with `-B`. Cache defaults are
`PART=xcv80-lsva4737-2MHP-e-S`, `CLOCK_NS=3.333333`; override them with
`-DPART=... -DCLOCK_NS=...`. Tool paths can be overridden with `-DSBT=...`,
`-DVIVADO=...`, `-DVITIS_RUN=...`, `-DXVLOG=...`, `-DXELAB=...`, `-DXSIM=...`
and `-DVIVADO_ROOT=...`. Missing hardware tools fail only when the corresponding
target is invoked; source the environment and reconfigure to discover them.

Use separate build directories per configuration; do not run the same target
concurrently in one directory. Hardware targets rerun when requested and replace
their own previous tool outputs. The shared golden vectors regenerate only when
the oracle changes. The default build does not start hardware flows.
Run only one `rtl-gen` at a time, and wait for it to finish before simulation,
implementation or packaging. Other targets never invoke Scala implicitly.
`hls-cosim` includes C simulation,
synthesis, random-stall co-simulation and independent generated-AXIS simulation.
`hls-csim` and `hls-synth` are also available.

12,560 golden blocks cover every code pair at every position, signed zero,
extremes, cancellation and seeded random inputs. Scoreboards check reset, stalls,
bubbles, draining, latency and II=1; FIFO tests also pause CE.
Direct-core tests additionally change inputs while CE is low and assert reset
with CE low. Interface tests reset during backpressure, and the HLS AXIS test
requires the six-cycle integration latency explicitly.

`rtl-impl --parallel 2` routes two designs concurrently: `internal/` contains the standalone
core; `integration/` adds a two-slot registered FIFO at each AXIS boundary. The
fixture adds two clocks and checks setup/hold through all six data/valid/ready
ports, including the output sum. Standalone OOC excludes external paths and cannot
by itself establish output-adder timing. Both flows use 100 ps setup/hold
uncertainty. Board-level timing remains outside these checks.

Validated on 2026-10-30 with Vivado/Vitis 2025.1, the default V80 part and 300 MHz.
Routed utilization and measured unstalled handshake latency (all II=1):

| Design | DSP58 | LUT | FF | Setup slack | Hold slack | Clocks |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| SpinalHDL OOC | 4 | 145 | 42 | +1.561 ns | +0.114 ns | 2 |
| SpinalHDL + boundary FIFOs | 4 | 238 | 338 | +0.921 ns | +0.045 ns | 4 |

The FIFO rows include both fixture FIFOs and cover the output-adder path.
Functional simulation, HLS C/RTL co-simulation and both physical checks passed.
These results were reproduced through CMake 3.31.6 and Ninja 1.12.1 after the
build migration. Reports and routed checkpoints are under
`build/cmake-acceptance/rtl-impl/{internal,integration}/`; the integration report
`interfaces.tsv` records setup/hold checks through all six core AXIS ports.

## Layout and packages

- `rtl/spinal/src/`: maintained hardware descriptions; sbt configuration is in `rtl/spinal/`.
- `rtl/generated/`: generated SystemVerilog; do not edit by hand.
- `rtl/tb/`: independent scoreboards and integration fixture.
- `CMakeLists.txt`, `rtl/CMakeLists.txt`, `hls/CMakeLists.txt`: common, RTL and HLS targets.
- `cmake/`: shared tool execution, configuration and archive helpers.
- `rtl/scripts/`: RTL generation, simulation, implementation and IP packaging flows.
- `hls/{include,src,tb,scripts}`: C++ API/model/wrapper and Vitis flows.
- `tests/`: independent integer oracle, arithmetic unit tests and vector generation.
- `build/`: CMake build trees, reports, logs and artifacts.

IP archives are `rtl-ip/nvfp4_dot16_axis.zip` and
`hls-ip/project/solution/impl/ip/*.zip` under
the chosen CMake build directory. `rtl-ip` and `hls-ip` export the individual
packages; `ip-check` builds both automatically, relocates them, verifies file references,
then imports each through Vivado IP Catalog and checks its structure and
internal OOC timing. Core interface timing is checked by `rtl-impl`.
HLS export applies a process-local workaround for 2025.1 without changing
the installed tools. `dist/nvfp4_dsp58-source.tar.gz` contains the Scala sources,
build configuration, generated RTL and other main project sources;
build outputs, Scala/IDE caches and AMD libraries are excluded.

## License

Licensed under the [MIT License](LICENSE).
