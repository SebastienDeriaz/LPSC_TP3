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
# Description: TCL script used to load software application
#
# Last update: <update_time>
#
##################################################################################

source utils.tcl

set PRJ_DIR ".."
set prj_name "<prj_name>"
set hw_platform_name "${prj_name}_hw_platform_0"
set app_name "${prj_name}_app"

# Connect to the hardware server
connect -url tcp:127.0.0.1:3121
print_status "Connect to hardware server" "OK"

# Connect to the processor
targets 2
print_status "Connect to ARM Cortex-A9 MPCore #0" "OK"

# Load the hardware design
loadhw -hw ${PRJ_DIR}/app/$prj_name.hdf
print_status "Load hardware design" "OK"

# Reset the processor
rst -processor
print_status "Reset ARM Cortex-A9 MPCore #0" "OK"

# Initialize the MPSoC
source ${PRJ_DIR}/app/ps7_init.tcl
ps7_init
ps7_post_config
print_status "Initialize PS7" "OK"

# Load the application
dow ${PRJ_DIR}/app/$app_name.elf
print_status "Load software application" "OK"

# Run the application
con
print_status "Run software application" "OK"

# Disconnect from the target
disconnect
print_status "Disconnect from hardware server" "OK"

exit

