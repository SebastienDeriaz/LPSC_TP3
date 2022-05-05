----------------------------------------------------------------------------------
-- Company: HES-SO Master
-- Engineer: Sébastien Deriaz
-- 
-- Create Date: 01.05.2022 18:42:00
-- Design Name: 
-- Module Name: evaluator - Behavioral
-- Project Name: LPSC - TP3 - Mandelbrot
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--
-- VHDL Module to evaluate the number of iterations of the mandelbrot equation
-- needed to atteign or cross the R radius. The number if iterations has a upper bound of max_iter
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity evaluator is
    generic (
        max_iter : integer := 100; -- Max number of iterations
        m        : integer := 15;  -- Number of integer bits (with sign bit)
        n        : integer := 3    -- Number of decimals bits
    );
    port (
        clk        : in std_logic;                    -- clock
        rst        : in std_logic;                    -- reset
        start      : in std_logic;                    -- Start signal
        Cr         : in signed (m + n - 1 downto 0);  -- Real part of the starting point
        Ci         : in signed (m + n - 1 downto 0);  -- Imaginary part of the starting point
        R          : in signed (m + n - 1 downto 0);  -- Stopping radius
        iterations : out integer range 0 to max_iter; -- Number of iterations
        done       : out std_logic                    -- Done signal
    );
end evaluator;

architecture Behavioral of evaluator is

    

    signal done_s        : std_logic;
    signal iter_counter  : integer range 0 to max_iter;
    signal Zr            : signed(m + n - 1 downto 0);
    signal Zi            : signed(m + n - 1 downto 0);
    signal interations_s : integer range 0 to max_iter;
begin
    done       <= done_s;
    iterations <= interations_s;
    process (clk, rst)
    begin
        if rst = '1' then
            done_s        <= '0';
            interations_s <= 0;
        else
            if done_s = '0' and (iter_counter > 0 or start = '1') then
                if iter_counter = max_iter then
                    -- Stop the process
                    done_s        <= '1';
                    interations_s <= iter_counter;
                else
                    if signed_multiply(Zr, Zr) + signed_multiply(Zi, Zi) >= signed_multiply(R, R) then
                        -- Stop the process because we've reached the stop redius
                        interations_s <= iter_counter;
                    else
                        -- Run the process
                        

                        iter_counter <= iter_counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;