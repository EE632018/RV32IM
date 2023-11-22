library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_ns is
    port ( 
        NorA    : in std_logic_vector(36 downto 0);
        NorB    : in std_logic_vector(36 downto 0);
        MixA    : in std_logic_vector(36 downto 0);
        MixB    : in std_logic_vector(36 downto 0);
        e_data  : in std_logic_vector(1 downto 0);
        NA      : out std_logic_vector(36 downto 0);
        NB      : out std_logic_vector(36 downto 0)
    );  
end entity;

architecture behavioral of mux_ns is

begin

    process(e_data, NorA, NorB, MixA, MixB)
    begin
        case e_data is
            when "01" =>
                NA <= NorA;
                NB <= NorB;
            when "10" =>
                NA <= MixA;
                NB <= MixB;
            when others =>
                NA <= (others => '-');
                NB <= (others => '-');
        end case;
    end process;
end behavioral;