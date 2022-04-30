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
# Description: TCL script used to load FPGA bitstream
#
# Last update: 2022-04-12 12:06:07
#
##################################################################################

source utils.tcl

set PRJ_DIR ".."
set prj_name "lpsc_mandelbrot_firmware"

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
