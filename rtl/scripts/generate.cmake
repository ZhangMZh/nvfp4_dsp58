# SPDX-License-Identifier: MIT
include("${CONFIG}")
require_tool(SBT)
set(work "${BUILD}/rtl-gen")
prepare_work("${work}")
# sbt needs the Scala project as its cwd; keep its log under the build tree.
run_tool("${ROOT}/rtl/spinal" "${work}/generate" DOT16_GENERATION_PASS
    "${SBT}" "runMain nvfp4.Generate \"${work}/hdl\"")
foreach(name IN ITEMS nvfp4_dot16 nvfp4_dot16_axis nvfp4_dot16_rtl)
    configure_file("${work}/hdl/${name}.sv" "${ROOT}/rtl/generated/${name}.sv" COPYONLY)
endforeach()
