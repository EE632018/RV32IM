----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/28/2023 11:58:30 AM
-- Design Name: 
-- Module Name: floatDevision - Behavioral
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

entity floatDevision is
    Port ( a_in : in STD_LOGIC_VECTOR (31 downto 0);
           b_in : in STD_LOGIC_VECTOR (31 downto 0);
           r_out : out STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           start : in std_logic; 
           stall_o : out STD_LOGIC);
end floatDevision;

architecture Behavioral of floatDevision is
    component floatReciproach
        Port ( b_in : in STD_LOGIC_VECTOR (31 downto 0);
               clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               start : in STD_LOGIC;
               stall_o : out std_logic;
               r_out : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component floatM
        Port ( a_in : in std_logic_vector(31 downto 0);
               b_in : in std_logic_vector(31 downto 0);
               c_out : out std_logic_vector(31 downto 0));
    end component;
    
    signal rec : std_logic_vector(31 downto 0);
begin

    floatRec_i: floatReciproach
    port map(clk => clk,
             rst => rst,
             start => start,
             b_in => b_in,
             stall_o => stall_o,
             r_out => rec);
             
    floatM_i: floatM
    port map (a_in => a_in, b_in => rec, c_out => r_out);
end Behavioral;
