# SPDX-License-Identifier: MIT
include("${CONFIG}")
require_tool(SBT)
set(work "${BUILD}/rtl-gen")
prepare_work("${work}")
# sbt needs the Scala project as its cwd; keep its log under the build tree.
set(modules ${RTL_FAMILY} ${RTL_FAMILY}_axis ${RTL_FAMILY}_rtl)
set(options "")
if(BLOCK_SCALING)
    set(options " --block-scaling")
endif()
run_tool("${ROOT}/rtl/spinal" "${work}/generate" DOT16_GENERATION_PASS
    "${SBT}" "runMain nvfp4.Generate \"${work}/hdl\"${options}")
foreach(name IN LISTS modules)
    configure_file("${work}/hdl/${name}.sv" "${ROOT}/rtl/generated/${name}.sv" COPYONLY)
endforeach()
