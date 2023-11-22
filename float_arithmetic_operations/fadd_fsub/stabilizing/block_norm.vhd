library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity block_norm is
    port ( 
        MS: in std_logic_vector(27 downto 0);
        ES: in std_logic_vector(7 downto 0);
        Co: in std_logic;
        E: out std_logic_vector(7 downto 0);
        M: out std_logic_vector(22 downto 0)
    );  
end entity;

architecture behavioral of block_norm is
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

    component round
    port ( 
        Min: in std_logic_vector(27 downto 0);
        Mout: out std_logic_vector(22 downto 0)
    );
    end component;

    signal Zcount_aux, shift_s: std_logic_vector(4 downto 0);
    signal Number: std_logic_vector(27 downto 0);
begin
    

    zero0: zero
    generic map(WIDTH => 28)
    port map (T => MS, Zcount => Zcount_aux);

    shift0: shift
    generic map(WIDTH => 28)
    port map (T => MS, shift => shift_s, S => Number);

    round0: round
    port map (Min => Number, Mout => M);

    process(MS,ES,Zcount_aux, shift_s, Co)
    begin
        E <= (others => '-');
        shift_s <= (others => '-');
        if ES > Zcount_aux then
            shift_s <= Zcount_aux;
            E <= std_logic_vector(unsigned(ES) - unsigned(shift_s));
        elsif ES < Zcount_aux then
            shift_s <= ES(4 downto 0);
            E <= x"00";
        elsif ES = Zcount_aux then
            shift_s <= Zcount_aux;
            E <= x"01";    
        end if;    
    end process;

end behavioral;