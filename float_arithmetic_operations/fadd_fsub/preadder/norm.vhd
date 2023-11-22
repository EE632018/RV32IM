library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity norm is
    generic(WIDTH: integer:= 37);
    port ( 
        NumberA : in std_logic_vector(WIDTH - 1 downto 0);
        NumberB : in std_logic_vector(WIDTH - 1 downto 0);
        MA      : out std_logic_vector(WIDTH - 1 downto 0);
        MB      : out std_logic_vector(WIDTH - 1 downto 0)
    );  
 end entity;

architecture behavioral of norm is

    -- component instations
    component comp
    generic(WIDTH: integer:= 36);
    port ( 
        NumberA : in std_logic_vector(WIDTH - 1 downto 0);
        NumberB : in std_logic_vector(WIDTH - 1 downto 0);
        NA      : out std_logic_vector(WIDTH - 1 downto 0);
        NB      : out std_logic_vector(WIDTH - 1 downto 0)
    ); 
    end component;

    component zero
    generic(WIDTH: integer:= 28);
    port ( 
        T       : in std_logic_vector(WIDTH - 1 downto 0);
        Zcount  : out std_logic_vector(4 downto 0)
    );
    end component;

    component shift
    generic(WIDTH: integer:= 28);
    port ( 
        T       : in std_logic_vector(WIDTH - 1 downto 0);
        shift   : in std_logic_vector(4 downto 0);
        S       : out std_logic_vector(WIDTH - 1 downto 0)
    );  
    end component;

    signal NumberB_aux : std_logic_vector(WIDTH - 1 downto 0);
    signal Zcount_aux: std_logic_vector(4 downto 0);
    signal EB       : std_logic_vector(7 downto 0);
    signal MB_aux   : std_logic_vector(27 downto 0);
begin

    comp1: comp 
    generic map(WIDTH => 37)
    port map (NumberA => NumberA,
              NumberB => NumberB,
              NA      => MA,
              NB      => NumberB_aux);
    
    comp2: zero
    generic map(WIDTH => 28)
    port map (T => NumberB_aux(27 downto 0),
              Zcount => Zcount_aux
            );

    comp3: shift
    generic map(WIDTH => 28)
    port map (T => NumberB_aux(27 downto 0),
              shift => Zcount_aux,
              S => MB_aux
            );   
    
    -- exponent part for B value
    process(Zcount_aux, NumberB_aux, EB, MB_aux)   
    begin
        MB(36)           <= NumberB_aux(36);
        MB(35 downto 28) <= EB;

        if Zcount_aux /= "-----" then
            EB <= "000" & Zcount_aux;
            MB (27 downto 0) <= MB_aux(27 downto 1) & '1';
        else
            EB <= (others => '-');
            MB(27 downto 0) <= MB_aux;
        end if;
    end process;    

end behavioral;