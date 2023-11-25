library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fcvt is
    Port ( a_in : in STD_LOGIC_VECTOR (31 downto 0);
           c_s_out : out STD_LOGIC_VECTOR (31 downto 0);
           c_u_out : out STD_LOGIC_VECTOR (31 downto 0));
end fcvt;

architecture behavioral of fcvt is

    signal a_s : std_logic;
    signal a_e : std_logic_vector(7 downto 0);
    signal a_m : std_logic_vector(22 downto 0);
begin

    a_m <= a_in(22 downto 0);
    a_e <= a_in(30 downto 23);
    a_s <= a_in(31);

    c_s_out <= a_s & "00000000000000000000000" & a_e;
    c_u_out <= "00000000000000000000000" & a_s & a_e;
end behavioral;