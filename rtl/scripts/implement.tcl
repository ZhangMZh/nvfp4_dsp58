# SPDX-License-Identifier: MIT
lassign $argv root output part period scope scaled
if {$scaled eq ""} { set scaled 0 }
set root [file normalize $root]
set output [file normalize $output]
file mkdir $output
set_param general.maxThreads 4
create_project -in_memory -part $part
set family [expr {$scaled ? "nvfp4_scaled_dot16" : "nvfp4_dot16"}]
read_verilog -sv $root/rtl/generated/${family}.sv
read_verilog -sv $root/rtl/generated/${family}_axis.sv
set fixture [expr {$scope eq "integration"}]
set top ${family}_axis
if {$fixture} {
    if {$scaled} { set_property verilog_define {BLOCK_SCALING=1} [current_fileset] }
    read_verilog -sv $root/rtl/tb/nvfp4_dot16_fixture.sv
    set top ${family}_fixture
} elseif {$scope ne "internal"} {
    error "Unknown implementation scope: $scope"
}
synth_design -top $top -part $part -mode out_of_context
source $root/rtl/scripts/physical.tcl
dot16_implement $output $period $scaled
if {$fixture} {
    source $root/rtl/scripts/check_interfaces.tcl
}
puts "DOT16_FLOW_PASS"
exit
