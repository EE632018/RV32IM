library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity zero is
    generic(WIDTH: integer:= 28);
    port ( 
        T       : in std_logic_vector(WIDTH - 1 downto 0);
        Zcount  : out std_logic_vector(4 downto 0)
    );  
 end entity;

architecture behavioral of zero is
    signal aux: std_logic_vector(7 downto 0);
    signal zero_vector: std_logic_vector(27 downto 0) := (others => '0');
begin

    zero_vector <= (others => '0');
    -- logic aux 
    aux <= (others => '-') when T(27 downto 27) = '-' else
           x"1c" when T(27 downto 0) = zero_vector(27 downto 0) else
           x"1b" when T(27 downto 1) = zero_vector(27 downto 1) else
           x"1a" when T(27 downto 2) = zero_vector(27 downto 2) else
           x"19" when T(27 downto 3) = zero_vector(27 downto 3) else
           x"18" when T(27 downto 4) = zero_vector(27 downto 4) else
           x"17" when T(27 downto 5) = zero_vector(27 downto 5) else
           x"16" when T(27 downto 6) = zero_vector(27 downto 6) else
           x"15" when T(27 downto 7) = zero_vector(27 downto 7) else
           x"14" when T(27 downto 8) = zero_vector(27 downto 8) else
           x"13" when T(27 downto 9) = zero_vector(27 downto 9) else
           x"12" when T(27 downto 10) = zero_vector(27 downto 10) else
           x"11" when T(27 downto 11) = zero_vector(27 downto 11) else
           x"10" when T(27 downto 12) = zero_vector(27 downto 12) else
           x"0f" when T(27 downto 13) = zero_vector(27 downto 13) else
           x"0e" when T(27 downto 14) = zero_vector(27 downto 14) else
           x"0d" when T(27 downto 15) = zero_vector(27 downto 15) else
           x"0c" when T(27 downto 16) = zero_vector(27 downto 16) else
           x"0b" when T(27 downto 17) = zero_vector(27 downto 17) else
           x"0a" when T(27 downto 18) = zero_vector(27 downto 18) else
           x"09" when T(27 downto 19) = zero_vector(27 downto 19) else
           x"08" when T(27 downto 20) = zero_vector(27 downto 20) else
           x"07" when T(27 downto 21) = zero_vector(27 downto 21) else
           x"06" when T(27 downto 22) = zero_vector(27 downto 22) else
           x"05" when T(27 downto 23) = zero_vector(27 downto 23) else
           x"04" when T(27 downto 24) = zero_vector(27 downto 24) else
           x"03" when T(27 downto 25) = zero_vector(27 downto 25) else
           x"02" when T(27 downto 26) = zero_vector(27 downto 26) else
           x"01" when T(27 downto 27) = zero_vector(27 downto 27) else
           x"00";
           
    -- Output        
    Zcount <= aux(4 downto 0);

end behavioral;