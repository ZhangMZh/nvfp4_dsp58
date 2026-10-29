# SPDX-License-Identifier: MIT
# Import ONLY a relocated package through the Vivado IP catalog.
lassign $argv root package output part period vlnv
set output [file normalize $output]
file mkdir $output
set_param general.maxThreads 4
create_project -force check_ip $output/project -part $part
set_property ip_repo_paths [list [file normalize $package]] [current_project]
update_ip_catalog
create_ip -vlnv $vlnv -module_name imported_dot16
set ip [get_ips imported_dot16]
set_property generate_synth_checkpoint false [get_files imported_dot16.xci]
generate_target all $ip
# Check package portability and internal timing; rtl-impl covers the core interfaces.
synth_design -top imported_dot16 -part $part -mode out_of_context
source [file join $root rtl scripts physical.tcl]
dot16_implement $output $period
puts "DOT16_FLOW_PASS"
exit
