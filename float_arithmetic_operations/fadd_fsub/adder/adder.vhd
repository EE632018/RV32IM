library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
    port ( 
        A: in std_logic_vector(27 downto 0);
        B: in std_logic_vector(27 downto 0);
        A_S: in std_logic;
        Cout: out std_logic;
        S: out std_logic_vector(27 downto 0)
    );  
end entity;

architecture behavioral of adder is
    component cla
    port ( 
        A: in std_logic;
        B: in std_logic;
        Cin: in std_logic;
        Cout: out std_logic;
        S: out std_logic
    );
    end component;

    signal B1,aux : std_logic_vector(27 downto 0);
begin

    Comp1: for i in 0 to 27 generate
            B1(i) <= B(i) xor A_S;
            sum0: if i = 0 generate
                    cla0: cla port map(A => A(i), B => B1(i), Cin => A_S, Cout => aux(i), S => S(i));
                  end generate;
            sum1: if i > 0 and i < 28 generate
                  clai: cla port map(A => A(i), B => B1(i), Cin => aux(i-1), Cout => aux(i), S => S(i));
                end generate;      
            end generate;
    Cout <= aux(27);        
end behavioral;