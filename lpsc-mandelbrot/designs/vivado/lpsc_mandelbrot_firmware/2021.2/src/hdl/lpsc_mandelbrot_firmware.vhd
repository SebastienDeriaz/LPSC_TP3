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
-- Author: Joachim Schmidt <joachim.schmidt@hesge.ch
--
-- Module Name: lpsc_mandelbrot_firmware - arch
-- Target Device: digilentinc.com:nexys_video:part0:1.1 xc7a200tsbg484-1
-- Tool version: 2021.2
-- Description: lpsc_mandelbrot_firmware
--
-- Last update: 2022-04-12
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library lpsc_lib;
use lpsc_lib.lpsc_hdmi_interface_pkg.all;

library work;
use work.mandelbrot_colors.all;

entity lpsc_mandelbrot_firmware is

    generic (
        C_CHANNEL_NUMBER : integer := 4;
        C_HDMI_LATENCY   : integer := 0;
        C_GPIO_SIZE      : integer := 8;
        C_AXI4_DATA_SIZE : integer := 32;
        C_AXI4_ADDR_SIZE : integer := 12);

    port (
        -- Clock and Reset Active Low
        ClkSys100MhzxCI : in std_logic;
        ResetxRNI       : in std_logic;
        -- Leds
        LedxDO          : out std_logic_vector((C_GPIO_SIZE - 1) downto 0);
        -- Buttons
        -- BtnCxSI         : in    std_logic;
        -- HDMI
        HdmiTxRsclxSO   : out std_logic;
        HdmiTxRsdaxSIO  : inout std_logic;
        HdmiTxHpdxSI    : in std_logic;
        HdmiTxCecxSIO   : inout std_logic;
        HdmiTxClkPxSO   : out std_logic;
        HdmiTxClkNxSO   : out std_logic;
        HdmiTxPxDO      : out std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0);
        HdmiTxNxDO      : out std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0));

end lpsc_mandelbrot_firmware;

