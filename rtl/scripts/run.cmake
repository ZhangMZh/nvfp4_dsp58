# SPDX-License-Identifier: MIT
include("${CONFIG}")
require_tool(VIVADO)
prepare_work("${WORK}")
run_tool("${WORK}" "${FLOW}" DOT16_FLOW_PASS
    "${VIVADO}" -mode batch -nojournal -source "${ROOT}/rtl/scripts/${FLOW}.tcl"
    -tclargs "${ROOT}" "${WORK}" "${PART}" "${CLOCK_NS}" ${SCOPE})
if(FLOW STREQUAL "package")
    include("${ROOT}/cmake/Archive.cmake")
    package_docs("${WORK}/nvfp4_dot16_axis.zip" "${WORK}/archive")
endif()
