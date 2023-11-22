library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signout is
    port ( 
        SA: in std_logic;
        SB: in std_logic;
        A_S: in std_logic;
        A: in std_logic_vector(27 downto 0);
        B: in std_logic_vector(27 downto 0);
        Comp: in std_logic;
        Aa: out std_logic_vector(27 downto 0);
        Bb: out std_logic_vector(27 downto 0);
        AS: out std_logic;
        SO: out std_logic
    );  
end entity;

architecture behavioral of signout is
    signal SB_aux: std_logic;
begin

    SB_aux <= SB xor A_S;
    SO <= SA when Comp = '1' else
          SB_aux when Comp = '0' else
          '-';
    
    process(SA, SB_aux, A, B)
    begin
        if (SA xor SB_aux) = '0' then
            Aa <= A;
            Bb <= B;
        elsif SA = '1' and SB_aux = '0' then 
            Aa <= B;
            Bb <= A;
        elsif SA = '0' and SB_aux = '1' then
            Aa <= A;
            Bb <= B;
        else
            Aa <= (others => '-');
            Bb <= (others => '-');
        end if;
    end process;    

    AS <= '1' when SA /= SB_aux else
          '0';
end behavioral;