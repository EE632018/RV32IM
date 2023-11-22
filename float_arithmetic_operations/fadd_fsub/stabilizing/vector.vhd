library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vector is
    port ( 
        M: in std_logic_vector(22 downto 0);
        E: in std_logic_vector(7 downto 0);
        S: in std_logic;
        N: out std_logic_vector(31 downto 0)
    );  
end entity;

architecture behavioral of vector is

begin

    N <= S & E & M;
end behavioral;