# SPDX-License-Identifier: MIT
include("${CONFIG}")
set(work "${BUILD}/dist")
prepare_work("${work}")
set(stage "${work}/nvfp4_dsp58")
file(MAKE_DIRECTORY "${stage}")
foreach(name IN ITEMS CMakeLists.txt .gitignore .clang-format AGENTS.md LICENSE README.md)
    file(COPY "${ROOT}/${name}" DESTINATION "${stage}")
endforeach()
foreach(directory IN ITEMS cmake rtl hls tests)
    file(COPY "${ROOT}/${directory}" DESTINATION "${stage}"
        PATTERN "target" EXCLUDE
        PATTERN "__pycache__" EXCLUDE
        PATTERN ".bsp" EXCLUDE
        PATTERN ".metals" EXCLUDE
        PATTERN ".bloop" EXCLUDE)
endforeach()
execute_process(COMMAND "${CMAKE_COMMAND}" -E tar czf nvfp4_dsp58-source.tar.gz -- nvfp4_dsp58
    WORKING_DIRECTORY "${work}" COMMAND_ERROR_IS_FATAL ANY)
message(STATUS "Source package: ${work}/nvfp4_dsp58-source.tar.gz")
