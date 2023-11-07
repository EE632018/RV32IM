----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/07/2023 09:20:34 AM
-- Design Name: 
-- Module Name: priority_encoder_tb - Behavioral
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

entity priority_encoder_tb is
--  Port ( );
end priority_encoder_tb;

architecture Behavioral of priority_encoder_tb is

    COMPONENT priority_encoder
    Port (  cnt_one : in STD_LOGIC_VECTOR (1 downto 0);
            cnt_two : in STD_LOGIC_VECTOR (1 downto 0);
            cnt_three : in STD_LOGIC_VECTOR (1 downto 0);
            cnt_four : in STD_LOGIC_VECTOR (1 downto 0);
            index_sel : out STD_LOGIC_VECTOR (1 downto 0)
            ); 
    END COMPONENT;

    signal cnt_one_s, cnt_two_s, cnt_three_s, cnt_four_s, index_sel_s: std_logic_vector(1 downto 0);    

begin

    PE_INST:priority_encoder
    PORT MAP    (cnt_one            =>  cnt_one_s,
                 cnt_two            =>  cnt_two_s,
                 cnt_three          =>  cnt_three_s,
                 cnt_four           =>  cnt_four_s,
                 index_sel          =>  index_sel_s
                );
                
     process
     begin
          cnt_one_s <= "11";
          cnt_two_s <= "11";
          cnt_three_s <= "11";
          cnt_four_s <= "11";
          wait for 50ns;
          
          cnt_one_s <= "10";
          cnt_two_s <= "11";
          cnt_three_s <= "11";
          cnt_four_s <= "11";
          wait for 50ns;
          
          
          cnt_one_s <= "01";
          cnt_two_s <= "10";
          cnt_three_s <= "11";
          cnt_four_s <= "11";
          wait for 50ns;
          
          
          cnt_one_s <= "10";
          cnt_two_s <= "01";
          cnt_three_s <= "10";
          cnt_four_s <= "11";
          wait for 50ns;
          wait;
     end process;            
                
end Behavioral;
