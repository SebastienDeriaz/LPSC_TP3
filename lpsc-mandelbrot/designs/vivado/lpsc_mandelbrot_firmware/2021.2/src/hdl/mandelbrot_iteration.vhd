----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.05.2022 19:02:41
-- Design Name: Sébastien Deriaz
-- Module Name: mandelbrot_iteration - Behavioral
-- Project Name: LPSC - TP3
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Single Mandelbrot iteration
-- If the input done signal is '1', then the system doesn't do anything.
-- This is to allow for the future implementation in a pipeline
--
--
--
--
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity mandelbrot_iteration is
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
end mandelbrot_iteration;

architecture MandelbrotIteration of mandelbrot_iteration is
    -- Multiply function with n+m bits output
    function signed_multiply(A : signed; B : signed) return signed is
        variable result : signed(2 * m + 2 * n - 1 downto 0);
    begin
        result := A * B;
        return signed(result(m + n + n - 1 downto n));
    end signed_multiply;

    -- Multiply function with more bits as output
    function signed_multiply_high(A : signed; B : signed) return signed is
        variable result : signed(2 * m + 2 * n - 1 downto 0);
    begin
        result := A * B;
        return result(2 * m + 2 * n - 1 downto n);
    end signed_multiply_high;
begin
    process (clk, reset)
        variable Zr_new_v     : signed(m + n - 1 downto 0);
        variable Zi_new_v     : signed(m + n - 1 downto 0);
        variable done_input_v : boolean;
        variable done_self_v  : boolean;
    begin

        if reset = '1' then
            Zr_next <= (others  => '0');
            Zi_next <= (others  => '0');
            done_out       <= '0';
            iterations_out <= 0;

        elsif rising_edge(clk) then
            -- Calculate the new Zr and new Zi
            Zr_new_v     := signed_multiply(Zr_previous, Zr_previous) - signed_multiply(Zi_previous, Zi_previous) + Cr;
            Zi_new_v     := signed_multiply(Zi_previous, Zr_previous) + signed_multiply(Zi_previous, Zr_previous) + Ci;
            
            -- Check if we're done
            done_input_v := done_in = '1' or iterations_in = max_iter;
            done_self_v  := signed_multiply_high(Zr_new_v, Zr_new_v) + signed_multiply_high(Zi_new_v, Zi_new_v) >= signed_multiply_high(R, R);

            -- Update the output values
            if done_input_v then
                iterations_out <= iterations_in;
                Zr_next        <= Zr_previous;
                Zi_next        <= Zi_previous;
                done_out       <= '1';
            else
                Zr_next        <= Zr_new_v;
                Zi_next        <= Zi_new_v;
                iterations_out <= iterations_in + 1;
                if done_self_v then
                    done_out <= '1';
                else
                    done_out <= '0';
                end if;

            end if;
        end if;
    end process;
end MandelbrotIteration;