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
# Description: TCL script used to load FPGA bitstream
#
# Last update: <update_time>
#
##################################################################################

source utils.tcl

set PRJ_DIR ".."
set prj_name "<prj_name>"

# Open the hardware manager and connect to the hardware server
open_hw
print_status "Open hardware manager" "OK"
connect_hw_server -url localhost:3121
print_status "Connect to hardware server" "OK"

# Get the hardware target and open it
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/*]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/*]
open_hw_target
print_status "Open hardware target" "OK"

# Display targets list
set index -1
set targets [lindex [get_hw_devices]]
puts "Found target(s):"
foreach target $targets {
  incr index
  puts "$index : $target"
}
puts "Which target do you want to program?"
set sel_target [read stdin 1]

# Set the program file
set_property PROGRAM.FILE ${PRJ_DIR}/bitstream/$prj_name.bit [lindex [get_hw_devices] $sel_target]
current_hw_device [lindex [get_hw_devices] $sel_target]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] $sel_target]
print_status "Set program file" "OK"

# Program the device
print_status "Program device" "IN_PROGRESS"
program_hw_device [lindex [get_hw_devices] $sel_target]
print_status "Program device" "OK"

exit
