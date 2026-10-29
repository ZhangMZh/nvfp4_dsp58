# SPDX-License-Identifier: MIT
# Require actual register-to-register timing paths through all six core AXIS ports.
set upstream_registers [get_cells -hier -filter {NAME =~ upstream/* && REF_NAME =~ FD*}]
set downstream_registers [get_cells -hier -filter {NAME =~ downstream/* && REF_NAME =~ FD*}]
if {![llength $upstream_registers] || ![llength $downstream_registers]} {
    error "Missing registered interface boundaries"
}
report_utilization -hierarchical -file $output/hierarchy.rpt
set interface_metrics [open $output/interfaces.tsv w]
foreach {port source_registers sink_registers} [list \
    s_axis_tdata $upstream_registers [all_registers] \
    s_axis_tvalid $upstream_registers [all_registers] \
    s_axis_tready [all_registers] $upstream_registers \
    m_axis_tdata [all_registers] $downstream_registers \
    m_axis_tvalid [all_registers] $downstream_registers \
    m_axis_tready $downstream_registers [all_registers]] {
    set pins [get_pins -quiet dut/${port}*]
    if {![llength $pins]} {
        error "Missing core boundary pins: $port"
    }
    foreach {kind delay} {setup max hold min} {
        set arguments [list -from $source_registers -through $pins -to $sink_registers \
            -delay_type $delay -max_paths 1]
        set paths [get_timing_paths {*}$arguments]
        if {![llength $paths]} {
            error "Untimed core boundary: $port $kind"
        }
        if {[get_property SLACK $paths] < 0} {
            error "Core boundary timing failed: $port $kind"
        }
        puts $interface_metrics "${port}_${kind}_slack_ns\t[get_property SLACK $paths]"
        report_timing {*}$arguments -file $output/${port}_${kind}.rpt
    }
}
close $interface_metrics
