# SPDX-License-Identifier: MIT
# Shared OOC implementation and physical acceptance gates, after synthesis.
proc dot16_implement {output period} {
    create_clock -name ap_clk -period $period [get_ports ap_clk]
    set_clock_uncertainty -setup 0.1 [get_clocks ap_clk]
    set_clock_uncertainty -hold 0.1 [get_clocks ap_clk]
    # Only external I/O timing is delegated to the integrating design.
    set_false_path -from [get_ports -filter {DIRECTION == IN && NAME != ap_clk}]
    set_false_path -to [all_outputs]
    opt_design
    place_design
    phys_opt_design
    route_design
    report_utilization -file $output/utilization.rpt
    report_timing_summary -report_unconstrained -max_paths 10 -file $output/timing.rpt
    report_route_status -file $output/route.rpt
    report_drc -file $output/drc.rpt
    check_timing -verbose -file $output/check_timing.rpt
    write_checkpoint -force $output/routed.dcp
    set f [open $output/route.rpt r]
    set route_status [read $f]
    close $f
    foreach {label variable} {
        {routable nets} routable {fully routed nets} routed {nets with routing errors} errors
    } {
        set pattern [format {# of %s[. ]*:\s*([0-9]+)} $label]
        if {![regexp $pattern $route_status -> $variable]} {
            error "Missing route-status field: $label"
        }
    }
    if {$routable == 0 || $routed != $routable || $errors != 0} {
        error "Incomplete routing"
    }
    dot16_audit $output $period
}

proc dot16_constant {cell port width} {
    set value 0
    for {set bit 0} {$bit < $width} {incr bit} {
        if {$width == 1} {
            set pin $cell/$port
        } else {
            set pin [format {%s/%s[%d]} $cell $port $bit]
        }
        set net [get_nets -of_objects [get_pins $pin]]
        set type [get_property TYPE $net]
        if {$type eq "POWER"} {
            set value [expr {$value | (1 << $bit)}]
        } elseif {$type ne "GROUND"} {
            error "$pin is not a constant"
        }
    }
    return $value
}

proc dot16_audit {output period} {
    set dsps [lsort [get_cells -hier -filter {REF_NAME == DSP58}]]
    if {[llength $dsps] != 4} {
        error "Expected exactly four DSP58s"
    }
    if {[llength [get_cells -quiet -hier -filter {REF_NAME == DSPFP32 || REF_NAME =~ RAMB* || REF_NAME =~ URAM*}]]} {
        error "Unexpected extra DSP or block memory"
    }
    if {[llength [get_cells -quiet -hier -filter {IS_BLACKBOX == 1}]]} {
        error "Unresolved blackbox"
    }
    set structure [open $output/structure.tsv w]
    set index 0
    foreach cell $dsps {
        foreach {key value} {
            DSP_MODE INT8 USE_SIMD ONE58 AREG 1 BREG 1 CREG 0
            CARRYINREG 0 MREG 0 PREG 1 OPMODEREG 0
        } {
            if {[get_property $key $cell] ne $value} {
                error "$cell: expected $key=$value"
            }
        }
        set opmode [dot16_constant $cell OPMODE 9]
        if {$opmode != 0x185} {
            error "$cell: unexpected OPMODE $opmode"
        }
        if {[dot16_constant $cell ALUMODE 4] || [dot16_constant $cell CARRYINSEL 3]} {
            error "Unexpected adder control"
        }
        if {[dot16_constant $cell PCIN 58]} {
            error "$cell: PCIN must be zero"
        }
        puts $structure "$index\t$cell\t[get_property LOC $cell]\t[format 0x%03x $opmode]"
        incr index
    }
    close $structure
    set metrics [open $output/metrics.tsv w]
    puts $metrics "period_ns\t$period"
    puts $metrics "DSP58\t[llength $dsps]"
    set utilization [report_utilization -return_string]
    if {![regexp {\| CLB LUTs\*? +\| +([0-9]+)} $utilization -> luts]} {
        error "Missing physical LUT count"
    }
    puts $metrics "LUT\t$luts"
    puts $metrics "FF\t[llength [get_cells -quiet -hier -filter {REF_NAME =~ FD*}]]"
    set timing_ok 1
    foreach {kind delay} {setup max hold min} {
        set paths [get_timing_paths -from [all_registers] -to [all_registers] -delay_type $delay -max_paths 1]
        if {![llength $paths]} {
            error "Missing internal $kind path"
        }
        set slack [get_property SLACK $paths]
        puts $metrics "${kind}_slack_ns\t$slack"
        report_timing -from [all_registers] -to [all_registers] -delay_type $delay -max_paths 10 -file $output/$kind.rpt
        if {$slack < 0} {
            set timing_ok 0
        }
    }
    close $metrics
    set f [open $output/check_timing.rpt r]
    set timing_checks [read $f]
    close $f
    foreach category {no_clock constant_clock unconstrained_internal_endpoints multiple_clock loops latch_loops} {
        if {![regexp "checking $category \\(0\\)" $timing_checks]} {
            error "Failed check_timing: $category"
        }
    }
    if {[llength [get_drc_violations -quiet -filter {SEVERITY == Error || SEVERITY == {Critical Warning}}]]} {
        error "Implementation DRC failed"
    }
    if {!$timing_ok} {
        error "Internal timing failed"
    }
}
