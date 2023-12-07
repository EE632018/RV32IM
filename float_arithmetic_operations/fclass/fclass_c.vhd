----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/25/2023 11:04:13 AM
-- Design Name: 
-- Module Name: fclass - Behavioral
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

entity fclass_c is
    Port ( a_in : in STD_LOGIC_VECTOR (31 downto 0);
           c_out : out STD_LOGIC_VECTOR (31 downto 0));
end fclass_c;

architecture Behavioral of fclass_c is
    signal a_s : std_logic;
    signal a_e : std_logic_vector(7 downto 0);
    signal a_m : std_logic_vector(22 downto 0);
begin
    a_m <= a_in(22 downto 0);
    
    a_e <= a_in(30 downto 23);
    
    a_s <= a_in(31);
    
    process(a_m, a_e, a_s)
    begin
        c_out <= (others => '0');
        if a_s = '0' then
            if(unsigned(a_e) = TO_UNSIGNED(0, 8)) then
                if(unsigned(a_m) = TO_UNSIGNED(0, 23)) then
                    c_out(4) <= '1';
                else
                    c_out(5) <= '1';
                end if; 
            elsif(unsigned(a_e) = TO_UNSIGNED(255, 8)) then
                if(unsigned(a_m) = TO_UNSIGNED(0, 23)) then
                    c_out(7) <= '1';
                else 
                    if a_m(22) = '0' then
                        c_out(8) <= '1';
                    else
                        c_out(9) <= '1';
                    end if;                    
                end if; 
            else
                c_out(6) <= '1';
            end if; 
        else
            if(unsigned(a_e) = TO_UNSIGNED(0, 8)) then
                if(unsigned(a_m) = TO_UNSIGNED(0, 23)) then
                    c_out(3) <= '1';
                else
                    c_out(2) <= '1';
                end if; 
            elsif(unsigned(a_e) = TO_UNSIGNED(255, 8)) then
                if(unsigned(a_m) = TO_UNSIGNED(0, 23)) then
                    c_out(0) <= '1';
                else 
                    if a_m(22) = '0' then
                        c_out(8) <= '1';
                    else
                        c_out(9) <= '1';
                    end if;                    
                end if;
            else
                c_out(1) <= '1';
            end if; 
        end if; 
    end process;

end Behavioral;