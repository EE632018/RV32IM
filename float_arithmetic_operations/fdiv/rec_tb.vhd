----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/28/2023 11:38:53 AM
-- Design Name: 
-- Module Name: rec_tb - Behavioral
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

entity rec_tb is
--  Port ( );
end rec_tb;

architecture Behavioral of rec_tb is
    component floatReciproach
        Port ( b_in : in STD_LOGIC_VECTOR (31 downto 0);
               clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               start : in STD_LOGIC;
               r_out : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    signal clk_s, rst_s, start_s: std_logic;
    signal b_s, res_s : std_logic_vector(31 downto 0);
    
begin

    duv: floatReciproach
    port map(b_in => b_s, clk => clk_s, rst => rst_s, start => start_s, r_out => res_s);
    
    process
    begin
        clk_s <= '0', '1' after 50 ns;
        wait for 100 ns;
    end process;
    
    process
    begin
        rst_s <= '1', '0' after 300 ns;
        start_s <= '0', '1' after 500 ns, '0' after 600 ns;     
        wait;
    end process;
    
    process
    begin
        b_s <=  "01000010111110100100000000000000";
        wait;
    end process;
end Behavioral;