architecture arch of lpsc_mandelbrot_firmware is

    -- Constants

    ---------------------------------------------------------------------------
    -- Resolution configuration
    ---------------------------------------------------------------------------
    -- Possible resolutions
    --
    -- 1024x768
    -- 1024x600
    -- 800x600
    -- 640x480

    -- constant C_VGA_CONFIG : t_VgaConfig := C_1024x768_VGACONFIG;
    constant C_VGA_CONFIG                       : t_VgaConfig           := C_1024x600_VGACONFIG;
    --constant C_VGA_CONFIG                       : t_VgaConfig           := C_800x600_VGACONFIG;
    -- constant C_VGA_CONFIG : t_VgaConfig := C_640x480_VGACONFIG;

    -- constant C_RESOLUTION : string := "1024x768";
    constant C_RESOLUTION                       : string                := "1024x600";
    --constant C_RESOLUTION                       : string                := "800x600";
    -- constant C_RESOLUTION : string := "640x480";

    constant C_DATA_SIZE                        : integer               := 16;
    constant C_PIXEL_SIZE                       : integer               := 8;
    constant C_BRAM_VIDEO_MEMORY_ADDR_SIZE      : integer               := 20;
    constant C_BRAM_VIDEO_MEMORY_HIGH_ADDR_SIZE : integer               := 10;
    constant C_BRAM_VIDEO_MEMORY_LOW_ADDR_SIZE  : integer               := 10;
    constant C_BRAM_VIDEO_MEMORY_DATA_SIZE      : integer               := 7;
    constant C_CDC_TYPE                         : integer range 0 to 2  := 1;
    constant C_RESET_STATE                      : integer range 0 to 1  := 0;
    constant C_SINGLE_BIT                       : integer range 0 to 1  := 1;
    constant C_FLOP_INPUT                       : integer range 0 to 1  := 1;
    constant C_VECTOR_WIDTH                     : integer range 0 to 32 := 2;
    constant C_MTBF_STAGES                      : integer range 0 to 6  := 5;
    constant C_ALMOST_FULL_LEVEL                : integer               := 948;
    constant C_ALMOST_EMPTY_LEVEL               : integer               := 76;
    constant C_FIFO_DATA_SIZE                   : integer               := 32;
    constant C_FIFO_PARITY_SIZE                 : integer               := 4;
    constant C_OUTPUT_BUFFER                    : boolean               := false;

    -- Components

    component hdmi is
        generic (
            C_CHANNEL_NUMBER : integer;
            C_DATA_SIZE      : integer;
            C_PIXEL_SIZE     : integer;
            C_HDMI_LATENCY   : integer;
            C_VGA_CONFIG     : t_VgaConfig;
            C_RESOLUTION     : string);
        port (
            ClkSys100MhzxCI : in std_logic;
            RstxRI          : in std_logic;
            PllLockedxSO    : out std_logic;
            ClkVgaxCO       : out std_logic;
            HCountxDO       : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDO       : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VidOnxSO        : out std_logic;
            DataxDI         : in std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
            HdmiTxRsclxSO   : out std_logic;
            HdmiTxRsdaxSIO  : inout std_logic;
            HdmiTxHpdxSI    : in std_logic;
            HdmiTxCecxSIO   : inout std_logic;
            HdmiTxClkPxSO   : out std_logic;
            HdmiTxClkNxSO   : out std_logic;
            HdmiTxPxDO      : out std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0);
            HdmiTxNxDO      : out std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0));
    end component hdmi;

    component clk_mandelbrot
        port (
            ClkMandelxCO    : out std_logic;
            reset           : in std_logic;
            PllLockedxSO    : out std_logic;
            ClkSys100MhzxCI : in std_logic);
    end component;

    component blk_mem_gen_0 -- bram_video_memory_wauto_dauto_rdclk1_wrclk1
        port (
            clka  : in std_logic;
            wea   : in std_logic_vector(0 downto 0);
            addra : in std_logic_vector(19 downto 0);
            dina  : in std_logic_vector(6 downto 0);
            douta : out std_logic_vector(6 downto 0);
            clkb  : in std_logic;
            web   : in std_logic_vector(0 downto 0);
            addrb : in std_logic_vector(19 downto 0);
            dinb  : in std_logic_vector(6 downto 0);
            doutb : out std_logic_vector(6 downto 0));
    end component;

    -- Signals

    -- Clocks
    signal ClkVgaxC                   : std_logic := '0';
    signal ClkMandelxC                : std_logic;
    signal UBlazeUserClkxC            : std_logic                    := '0';
    -- Reset
    signal ResetxR                    : std_logic                    := '0';
    -- Pll Locked
    signal PllLockedxS                : std_logic                    := '0';
    signal PllLockedxD                : std_logic_vector(0 downto 0) := (others => '0');
    signal PllNotLockedxS             : std_logic                    := '0';
    signal HdmiPllLockedxS            : std_logic                    := '0';
    signal HdmiPllNotLockedxS         : std_logic                    := '0';
    signal UBlazePllLockedxS          : std_logic                    := '0';
    signal UBlazePllNotLockedxS       : std_logic                    := '0';
    -- VGA
    signal HCountxD                   : std_logic_vector((C_DATA_SIZE - 1) downto 0);
    signal VCountxD                   : std_logic_vector((C_DATA_SIZE - 1) downto 0);
    signal VidOnxS                    : std_logic;
    -- Others
    signal DataImGen2HDMIxD           : std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
    signal DataImGen2BramMVxD         : std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
    signal DataBramMV2HdmixD          : std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
    signal HdmiSourcexD               : t_HdmiSource                                                   := C_NO_HDMI_SOURCE;
    signal BramVideoMemoryWriteAddrxD : std_logic_vector((C_BRAM_VIDEO_MEMORY_ADDR_SIZE - 1) downto 0) := (others => '0');
    signal BramVideoMemoryReadAddrxD  : std_logic_vector((C_BRAM_VIDEO_MEMORY_ADDR_SIZE - 1) downto 0);
    signal BramVideoMemoryWriteDataxD : std_logic_vector((C_BRAM_VIDEO_MEMORY_DATA_SIZE - 1) downto 0);
    signal BramVideoMemoryReadDataxD  : std_logic_vector((C_BRAM_VIDEO_MEMORY_DATA_SIZE - 1) downto 0);
    -- AXI4 Lite To Register Bank Signals
    signal WrDataxD                   : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal WrAddrxD                   : std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0) := (others => '0');
    signal WrValidxS                  : std_logic                                         := '0';
    signal RdDataxD                   : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal RdAddrxD                   : std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0) := (others => '0');
    signal RdValidxS                  : std_logic                                         := '0';
    signal WrValidDelayedxS           : std_logic                                         := '0';
    signal RdValidFlagColor1xS        : std_logic                                         := '0';
    signal RdEmptyFlagColor1xS        : std_logic                                         := '0';
    signal RdDataFlagColor1xDP        : std_logic_vector((C_FIFO_DATA_SIZE - 1) downto 0) := x"003a8923";
    signal RdDataFlagColor1xDN        : std_logic_vector((C_FIFO_DATA_SIZE - 1) downto 0) := x"003a8923";

    -- Attributes
    -- attribute mark_debug                              : string;
    -- attribute mark_debug of DebugFlagColor1RegPortxDP : signal is "true";
    -- --
    -- attribute keep                                    : string;
    -- attribute keep of DebugFlagColor1RegPortxDP       : signal is "true";
    component mandelbrot_loop_wrapper is
        generic (
            SIZE       : integer := 16;   -- Taille en bits de nombre au format virgule fixe
            X_SIZE     : integer := 1024; -- Taille en X (Nombre de pixel) de la fractale à afficher
            Y_SIZE     : integer := 600;  -- Taille en Y (Nombre de pixel) de la fractale à afficher
            SCREEN_RES : integer := 10;
            RAM_SIZE   : integer := 18);
        port (
            clk                 : in std_logic;
            reset               : in std_logic;
            -- In
            run                 : in std_logic;
            -- Out
            memory_write_enable : out std_logic;
            memory_address      : out std_logic_vector(2 * SCREEN_RES - 1 downto 0);
            memory_data         : out std_logic_vector(RAM_SIZE - 1 downto 0)
        );
    end component mandelbrot_loop_wrapper;

    signal BramVideoMemoryWriteEnable : std_logic;

    signal test_signal                : std_logic_vector(6 downto 0);

