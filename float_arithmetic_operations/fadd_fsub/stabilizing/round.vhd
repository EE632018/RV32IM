library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity round is
    port ( 
        Min: in std_logic_vector(27 downto 0);
        Mout: out std_logic_vector(22 downto 0)
    );  
end entity;

architecture behavioral of round is
    
begin
    process(Min)
    begin
        if Min(3 downto 0) = "1000" then
            Mout <= std_logic_vector(unsigned(Min(26 downto 4)) + to_unsigned(1,23));
        else
            Mout <= Min(26 downto 4);
        end if;
    end process;
end behavioral;