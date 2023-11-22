library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity block_adder is
    port (
        SA: in std_logic;
        SB: in std_logic;
        A_S: in std_logic; 
        A: in std_logic_vector(27 downto 0);
        B: in std_logic_vector(27 downto 0);
        Comp: in std_logic;
        CO: out std_logic;
        SO: out std_logic;
        S: out std_logic_vector(27 downto 0)
    );  
end entity;

architecture behavioral of block_adder is
    component signout
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
    end component;

    component adder
    port ( 
        A: in std_logic_vector(27 downto 0);
        B: in std_logic_vector(27 downto 0);
        A_S: in std_logic;
        Cout: out std_logic;
        S: out std_logic_vector(27 downto 0)
    );
    end component;

    signal S_aux, S2 : std_logic_vector(27 downto 0); 
    signal CO_s, SO_aux, AS_aux: std_logic;
    signal AA_aux, Bb_aux: std_logic_vector(27 downto 0); 
begin


    Sign1: signout
    port map( 
        SA => SA,
        SB => SB,
        A_S => A_S,
        A => A,
        B => B,
        Comp => Comp,
        Aa => Aa_aux,
        Bb => Bb_aux,
        AS => AS_aux,
        SO => SO_aux
    );

    add1: adder
    port map (A => Aa_aux, B => Bb_aux, A_S => AS_aux, S => S_aux, Cout => CO_s);

    S2 <= S_aux xor x"FFFFFFF";
    S <= std_logic_vector(unsigned(S2) + to_unsigned(1,28)) when (AS_aux and SO_aux) = '1' else
        S_aux;

    SO <= SO_aux;
    CO <= '0' when (SB xor A_S) /= SA else
           CO_s;
end behavioral;