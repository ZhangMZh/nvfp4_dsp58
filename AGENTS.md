# Repository Guidelines

## Project Structure & Module Organization

This project implements a 16-element E2M1 dot product using four Versal DSP58s. Block/global scaling remains external to the IP.

- `rtl/spinal/src/`: maintained Scala/SpinalHDL datapath, DSP58 primitive, wrappers and generator; sbt configuration is in `rtl/spinal/`.
- `rtl/generated/`: checked-in generated SystemVerilog; do not edit by hand. `rtl/tb/`: independent scoreboards; `rtl/scripts/`: implementation and IP packaging Tcl.
- `hls/include/` and `hls/src/`: public C++ interface, arithmetic model, and DATAFLOW wrapper; `hls/tb/` and `hls/scripts/`: verification and Vitis flow.
- `tests/`: independent Python integer oracle and unit tests.
- Root, `rtl/` and `hls/` CMakeLists define the build targets; `cmake/` contains shared execution and packaging helpers.
- `build/`: generated artifacts, ignored by Git. Keep source changes outside this directory.

## Build, Test, and Development Commands

CMake 3.20+ and Python 3.9+ are required. Configure with `cmake -S . -B build/cmake -G Ninja`. Hardware targets require a sourced, licensed Vivado/Vitis 2025.1 environment with UNISIM; source it before configuring.

Invoke the named targets below with `cmake --build build/cmake --target <target>`.

- `ctest --test-dir build/cmake --output-on-failure`: run Python arithmetic tests.
- `cmake --build build/cmake --target rtl-gen`: generate and update the three checked-in RTL files.
- Target `rtl-sim`: simulate the direct core, native AXIS, FIFO and registered integration interfaces.
- Target `rtl-impl --parallel 2`: route standalone RTL and registered integration concurrently, checking timing/resources.
- Targets `hls-csim`, `hls-synth`, `hls-cosim`: run HLS C simulation, synthesis, and co-simulation.
- Targets `rtl-ip` / `hls-ip`: export IP; `ip-check` builds both and validates relocated packages.
- Target `dist`: package distributable sources.

Use separate configurations, for example `cmake -S . -B build/v80-300 -G Ninja -DCLOCK_NS=3.333333`, then `cmake --build build/v80-300 --target rtl-impl --parallel 2`. Never run the same target concurrently in the same build directory. Hardware targets replace their own old outputs on each invocation; the default build does not run them.
Generation requires JDK 21 and sbt 1.10.2; Scala 2.13.14 and SpinalHDL 1.15.0
are pinned by the project. Configure with `-DSBT=/path/to/sbt` if needed. Other targets use
checked-in RTL without running Scala. Run `rtl-gen` after changing Scala sources;
do not run it concurrently with another generation or RTL consumer.

## Coding Style & Naming Conventions

Use four-space indentation and descriptive `snake_case` names; Scala classes use PascalCase.
Retain `nvfp4_dot16*` public module/function names. Generated RTL retains the generator's formatting.
C++ formatting follows `.clang-format`: LLVM base, 110-column limit, attached braces, and preserved include order. No dedicated lint target is configured. Preserve SPDX license headers and follow adjacent SystemVerilog, Python, and Tcl conventions.

## Testing Guidelines

Python tests use `unittest`; name files `test_*.py` and methods `test_*`. Extend the independent oracle and relevant RTL/HLS scoreboards when behavior changes. Preserve exhaustive code-pair coverage at every position, signed-zero/extrema cases, and seeded random vectors. Interface changes must verify stalls, bubbles, reset, draining, two-cycle native latency, and II=1. No percentage coverage threshold is configured. Include relevant simulation and routed timing/resource evidence for hardware changes.

## Commit & Pull Request Guidelines

Use concise Conventional Commit subjects, such as `feat(rtl): promote two-cycle dot16 core`. PRs should explain the change, link relevant issues, and list commands/results plus tool version, part, and clock for hardware checks. Update README.md when public behavior changes. Commit generated `rtl/generated/*.sv` alongside Scala changes; exclude other generated artifacts, Scala/IDE caches and proprietary AMD files.
