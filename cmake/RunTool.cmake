# SPDX-License-Identifier: MIT
function(require_tool variable)
    if(NOT ${variable} OR NOT EXISTS "${${variable}}")
        message(FATAL_ERROR
            "${variable} not found. Source the tool environment and reconfigure, "
            "or configure with -D${variable}=/path/to/tool.")
    endif()
endfunction()

# Each invocation owns its output directory; never clear another target's work.
function(prepare_work directory)
    file(REMOVE_RECURSE "${directory}")
    file(MAKE_DIRECTORY "${directory}")
endfunction()

function(run_tool directory name marker)
    # xelab and HLS's host compiler need the GCC startup-object directory.
    find_program(gcc NAMES gcc)
    if(gcc)
        execute_process(COMMAND "${gcc}" -print-file-name=crt1.o
            OUTPUT_VARIABLE crt OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(EXISTS "${crt}")
            get_filename_component(libdir "${crt}" DIRECTORY)
            if(DEFINED ENV{LIBRARY_PATH} AND NOT "$ENV{LIBRARY_PATH}" STREQUAL "")
                string(APPEND libdir ":$ENV{LIBRARY_PATH}")
            endif()
            set(ENV{LIBRARY_PATH} "${libdir}")
        endif()
    endif()
    if(IS_ABSOLUTE "${name}")
        set(log "${name}.log")
    else()
        set(log "${directory}/${name}.log")
    endif()
    get_filename_component(label "${name}" NAME)
    message(STATUS "Running ${label}: ${log}")
    execute_process(COMMAND ${ARGN} WORKING_DIRECTORY "${directory}"
        OUTPUT_FILE "${log}" ERROR_FILE "${log}" RESULT_VARIABLE result)
    file(READ "${log}" output)
    if(NOT result STREQUAL "0" OR
       (NOT marker STREQUAL "" AND NOT output MATCHES "(^|\n)(\\[info\\] )?${marker}"))
        string(LENGTH "${output}" length)
        if(length GREATER 8000)
            math(EXPR start "${length} - 8000")
            string(SUBSTRING "${output}" ${start} -1 output)
        endif()
        message(FATAL_ERROR "${label} failed (${result}): ${log}\n${output}")
    endif()
    message(STATUS "PASS ${label}")
endfunction()
