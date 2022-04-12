----------------------------------------------------------------------------------
--                                 _             _
--                                | |_  ___ _ __(_)__ _
--                                | ' \/ -_) '_ \ / _` |
--                                |_||_\___| .__/_\__,_|
--                                         |_|
--
----------------------------------------------------------------------------------
--
-- Company: hepia
-- Author: <author>
--
-- Module Name: tb_<prj_name> - arch
-- Target Device: <board_name> <part_name>
-- Tool version: <tool_version>
-- Description: Testbench for <prj_name>
--
-- Last update: <update_time>
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_<prj_name> is
end tb_<prj_name>;


architecture behavioral of tb_<prj_name> is

  constant C_S00_AXI_DATA_WIDTH : integer := 32;
  constant C_S00_AXI_ADDR_WIDTH : integer := 5;

  component <prj_name> is
    generic (
      C_S00_AXI_DATA_WIDTH : integer;
      C_S00_AXI_ADDR_WIDTH : integer
      );
    port (
      s00_axi_aclk      : in  std_logic;
      s00_axi_aresetn   : in  std_logic;
      s00_axi_awaddr    : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
      s00_axi_awprot    : in  std_logic_vector(2 downto 0);
      s00_axi_awvalid   : in  std_logic;
      s00_axi_awready   : out std_logic;
      s00_axi_wdata     : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
      s00_axi_wstrb     : in  std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
      s00_axi_wvalid    : in  std_logic;
      s00_axi_wready    : out std_logic;
      s00_axi_bresp     : out std_logic_vector(1 downto 0);
      s00_axi_bvalid    : out std_logic;
      s00_axi_bready    : in  std_logic;
      s00_axi_araddr    : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
      s00_axi_arprot    : in  std_logic_vector(2 downto 0);
      s00_axi_arvalid   : in  std_logic;
      s00_axi_arready   : out std_logic;
      s00_axi_rdata     : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
      s00_axi_rresp     : out std_logic_vector(1 downto 0);
      s00_axi_rvalid    : out std_logic;
      s00_axi_rready    : in  std_logic
      );
  end component <prj_name>;

  signal s00_axi_aclk    : std_logic := '1';
  signal s00_axi_aresetn : std_logic := '0';

  signal s00_axi_awaddr  : std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0)     := (others => '0');
  signal s00_axi_awprot  : std_logic_vector(2 downto 0)                          := (others => '0');
  signal s00_axi_awvalid : std_logic                                             := '0';
  signal s00_axi_awready : std_logic;
  signal s00_axi_wdata   : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0)     := (others => '0');
  signal s00_axi_wstrb   : std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0) := (others => '0');
  signal s00_axi_wvalid  : std_logic                                             := '0';
  signal s00_axi_wready  : std_logic;
  signal s00_axi_bresp   : std_logic_vector(1 downto 0);
  signal s00_axi_bvalid  : std_logic;
  signal s00_axi_bready  : std_logic                                             := '0';
  signal s00_axi_araddr  : std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0)     := (others => '0');
  signal s00_axi_arprot  : std_logic_vector(2 downto 0)                          := (others => '0');
  signal s00_axi_arvalid : std_logic                                             := '0';
  signal s00_axi_arready : std_logic;
  signal s00_axi_rdata   : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
  signal s00_axi_rresp   : std_logic_vector(1 downto 0);
  signal s00_axi_rvalid  : std_logic;
  signal s00_axi_rready  : std_logic                                             := '0';

  constant s00_axi_aclk_period : time := 10 ns;

  -- Registers offset
  constant DATA_0_REG_OFFSET : integer := 0;  -- Data 0 register
  constant DATA_1_REG_OFFSET : integer := 4;  -- Data 1 register

  -- Data read from registers
  signal rd_data : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0) := (others => '0');

begin

  <prj_name>_i : entity work.<prj_name>
    generic map (
      C_S00_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
      C_S00_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
      )
    port map (
      s00_axi_aclk      => s00_axi_aclk,
      s00_axi_aresetn   => s00_axi_aresetn,
      s00_axi_awaddr    => s00_axi_awaddr,
      s00_axi_awprot    => s00_axi_awprot,
      s00_axi_awvalid   => s00_axi_awvalid,
      s00_axi_awready   => s00_axi_awready,
      s00_axi_wdata     => s00_axi_wdata,
      s00_axi_wstrb     => s00_axi_wstrb,
      s00_axi_wvalid    => s00_axi_wvalid,
      s00_axi_wready    => s00_axi_wready,
      s00_axi_bresp     => s00_axi_bresp,
      s00_axi_bvalid    => s00_axi_bvalid,
      s00_axi_bready    => s00_axi_bready,
      s00_axi_araddr    => s00_axi_araddr,
      s00_axi_arprot    => s00_axi_arprot,
      s00_axi_arvalid   => s00_axi_arvalid,
      s00_axi_arready   => s00_axi_arready,
      s00_axi_rdata     => s00_axi_rdata,
      s00_axi_rresp     => s00_axi_rresp,
      s00_axi_rvalid    => s00_axi_rvalid,
      s00_axi_rready    => s00_axi_rready
      );


  s00_axi_aclk <= not s00_axi_aclk after s00_axi_aclk_period / 2;


  waveform_proc : process

    ---------------------------------------------------------------------------------
    -- Write a value in an AXI register
    ---------------------------------------------------------------------------------
    procedure write_reg(
      reg_offset : integer;
      wr_data : std_logic_vector((C_S00_AXI_DATA_WIDTH-1) downto 0)
    ) is
    begin

      s00_axi_awaddr <= std_logic_vector(to_unsigned(reg_offset, C_S00_AXI_ADDR_WIDTH));
      s00_axi_awvalid <= '1';
      s00_axi_wdata <= wr_data;
      s00_axi_wvalid <= '1';
      s00_axi_wstrb <= (others => '1');
      if s00_axi_awready = '0' then
        wait until s00_axi_awready = '1';
      end if;
      if s00_axi_wready = '0' then
        wait until s00_axi_wready = '1';
      end if;
      wait for s00_axi_aclk_period;
      s00_axi_wvalid <= '0';
      s00_axi_awvalid <= '0';

      if s00_axi_bvalid = '0' then
        wait until s00_axi_bvalid = '1';
      end if;
      wait for s00_axi_aclk_period;
      s00_axi_bready <= '1';
      wait for s00_axi_aclk_period;
      s00_axi_bready <= '0';

    end procedure write_reg;

    ---------------------------------------------------------------------------------
    -- Read a value from an AXI register
    ---------------------------------------------------------------------------------
    procedure read_reg(
      reg_offset : in integer;
      signal rd_data    : out std_logic_vector((C_S00_AXI_DATA_WIDTH-1) downto 0)
      ) is
    begin

      s00_axi_araddr  <= std_logic_vector(to_unsigned(reg_offset, C_S00_AXI_ADDR_WIDTH));
      s00_axi_arvalid <= '1';
      if s00_axi_arready = '0' then
        wait until s00_axi_arready = '1';
      end if;
      if s00_axi_rvalid = '0' then
        wait until s00_axi_rvalid = '1';
      end if;
      wait for s00_axi_aclk_period;
      s00_axi_arvalid <= '0';
      s00_axi_rready <= '1';
      rd_data <= s00_axi_rdata;
      wait for s00_axi_aclk_period;
      s00_axi_rready <= '0';

    end procedure read_reg;

  begin

    -- hold reset
    s00_axi_aresetn <= '0';
    wait for s00_axi_aclk_period * 10;
    s00_axi_aresetn <= '1';

    -- Write in register 0
    report "Write Data 0 register" severity note;
    write_reg(DATA_0_REG_OFFSET, X"CAFEFACE");
    wait for s00_axi_aclk_period * 4;

    -- Read and check register 0
    report "Read Data 0 register" severity note;
    read_reg(DATA_0_REG_OFFSET, rd_data);
    assert rd_data = X"CAFEFACE" report "# Error reading Data 0" severity failure;
    wait for s00_axi_aclk_period * 20;


    -- Write in register 1
    report "Write Data 1 register" severity note;
    write_reg(DATA_1_REG_OFFSET, X"DEADBEEF");
    wait for s00_axi_aclk_period * 4;

    -- Read and check register 1
    report "Read Data 1 register" severity note;
    read_reg(DATA_1_REG_OFFSET, rd_data);
    assert rd_data = X"DEADBEEF" report "# Error reading Data 1" severity failure;
    wait for s00_axi_aclk_period * 20;

    assert false report "-- Simulation completed successfully --" severity failure;

    wait;

  end process waveform_proc;

end behavioral;
