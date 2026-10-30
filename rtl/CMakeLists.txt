# SPDX-License-Identifier: MIT
add_custom_target(rtl-gen
    COMMAND "${CMAKE_COMMAND}" "-DCONFIG=${CONFIG}" -P "${CMAKE_CURRENT_SOURCE_DIR}/scripts/generate.cmake"
    VERBATIM)

add_custom_target(rtl-sim)
foreach(kind IN ITEMS core axis fifo integration)
    add_custom_target(rtl-sim-${kind}
        COMMAND "${CMAKE_COMMAND}" "-DCONFIG=${CONFIG}" "-DKIND=${kind}"
            "-DWORK=${BUILD}/rtl-sim/${kind}" -P "${CMAKE_CURRENT_SOURCE_DIR}/scripts/simulate.cmake"
        DEPENDS vectors
        VERBATIM)
    add_dependencies(rtl-sim rtl-sim-${kind})
endforeach()

add_custom_target(rtl-impl)
foreach(scope IN ITEMS internal integration)
    add_custom_target(rtl-impl-${scope}
        COMMAND "${CMAKE_COMMAND}" "-DCONFIG=${CONFIG}" -DFLOW=implement "-DSCOPE=${scope}"
            "-DWORK=${BUILD}/rtl-impl/${scope}" -P "${CMAKE_CURRENT_SOURCE_DIR}/scripts/run.cmake"
        VERBATIM)
    add_dependencies(rtl-impl rtl-impl-${scope})
endforeach()
add_custom_target(rtl-ip
    COMMAND "${CMAKE_COMMAND}" "-DCONFIG=${CONFIG}" -DFLOW=package
        "-DWORK=${BUILD}/rtl-ip" -P "${CMAKE_CURRENT_SOURCE_DIR}/scripts/run.cmake"
    VERBATIM)
