library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2on1 is
    port ( 
        A       : in std_logic;
        B       : in std_logic;
        Sel     : in std_logic;
        Z       : out std_logic
    );  
 end entity;

architecture behavioral of mux2on1 is

begin
    Z <= A when Sel = '0' else
         B;
end behavioral;