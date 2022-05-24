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
        RAM_SIZE   : integer := 7);
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
    constant max_iter                     : integer                             := 100;
    constant n                            : integer                             := 15;
    constant m                            : integer                             := 3;

    -- Initial values
    constant top_left_real_initial_value  : std_logic_vector(SIZE - 1 downto 0) := "101110011001100110";
    constant top_left_imag_initial_value  : std_logic_vector(SIZE - 1 downto 0) := "000111100000000000";
    constant real_increment_initial_value : std_logic_vector(SIZE - 1 downto 0) := "000000000001100111";
    constant imag_increment_initial_value : std_logic_vector(SIZE - 1 downto 0) := "000000000001100111";

    -- Increment to the initial values on each zoom iteration
    constant top_left_real_zoom           : std_logic_vector(SIZE - 1 downto 0) := "000000000111100101";
    constant top_left_imag_zoom           : std_logic_vector(SIZE - 1 downto 0) := "111111111001000110";
    constant real_increment_zoom          : std_logic_vector(SIZE - 1 downto 0) := "111111111111111111";
    constant imag_increment_zoom          : std_logic_vector(SIZE - 1 downto 0) := "111111111111111111";

    -- Current values
    signal real_increment                 : std_logic_vector(SIZE - 1 downto 0);
    signal imag_increment                 : std_logic_vector(SIZE - 1 downto 0);
    signal top_left_real                  : std_logic_vector(SIZE - 1 downto 0);
    signal top_left_imag                  : std_logic_vector(SIZE - 1 downto 0);

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

    component ComplexValueGenerator is
        generic (
            SIZE       : integer;
            X_SIZE     : integer;
            Y_SIZE     : integer;
            SCREEN_RES : integer);
        port (
            clk           : in std_logic;
            reset         : in std_logic;
            next_value    : in std_logic;
            c_top_left_RE : in std_logic_vector((SIZE - 1) downto 0);
            c_top_left_IM : in std_logic_vector((SIZE - 1) downto 0);
            c_inc_RE      : in std_logic_vector((SIZE - 1) downto 0);
            c_inc_IM      : in std_logic_vector((SIZE - 1) downto 0);
            c_real        : out std_logic_vector((SIZE - 1) downto 0);
            c_imaginary   : out std_logic_vector((SIZE - 1) downto 0);
            X_screen      : out std_logic_vector((SCREEN_RES - 1) downto 0);
            Y_screen      : out std_logic_vector((SCREEN_RES - 1) downto 0));
    end component ComplexValueGenerator;

    signal Cr_start        : std_logic_vector(SIZE - 1 downto 0);
    signal Ci_start        : std_logic_vector(SIZE - 1 downto 0);
    signal Cr_start_signed : signed(SIZE - 1 downto 0);
    signal Ci_start_signed : signed(SIZE - 1 downto 0);

    type screen_array is array(0 to max_iter - 1) of std_logic_vector((SCREEN_RES - 1) downto 0);
    signal X_screen_array     : screen_array;
    signal Y_screen_array     : screen_array;
    signal valid              : std_logic;

    signal X_screen           : std_logic_vector(SCREEN_RES - 1 downto 0);
    signal Y_screen           : std_logic_vector(SCREEN_RES - 1 downto 0);
    -- Zoom clock counter (10x per second)
    constant zoom_clock_max   : integer := 5000000;
    signal zoom_clock_counter : integer range 0 to zoom_clock_max;
    -- Zoom iterations
    -- 0 - 100 : nothing
    -- 101 -- 200 : zoom in
    -- 201 -- 300 : nothing
    constant zoom_iterations  : integer := 300;
    signal zoom_counter       : integer range 0 to zoom_iterations;

    signal iterations_out     : integer range 0 to 100;
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
    ComplexValueGeneratorxI : entity work.ComplexValueGenerator
        generic map(
            SIZE       => SIZE,
            X_SIZE     => X_SIZE,
            Y_SIZE     => Y_SIZE,
            SCREEN_RES => SCREEN_RES)
        port map(
            clk           => clk,
            reset         => reset,
            next_value    => '1',
            c_inc_RE      => real_increment,
            c_inc_IM      => imag_increment,
            c_top_left_RE => top_left_real,
            c_top_left_IM => top_left_imag,
            c_real        => Cr_start,
            c_imaginary   => Ci_start,
            X_screen      => X_screen,
            Y_screen      => Y_screen);

    -- pipeline inputs
    X_screen_array(0) <= X_screen when run = '1' else
    (others => '0');
    Y_screen_array(0) <= Y_screen when run = '1' else
    (others => '0');

    -- Memory interface
    memory_address      <= Y_screen_array(max_iter - 1) & X_screen_array(max_iter - 1);
    memory_data         <= std_logic_vector(to_unsigned(iterations_out, RAM_SIZE));
    memory_write_enable <= valid;

    process (clk, reset) is
    begin
        if reset = '1' then
            real_increment     <= real_increment_initial_value;
            imag_increment     <= imag_increment_initial_value;
            top_left_real      <= top_left_real_initial_value;
            top_left_imag      <= top_left_imag_initial_value;
            zoom_counter       <= 0;
            zoom_clock_counter <= 0;

        elsif rising_edge(clk) then
            -- Shift the X_screen and Y_screen values (to account for the delay in the pipeline)
            for I in 1 to max_iter - 1 loop
                X_screen_array(I) <= X_screen_array(I - 1);
                Y_screen_array(I) <= Y_screen_array(I - 1);
            end loop;
            -- If the zoom clock ticks
            if zoom_clock_counter = zoom_clock_max then
                zoom_clock_counter <= 0;
                -- Evaluate the next zoom iteration
                if zoom_counter = zoom_iterations then
                    -- Reset the zoom
                    zoom_counter   <= 0;
                    real_increment <= real_increment_initial_value;
                    imag_increment <= imag_increment_initial_value;
                    top_left_real  <= top_left_real_initial_value;
                    top_left_imag  <= top_left_imag_initial_value;
                else
                    -- Do an iteration
                    zoom_counter <= zoom_counter + 1;
                    -- test
                    if zoom_counter >= zoom_iterations / 3 and
                        zoom_counter   <= 2 * zoom_iterations / 3 then
                            -- If we need to zoom in
                            -- Update the current display constants
                            real_increment <= std_logic_vector(signed(real_increment) + signed(real_increment_zoom));
                        imag_increment <= std_logic_vector(signed(imag_increment) + signed(imag_increment_zoom));
                        top_left_real  <= std_logic_vector(signed(top_left_real) + signed(top_left_real_zoom));
                        top_left_imag  <= std_logic_vector(signed(top_left_imag) + signed(top_left_imag_zoom));
                    end if;
                end if;
            else
                zoom_clock_counter <= zoom_clock_counter + 1;
            end if;
        end if;
    end process;

end architecture Behavioral;