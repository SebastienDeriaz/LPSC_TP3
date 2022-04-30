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
# Author: <author>
#
# Project Name: <prj_name>
# Target Device: <board_name> <part_name>
# Tool version: <tool_version>
# Description: TCL script used to generate bitstream file
#
# Last update: <update_time>
#
##################################################################################

source utils.tcl

set PRJ_DIR ".."
set prj_name "<prj_name>"

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
