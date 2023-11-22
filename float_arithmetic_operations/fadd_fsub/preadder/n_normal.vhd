library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity n_normal is
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

architecture behavioral of n_normal is

    component comp_exp
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
    end component;

    component shift_exp
    generic(WIDTH: integer:= 28);
    port ( 
        T       : in std_logic_vector(WIDTH - 1 downto 0);
        shift   : in std_logic_vector(4 downto 0);
        S       : out std_logic_vector(WIDTH - 1 downto 0)
    );
    end component;

    signal Mshft_aux: std_logic_vecotr(27 downto 0);
    signal Dexp_aux: std_logic_vecotr(4 downto 0);
begin
    
    comp1: comp_exp
    generic map(WIDTH => 37)
    port map(NumberA => NumberA,
             NumberB => NumberB,
             SA      => SA,
             SB      => SB,
             Emax    => EO,
             Mmax    => MA, 
             Mshft   => Mshft_aux,
             Dexp    => Dexp_aux,
             Comp    => Comp);
    comp2: shift_exp 
    generic map (WIDTH => 28)
    port map(T      => Mshft_aux,
             shift  => Dexp_aux,
             S      => MB);        
end behavioral;    