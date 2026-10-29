# SPDX-License-Identifier: MIT
lassign $argv source top output part period
set source [file normalize $source]
set output [file normalize $output]
file mkdir $output
set_param general.maxThreads 4
create_project -in_memory -part $part
foreach file [glob -nocomplain $source/*.sv] {
    read_verilog -sv $file
}
foreach file [glob -nocomplain $source/*.v] {
    read_verilog $file
}
synth_design -top $top -part $part -mode out_of_context
source [file join [file dirname [info script]] physical.tcl]
dot16_implement $output $period
puts "DOT16_FLOW_PASS"
exit
