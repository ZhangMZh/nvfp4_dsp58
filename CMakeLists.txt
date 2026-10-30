# SPDX-License-Identifier: MIT
cmake_minimum_required(VERSION 3.20)
project(nvfp4_dsp58 LANGUAGES NONE)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR "Use an out-of-source build: cmake -S . -B build/cmake")
endif()

set(ROOT "${CMAKE_CURRENT_SOURCE_DIR}")
set(BUILD "${CMAKE_CURRENT_BINARY_DIR}")
set(PART "xcv80-lsva4737-2MHP-e-S" CACHE STRING "AMD device part")
set(CLOCK_NS "3.333333" CACHE STRING "Clock period in nanoseconds")
find_package(Python3 3.9 REQUIRED COMPONENTS Interpreter)
find_program(SBT NAMES sbt)
find_program(VIVADO NAMES vivado HINTS "$ENV{XILINX_VIVADO}/bin")
find_program(VITIS_RUN NAMES vitis-run HINTS "$ENV{XILINX_VITIS}/bin")
if(VIVADO)
    get_filename_component(vivado_real "${VIVADO}" REALPATH)
    get_filename_component(vivado_bin "${vivado_real}" DIRECTORY)
    get_filename_component(vivado_hint "${vivado_bin}" DIRECTORY)
endif()
find_path(VIVADO_ROOT NAMES data/verilog/src/glbl.v
    HINTS "$ENV{XILINX_VIVADO}" "${vivado_hint}")
foreach(tool IN ITEMS xvlog xelab xsim)
    string(TOUPPER "${tool}" variable)
    find_program(${variable} NAMES "${tool}" HINTS "${VIVADO_ROOT}/bin")
endforeach()

set(CONFIG "${BUILD}/config.cmake")
configure_file(cmake/Config.cmake.in "${CONFIG}" @ONLY)
set(VECTORS "${BUILD}/tests/vectors.mem")
add_custom_command(OUTPUT "${VECTORS}"
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${BUILD}/tests"
    COMMAND "${Python3_EXECUTABLE}" "${ROOT}/tests/reference.py" "${VECTORS}"
    DEPENDS "${ROOT}/tests/reference.py"
    COMMENT "Generating golden vectors"
    VERBATIM)
add_custom_target(vectors DEPENDS "${VECTORS}")

enable_testing()
add_test(NAME reference COMMAND "${Python3_EXECUTABLE}" -m unittest
    discover -s "${ROOT}/tests" -p test_reference.py -v)
set_tests_properties(reference PROPERTIES ENVIRONMENT "PYTHONDONTWRITEBYTECODE=1")

add_subdirectory(rtl)
add_subdirectory(hls)
add_custom_target(ip-check
    COMMAND "${CMAKE_COMMAND}" "-DCONFIG=${CONFIG}" -P "${ROOT}/cmake/CheckIP.cmake"
    DEPENDS rtl-ip hls-ip
    VERBATIM)
add_custom_target(dist
    COMMAND "${CMAKE_COMMAND}" "-DCONFIG=${CONFIG}" -P "${ROOT}/cmake/Dist.cmake"
    VERBATIM)
