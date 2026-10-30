# SPDX-License-Identifier: MIT
lassign $argv root output part period scope
set root [file normalize $root]
set output [file normalize $output]
file mkdir $output
set_param general.maxThreads 4
create_project -in_memory -part $part
read_verilog -sv [glob $root/rtl/generated/*.sv]
set fixture [expr {$scope eq "integration"}]
set top nvfp4_dot16_axis
if {$fixture} {
    read_verilog -sv $root/rtl/tb/nvfp4_dot16_fixture.sv
    set top nvfp4_dot16_fixture
} elseif {$scope ne "internal"} {
    error "Unknown implementation scope: $scope"
}
synth_design -top $top -part $part -mode out_of_context
source $root/rtl/scripts/physical.tcl
dot16_implement $output $period
if {$fixture} {
    source $root/rtl/scripts/check_interfaces.tcl
}
puts "DOT16_FLOW_PASS"
exit
