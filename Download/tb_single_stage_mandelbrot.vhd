


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_lpsc_mandelbrot_firmware is
    generic (
        comma   : integer := 14;
        SIZE    : integer := 18
    );
end tb_lpsc_mandelbrot_firmware;


architecture test_bench of tb_lpsc_mandelbrot_firmware is

    type stimulus_t is record
        c_real          : std_logic_vector(SIZE - 1 downto 0);
        c_imaginary     : std_logic_vector(SIZE - 1 downto 0);
        z_real_in       : std_logic_vector(SIZE - 1 downto 0);
        z_imaginary_in  : std_logic_vector(SIZE - 1 downto 0);
    end record;
    
    type observed_t is record
        z_real_out      : std_logic_vector(SIZE - 1 downto 0);
        z_imaginary_out : std_logic_vector(SIZE - 1 downto 0);
    end record;

    signal stimulus_sti  : stimulus_t;
    signal observed_obs  : observed_t;
    signal reference_ref : observed_t;

    signal sim_end_s : boolean   := false;
    signal clock_s : std_logic := '0';
    signal reset_s : std_logic := '0';

    -- Flag to start verification
    signal verif_s : std_logic := '0';

    signal mismatch_s : std_logic := '0';

    -- Clock period
    constant PERIOD : time := 10 ns;

    component single_stage_mandelbrot is
        generic (
            comma    : integer := 14; -- nombre de bits après la virgule
            SIZE     : integer := 18);
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            c_real          : in std_logic_vector(SIZE - 1 downto 0);
            c_imaginary     : in std_logic_vector(SIZE - 1 downto 0);
            z_real_in       : in std_logic_vector(SIZE - 1 downto 0);
            z_imaginary_in  : in std_logic_vector(SIZE - 1 downto 0);
            z_real_out      : out std_logic_vector(SIZE - 1 downto 0);
            z_imaginary_out : out std_logic_vector(SIZE - 1 downto 0)
        );
    end component;

    constant golden_model_path : string := "../golden_model/fixed_data/single_stage/";

    -- Déclaration d’un type de fichier
    -- type file_real is file of real;
    -- Déclaration d’un fichier en lecture
    file sti_file : text;
    file ref_file : text;

begin

    duv : single_stage_mandelbrot
    generic map(
        comma       => 14,
        SIZE        => 18
    )
    port map(
        clk             => clock_s,
        rst             => reset_s,
        c_real          => stimulus_sti.c_real,
        c_imaginary     => stimulus_sti.c_imaginary,
        z_real_in       => stimulus_sti.z_real_in,
        z_imaginary_in  => stimulus_sti.z_imaginary_in,
        z_real_out      => observed_obs.z_real_out,
        z_imaginary_out => observed_obs.z_imaginary_out
    );
    
    clock_proc : process is
    begin
        while not(sim_end_s) loop
            clock_s <= '0', '1' after PERIOD/2;
            wait for PERIOD;
        end loop;
        wait;
    end process;

    verif_proc : process is
        variable txt_line   : Line;
        variable z_real_txt_obs   : std_logic_vector(SIZE - 1 downto 0);
        variable z_imag_txt_obs   : std_logic_vector(SIZE - 1 downto 0);
    begin
        file_open(ref_file, golden_model_path & "18_14_ref.txt", READ_MODE);

        wait until verif_s = '1';

        while not endfile(ref_file) loop
            readline(ref_file, txt_line);
            read(txt_line, z_real_txt_obs);
            read(txt_line, z_imag_txt_obs);

            reference_ref.z_real_out <= z_real_txt_obs;
            reference_ref.z_imaginary_out <= z_imag_txt_obs;

            if observed_obs.z_real_out = reference_ref.z_real_out and observed_obs.z_imaginary_out = reference_ref.z_imaginary_out then
                mismatch_s <= '1';
                report "error" severity error;
            else
                report "good" severity warning;
            end if;

            wait until rising_edge(clock_s);
            wait for 2 ns;

        end loop;
        
        wait;
    end process;


    stimulus_proc: process is
        variable txt_line   : Line;
        variable c_real_txt_sti   : std_logic_vector(SIZE - 1 downto 0);
        variable c_imag_txt_sti   : std_logic_vector(SIZE - 1 downto 0);
        variable z_real_txt_sti   : std_logic_vector(SIZE - 1 downto 0);
        variable z_imag_txt_sti   : std_logic_vector(SIZE - 1 downto 0);

    begin
        file_open(sti_file, golden_model_path & "18_14_sti.txt", READ_MODE);

        stimulus_sti.c_real         <= (others => '0');
        stimulus_sti.c_imaginary    <= (others => '0');
        stimulus_sti.z_real_in      <= (others => '0');
        stimulus_sti.z_imaginary_in <= (others => '0');

        wait until rising_edge(clock_s);
        reset_s <= '1';
        wait for 10*PERIOD;

        reset_s <= '0';
        wait for 10*PERIOD;

        while not endfile(sti_file) loop
            readline(sti_file, txt_line);
            read(txt_line, c_real_txt_sti);
            read(txt_line, c_imag_txt_sti);
            read(txt_line, z_real_txt_sti);
            read(txt_line, z_imag_txt_sti);

            stimulus_sti.c_real         <= c_real_txt_sti;
            stimulus_sti.c_imaginary    <= c_imag_txt_sti;
            stimulus_sti.z_real_in      <= z_real_txt_sti;
            stimulus_sti.z_imaginary_in <= z_imag_txt_sti;

            wait until falling_edge(clock_s);
            wait for 2 ns;
            verif_s <= '1';

        end loop;

        -- report "Running TESTCASE " & integer'image(TESTCASE) severity note;

        -- close file
        file_close(sti_file);

        -- end of simulation
        sim_end_s <= true;

        -- stop the process
        wait;

    end process; -- stimulus_proc

end test_bench;