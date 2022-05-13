----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.05.2022 13:56:19
-- Design Name: 
-- Module Name: tb_mandelbrot_loop - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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
use std.textio.all;

entity tb_mandelbrot_loop is
end tb_mandelbrot_loop;

architecture Behavioral of tb_mandelbrot_loop is
    constant max_iter       : integer                    := 100;
    constant m              : integer                    := 3;
    constant n              : integer                    := 15;
    constant R              : signed(m + n - 1 downto 0) := to_signed(2 * 2 ** n, m + n);
    constant CLK_PERIOD     : time                       := 10 ns;
    -- Files
    constant test_file_path : string                     := "../../../../../../../../../../../Tests/mandelbrot_loop_testcases.txt";
    constant log_file_path  : string                     := "../../../../../../../../../../../Tests/logs/tb_mandelbrot_loop.log";
    file test_file          : text;
    file log_file           : text;

    -- DUV
    component mandelbrot_loop is
        generic (
            max_iter : integer                    := 100;
            m        : integer                    := 3;
            n        : integer                    := 15;
            R        : signed(m + n - 1 downto 0) := to_signed(2 * 2 ** n, m + n)
        );
        port (
            clk                  : in std_logic;
            reset                : in std_logic;
            -- In
            Cr                   : in signed(m + n - 1 downto 0);
            Ci                   : in signed(m + n - 1 downto 0);
            start                : in std_logic;
            -- Out
            done                 : out std_logic;
            iterations           : out integer range 0 to max_iter;
            -- Debug
            debug                : out std_logic;
            debug_iterations_in  : out integer range 0 to max_iter;
            debug_iterations_out : out integer range 0 to max_iter;
            debug_Zr             : out signed(m + n - 1 downto 0);
            debug_Zi             : out signed(m + n - 1 downto 0);
            debug_Zi_next        : out signed(m + n - 1 downto 0);
            debug_Zr_next        : out signed(m + n - 1 downto 0)
        );
    end component;

    signal clk                      : std_logic := '0';
    signal reset                    : std_logic := '0';

    signal duv_clk                  : std_logic;
    signal duv_reset                : std_logic;
    signal duv_Cr                   : signed(m + n - 1 downto 0);
    signal duv_Ci                   : signed(m + n - 1 downto 0);
    signal duv_start                : std_logic;
    signal duv_done                 : std_logic;
    signal duv_iterations           : integer range 0 to max_iter;
    signal duv_debug                : std_logic;
    signal duv_debug_iterations_in  : integer range 0 to max_iter;
    signal duv_debug_iterations_out : integer range 0 to max_iter;
    signal duv_debug_Zr             : signed(m + n - 1 downto 0);
    signal duv_debug_Zi             : signed(m + n - 1 downto 0);
    signal duv_debug_Zi_next        : signed(m + n - 1 downto 0);
    signal duv_debug_Zr_next        : signed(m + n - 1 downto 0);

    procedure writeline_color(
        str              : string;
        color0           : integer := 0;
        color1           : integer := 0) is
        variable newline : line;
    begin
        if color1 /= 0 then
            write(newline, string'(ESC & "[" & integer'image(color0) & ";" & integer'image(color1) & "m" & str & ESC & "[0m"));
        else
            write(newline, string'(ESC & "[" & integer'image(color0) & "m" & str & ESC & "[0m"));
        end if;
        writeline(log_file, newline);
    end writeline_color;
begin
    duv : mandelbrot_loop
    generic map(
        max_iter => max_iter,
        m        => m,
        n        => n,
        R        => R
    )
    port map(
        clk                  => duv_clk,
        reset                => duv_reset,
        -- In
        Cr                   => duv_Cr,
        Ci                   => duv_Ci,
        start                => duv_start,
        -- Out
        done                 => duv_done,
        iterations           => duv_iterations,
        -- Debug
        debug                => duv_debug,
        debug_iterations_in  => duv_debug_iterations_in,
        debug_iterations_out => duv_debug_iterations_out,
        debug_Zr             => duv_debug_Zr,
        debug_Zi             => duv_debug_Zi,
        debug_Zr_next        => duv_debug_Zr_next,
        debug_Zi_next        => duv_debug_Zi_next
    );

    duv_clk   <= clk;
    duv_reset <= reset;
    clk       <= not clk after (CLK_PERIOD / 2);

    process is
        variable test_line         : line;

        variable Cr                : std_logic_vector(m + n - 1 downto 0);
        variable Ci                : std_logic_vector(m + n - 1 downto 0);
        variable iterations_out    : integer range 0 to max_iter;

        variable line_counter      : integer := 2; -- .csv starts at line 2

        variable total_error_count : integer := 0;
        variable error_count       : integer := 0;
    begin
        -- Open files
        file_open(test_file, test_file_path, READ_MODE);
        file_open(log_file, log_file_path, WRITE_MODE);

        -- Reset
        reset <= '1';
        wait for 2 * CLK_PERIOD;
        reset <= '0';
        wait for 2 * CLK_PERIOD;

        -- Loop over the test cases
        while not endfile(test_file) loop
            error_count := 0;
            wait until falling_edge(clk);
            readline(test_file, test_line);
            read(test_line, Cr);
            read(test_line, Ci);
            read(test_line, iterations_out);
            writeline_color("Testing line " & to_string(line_counter), 36, 4);
            line_counter := line_counter + 1;

            duv_Cr    <= signed(Cr);
            duv_Ci    <= signed(Ci);
            duv_start <= '1';
            --wait until rising_edge(clk);
            wait until falling_edge(clk);
            duv_start <= '0';

            wait until rising_edge(duv_done);

            -- Check Zr_next
            if duv_iterations /= iterations_out then
                writeline_color("iterations is wrong (" & to_string(duv_iterations)
                & " instead of " & to_string(iterations_out) & ")", 31);
                error_count := error_count + 1;
            end if;

            wait for CLK_PERIOD * 10;

            total_error_count := total_error_count + error_count;
        end loop;

        if total_error_count = 0 then
            writeline_color("Simulation success ! 0 errors", 42);
        else
            writeline_color("Simulation failed with " & to_string(total_error_count) & " errors", 41);
        end if;

        file_close(test_file);
        file_close(log_file);
        wait;
    end process;

end Behavioral;