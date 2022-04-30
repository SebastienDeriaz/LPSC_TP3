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
# Description: Export the hardware design to Vitis SDK
#
# Last update: 2022-04-12 12:06:07
#
##################################################################################

source utils.tcl

# Project paths
set PRJ_DIR ".."
set SRC_DIR "${PRJ_DIR}/../src"
set EXPORT_DIR "${SRC_DIR}/sw/hw_export"

# Initialize workspace directories name
set prj_name "lpsc_mandelbrot_firmware"
# Create the export directory if not present
file mkdir ${EXPORT_DIR}
print_status "Initialize workspace directories" "OK"

# Open the project
open_project -verbose ${PRJ_DIR}/${prj_name}/${prj_name}.xpr
print_status "Open project $prj_name" "OK"

# Export the hardware including the bitstream
if {[version -short] < "2019.2"} {
    # Before Vivado 2019.2, export the .hdf
    set IMPL_DIR "${PRJ_DIR}/${prj_name}/${prj_name}.runs/impl_1/"
    file copy -force ${IMPL_DIR}/${prj_name}.sysdef ${EXPORT_DIR}/${prj_name}.hdf
} else {
    # Starting with Vivado 2019.2, export the .xsa
    write_hw_platform -fixed -force -include_bit -file ${EXPORT_DIR}/${prj_name}.xsa
}
print_status "Export hardware to SDK" "OK"

exit
