----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.05.2022 07:02:11
-- Design Name: 
-- Module Name: iterations_to_color - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity iterations_to_color is
    Port ( iterations : in STD_LOGIC;
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           R : in STD_LOGIC;
           G : in STD_LOGIC;
           B : in STD_LOGIC);
end iterations_to_color;

architecture Behavioral of iterations_to_color is

begin


end Behavioral;
