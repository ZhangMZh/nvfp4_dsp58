# SPDX-License-Identifier: MIT
# The descriptor budgets 145 core LUTs plus four FIFO-control LUTs; route reports
# remain authoritative for each integration.
configure_file(scripts/dot16.json.in "${CMAKE_CURRENT_BINARY_DIR}/dot16.json" @ONLY)
foreach(mode IN ITEMS csim synth cosim ip)
    set(work "${BUILD}/hls-${mode}")
    configure_file(scripts/launch.tcl.in "${CMAKE_CURRENT_BINARY_DIR}/${mode}.tcl" @ONLY)
    add_custom_target(hls-${mode}
        COMMAND "${CMAKE_COMMAND}" "-DCONFIG=${CONFIG}" "-DMODE=${mode}"
            -P "${CMAKE_CURRENT_SOURCE_DIR}/scripts/run.cmake"
        DEPENDS vectors
        VERBATIM)
endforeach()
