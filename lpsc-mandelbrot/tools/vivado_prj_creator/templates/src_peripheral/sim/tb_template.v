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

module tb_<prj_name> ();

// Constants
localparam C_S00_AXI_DATA_WIDTH = 32;
localparam C_S00_AXI_ADDR_WIDTH = 4;

// Unit under test ports
reg  s00_axi_aclk = 1'b1;
reg  s00_axi_aresetn = 1'b0;

reg [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr = {C_S00_AXI_ADDR_WIDTH {1'b0}};
reg [2 : 0] s00_axi_awprot = {3 {1'b0}};
reg  s00_axi_awvalid = 1'b0;
wire  s00_axi_awready;
reg [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata = {C_S00_AXI_DATA_WIDTH {1'b0}};
reg [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb = {(C_S00_AXI_DATA_WIDTH/8) {1'b0}};
reg  s00_axi_wvalid = 1'b0;
wire  s00_axi_wready;
wire [1 : 0] s00_axi_bresp;
wire  s00_axi_bvalid;
reg  s00_axi_bready = 1'b0;

reg [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr = {C_S00_AXI_ADDR_WIDTH {1'b0}};
reg [2 : 0] s00_axi_arprot = {3 {1'b0}};
reg  s00_axi_arvalid = 1'b0;
wire  s00_axi_arready;
wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
wire [1 : 0] s00_axi_rresp;
wire  s00_axi_rvalid;
reg  s00_axi_rready = 1'b0;

// Clock period: 100 MHz (10 ns)
localparam s00_axi_aclk_period = 10;
localparam s00_axi_aclk_half_period = s00_axi_aclk_period / 2;

// Registers offset
localparam DATA_0_REG_OFFSET = 0;   // Data 0 register
localparam DATA_1_REG_OFFSET = 4;   // Data 1 register

// Data read from registers
reg [C_S00_AXI_DATA_WIDTH-1 : 0] rd_data = {C_S00_AXI_DATA_WIDTH {1'b0}};

// Instantiate unit under test
<prj_name> # (
  .C_S00_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
  .C_S00_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
) <prj_name>_i (
  .s00_axi_aclk(s00_axi_aclk),
  .s00_axi_aresetn(s00_axi_aresetn),
  .s00_axi_awaddr(s00_axi_awaddr),
  .s00_axi_awprot(s00_axi_awprot),
  .s00_axi_awvalid(s00_axi_awvalid),
  .s00_axi_awready(s00_axi_awready),
  .s00_axi_wdata(s00_axi_wdata),
  .s00_axi_wstrb(s00_axi_wstrb),
  .s00_axi_wvalid(s00_axi_wvalid),
  .s00_axi_wready(s00_axi_wready),
  .s00_axi_bresp(s00_axi_bresp),
  .s00_axi_bvalid(s00_axi_bvalid),
  .s00_axi_bready(s00_axi_bready),
  .s00_axi_araddr(s00_axi_araddr),
  .s00_axi_arprot(s00_axi_arprot),
  .s00_axi_arvalid(s00_axi_arvalid),
  .s00_axi_arready(s00_axi_arready),
  .s00_axi_rdata(s00_axi_rdata),
  .s00_axi_rresp(s00_axi_rresp),
  .s00_axi_rvalid(s00_axi_rvalid),
  .s00_axi_rready(s00_axi_rready)
);

// Generate clock
always
  #s00_axi_aclk_half_period s00_axi_aclk = ~s00_axi_aclk;

//-------------------------------------------------------------------------------
// Task: Write a value in an AXI register
//-------------------------------------------------------------------------------
task write_reg;
  input reg_offset;
  input [C_S00_AXI_DATA_WIDTH-1 : 0] wr_data;
  begin
      s00_axi_awaddr = reg_offset;
      s00_axi_awvalid = 1'b1;
      #s00_axi_aclk_period;
      s00_axi_wdata = wr_data;
      s00_axi_wvalid = 1'b1;
      s00_axi_wstrb = {(C_S00_AXI_DATA_WIDTH/8) {1'b1}};
      
      if (s00_axi_awready == 1'b0) begin
        wait(s00_axi_awready == 1'b1);
      end
      if (s00_axi_wready == 1'b0) begin
        wait(s00_axi_wready == 1'b1);
      end
      
      #s00_axi_aclk_period;
      
      #1 s00_axi_awvalid = 1'b0;
      #1 s00_axi_wvalid = 1'b0;

      if (s00_axi_bvalid == 1'b0) begin
        wait(s00_axi_bvalid == 1'b1);
      end
      #s00_axi_aclk_period;
      s00_axi_bready = 1'b1;
      #s00_axi_aclk_period;
      s00_axi_bready = 1'b0;
  end
endtask

//-------------------------------------------------------------------------------
// Task: Read a value from an AXI register
//-------------------------------------------------------------------------------
task read_reg;
  input reg_offset;
  output [C_S00_AXI_DATA_WIDTH-1 : 0] rd_data;
  begin
      s00_axi_araddr = reg_offset;
      s00_axi_arvalid = 1'b1;
      
      if (s00_axi_arready == 1'b0) begin
        wait(s00_axi_arready == 1'b1);
      end
      if (s00_axi_rvalid == 1'b0) begin
        wait(s00_axi_rvalid == 1'b1);
      end
      
      #s00_axi_aclk_period;
      
      #1 s00_axi_arvalid = 1'b0;
      #1 s00_axi_rready = 1'b1;
      rd_data = s00_axi_rdata;
      
      #s00_axi_aclk_period;
      
      s00_axi_rready = 1'b0;
  end
endtask

// Assertion function
`define assert(signal, value) \
  if (signal !== value) begin \
    $display("Assertion FAILED in %m: signal != value"); \
    $finish; \
  end

// Stimulis generator
initial begin
  // hold reset
  s00_axi_aresetn = 1'b0;
  #(s00_axi_aclk_period * 10) s00_axi_aresetn = 1'b1;
  #(s00_axi_aclk_period * 4);
  
  // Write in register 0
  $display("Write Data 0 register");
  write_reg(DATA_0_REG_OFFSET, 32'hCAFEFACE);
  #(s00_axi_aclk_period * 4);

  // Read and check register 0
  $display("Read Data 0 register");
  read_reg(DATA_0_REG_OFFSET, rd_data);
  `assert(rd_data, 32'hCAFEFACE);
  #(s00_axi_aclk_period * 20);

  // Write in register 0
  $display("Write Data 1 register");
  write_reg(DATA_1_REG_OFFSET, 32'hDEADBEEF);
  #(s00_axi_aclk_period * 4);

  // Read and check register 0
  $display("Read Data 1 register");
  read_reg(DATA_1_REG_OFFSET, rd_data);
  `assert(rd_data, 32'hDEADBEEF);
  #(s00_axi_aclk_period * 20);
  
  $display("-- Simulation completed successfully --");
  $finish;
end

endmodule
