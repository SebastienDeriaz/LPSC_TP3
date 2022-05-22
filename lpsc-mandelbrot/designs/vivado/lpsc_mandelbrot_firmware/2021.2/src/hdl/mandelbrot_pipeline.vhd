----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.05.2022
-- Design Name: Mandelbrot pipeline
-- Module Name: Mandelbrot pipeline - Behavioral
-- Project Name: LPSC - TP3 - Mandelbrot
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Pipeline of mandelbrot iterators
--
--
-- Dependencies: 
-- mandelbrot_pipeline.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
entity mandelbrot_pipeline is
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
end mandelbrot_pipeline;

architecture Behavioral of mandelbrot_pipeline is
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

    -- Input
    --signal iterator_done_in              : std_logic;
    --signal iterator_Cr_in          : signed (m + n - 1 downto 0);
    --signal iterator_Ci_in          : signed (m + n - 1 downto 0);

    -- Output
    signal iterator_done_out       : std_logic;
    signal iterator_iterations_out : integer range 0 to max_iter;
    -- Ignore Zr_next and Zi_next

    -- Arrays (connect instances together)
    type std_logic_array is array(0 to max_iter - 1) of std_logic;
    type signed_array is array(0 to max_iter - 2) of signed (m + n - 1 downto 0);
    type integer_array is array(0 to max_iter - 2) of integer range 0 to max_iter;

    signal done_in_array                 : std_logic_array;
    signal iterator_Cr_array             : signed_array;
    signal iterator_Ci_array             : signed_array;
    signal iterator_Zr_next_array        : signed_array;
    signal iterator_Zi_next_array        : signed_array;
    signal iterator_iterations_out_array : integer_array;
    signal iterator_done_out_array       : std_logic_array;
begin

    GEN_REG :
    for I in 0 to max_iter - 1 generate
        iterator_first_if : if I = 0 generate
            iterator_first : mandelbrot_iteration
            generic map(
                max_iter => max_iter,
                m        => m,
                n        => n
            )
            port map(
                clk            => clk,
                reset          => reset,
                done_in        => '0',
                Cr             => iterator_Cr_array(0),
                Ci             => iterator_Ci_array(0),
                Zr_previous => (others => '0'),
                Zi_previous => (others => '0'),
                R              => R,
                iterations_in  => 0,
                Zr_next        => iterator_Zr_next_array(0),
                Zi_next        => iterator_Zi_next_array(0),
                iterations_out => iterator_iterations_out_array(0),
                done_out       => iterator_done_out_array(0)
            );
        end generate;

        iterator_if : if I /= max_iter - 1 and I /= 0 generate
            iterator : mandelbrot_iteration
            generic map(
                max_iter => max_iter,
                m        => m,
                n        => n
            )
            port map(
                clk            => clk,
                reset          => reset,
                -- Inputs
                done_in        => iterator_done_out_array(I - 1),
                Cr             => iterator_Cr_array(I - 1),
                Ci             => iterator_Ci_array(I - 1),
                Zr_previous    => iterator_Zr_next_array(I - 1),
                Zi_previous    => iterator_Zi_next_array(I - 1),
                R              => R,
                iterations_in  => iterator_iterations_out_array(I - 1),
                -- Outputs
                Zr_next        => iterator_Zr_next_array(I),
                Zi_next        => iterator_Zi_next_array(I),
                iterations_out => iterator_iterations_out_array(I),
                done_out       => iterator_done_out_array(I)
            );
        end generate;

        iterator_last_if : if I = max_iter - 1 generate
            iterator_last : mandelbrot_iteration
            generic map(
                max_iter => max_iter,
                m        => m,
                n        => n
            )
            port map(
                clk            => clk,
                reset          => reset,
                -- Inputs
                done_in        => iterator_done_out_array(I - 1),
                Cr             => iterator_Cr_array(I - 1),
                Ci             => iterator_Ci_array(I - 1),
                Zr_previous    => iterator_Zr_next_array(I - 1),
                Zi_previous    => iterator_Zi_next_array(I - 1),
                R              => R,
                iterations_in  => iterator_iterations_out_array(I - 1),
                -- Outputs
                Zr_next        => open,
                Zi_next        => open,
                iterations_out => iterator_iterations_out,
                done_out       => iterator_done_out
            );
        end generate;

    end generate GEN_REG;
    iterations <= iterator_iterations_out;
    valid      <= '1' when iterator_iterations_out > 0 else
        '0';

    iterator_Cr_array(0) <= Cr when run = '1' else
    (others => '0');
    iterator_Ci_array(0) <= Ci when run = '1' else
    (others => '0');

    process (clk, reset)
    begin
        if reset = '1' then
            -- Nothing to reset
        elsif rising_edge(clk) then
            for I in 1 to max_iter - 2 loop
                iterator_Cr_array(I) <= iterator_Cr_array(I - 1);
                iterator_Ci_array(I) <= iterator_Ci_array(I - 1);
            end loop;
        end if;
    end process;
end Behavioral;