# SPDX-License-Identifier: MIT
# Import ONLY a relocated package through the Vivado IP catalog.
lassign $argv root package output part period scaled
if {$scaled eq ""} { set scaled 0 }
set package [file normalize $package]
set output [file normalize $output]
file mkdir $output
set_param general.maxThreads 4
set core [ipx::open_core $package/component.xml]
set vlnv [get_property VLNV $core]
set references 0
foreach group [ipx::get_file_groups -of_objects $core] {
    foreach item [ipx::get_files -of_objects $group] {
        set name [get_property NAME $item]
        set path [file normalize [file join $package $name]]
        if {[file pathtype $name] ne "relative" ||
            [string first "$package/" $path] != 0 || ![file isfile $path]} {
            error "Package references missing/external file: $name"
        }
        if {[file extension $path] in {.v .sv}} {
            set source [open $path r]
            set content [read $source]
            close $source
            if {[string first "BLOCK_SCALING" $content] >= 0} {
                error "Exported HDL still depends on the mode macro: $name"
            }
        }
        incr references
    }
}
if {$references == 0} {
    error "Package has no file references"
}
puts "Verified $vlnv: $references package file references"
ipx::unload_core $core
create_project -force check_ip $output/project -part $part
set_property ip_repo_paths [list [file normalize $package]] [current_project]
update_ip_catalog
create_ip -vlnv $vlnv -module_name imported_dot16
set ip [get_ips imported_dot16]
set_property generate_synth_checkpoint false [get_files imported_dot16.xci]
generate_target all $ip
# Check package portability and internal timing; rtl-impl covers the core interfaces.
synth_design -top imported_dot16 -part $part -mode out_of_context
set input_width [expr {$scaled ? 144 : 128}]
set output_width [expr {$scaled ? 64 : 16}]
if {[llength [get_ports -quiet {s_axis_tdata* input_r_TDATA*}]] != $input_width ||
    [llength [get_ports -quiet {m_axis_tdata* output_r_TDATA*}]] != $output_width} {
    error "Imported IP stream widths do not match the selected mode"
}
puts "Verified imported stream widths: $input_width / $output_width"
source [file join $root rtl scripts physical.tcl]
dot16_implement $output $period $scaled
puts "DOT16_FLOW_PASS"
exit
