----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2023 10:46:33 AM
-- Design Name: 
-- Module Name: floatM - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity floatM is
    Port ( a_in : in std_logic_vector(31 downto 0);
           b_in : in std_logic_vector(31 downto 0);
           c_out : out std_logic_vector(31 downto 0));
end floatM;

architecture Behavioral of floatM is

    signal a_m, b_m : std_logic_vector(23 downto 0);
    signal c_m : std_logic_vector(47 downto 0);
    signal c_mf : std_logic_vector(22 downto 0);
    signal c_s, a_s, b_s : std_logic;
    signal c_e, a_e, b_e : std_logic_vector(7 downto 0);
    
begin
 
    a_m <= '1' & a_in(22 downto 0);
    b_m <= '1' & b_in(22 downto 0);
    
    a_e <= a_in(30 downto 23);
    b_e <= b_in(30 downto 23);
    
    a_s <= a_in(31);
    b_s <= b_in(31);
    c_s <= a_s xor b_s;
    
    process(a_m,b_m) is
    begin
        c_m <= std_logic_vector(unsigned(a_m) * unsigned(b_m));
    end process;

    process(c_m) is
    begin
        if c_m(47) = '1' then
            c_mf <= c_m(46 downto 24);
        else
            c_mf <= c_m(47 downto 25);
        end if;
    end process;
    
    process(a_e, b_e, c_m)is
    begin
        if c_m(47) = '1' then
            c_e <= std_logic_vector(unsigned(a_e) + unsigned(b_e) - TO_UNSIGNED(126, 8));
        else
            c_e <= std_logic_vector(unsigned(a_e) + unsigned(b_e) - TO_UNSIGNED(127, 8));
        end if;
    end process;
    
    c_out <= c_s & c_e & c_mf;
end Behavioral;
