----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.05.2022 13:56:19
-- Design Name: mandelbrot loop wrapper
-- Module Name: mandelbrot_loop_wrapper - Behavioral
-- Project Name: LPSC - TP3 - Mandelbrot
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Manages the mandelbrot loop entity. This is mainly
-- to manage access to the memory
--
--
-- Dependencies: 
-- mandelbrot_loop_wrapper.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--library work;
--use work.mandelbrot_colors.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mandelbrot_loop_wrapper is
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
end mandelbrot_loop_wrapper;

architecture Behavioral of mandelbrot_loop_wrapper is
    component mandelbrot_loop is
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
            start      : in std_logic;
            -- Out
            done       : out std_logic;
            iterations : out integer range 0 to max_iter
        );
    end component mandelbrot_loop;

    component ComplexValueGenerator is
        generic (
            SIZE       : integer := 18;   -- Taille en bits de nombre au format virgule fixe
            X_SIZE     : integer := 1024; -- Taille en X (Nombre de pixel) de la fractale à afficher
            Y_SIZE     : integer := 600;  -- Taille en Y (Nombre de pixel) de la fractale à afficher
            SCREEN_RES : integer := 10;   -- Nombre de bit pour les vecteurs X et Y de la position du pixel
            RAM_SIZE   : integer := 9
        );
        port (
            clk           : in std_logic;
            reset         : in std_logic;
            -- interface avec le module MandelbrotMiddleware
            next_value    : in std_logic;
            c_inc_RE      : in std_logic_vector((SIZE - 1) downto 0);
            c_inc_IM      : in std_logic_vector((SIZE - 1) downto 0);
            c_top_left_RE : in std_logic_vector((SIZE - 1) downto 0);
            c_top_left_IM : in std_logic_vector((SIZE - 1) downto 0);
            c_real        : out std_logic_vector((SIZE - 1) downto 0);
            c_imaginary   : out std_logic_vector((SIZE - 1) downto 0);
            X_screen      : out std_logic_vector((SCREEN_RES - 1) downto 0);
            Y_screen      : out std_logic_vector((SCREEN_RES - 1) downto 0)
        );
    end component ComplexValueGenerator;

    type StateMachine is (IDLE, RUNNING, WAIT_FOR_NEXT, LOOP_INIT, WRITE_MEMORY);
    signal State           : StateMachine;
    -- ComplexValueGenerator signals
    signal next_value      : std_logic;
    signal Cr              : std_logic_vector(SIZE - 1 downto 0);
    signal Ci              : std_logic_vector(SIZE - 1 downto 0);
    signal X_screen        : std_logic_vector((SCREEN_RES - 1) downto 0);
    signal Y_screen        : std_logic_vector((SCREEN_RES - 1) downto 0);

    signal loop_Cr         : std_logic_vector((SIZE - 1) downto 0);
    signal loop_Ci         : std_logic_vector((SIZE - 1) downto 0);
    signal loop_start      : std_logic;
    signal loop_done       : std_logic;
    signal loop_iterations : integer range 0 to 100;

    signal write_addr      : std_logic_vector(2 * SCREEN_RES - 1 downto 0);
begin

    ComplexValueGenerator_inst : ComplexValueGenerator
    generic map(
        SIZE       => SIZE,
        X_SIZE     => X_SIZE,
        Y_SIZE     => Y_SIZE,
        SCREEN_RES => SCREEN_RES
    )
    port map(
        clk           => clk,
        reset         => reset,
        -- In
        next_value    => next_value,
        c_inc_RE      => "000000000010000011", -- 0.004
        c_inc_IM      => "000000000010000011", -- 0.004
        c_top_left_RE => "101110011001100110", -- -2.2
        c_top_left_IM => "001001100110011010", -- -1.2
        -- Out
        c_real        => loop_Cr,
        c_imaginary   => loop_Ci,
        X_screen      => X_screen,
        Y_screen      => Y_screen
    );

    mandelbroot_loop_inst : mandelbrot_loop
    generic map(
        max_iter => 100,
        m        => 3,
        n        => 15,
        R        => to_signed(2 * 2 ** 15, 3 + 15)
    )
    port map(
        clk        => clk,
        reset      => reset,
        -- In
        Cr         => signed(loop_Cr),
        Ci         => signed(loop_Ci),
        start      => loop_start,
        -- Out
        done       => loop_done,
        iterations => loop_iterations
    );

    memory_address <= Y_screen((SCREEN_RES - 1) downto 0) & X_screen((SCREEN_RES - 1) downto 0);
    next_value     <= '1' when State = WAIT_FOR_NEXT else
        '0';
    loop_start <= '1' when State = LOOP_INIT else
        '0';
    memory_write_enable <= '1' when State = WRITE_MEMORY else
        '0';

    process (clk, reset) is
    begin
        if reset = '1' then
            State       <= IDLE;
            memory_data <= (others => '0');
        elsif rising_edge(clk) then
            if State = IDLE then
                if run = '1' then
                    State <= WAIT_FOR_NEXT;
                end if;
            elsif State = WAIT_FOR_NEXT then
                State <= LOOP_INIT;
            elsif State = LOOP_INIT then
                State <= RUNNING;
            elsif State = RUNNING then
                if loop_done = '1' then
                    State       <= WRITE_MEMORY;
                    memory_data <= std_logic_vector(to_unsigned(loop_iterations, RAM_SIZE)); 
                    
                end if;
            elsif State = WRITE_MEMORY then
                if run = '1' then
                    State <= WAIT_FOR_NEXT;
                else
                    State <= IDLE;
                end if;
            end if;
        end if;
    end process;

end architecture Behavioral;