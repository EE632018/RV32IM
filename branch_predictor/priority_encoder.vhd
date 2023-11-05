----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/02/2023 08:46:33 AM
-- Design Name: 
-- Module Name: priority_encoder - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

entity priority_encoder is
    Port ( cnt_one : in STD_LOGIC_VECTOR (1 downto 0);
           cnt_two : in STD_LOGIC_VECTOR (1 downto 0);
           cnt_three : in STD_LOGIC_VECTOR (1 downto 0);
           cnt_four : in STD_LOGIC_VECTOR (1 downto 0);

           -- This index sel is not connected to index_sel in TOC
           index_sel : out STD_LOGIC_VECTOR (1 downto 0));
end priority_encoder;

architecture Behavioral of priority_encoder is
begin
    
    priority_enc: process(cnt_one,cnt_two,cnt_three,cnt_four)
                  variable priority: std_logic_vector(1 downto 0) := "00";
                  begin
                    -- Default output values
                    index_sel <= "00";
                    
                    -- Check the input groups to determine the highest priority
                    if cnt_one > cnt_two and cnt_one > cnt_three and cnt_one > cnt_four then
                        index_sel <= "00";
                    elsif cnt_two > cnt_one and cnt_two > cnt_three and cnt_two > cnt_four then
                        index_sel <= "01";
                    elsif cnt_three > cnt_one and cnt_three > cnt_two and cnt_three > cnt_four then
                        index_sel <= "10";
                    elsif cnt_four > cnt_one and cnt_four > cnt_two and cnt_four > cnt_three then
                        index_sel <= "11";
                    end if;
            
                    -- If there's a tie in the highest value, choose the input with the lowest value, two cnt are same value
                    if cnt_one = cnt_two and cnt_one > cnt_three and cnt_one > cnt_four then
                        index_sel <= "00";
                    elsif cnt_one = cnt_three and cnt_one > cnt_two and cnt_one > cnt_four then
                        index_sel <= "00";
                    elsif cnt_one = cnt_four and cnt_one > cnt_two and cnt_one > cnt_three then
                        index_sel <= "00";
                    elsif cnt_two = cnt_three and cnt_two > cnt_one and cnt_two > cnt_four then
                        index_sel <= "01";
                    elsif cnt_two = cnt_four and cnt_two > cnt_one and cnt_two > cnt_three then
                        index_sel <= "01";
                    elsif cnt_three = cnt_four and cnt_three > cnt_one and cnt_three > cnt_two then
                        index_sel <= "10";
                    end if;
                    
                    -- If there's a tie in the highest value, choose the input with the lowest value, three cnt are same value
                    if cnt_one = cnt_two and cnt_one = cnt_three and cnt_one > cnt_four then
                        index_sel <= "00";
                    elsif cnt_one = cnt_two and cnt_one > cnt_three and cnt_one = cnt_four then
                        index_sel <= "00";    
                    elsif cnt_one = cnt_three and cnt_one > cnt_two and cnt_one = cnt_four then
                        index_sel <= "00";
                    elsif cnt_two = cnt_four and cnt_two > cnt_one and cnt_two = cnt_three then
                        index_sel <= "01";
                    elsif cnt_three = cnt_four and cnt_three > cnt_one and cnt_three = cnt_two then
                        index_sel <= "10";
                    end if;
                    
                    -- If all `cnt` values are the same
                    if cnt_one = cnt_two and cnt_one = cnt_three and cnt_one = cnt_four then
                        index_sel <= "00";
                    end if;
                 
                  end process priority_enc;
    
end Behavioral;
