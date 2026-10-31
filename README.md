# NVFP4 Dot16 on Versal DSP58

Exact 16-element E2M1 dot product, with optional E4M3 block scaling. Global scaling
and cross-block accumulation remain external. Both modes support II=1 and backpressure.

## Design

- **Exact integer mapping:** Decode each NVFP4 E2M1 value `x` as the signed integer `q = 2*x`, with magnitudes `{0, 1, 2, 3, 4, 6, 8, 12}`. The unscaled output is `Q = sum(q_a*q_b)`, so the E2M1 dot product is exactly `Q/4`.
- **Four DSP58s for 16 products:** DSP58 provides a native three-product sum mode that DSP48E2 lack; see [AMD's architecture comparison](https://docs.amd.com/r/en-US/am004-versal-dsp-engine/Differences-from-Previous-Generations). Each group of four uses the DSP58 INT8 dot-product mode for three products; a LUT computes the fourth and adds it through `C/CARRYIN`. A fabric adder tree combines the four group sums. 

## Interfaces

| Unscaled module/function | Scaled module/function | Role |
| --- | --- | --- |
| `nvfp4_dot16` | `nvfp4_scaled_dot16` | Datapath with clock enable and input/output valid |
| `nvfp4_dot16_axis` | `nvfp4_scaled_dot16_axis` | RTL AXI4-Stream interface to the datapath |
| `nvfp4_dot16_rtl` | `nvfp4_scaled_dot16_rtl` | FIFO interface for HLS RTL blackbox integration |
| `nvfp4_dot16_hls` | `nvfp4_scaled_dot16_hls` | HLS DATAFLOW AXI4-Stream integration of the RTL blackbox |

Configure with `-DBLOCK_SCALING=ON` to select exact E4M3 block scaling (default OFF):

| Mode | DSP58 | Input / stream output | Unstalled RTL AXIS / HLS latency |
| --- | ---: | --- | --- |
| OFF | 4 | 128 / 16 bits | 2 / 6 clocks |
| ON | 5 | 144 / 64 bits | 5 / 9 clocks |

## Build and validation

```sh
cmake -S . -B build -G Ninja -DBLOCK_SCALING=OFF
# For scaling, use a separate directory and -DBLOCK_SCALING=ON.
# Override the device/clock with -DPART=... -DCLOCK_NS=... .

# Quick checks: Python, direct-core RTL simulation, HLS C simulation
ctest --test-dir build --output-on-failure
cmake --build build --target rtl-sim-core hls-csim --parallel 2

# Additional checks (run as needed)
cmake --build build --target rtl-sim --parallel 2  # Core, AXIS, FIFO, integration
cmake --build build --target hls-synth           # HLS synthesis
cmake --build build --target hls-cosim           # C/RTL + external AXIS simulation
cmake --build build --target rtl-impl --parallel 2  # Place/route and timing
```

Checked-in RTL is ready to use. After editing `rtl/spinal/src/`, run
`cmake --build build --target rtl-gen` in each OFF/ON configuration to update
both families. Generation requires JDK 21 and sbt 1.10.2 (`-DSBT=/path/to/sbt` if needed).

## IP export and integration

### Vivado Block Design

```sh
cmake --build build --target rtl-ip hls-ip --parallel 2
# Optional relocated-package validation, including place/route:
cmake --build build --target ip-check --parallel 2
```

Archive paths are relative to the build directory:

| Mode | IP package | Archive | IP to add |
| --- | --- | --- | --- |
| OFF | RTL AXI4-Stream IP | `rtl-ip/nvfp4_dot16_axis.zip` | `nvfp4_dot16_axis` |
| ON | RTL AXI4-Stream IP | `rtl-ip/nvfp4_scaled_dot16_axis.zip` | `nvfp4_scaled_dot16_axis` |
| OFF | HLS DATAFLOW AXI4-Stream IP | `hls-ip/project/solution/impl/ip/nvfp4_org_hls_nvfp4_dot16_hls_1_0.zip` | `nvfp4_dot16_hls` |
| ON | HLS DATAFLOW AXI4-Stream IP | `hls-ip/project/solution/impl/ip/nvfp4_org_hls_nvfp4_scaled_dot16_hls_1_0.zip` | `nvfp4_scaled_dot16_hls` |

Unzip the selected archive, then register the directory containing `component.xml`
in the Vivado project's IP repository:

```tcl
set_property ip_repo_paths [list /path/to/unpacked_ip] [current_project]
update_ip_catalog
```

In Block Design, use **Add IP**, select the exported IP, and connect its clock,
reset and input/output AXI streams. Match reset polarity and stream widths to the
interface table. 

### Reuse inside an HLS design

Run `hls-csim` to generate the descriptor for the selected mode:

| Mode | Descriptor | Function to call |
| --- | --- | --- |
| OFF | `build/hls-csim/nvfp4_dot16.json` | `nvfp4_dot16_rtl` |
| ON | `build/hls-csim/nvfp4_scaled_dot16.json` | `nvfp4_scaled_dot16_rtl` |

Include `hls/include/nvfp4_dot16.hpp` and register the descriptor:

```tcl
# OFF:
add_files -blackbox /path/to/build/hls-csim/nvfp4_dot16.json
# ON (use instead of the line above):
add_files -blackbox /path/to/build/hls-csim/nvfp4_scaled_dot16.json
```

Add `hls/include` to the include path and call the function above using
internal `hls::stream` channels; see [top.cpp](hls/src/top.cpp) for the DATAFLOW
integration. 

[MIT License](LICENSE).
