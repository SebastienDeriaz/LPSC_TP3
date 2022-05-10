----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.05.2022 13:56:19
-- Design Name: mandelbrot loop
-- Module Name: mandelbrot_loop - Behavioral
-- Project Name: LPSC - TP3 - Mandelbrot
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Loops over mandelbrot iteration and outputs the number of iterations for each
-- point to reach the stopping radius or the max number of iterations
--
--
--
-- Dependencies: 
-- mandelbrot_iteration.vhd
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

entity mandelbrot_loop is
    generic (
        max_iter : integer                    := 100;
        m        : integer                    := 3;
        n        : integer                    := 15;
        R        : signed(m + n - 1 downto 0) := to_signed(2 * 2 ** n, m + n)
    );
    port (
        clk              : in std_logic;
        reset            : in std_logic;
        -- In
        Cr               : in signed(m + n - 1 downto 0);
        Ci               : in signed(m + n - 1 downto 0);
        start            : in std_logic;
        -- Out
        done             : out std_logic;
        iterations       : out integer range 0 to max_iter;
        -- Debug
        debug            : out std_logic;
        debug_iterations : out integer range 0 to max_iter;
        debug_Zr         : out signed(m + n - 1 downto 0);
        debug_Zi         : out signed(m + n - 1 downto 0);
        debug_Zr_next    : out signed(m + n - 1 downto 0);
        debug_Zi_next    : out signed(m + n - 1 downto 0)
    );
end mandelbrot_loop;

architecture Behavioral of mandelbrot_loop is
    component mandelbrot_iteration is
        generic (
            max_iter : integer := 100; -- Max number of iterations
            m        : integer := 3;   -- Number of integer bits (with sign bit)
            n        : integer := 15   -- Number of decimals bits
        );
        port (
            clk            : in std_logic;
            reset          : in std_logic;
            -- In
            done_in        : in std_logic;
            Cr             : in signed (m + n - 1 downto 0);  -- Real part of the starting point
            Ci             : in signed (m + n - 1 downto 0);  -- Imaginary part of the starting point
            Zr_previous    : in signed (m + n - 1 downto 0);  -- Real part of the previous point
            Zi_previous    : in signed (m + n - 1 downto 0);  -- Imaginary part of the previous point
            R              : in signed (m + n - 1 downto 0);  -- Stopping radius
            iterations_in  : in integer range 0 to max_iter;  -- Number of iterations previously done
            -- Out
            Zr_next        : out signed(m + n - 1 downto 0);  -- Output imaginary part (after iteration)
            Zi_next        : out signed(m + n - 1 downto 0);  -- Output imaginary part (after iteration)
            iterations_out : out integer range 0 to max_iter; -- New number of iterations (+1 or +0 of iterations_in)
            done_out       : out std_logic                    -- Done signal
        );
    end component;

    signal running                 : std_logic;
    -- Iterator signals
    --signal Zr                      : signed(m + n - 1 downto 0);
    --signal Zi                      : signed(m + n - 1 downto 0);

    signal iterator_done_in        : std_logic;
    signal iterator_Cr             : signed (m + n - 1 downto 0);
    signal iterator_Ci             : signed (m + n - 1 downto 0);
    signal iterator_Zr_previous    : signed (m + n - 1 downto 0);
    signal iterator_Zi_previous    : signed (m + n - 1 downto 0);
    signal iterator_iterations_in  : integer range 0 to max_iter;
    signal iterator_Zr_next        : signed(m + n - 1 downto 0);
    signal iterator_Zi_next        : signed(m + n - 1 downto 0);
    signal iterator_iterations_out : integer range 0 to max_iter;
    signal iterator_done_out       : std_logic;

begin
    iterator : mandelbrot_iteration
    generic map(
        max_iter => max_iter,
        m        => m,
        n        => n
    )
    port map(
        clk            => clk,
        reset          => reset,
        done_in        => '0',
        Cr             => iterator_Cr,
        Ci             => iterator_Ci,
        Zr_previous    => iterator_Zr_previous,
        Zi_previous    => iterator_Zi_previous,
        R              => R,
        iterations_in  => iterator_iterations_in,
        Zr_next        => iterator_Zr_next,
        Zi_next        => iterator_Zi_next,
        iterations_out => iterator_iterations_out,
        done_out       => iterator_done_out
    );
    debug_iterations <= iterator_iterations_out;

    debug            <= iterator_done_out;
    debug_Zr         <= iterator_Zr_previous;
    debug_Zi         <= iterator_Zi_previous;
    debug_Zi_next    <= iterator_Zi_next;
    debug_Zr_next    <= iterator_Zr_next;

    process (clk, reset)
        variable running_v : std_logic;
    begin
        running_v := running;
        if reset = '1' then
            running_v := '0';
            done                 <= '0';
            iterator_Cr          <= (others => '0');
            iterator_Ci          <= (others => '0');
            iterations           <= 0;
            iterator_Zr_previous <= (others => '0');
            iterator_Zi_previous <= (others => '0');
        elsif rising_edge(clk) then
            if running_v = '0' then
                if start = '1' then
                    done <= '0';
                    running_v := '1';
                    iterator_Cr            <= Cr;
                    iterator_Ci            <= Ci;
                    iterator_Zi_previous   <= (others => '0');
                    iterator_Zr_previous   <= (others => '0');
                    iterator_iterations_in <= 0;
                end if;
            else
                iterator_iterations_in <= iterator_iterations_out;
                iterator_Zi_previous   <= iterator_Zi_next;
                iterator_Zr_previous   <= iterator_Zr_next;

                if iterator_done_out = '1' then
                    running_v := '0';
                    done       <= '1';
                    iterations <= iterator_iterations_out;
                end if;
            end if;
        end if;
        running <= running_v;
    end process;
end Behavioral;