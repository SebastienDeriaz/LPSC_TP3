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
# Description: TCL script for re-creating Vitis workspace
#
# Last update: <update_time>
#
##################################################################################

#
# Include files
#
source utils.tcl

#
# Procedures
#
# Create source directories and import application source files
proc import_app_sources {prj_workspace app_name app_src_path} {
	puts "Import application source file into workspace..."

	# Create workspace application directory
	set ws_app_src_dir "${prj_workspace}/${app_name}/src"
	file mkdir "${ws_app_src_dir}"
	print_status "Create app directory into workspace: ${ws_app_src_dir}" "OK"

	foreach f [glob -nocomplain -directory ${app_src_path} *] {
		file copy -force $f ${ws_app_src_dir}
		print_status "Copy $f into ${ws_app_src_dir}" "OK"
	}
}

#
# Generate workspace
#

# Set variables
set pwd [pwd]
set tool_version "<tool_version>"

if {$tool_version >= "2019.2"} {
  set prj_workspace "../vitis_workspace"

  set prj_platform "<prj_name>"
  set prj_desc "Zynq platform project"
  set prj_xsa "${pwd}/../hw_export/<prj_name>.xsa"

  # Generate default application for APU0
  # APU0
  set apu_0_prj_proc "<proc_name>"
  set apu_0_prj_os "<os_name>"

  set apu_0_domain_name "<os_name>_apu0_domain"

  set apu_0_app_sysprj "<prj_name>_app_system"
  set apu_0_app_template "<template_name>"

  set apu_0_app_name "<prj_name>_app"
  set apu_0_app_src_dir "${pwd}/../sw_apps/<prj_name>_app/src"

  # Create the workspace
  file mkdir $prj_workspace
  setws $prj_workspace

  # Create the platform from the XSA (Xilinx Shell Archive) file
  platform create -name $prj_platform -desc $prj_desc -hw $prj_xsa 

  # Create a domain for the APU (Core_0)
  domain create -name ${apu_0_domain_name} -proc ${apu_0_prj_proc} -os ${apu_0_prj_os}

  # Setup the APU_0 domain
  domain active ${apu_0_domain_name}
  # Example of how to add libraries to the BSP
  #bsp setlib -name xilfpga
  #bsp setlib -name xilsecure

  # Build the platform
  platform active ${prj_platform}
  platform generate

  # Build the APU_0 domain
  domain active ${apu_0_domain_name}
  # Create an application for APU Core_0
  app create -name ${apu_0_app_name} -sysproj ${apu_0_app_sysprj} -platform ${prj_platform} -domain ${apu_0_domain_name} -proc ${apu_0_prj_proc} -os ${apu_0_prj_os} -template ${apu_0_app_template} -lang {c}
  # Add application sources
  # Sources are copied into the workspace directory
  import_app_sources ${prj_workspace} ${apu_0_app_name} ${apu_0_app_src_dir}
  # Set includes path
  app config -name ${apu_0_app_name} -add include-path {"${workspace_loc:/${ProjName}/src/inc}"}
  # Build application
  app build ${apu_0_app_name}
} else {
  set prj_workspace "../sdk_workspace"
  set prj_name "<prj_name>"

  set workspace_dir "${prj_workspace}/$prj_name/$prj_name.sdk/"
  set hw_spec_file "../hw_export/$prj_name.hdf"

  set hw_platform_name "${prj_name}_hw_platform_0"
  set proc_name "<proc_name>"
  set os_name "<os_name>"

  set bsp_name "${prj_name}_bsp"
  set app_name "${prj_name}_app"

  # Set the SDK workspace
  setws $prj_workspace
  print_status "Set workspace directory" "OK"

  # Create the hardware project
  sdk createhw -name $hw_platform_name -hwspec $hw_spec_file
  print_status "Create hardware project" "OK"

  # Create the OS BSP
  sdk createbsp -name $bsp_name -hwproject $hw_platform_name -proc $proc_name -os $os_name
  print_status "Create OS BSP project" "OK"

  # Create the empty application
  sdk createapp -name $app_name -hwproject $hw_platform_name -proc $proc_name -lang C -app {Empty Application} -os $os_name -bsp $bsp_name
  print_status "Create Empty Application project" "OK"

  # Import source files
  sdk importsources -name $app_name -path ../sw_apps/<prj_name>_app/src
  print_status "Import project source files" "OK"

  # Set the include directories
  configapp -app $app_name include-path {"${workspace_loc:/${ProjName}/src/inc/}"}
  print_status "Set includes directories" "OK"

  # Build the projects
  print_status "Build BSP project" "IN_PROGRESS"
  sdk projects -build -type bsp -name $bsp_name
  print_status "Build BSP project" "OK"

  print_status "Build application project" "IN_PROGRESS"
  sdk projects -build -type app -name $app_name
  print_status "Build application project" "OK"
}
