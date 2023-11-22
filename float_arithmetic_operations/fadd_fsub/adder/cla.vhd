library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cla is
    port ( 
        A: in std_logic;
        B: in std_logic;
        Cin: in std_logic;
        Cout: out std_logic;
        S: out std_logic
    );  
end entity;

architecture behavioral of cla is
    signal c_g,c_p: std_logic;
begin
    c_g <= A and B;
    c_p <= A xor B;
    Cout <= c_g or (c_p and Cin);
    S <= c_p xor Cin;
end behavioral;