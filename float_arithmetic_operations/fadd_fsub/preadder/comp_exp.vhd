library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comp_exp is
    generic(WIDTH: integer:= 37);
    port ( 
        NumberA : in std_logic_vector(WIDTH - 1 downto 0);
        NumberB : in std_logic_vector(WIDTH - 1 downto 0);
        SA      : out std_logic;
        SB      : out std_logic;
        Emax    : out std_logic_vecotr(7 downto 0);
        Mmax    : out std_logic_vecotr(27 downto 0);
        Mshft   : out std_logic_vecotr(27 downto 0);
        Dexp    : out std_logic_vecotr(4 downto 0);
        Comp    : out std_logic
    );  
 end entity;

architecture behavioral of comp_exp is
    signal EA, EB,dif : std_logic_vector(7 downto 0);
    signal MA, MB : std_logic_vector(27 downto 0);
    signal C : std_logic;
begin

    SA <= NumberA(36);
    SB <= NumberB(36);

    EA <= NumberA(35 downto 28);
    EB <= NumberB(35 downto 28);
    MA <= NumberA(27 downto 0);
    MB <= NumberB(27 downto 0);

    -- C value
    C <= '1' when EA > EB or MB(0) = '1' else
         '0' when EA < EB else
         '1' when MA >= MB else
         '0' when MA < MB else
         '-';
    
    Comp <= C;
    Emax <= EA when C = '1' else    
            EB;
    Mmax <= MA when C = '1' else    
            MB;
    Mshft <= MB when C = '1' else    
             MA;  

    dif <= std_logic_vector(unsigned(EA) - unsigned(EB)) when C = '1' and MB(0) = '0' else
           std_logic_vector(unsigned(EB) - unsigned(EA)) when C = '0' else
           std_logic_vector(unsigned(EA) + unsigned(EB)) when C = '1' and MB(0) = '1' else
           (others => '-');        
    process(dif)
    begin
        if dif <= x"1b" then
            Dexp <= dif(4 downto 0);
        elsif dif > x"1b" then
            Dexp <= "11100"
        else
            Dexp <= (others => '-');
        end if;
    end process;    
end behavioral;