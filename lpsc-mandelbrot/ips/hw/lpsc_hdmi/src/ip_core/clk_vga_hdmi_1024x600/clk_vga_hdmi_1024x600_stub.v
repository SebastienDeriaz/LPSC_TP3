// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.2 (lin64) Build 3367213 Tue Oct 19 02:47:39 MDT 2021
// Date        : Mon Feb 28 09:37:39 2022
// Host        : debian-xps15 running 64-bit Debian GNU/Linux 11 (bullseye)
// Command     : write_verilog -force -mode synth_stub
//               /home/jo/Documents/Hepia/cours/lpsc/lpsc-mandelbrot/ips/hw/lpsc_hdmi/src/ip_core/clk_vga_hdmi_1024x600/clk_vga_hdmi_1024x600_stub.v
// Design      : clk_vga_hdmi_1024x600
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tsbg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_vga_hdmi_1024x600(ClkVgaxCO, ClkHdmixCO, reset, PllLockedxSO, 
  ClkSys100MhzxCI)
/* synthesis syn_black_box black_box_pad_pin="ClkVgaxCO,ClkHdmixCO,reset,PllLockedxSO,ClkSys100MhzxCI" */;
  output ClkVgaxCO;
  output ClkHdmixCO;
  input reset;
  output PllLockedxSO;
  input ClkSys100MhzxCI;
endmodule
