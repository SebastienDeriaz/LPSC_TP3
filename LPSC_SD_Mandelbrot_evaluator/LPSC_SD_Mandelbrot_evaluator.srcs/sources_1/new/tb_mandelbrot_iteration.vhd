----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.05.2022 19:02:41
-- Design Name: 
-- Module Name: tb_mandelbrot_iteration - Behavioral
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
use ieee.numeric_std.all;
use std.textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_mandelbrot_iteration is
end tb_mandelbrot_iteration;

architecture IterationTestbench of tb_mandelbrot_iteration is
    constant test_file_path : string := "../../../../../Tests/mandelbrot_iteration_testcases.txt";
    constant log_file_path  : string := "../../../../../Tests/logs/tb_mandelbrot_iteration.log";
    file test_file          : text;
    file log_file           : text;

    constant max_iter       : integer := 100;
    constant CLK_PERIOD     : time    := 10 ns;
    constant m              : integer := 3;
    constant n              : integer := 15;

    component mandelbrot_iteration is
        generic (
            max_iter : integer := 100; -- Max number of iterations
            m        : integer := 15;  -- Number of integer bits (with sign bit)
            n        : integer := 3    -- Number of decimals bits
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
            -- Debug
            --debug_value    : out signed(m + n - 1 downto 0);
            --debug_value_2  : out signed(2*m + n - 1 downto 0)
        );
    end component;

    signal duv_clk            : std_logic;
    signal duv_reset          : std_logic;
    signal duv_done_in        : std_logic;
    signal duv_Cr             : signed (m + n - 1 downto 0);
    signal duv_Ci             : signed (m + n - 1 downto 0);
    signal duv_Zr_previous    : signed (m + n - 1 downto 0);
    signal duv_Zi_previous    : signed (m + n - 1 downto 0);
    signal duv_Zr_next        : signed(m + n - 1 downto 0);
    signal duv_Zi_next        : signed(m + n - 1 downto 0);
    signal duv_R              : signed (m + n - 1 downto 0);
    signal duv_iterations_in  : integer range 0 to max_iter;
    signal duv_iterations_out : integer range 0 to max_iter;
    signal duv_done_out       : std_logic;
    --signal duv_debug_value    : signed (m + n - 1 downto 0);
    --signal duv_debug_value_2  : signed(2*m + n - 1 downto 0);

    signal clk                : std_logic := '0';
    signal reset              : std_logic := '0';

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
    duv : mandelbrot_iteration
    generic map(
        max_iter => max_iter,
        m        => m,
        n        => n
    )
    port map(
        clk            => duv_clk,
        reset          => duv_reset,
        done_in        => duv_done_in,
        Cr             => duv_Cr,
        Ci             => duv_Ci,
        Zr_previous    => duv_Zr_previous,
        Zi_previous    => duv_Zi_previous,
        Zr_next        => duv_Zr_next,
        Zi_next        => duv_Zi_next,
        R              => duv_R,
        iterations_in  => duv_iterations_in,
        iterations_out => duv_iterations_out,
        done_out       => duv_done_out
        --debug_value    => duv_debug_value,
        --debug_value_2  => duv_debug_value_2
    );

    duv_clk   <= clk;
    duv_reset <= reset;
    clk       <= not clk after (CLK_PERIOD / 2);

    process is
        variable test_line         : line;

        variable Cr                : std_logic_vector(m + n - 1 downto 0);
        variable Ci                : std_logic_vector(m + n - 1 downto 0);
        variable Zr_previous       : std_logic_vector(m + n - 1 downto 0);
        variable Zi_previous       : std_logic_vector(m + n - 1 downto 0);
        variable Zr_next           : std_logic_vector(m + n - 1 downto 0);
        variable Zi_next           : std_logic_vector(m + n - 1 downto 0);
        variable done_in           : std_logic;
        variable R                 : std_logic_vector(m + n - 1 downto 0);
        variable iterations_in     : integer range 0 to max_iter;
        variable iterations_out    : integer range 0 to max_iter;
        variable done_out          : std_logic;

        variable filestatus        : file_open_status;

        variable line_counter      : integer := 2; -- .csv starts at line 2

        variable total_error_count : integer := 0;
        variable error_count       : integer := 0;
    begin
        -- Open files
        file_open(test_file, test_file_path, READ_MODE);
        file_open(log_file, log_file_path, WRITE_MODE);

        writeline_color(test_file_path & LF & HT & "file_open_status = " &
        file_open_status'image(filestatus));
        if filestatus /= OPEN_OK then
            report "file_open_status /= file_ok" severity FAILURE; -- end simulation
        end if;

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
            read(test_line, Zr_previous);
            read(test_line, Zi_previous);
            read(test_line, Zr_next);
            read(test_line, Zi_next);
            read(test_line, done_in);
            read(test_line, R);
            read(test_line, iterations_in);
            read(test_line, iterations_out);
            read(test_line, done_out);

            duv_Cr            <= signed(Cr);
            duv_Ci            <= signed(Ci);
            duv_Zr_previous   <= signed(Zr_previous);
            duv_Zi_previous   <= signed(Zi_previous);
            duv_done_in       <= done_in;
            duv_iterations_in <= iterations_in;
            duv_R             <= signed(R);

            writeline_color("Testing line " & to_string(line_counter), 36, 4);
            line_counter := line_counter + 1;

            wait until rising_edge(clk);

            -- Check Zr_next
            if std_logic_vector(duv_Zr_next) /= Zr_next then
                writeline_color("Zr_next is wrong (" & to_string(std_logic_vector(duv_Zr_next))
                & " instead of " & to_string(Zr_next) & ")", 31);
                error_count := error_count + 1;
            end if;
            -- Check Zi_next
            if std_logic_vector(duv_Zi_next) /= Zi_next then
                writeline_color("Zi_next is wrong (" & to_string(std_logic_vector(duv_Zi_next))
                & " instead of " & to_string(Zi_next) & ")", 31);
                error_count := error_count + 1;
            end if;
            -- Check iterations out
            if duv_iterations_out /= iterations_out then
                writeline_color("iterations_out is wrong (" & to_string(duv_iterations_out)
                & " instead of " & to_string(iterations_out) & ")", 31);
                error_count := error_count + 1;
            end if;
            -- Check done out
            if duv_done_out /= done_out then
                writeline_color("done_out is wrong (" & to_string(duv_done_out)
                & " instead of " & to_string(done_out) & ")", 31);
                error_count := error_count + 1;
            end if;

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
end IterationTestbench;