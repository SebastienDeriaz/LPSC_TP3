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
# Description: TCL script for re-creating Vivado project '<prj_name>'
#
# Last update: <update_time>
#
##################################################################################

# Include files
source utils.tcl

set PRJ_DIR ".."
set prj_name "<prj_name>"
set PKG_DIR "${PRJ_DIR}/../../../../../packages"
set SOC_DIR "${PRJ_DIR}/../../../../../soc/"

# Set project type
set PRJ_TYPE "<prj_type>"

# Create a variable to store the start time
set start_time [clock format [clock seconds] -format {%b. %d, %Y %I:%M:%S %p}]

# Set the original project directory path for adding/importing sources in the new project
set src_dir "${PRJ_DIR}/../src"
set ip_dir "${PRJ_DIR}/<ip_dir_path>"
set periph_dir "${PRJ_DIR}/<periph_dir_path>"
set comp_dir "${ip_dir}/$prj_name"
set comp_src_dir "${comp_dir}/src"
set pkg_src_dir "${PKG_DIR}/hw"
set soc_src_dir "${SOC_DIR}/hw"
print_status "Set directory paths" "OK"

# Create the project
create_project $prj_name ${PRJ_DIR}/$prj_name -part <part_name>
set_property board_part <board_name> [current_project]
set_property target_language VHDL [current_project]
print_status "Create project" "OK"

# Map the IP Repository so that custom IP is included
set_property ip_repo_paths [list $ip_dir $periph_dir] [current_fileset]
update_ip_catalog

#----------------------------------------------------------------
# Add project sources
#----------------------------------------------------------------

# Get HDL source files directory
if {$PRJ_TYPE == "DESIGN_PRJ_TYPE"} {
    set hdl_src_dir "${src_dir}/hdl"
    set sim_src_dir "${src_dir}/sim"
} elseif {$PRJ_TYPE == "COMP_PRJ_TYPE"} {
    # components sources are stored in an external directory
    set hdl_src_dir "${comp_src_dir}/hdl"
    set sim_src_dir "${comp_src_dir}/sim"
}

# add HDL source files
set vhdl_src_file_list [findFiles $hdl_src_dir *.vhd]
set verilog_src_file_list [findFiles $hdl_src_dir *.v]
set system_verilog_src_file_list [findFiles $hdl_src_dir *.sv]
set hdl_src_file_list [list {*}$vhdl_src_file_list {*}$verilog_src_file_list {*}$system_verilog_src_file_list]

if {$hdl_src_file_list != ""} {
  add_files -norecurse $hdl_src_file_list
} else {
  print_status "No sources to be added" "WARNING"
}

# Set VHDL version
foreach j $vhdl_src_file_list {
  set_property file_type {<vhdl_version>} [get_files $j]
  print_status "<vhdl_version> mode configured for the file $j" "OK"
}
print_status "<vhdl_version> mode configured for project sources" "OK"

# Add constraint files and IPs source files
if {$PRJ_TYPE == "DESIGN_PRJ_TYPE"} {
  # add the constraints file (XDC)
  <find_constr_file>
  # add IPs source files
  <find_xci_design_src_file>
} elseif {$PRJ_TYPE == "COMP_PRJ_TYPE"} {
  # add IPs source files
  <find_xci_comp_src_file>
  # add IP-XACT source file
  #add_files -norecurse $comp_dir/component.xml
}
print_status "Add project sources" "OK"

# Set packages libraries if any
#set_property library library_name [get_files  $src_dir/hdl/package_name.vhd]
#update_compile_order -fileset sources_1

# Create the IP Integrator portion of the design
#create_bd_design "axi_design"
#update_compile_order -fileset sources_1

# launch the TCL script to generate the IPI design
if {$PRJ_TYPE == "DESIGN_PRJ_TYPE"} {
  source $src_dir/ipi_tcl/${prj_name}_ipi.tcl
} elseif {$PRJ_TYPE == "COMP_PRJ_TYPE"} {
  source $comp_src_dir/ipi_tcl/${prj_name}_ipi.tcl
}
print_status "Add IPI design" "OK"

# Set the top level design
set_property top $prj_name [current_fileset]
update_compile_order -fileset sources_1

# Add packages sources
<find_pkg_src_file>

# Add SoC wrapper sources files
<find_soc_src_file>

# Add simulation sources
set vhdl_sim_file_list [findFiles $sim_src_dir *.vhd]
set verilog_sim_file_list [findFiles $sim_src_dir *.v]
set system_verilog_sim_file_list [findFiles $sim_src_dir *.sv]
set hdl_sim_file_list [list {*}$vhdl_sim_file_list {*}$verilog_sim_file_list {*}$system_verilog_sim_file_list]

if {$hdl_sim_file_list != ""} {
  add_files -fileset sim_1 -norecurse $hdl_sim_file_list
  update_compile_order -fileset sim_1
  print_status "Add simulation sources" "OK"
} else {
  print_status "No simulation sources to be added" "WARNING"
}

foreach j $vhdl_sim_file_list {
  set_property file_type {<vhdl_version>} [get_files $j]
  print_status "<vhdl_version> mode configured for the file $j" "OK"
}
print_status "<vhdl_version> mode configured for simulation sources" "OK"

# Add simulation packages sources
<find_sim_pkg_src_file>

# Set the completion time
set end_time [clock format [clock seconds] -format {%b. %d, %Y %I:%M:%S %p}]

# Display the start and end time to the screen
puts $start_time
puts $end_time

exit
