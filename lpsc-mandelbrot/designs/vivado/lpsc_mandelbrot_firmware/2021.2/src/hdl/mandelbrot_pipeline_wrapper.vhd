----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.05.2022 13:56:19
-- Design Name: mandelbrot pipeline wrapper
-- Module Name: mandelbrot_pipeline_wrapper - Behavioral
-- Project Name: LPSC - TP3 - Mandelbrot
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Manages the mandelbrot pipeline entity. This is mainly
-- to manage access to the memory
--
--
-- Dependencies: 
-- mandelbrot_pipeline_wrapper.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mandelbrot_pipeline_wrapper is
    generic (
        SIZE       : integer := 18;   -- Taille en bits de nombre au format virgule fixe
        X_SIZE     : integer := 1024; -- Taille en X (Nombre de pixel) de la fractale à afficher
        Y_SIZE     : integer := 600;  -- Taille en Y (Nombre de pixel) de la fractale à afficher
        SCREEN_RES : integer := 10;   -- Nombre de bit pour les vecteurs X et Y de la position du pixel
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
end mandelbrot_pipeline_wrapper;

architecture Behavioral of mandelbrot_pipeline_wrapper is
    constant max_iter : integer := 100;
    constant n        : integer := 15;
    constant m        : integer := 3;

    component mandelbrot_pipeline is
        generic (
            max_iter : integer                    := 100;
            m        : integer                    := 3;
            n        : integer                    := 15;
            R        : signed(m + n - 1 downto 0) := to_signed(2 * 2 ** n, m + n)
        );
        port (
            clk        : in std_logic;
            reset      : in std_logic;
            -- In
            Cr         : in signed(m + n - 1 downto 0);
            Ci         : in signed(m + n - 1 downto 0);
            run        : in std_logic;
            -- Out
            valid      : out std_logic;
            iterations : out integer range 0 to max_iter
        );
    end component mandelbrot_pipeline;

    component c_gen is
        generic (
            C_FXP_SIZE   : integer := 16;
            C_X_SIZE     : integer := 1024;
            C_Y_SIZE     : integer := 600;
            C_SCREEN_RES : integer := 11);

        port (
            ClkxC         : in std_logic;
            RstxRA        : in std_logic;
            ZoomInxSI     : in std_logic;
            ZoomOutxSI    : in std_logic;
            CRealxDO      : out std_logic_vector((C_FXP_SIZE - 1) downto 0);
            CImaginaryxDO : out std_logic_vector((C_FXP_SIZE - 1) downto 0);
            XScreenxDO    : out std_logic_vector((C_SCREEN_RES - 1) downto 0);
            YScreenxDO    : out std_logic_vector((C_SCREEN_RES - 1) downto 0));

    end component c_gen;

    signal Cr_start        : std_logic_vector(SIZE - 1 downto 0);
    signal Ci_start        : std_logic_vector(SIZE - 1 downto 0);
    signal Cr_start_signed : signed(SIZE - 1 downto 0);
    signal Ci_start_signed : signed(SIZE - 1 downto 0);

    type screen_array is array(0 to max_iter - 1) of std_logic_vector((SCREEN_RES - 1) downto 0);
    signal X_screen_array : screen_array;
    signal Y_screen_array : screen_array;
    signal valid          : std_logic;

    signal X_screen       : std_logic_vector(SCREEN_RES - 1 downto 0);
    signal Y_screen       : std_logic_vector(SCREEN_RES - 1 downto 0);

    signal iterations_out : integer range 0 to 100;
begin

    mandelbroot_pipeline_inst : mandelbrot_pipeline
    generic map(
        max_iter => 100,
        m        => 3,
        n        => 15,
        R        => to_signed(2 * 2 ** n, m + n)
    )
    port map(
        clk        => clk,
        reset      => reset,
        -- In
        Cr         => Cr_start_signed,
        Ci         => Ci_start_signed,
        run        => run,
        -- Out
        valid      => valid,
        iterations => iterations_out
    );

    Cr_start_signed <= signed(Cr_start);
    Ci_start_signed <= signed(Ci_start);

    c_gen_inst : c_gen
    generic map(
        C_FXP_SIZE   => SIZE,
        C_X_SIZE     => X_SIZE,
        C_Y_SIZE     => Y_SIZE,
        C_SCREEN_RES => SCREEN_RES
    )
    port map(
        ClkxC         => clk,
        RstxRA        => reset,
        ZoomInxSI     => '0',
        ZoomOutxSI    => '0',
        CRealxDO      => Cr_start,
        CImaginaryxDO => Ci_start,
        XScreenxDO    => X_screen,
        YScreenxDO    => Y_screen);

    -- pipeline inputs
    X_screen_array(0) <= X_screen when run = '1' else
    (others => '0');
    Y_screen_array(0) <= Y_screen when run = '1' else
    (others => '0');

    memory_address      <= Y_screen_array(max_iter - 1) & X_screen_array(max_iter - 1);
    memory_data         <= std_logic_vector(to_unsigned(iterations_out, RAM_SIZE));
    memory_write_enable <= valid;

    process (clk, reset) is
    begin
        if reset = '1' then
            -- Nothing to reset
        elsif rising_edge(clk) then
            for I in 1 to max_iter - 1 loop
                X_screen_array(I) <= X_screen_array(I - 1);
                Y_screen_array(I) <= Y_screen_array(I - 1);
            end loop;
        end if;
    end process;

end architecture Behavioral;