begin

    -- Asynchronous statements

    DebugxB : block is

        -- Debug signals
        -- signal DebugVectExamplexD : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');

        -- Attributes
        -- attribute mark_debug                       : string;
        -- attribute mark_debug of DebugVectExamplexD : signal is "true";
        -- --
        -- attribute keep                             : string;
        -- attribute keep of DebugVectExamplexD       : signal is "true";

    begin -- block DebugxB

    end block DebugxB;

    IOPinoutxB : block is
    begin -- block IOPinoutxB

        ResetxAS      : ResetxR                                 <= not ResetxRNI;
        HdmiTxRsclxAS : HdmiTxRsclxSO                           <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxRsclxS;
        HdmiTxRsdaxAS : HdmiTxRsdaxSIO                          <= HdmiSourcexD.HdmiSourceInOutxS.HdmiTxRsdaxS;
        HdmiTxHpdxAS  : HdmiSourcexD.HdmiSourceInxS.HdmiTxHpdxS <= HdmiTxHpdxSI;
        HdmiTxCecxAS  : HdmiTxCecxSIO                           <= HdmiSourcexD.HdmiSourceInOutxS.HdmiTxCecxS;
        HdmiTxClkPxAS : HdmiTxClkPxSO                           <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkPxS;
        HdmiTxClkNxAS : HdmiTxClkNxSO                           <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkNxS;
        HdmiTxPxAS    : HdmiTxPxDO                              <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxPxD;
        HdmiTxNxAS    : HdmiTxNxDO                              <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxNxD;

    end block IOPinoutxB;

    -- VGA HDMI Clock Domain
    ---------------------------------------------------------------------------

    VgaHdmiCDxB : block is
    begin -- block VgaHdmiCDxB

        DataBramMV2HdmixD <= 
            R(to_integer(unsigned(BramVideoMemoryReadDataxD))) &
            G(to_integer(unsigned(BramVideoMemoryReadDataxD))) &
            B(to_integer(unsigned(BramVideoMemoryReadDataxD)));

        BramVMRdAddrxAS : BramVideoMemoryReadAddrxD <= VCountxD((C_BRAM_VIDEO_MEMORY_HIGH_ADDR_SIZE - 1) downto 0) &
        HCountxD((C_BRAM_VIDEO_MEMORY_LOW_ADDR_SIZE - 1) downto 0);

        HdmiPllNotLockedxAS : HdmiPllNotLockedxS <= not HdmiPllLockedxS;

        LpscHdmixI          : entity work.lpsc_hdmi
            generic map(
                C_CHANNEL_NUMBER => C_CHANNEL_NUMBER,
                C_DATA_SIZE      => C_DATA_SIZE,
                C_PIXEL_SIZE     => C_PIXEL_SIZE,
                C_HDMI_LATENCY   => C_HDMI_LATENCY,
                C_VGA_CONFIG     => C_VGA_CONFIG,
                C_RESOLUTION     => C_RESOLUTION)
            port map(
                ClkSys100MhzxCI => ClkSys100MhzxCI,
                RstxRI          => ResetxR,
                PllLockedxSO    => HdmiPllLockedxS,
                ClkVgaxCO       => ClkVgaxC,
                HCountxDO       => HCountxD,
                VCountxDO       => VCountxD,
                VidOnxSO        => open,              --VidOnxS,           --open,
                DataxDI         => DataBramMV2HdmixD, --DataImGen2HDMIxD
                HdmiTXRsclxSO   => HdmiSourcexD.HdmiSourceOutxD.HdmiTxRsclxS,
                HdmiTXRsdaxSIO  => HdmiSourcexD.HdmiSourceInOutxS.HdmiTxRsdaxS,
                HdmiTXHpdxSI    => HdmiSourcexD.HdmiSourceInxS.HdmiTxHpdxS,
                HdmiTXCecxSIO   => HdmiSourcexD.HdmiSourceInOutxS.HdmiTxCecxS,
                HdmiTXClkPxSO   => HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkPxS,
                HdmiTXClkNxSO   => HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkNxS,
                HdmiTXPxDO      => HdmiSourcexD.HdmiSourceOutxD.HdmiTxPxD,
                HdmiTXNxDO      => HdmiSourcexD.HdmiSourceOutxD.HdmiTxNxD);

    end block VgaHdmiCDxB;

    -- VGA HDMI To FPGA User Clock Domain Crossing
    ---------------------------------------------------------------------------

    VgaHdmiToFpgaUserCDCxB : block is
    begin                             -- block VgaHdmiToFpgaUserCDCxB

        BramVideoMemoryxI : blk_mem_gen_0 -- bram_video_memory_wauto_dauto_rdclk1_wrclk1
        port map(
            -- Port A (Write)
            clka   => ClkMandelxC,
            wea(0) => BramVideoMemoryWriteEnable,
            addra  => BramVideoMemoryWriteAddrxD,
            dina   => BramVideoMemoryWriteDataxD,
            douta  => open,
            -- Port B (Read)
            clkb   => ClkVgaxC,
            web => (others => '0'),
            addrb  => BramVideoMemoryReadAddrxD,
            dinb => (others => '0'),
            doutb  => BramVideoMemoryReadDataxD);

    end block VgaHdmiToFpgaUserCDCxB;
    -- FPGA User Clock Domain
    ---------------------------------------------------------------------------

    FpgaUserCDxB              : block is

        signal ClkSys100MhzBufgxC : std_logic                                    := '0';
        signal HCountIntxD        : std_logic_vector((C_DATA_SIZE - 1) downto 0) := std_logic_vector(C_VGA_CONFIG.HActivexD - 1);
        signal VCountIntxD        : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');

    begin -- block FpgaUserCDxB

        PllNotLockedxAS         : PllNotLockedxS <= not PllLockedxS;
        PllLockedxAS            : PllLockedxD(0) <= PllLockedxS;

        BUFGClkSysToClkMandelxI : BUFG
        port map(
            O => ClkSys100MhzBufgxC,
            I => ClkSys100MhzxCI);

        ClkMandelbrotxI : clk_mandelbrot
        port map(
            ClkMandelxCO    => ClkMandelxC,
            reset           => ResetxR,
            PllLockedxSO    => PllLockedxS,
            ClkSys100MhzxCI => ClkSys100MhzBufgxC);

        mandelbrot_loop_wrapper_inst : mandelbrot_loop_wrapper
        generic map(
            SIZE       => 18,
            X_SIZE     => 800,
            Y_SIZE     => 600,
            SCREEN_RES => 10,
            RAM_SIZE   => C_BRAM_VIDEO_MEMORY_DATA_SIZE
        )
        port map(
            clk                 => ClkMandelxC,
            reset               => PllNotLockedxS,
            -- In
            run                 => '1',
            -- Out
            memory_write_enable => BramVideoMemoryWriteEnable,
            memory_address      => BramVideoMemoryWriteAddrxD,
            memory_data         => BramVideoMemoryWriteDataxD
        );

    end block FpgaUserCDxB;

end arch;