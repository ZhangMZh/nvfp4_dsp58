# SPDX-License-Identifier: MIT
include("${CONFIG}")
require_tool(VIVADO)
prepare_work("${WORK}")
# CMake list expansion drops empty arguments; keep the optional scope slot occupied.
if(NOT DEFINED SCOPE OR SCOPE STREQUAL "")
    set(SCOPE package)
endif()
run_tool("${WORK}" "${FLOW}" DOT16_FLOW_PASS
    "${VIVADO}" -mode batch -nojournal -source "${ROOT}/rtl/scripts/${FLOW}.tcl"
    -tclargs "${ROOT}" "${WORK}" "${PART}" "${CLOCK_NS}" "${SCOPE}" ${BLOCK_SCALING})
if(FLOW STREQUAL "package")
    include("${ROOT}/cmake/Archive.cmake")
    package_docs("${WORK}/${RTL_FAMILY}_axis.zip" "${WORK}/archive")
endif()
