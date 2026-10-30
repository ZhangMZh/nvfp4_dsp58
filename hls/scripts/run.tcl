# SPDX-License-Identifier: MIT
# CMake supplies argv: root work part period mode.
lassign $argv root work part period mode
set root [file normalize $root]
set work [file normalize $work]
if {$mode ni {csim synth cosim ip}} {
    error "Unknown HLS mode: $mode"
}
set crt [exec gcc -print-file-name=crt1.o]
if {[file exists $crt]} {
    set libdir [file dirname $crt]
    if {[info exists ::env(LIBRARY_PATH)]} {
        append libdir :$::env(LIBRARY_PATH)
    }
    set ::env(LIBRARY_PATH) $libdir
}
open_project -reset $work/project
set_top nvfp4_dot16_hls
set flags "-std=c++14 -I$root/hls/include"
add_files $root/hls/src/top.cpp -cflags $flags
add_files -blackbox $work/dot16.json
add_files -tb $root/hls/tb/test_dot16.cpp -cflags $flags
add_files -tb $work/vectors.mem
open_solution -reset solution -flow_target vivado
set_part $part
create_clock -period $period -name default
config_compile -pipeline_loops 0
config_rtl -reset all -reset_level high
csim_design -O
if {$mode ne "csim"} {
    csynth_design
}
if {$mode eq "cosim"} {
    cosim_design -rtl verilog -tool xsim -trace_level none -random_stall
}
if {$mode eq "ip"} {
    # Work around the 2025.1 blackbox metadata writer's inconsistent path roots.
    # This changes only this process, never the installed AMD tools.
    if {[string match "2025.1*" [version -short]]} {
        set procname ::AP::DESIGN_DATA::generate_json
        set old {set filepath_args [list "-quiet" "-filepaths" "relative" "-fileroot" $outdir]}
        set body [info body $procname]
        if {[string first $old $body] < 0} {
            error "Unsupported 2025.1 metadata writer"
        }
        set args {}
        foreach arg [info args $procname] {
            if {[info default $procname $arg value]} {
                lappend args [list $arg $value]
            } else {
                lappend args $arg
            }
        }
        proc $procname $args [string map [list $old {set filepath_args [list "-quiet" "-filepaths" "absolute"]}] $body]
    }
    export_design -format ip_catalog -rtl verilog -vendor nvfp4.org -library hls
}
puts "DOT16_FLOW_PASS"
exit
