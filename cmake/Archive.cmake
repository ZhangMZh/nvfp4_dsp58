# SPDX-License-Identifier: MIT
function(extract_package archive directory)
    execute_process(COMMAND "${CMAKE_COMMAND}" -E tar tf "${archive}"
        OUTPUT_VARIABLE entries COMMAND_ERROR_IS_FATAL ANY)
    string(REPLACE "\n" ";" entries "${entries}")
    foreach(entry IN LISTS entries)
        if(IS_ABSOLUTE "${entry}" OR entry MATCHES "(^|[/\\])\\.\\.([/\\]|$)")
            message(FATAL_ERROR "Nonportable archive entry: ${entry}")
        endif()
    endforeach()
    prepare_work("${directory}")
    file(ARCHIVE_EXTRACT INPUT "${archive}" DESTINATION "${directory}")
endfunction()

function(package_docs archive directory)
    extract_package("${archive}" "${directory}")
    file(COPY "${ROOT}/README.md" "${ROOT}/LICENSE" DESTINATION "${directory}")
    file(GLOB entries RELATIVE "${directory}" "${directory}/*")
    execute_process(COMMAND "${CMAKE_COMMAND}" -E tar cf "${archive}" --format=zip -- ${entries}
        WORKING_DIRECTORY "${directory}" COMMAND_ERROR_IS_FATAL ANY)
endfunction()
