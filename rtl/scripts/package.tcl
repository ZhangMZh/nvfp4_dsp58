# SPDX-License-Identifier: MIT
lassign $argv root output part period
set root [file normalize $root]
set output [file normalize $output]
set package $output/ip
file mkdir $package/hdl
foreach name {nvfp4_dot16 nvfp4_dot16_axis} {
    file copy -force $root/rtl/generated/$name.sv $package/hdl/$name.sv
}
create_project -in_memory -part $part
add_files [glob $package/hdl/*.sv]
set_property top nvfp4_dot16_axis [current_fileset]
ipx::package_project -root_dir $package -vendor nvfp4.org -library rtl -taxonomy /UserIP -import_files -set_current true
set core [ipx::current_core]
set_property name nvfp4_dot16_axis $core
set_property display_name {NVFP4 exact 16-element dot product} $core
set_property description {Two-cycle dot16: four parallel DSP58 Dot3 units, four LUT products and a combinational output sum; unscaled signed Q.} $core
set_property supported_families {versal Production} $core
ipx::infer_bus_interfaces xilinx.com:interface:axis_rtl:1.0 $core
ipx::infer_bus_interfaces xilinx.com:signal:clock_rtl:1.0 $core
ipx::infer_bus_interfaces xilinx.com:signal:reset_rtl:1.0 $core
set clock [ipx::get_bus_interfaces ap_clk -of_objects $core]
set param [ipx::add_bus_parameter ASSOCIATED_BUSIF $clock]
set_property value {s_axis:m_axis} $param
set param [ipx::add_bus_parameter ASSOCIATED_RESET $clock]
set_property value ap_rst $param
set param [ipx::add_bus_parameter FREQ_HZ $clock]
set_property value [expr {round(1.0e9 / $period)}] $param
set reset [ipx::get_bus_interfaces ap_rst -of_objects $core]
set param [ipx::add_bus_parameter POLARITY $reset]
set_property value ACTIVE_HIGH $param
ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::check_integrity $core
ipx::save_core $core
ipx::archive_core $output/nvfp4_dot16_axis.zip $core
puts "DOT16_FLOW_PASS"
exit
