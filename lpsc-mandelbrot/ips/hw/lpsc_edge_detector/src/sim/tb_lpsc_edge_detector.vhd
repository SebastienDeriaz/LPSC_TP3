----------------------------------------------------------------------------------
--                                 _             _
--                                | |_  ___ _ __(_)__ _
--                                | ' \/ -_) '_ \ / _` |
--                                |_||_\___| .__/_\__,_|
--                                         |_|
--
----------------------------------------------------------------------------------
--
-- Company: hepia
-- Author: Joachim Schmidt <joachim.schmidt@hesge.ch
--
-- Module Name: tb_lpsc_edge_detector - arch
-- Target Device: digilentinc.com:nexys_video:part0:1.1 xc7a200tsbg484-1
-- Tool version: 2021.2
-- Description: Testbench for lpsc_edge_detector
--
-- Last update: 2022-03-14
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Utile pour générer des valeurs pseudo-aléatoires.
use ieee.math_real.uniform;
use ieee.math_real.floor;

library unisim;
use unisim.vcomponents.all;

entity tb_lpsc_edge_detector is
-- Empty for a testbench
end tb_lpsc_edge_detector;


architecture behavioral of tb_lpsc_edge_detector is

    constant C_CLK_PERIOD : time    := 10 ns;
    constant C_NB_TEST    : integer := 10;

    component lpsc_edge_detector is
        port (
            ClkxCI   : in  std_ulogic;
            RstxRI   : in  std_ulogic;
            ProbexSI : in  std_ulogic;
            PulsexSO : out std_ulogic);
    end component lpsc_edge_detector;

    signal ClkxC            : std_ulogic := '0';
    signal RstxR            : std_ulogic := '1';  -- Au départ, on dans l'état reset.
    signal ProbexS          : std_ulogic := '0';
    signal PulsexS          : std_ulogic := '0';
    -- Signaux internes à la simulation.
    signal EndOfSimxS       : boolean    := false;
    signal RandomWaitTimexD : integer    := 10;

begin

    AsyncStatxB : block is
    begin  -- block AsyncStatxB

        -- On génére une horloge de période C_CLK_PERIOD.
        ClkxAS : ClkxC <= not ClkxC after (C_CLK_PERIOD / 2);
        -- On lève le reset après 100 ns.
        RstxAS : RstxR <= '0'       after (C_CLK_PERIOD * 10);

    end block AsyncStatxB;

    ---------------------------------------------------------------------------
    -- Instance du composant lpsc_edge_detector.
    ---------------------------------------------------------------------------
    LpscEdgeDetectorxI : entity work.lpsc_edge_detector
        port map (
            ClkxCI   => ClkxC,
            RstxRI   => RstxR,
            ProbexSI => ProbexS,
            PulsexSO => PulsexS);

    ---------------------------------------------------------------------------
    -- Process de fin de simulation.
    ---------------------------------------------------------------------------
    EndOfSimxP : process is
    begin  -- process EndOfSimxP

        -- Condition de fin de simulation.
        if EndOfSimxS = true then
            assert false report "Fin de la simulation!" severity failure;
        end if;

        -- On attend un cycle d'horloge.
        wait until rising_edge(ClkxC);

    end process EndOfSimxP;

    ---------------------------------------------------------------------------
    -- Process pour générer des temps d'attente pseudo-aléatoire.
    ---------------------------------------------------------------------------
    RandWaitxP : process is

        variable Seed1xD, Seed2xD : positive;
        variable RandxD           : real;
        variable RangeOfRandxD    : real := 100.0;

    begin  -- process RandWaitxP

        report "Début du process RandWaitxP" severity note;

        -- A chaque cycle d'horloge on sort un nouveau nombre pseudo-aléatoire.
        -- Ceci jusqu'à la fin de la simulation.
        RVTLoopxAS : loop
            exit RVTLoopxAS when (EndOfSimxS = true);
            uniform(Seed1xD, Seed2xD, RandxD);
            RandomWaitTimexD <= integer(RandxD * RangeOfRandxD) + 10;
            -- report "RandomWaitTimexD = " & integer'image(RandomWaitTimexD) severity note;
            -- wait for C_CLK_PERIOD;
            wait until rising_edge(ClkxC);
        end loop;

        report "Fin du process RandWaitxP" severity note;

    end process RandWaitxP;

    ---------------------------------------------------------------------------
    -- Process de test pour le composant lpsc_edge_detector.
    -- On alterne simplement le signal d'entrée avec une attente
    -- pseudo-aléatoire.
    ---------------------------------------------------------------------------
    TestLpscEdgeDetectorxP : process is
    begin  -- process TestLpscEdgeDetectorxP

        -- On initialise le signal d'entré à 0
        ProbexS <= '0';

        -- On attend la fin du reset.
        wait until (RstxR = '0');

        -- On effectue C_NB_TEST fois le test.
        for i in 0 to (C_NB_TEST - 1) loop

            -- On inverse le signal d'entré.
            -- On passera successivement de 0 à 1 et de 1 à 0
            -- avec des temps d'attente aléatoire.
            ProbexS <= not ProbexS;
            wait for RandomWaitTimexD * C_CLK_PERIOD;

        end loop;  -- i

        -- On signifie la fin de la simulation.
        -- Le process EndOfSimxP se chargera de mettre
        -- fin à la simulation.
        EndOfSimxS <= true;

    end process TestLpscEdgeDetectorxP;

end behavioral;
