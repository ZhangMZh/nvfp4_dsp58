# Repository Guidelines

## Design and sources

- Dot16 computes an exact 16-element E2M1 dot product using four DSP58s. Optional E4M3 block scaling adds a fifth; global scaling and cross-block accumulation remain external.
- Maintain shared hardware in `rtl/spinal/src/`. Never hand-edit `rtl/generated/`; regenerate and commit both families after Scala changes. RTL scoreboards and tool flows are in `rtl/tb/` and `rtl/scripts/`.
- `hls/` contains the shared C++ API/model/wrapper, tests and Vitis flows. `tests/` contains the independent Python oracle and tests. CMake defines build targets; `build/` is disposable output, not a source directory.
- `BLOCK_SCALING=OFF` selects `nvfp4_dot16*`; ON selects `nvfp4_scaled_dot16*`. Preserve these public names. Generated RTL needs no mode macro; shared C++ and scoreboards enable scaling by macro presence. Both Python scripts accept `--block-scaling`.

## Build and validation

Use CMake 3.20+, Python 3.9+ and Ninja. Source licensed Vivado/Vitis 2025.1 with UNISIM before configuring hardware flows; HLS paths must not contain spaces. RTL generation additionally requires JDK 21 and sbt 1.10.2; Scala/SpinalHDL versions are pinned in `rtl/spinal/`.

```sh
cmake -S . -B build -G Ninja -DBLOCK_SCALING=OFF
ctest --test-dir build --output-on-failure
cmake --build build --target rtl-sim-core hls-csim --parallel 2  # Quick functional checks
cmake --build build --target rtl-sim hls-cosim --parallel 2    # All interfaces and C/RTL integration
cmake --build build --target rtl-impl --parallel 2             # Routed timing/resources
cmake --build build --target rtl-ip hls-ip --parallel 2        # IP export
cmake --build build --target ip-check                         # Relocation/import, including routing
cmake --build build --target dist                             # Source archive
```

Use separate build directories for OFF/ON or device/clock variants (`-DPART=...`, `-DCLOCK_NS=...`). After Scala edits, run `rtl-gen` sequentially in both configurations before any RTL consumers. Never run generation alongside simulation/implementation/packaging, or the same target concurrently in one directory. Hardware targets replace their previous outputs; ordinary builds do not run them.

## Changes and checks

- Use four-space indentation and descriptive `snake_case`; Scala classes use PascalCase. Follow `.clang-format` for C++ and adjacent conventions elsewhere. Preserve SPDX and third-party notices.
- Keep Python `unittest` tests and RTL/HLS scoreboards independent of the implementation. Preserve exhaustive E2M1 pairs at every position, signed zeros, extrema and seeded random cases; scaled coverage also includes all E4M3 byte pairs and NaN/invalid handling.
- Verify stalls, bubbles, CE pauses, reset and draining for interface changes. Preserve II=1 and OFF/ON latencies: native 2/5, registered integration 4/7, HLS 6/9 clocks. Scaled results remain exact signed 48-bit values with 20 fractional bits; stream bit 48 is invalid and bits 63:49 are zero.
- Run checks relevant to the change in both modes; include routed timing/resource evidence for datapath or timing changes. Report commands, results and skipped checks; include tool version, part and clock for hardware results.
- Update README when public behavior or commands change. Use concise Conventional Commit subjects and include generated RTL with Scala changes. Exclude other build outputs, caches and proprietary AMD files from commits/source distributions.
- Distribute project-owned code with `LICENSE`. Do not relabel third-party or AMD-generated files as MIT; preserve their notices and check applicable redistribution terms before shipping IP archives.
