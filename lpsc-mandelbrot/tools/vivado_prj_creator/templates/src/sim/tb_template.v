//--------------------------------------------------------------------------------
//                                 _             _
//                                | |_  ___ _ __(_)__ _
//                                | ' \/ -_) '_ \ / _` |
//                                |_||_\___| .__/_\__,_|
//                                         |_|
//
//--------------------------------------------------------------------------------
//
// Company: hepia
// Author: <author>
//
// Module Name: tb_<prj_name> - arch
// Target Device: <board_name> <part_name>
// Tool version: <tool_version>
// Description: Testbench for <prj_name>
//
// Last update: <update_time>
//
//-------------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "../hdl/<prj_name>.v"

module tb_<prj_name> ();

// Stimulis generator
initial begin
  $finish;
end

// Instantiate unit under test
<prj_name> <prj_name>_i (

);

endmodule
