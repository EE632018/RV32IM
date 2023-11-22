library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity n_subn is
    generic(WIDTH: integer:= 37);
    port ( 
        NumberA : in std_logic_vector(WIDTH - 1 downto 0);
        NumberB : in std_logic_vector(WIDTH - 1 downto 0);
        SA      : out std_logic;
        SB      : out std_logic;
        Comp    : out std_logic;
        EO      : out std_logic_vector(7 downto 0);
        MA      : out std_logic_vector(27 downto 0);
        MB      : out std_logic_vector(27 downto 0)
    );  
 end entity;

architecture behavioral of n_subn is

    signal MAa, MBb : std_logic_vector(27 downto 0);
    signal C: std_logic;
begin

    -- Output sign
    SA <= NumberA(36);
    SB <= NumberB(36);
    -- Output exponent
    EO <= NumberA(35 downto 28);
    -- Output Mantissa
    MAa <= NumberA(27 downto 0);
    MBb <= NumberB(27 downto 0);

    -- Comparator
    C <= '1' when MAa >= MBb else
         '0' when MBb > MAa else
         '-';
    Comp <= C;
    
    -- Output mantissa
    MA <= MAa when C = '1' else
          MBb when C = '0' else
          (others => '-');
    MB <= MBb when C = '1' else
          MAa when C = '0' else
          (others => '-');    

end behavioral;