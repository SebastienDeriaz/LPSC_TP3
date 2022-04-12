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
# Description: Microprocessor Driver Definition (MDD)
#
# Last update: <update_time>
#
##################################################################################

proc generate {drv_handle} {
  ::hsi::utils::define_include_file $drv_handle "xparameters.h" "<prj_name>" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR"
  ::hsi::utils::define_canonical_xpars $drv_handle "xparameters.h" "<prj_name>" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR"
}
