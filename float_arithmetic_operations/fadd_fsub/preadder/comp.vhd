library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comp is
    generic(WIDTH: integer:= 37);
    port ( 
        NumberA : in std_logic_vector(WIDTH - 1 downto 0);
        NumberB : in std_logic_vector(WIDTH - 1 downto 0);
        NA      : out std_logic_vector(WIDTH - 1 downto 0);
        NB      : out std_logic_vector(WIDTH - 1 downto 0)
    );  
 end entity;

architecture behavioral of comp is
    signal EA, EB : std_logic_vector(7 downto 0);
begin

    -- exponent
    EA <= NumberA(35 downto 28);
    EB <= NumberB(35 downto 28);

    process(NumberA, NumberB, EA, EB)
    begin
        if EA = x"00" then
            NA <= NumberB;
            NB <= NumberA;
        elsif EB = x"00" then
            NA <= NumberA;
            NB <= NumberB;
        else
            NA <= (others => '-');
            NB <= (others => '-');    
        end if;    
    end process;
    
end behavioral;