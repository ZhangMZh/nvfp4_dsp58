# Repository Guidelines

## Project Structure & Module Organization

This project implements a 16-element E2M1 dot product using four Versal DSP58s. Block/global scaling remains external to the IP.

- `rtl/src/`: SystemVerilog datapath, AXIS wrapper, and HLS FIFO adapter; `rtl/tb/`: scoreboard testbench; `rtl/scripts/`: implementation and IP packaging Tcl.
- `hls/include/` and `hls/src/`: public C++ interface, arithmetic model, and DATAFLOW wrapper; `hls/tb/` and `hls/scripts/`: verification and Vitis flow.
- `tests/`: independent Python integer oracle and unit tests.
- `scripts/run.py`: shared command runner, vector generation, logs, and source-hash receipts.
- `build/`: generated artifacts, ignored by Git. Keep source changes outside this directory.

## Build, Test, and Development Commands

Python 3.9+ suffices for reference tests. Hardware targets require a sourced, licensed Vivado/Vitis 2025.1 environment with UNISIM.

- `make test`: run Python reference tests.
- `make rtl-sim`: simulate native AXIS and FIFO interfaces.
- `make rtl-impl`: route the RTL and check timing/resource constraints.
- `make hls-csim`, `make hls-synth`, `make hls-cosim`: run HLS C simulation, synthesis, and co-simulation.
- `make rtl-ip` / `make hls-ip`: export IP; then `make ip-check` validates relocated packages.
- `make dist`: package distributable sources.

Use separate configurations, for example `make rtl-impl BUILD_DIR=build/v80-300 CLOCK_NS=3.333333`. Never run the same target concurrently in the same build directory.

## Coding Style & Naming Conventions

Use four-space indentation and descriptive `snake_case` names; retain `nvfp4_dot16*` public module/function names. C++ formatting follows `.clang-format`: LLVM base, 110-column limit, attached braces, and preserved include order. No dedicated lint target is configured. Preserve SPDX license headers and follow adjacent SystemVerilog, Python, and Tcl conventions.

## Testing Guidelines

Python tests use `unittest`; name files `test_*.py` and methods `test_*`. Extend the independent oracle and relevant RTL/HLS scoreboards when behavior changes. Preserve exhaustive code-pair coverage at every position, signed-zero/extrema cases, and seeded random vectors. Interface changes must verify stalls, bubbles, reset, draining, six-cycle native latency, and II=1. No percentage coverage threshold is configured. Include relevant simulation and routed timing/resource evidence for hardware changes.

## Commit & Pull Request Guidelines

There is no commit history yet. Use concise imperative subjects, such as `Fix FIFO reset handling`. PRs should explain the change, link relevant issues, and list commands/results plus tool version, part, and clock for hardware checks. Update both README languages when public behavior changes. Exclude generated artifacts and proprietary AMD files.
