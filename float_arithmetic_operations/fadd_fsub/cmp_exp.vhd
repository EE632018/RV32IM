library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cmp_exp is
  Port (Ex: in std_logic_vector(8 downto 0);
        Ey: in std_logic_vector(8 downto 0);
        EQ: out std_logic;
        GT: out std_logic;
        LT: out std_logic
        );
end cmp_exp;

architecture Behavioral of cmp_exp is

begin

    process(Ex, Ey)
    begin
        GT <= '0';
        LT <= '0';
        EQ <= '0';
        if Ex > Ey then
            GT <= '1';
        elsif Ex < Ey then
            LT <= '1';
        else
            EQ <= '1';
        end if;
    end process;

end Behavioral;
