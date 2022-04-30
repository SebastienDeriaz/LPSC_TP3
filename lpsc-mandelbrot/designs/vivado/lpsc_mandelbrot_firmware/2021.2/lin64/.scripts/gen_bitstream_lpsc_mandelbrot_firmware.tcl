#!/usr/bin/tcl

##################################################################################
#                                 _             _
#                                | |_  ___ _ __(_)__ _
#                                | ' \/ -_) '_ \ / _` |
#                                |_||_\___| .__/_\__,_|
#                                         |_|
#
##################################################################################
#
# Company: hepia
# Author: Joachim Schmidt <joachim.schmidt@hesge.ch
#
# Project Name: lpsc_mandelbrot_firmware
# Target Device: digilentinc.com:nexys_video:part0:1.1 xc7a200tsbg484-1
# Tool version: 2021.2
# Description: TCL script used to generate bitstream file
#
# Last update: 2022-04-12 12:06:07
#
##################################################################################

source utils.tcl

set PRJ_DIR ".."
set prj_name "lpsc_mandelbrot_firmware"

# Create a variable to store the start time
set start_time [clock format [clock seconds] -format {%b. %d, %Y %I:%M:%S %p}]

# Open the project
open_project -verbose ${PRJ_DIR}/$prj_name/$prj_name.xpr
update_compile_order -fileset sources_1
print_status "Open project $prj_name" "OK"

# Run synthesis
print_status "Run synthesis" "IN_PROGRESS"
launch_runs synth_1
wait_on_run synth_1
print_status "Run synthesis" "OK"

# Run implementation
print_status "Run implementation" "IN_PROGRESS"
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
print_status "Run implementation" "OK"

# Set the completion time
set end_time [clock format [clock seconds] -format {%b. %d, %Y %I:%M:%S %p}]

# Display the start and end time on the screen
puts $start_time
puts $end_time

exit
