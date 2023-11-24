----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2023 10:55:38 AM
-- Design Name: 
-- Module Name: float_m_tb - Behavioral
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

entity float_m_tb is
--  Port ( );
end float_m_tb;

architecture Behavioral of float_m_tb is
    signal a_in_t, b_in_t : std_logic_vector(31 downto 0);
    signal c_out_t : std_logic_vector(31 downto 0);
    
    component floatM
        Port ( a_in : in std_logic_vector(31 downto 0);
           b_in : in std_logic_vector(31 downto 0);
           c_out : out std_logic_vector(31 downto 0));
    end component;
begin

    flot_i: floatM
    port map(a_in => a_in_t, b_in => b_in_t, c_out => c_out_t);
    
    process is
    begin
        a_in_t <=  "01000010111110100100000000000000";
        
        b_in_t <=  "01000001010000010000000000000000";
        
        wait;
    end process;
end Behavioral;
