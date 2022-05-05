----------------------------------------------------------------------------------
-- Company: HES-SO Master
-- Engineer: Sébastien Deriaz
-- 
-- Create Date: 01.05.2022 18:42:00
-- Design Name: LPSC - TP3 - Mandelbrot
-- Module Name: tb_evaluator - Behavioral
-- Project Name: Mandelbrot
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Testbench for 
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
--use ieee.std_logic_textio.hwrite;
use std.textio.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_evaluator is
end tb_evaluator;

architecture Behavioral of tb_evaluator is
    constant CLK_PERIOD     : time    := 10 ns;
    constant m              : integer := 3;
    constant n              : integer := 15;
    constant max_iter       : integer := 100;

    --constant test_file_path : string  := "../../../../Tests/evaluator_test_cases.txt";
    constant test_file_path : string  := "evaluator_test_cases.txt";
    constant log_file_path  : string  := "simulation.log";

    component evaluator is
        generic (
            max_iter : integer; -- Max number of iterations
            m        : integer; -- Number of integer bits (with sign bit)
            n        : integer  -- Number of decimals bits
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
    end component;

    signal clk           : std_logic                   := '0';
    signal reset         : std_logic                   := '1';

    signal start         : std_logic                   := '0';
    signal Cr            : signed(m + n - 1 downto 0)  := (others => '0');
    signal Ci            : signed(m + n - 1 downto 0)  := (others => '0');
    signal R             : signed(m + n - 1 downto 0)  := (others => '0');
    signal iterations    : integer range 0 to max_iter := 0;
    signal iterations_th : integer range 0 to max_iter := 0;
    signal done          : std_logic                   := '0';

    file test_file       : text;
    file log_file        : text;

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

    duv : evaluator
    generic map(
        max_iter => max_iter,
        m        => m,
        n        => n
    )
    port map(
        clk        => clk,
        rst        => reset,
        start      => start,
        Cr         => Cr,
        Ci         => Ci,
        R          => R,
        iterations => iterations,
        done       => done
    );

    clk <= not clk after (CLK_PERIOD / 2);

    R   <= "010000000000000000"; -- R=2

    process is
        variable test_line      : line;
        variable log_line       : line;
        variable filestatus     : file_open_status;
        variable good           : boolean;
        variable Cr_txt         : std_logic_vector(m + n - 1 downto 0);
        variable Ci_txt         : std_logic_vector(m + n - 1 downto 0);
        variable iterations_txt : std_logic_vector(m + n - 1 downto 0);
    begin
        -- Open files
        file_open(filestatus, test_file, test_file_path, READ_MODE);
        file_open(log_file, log_file_path, WRITE_MODE);

        writeline_color(test_file_path & LF & HT & "file_open_status = " &
        file_open_status'image(filestatus));
        if filestatus /= OPEN_OK then
            writeline_color("file_open_status /= file_ok", 41, 4);
            report "file_open_status /= file_ok" severity FAILURE; -- end simulation
        else
            writeline_color("File open ok", 42, 0);
        end if;

        -- Reset
        reset <= '1';
        wait for 2 * CLK_PERIOD;
        reset <= '0';
        wait for 2 * CLK_PERIOD;
        -- Loop over the test cases
        while not endfile(test_file) loop
            writeline_color("start loop");
            wait until falling_edge(clk);
            writeline_color("read line");
            readline(test_file, test_line);
            wait for 10 * CLK_PERIOD;
            writeline_color("read");
            read(test_line, Cr_txt);
            read(test_line, Ci_txt, good);
            read(test_line, iterations_txt, good);
            writeline_color("Testing with " & to_string(Cr_txt), 1, 0);
            Cr            <= signed(Cr_txt);
            Ci            <= signed(Ci_txt);
            iterations_th <= to_integer(unsigned(iterations_txt));
            start         <= '1';
            writeline_color("test", 101);
            
            --wait for CLK_PERIOD;
            --wait until rising_edge(clk);
            writeline_color("test 2", 101);
            start <= '0';
            writeline_color("test 3", 101);
            writeline_color("Wait for done to raise", 0, 0);
            wait until done = '1' for ((max_iter + 2) * CLK_PERIOD);
            if done = '0' then
                writeline_color("Done didn't raise", 31, 1);
            else
                if iterations = iterations_th then
                    writeline_color("Ok !", 32, 1);
                else
                    writeline_color("number of iterations is wrong", 33, 1);
                end if;
            end if;
        end loop;

        file_close(test_file);
        file_close(log_file);
        wait for 2 * CLK_PERIOD;
        wait;
    end process;
end Behavioral;