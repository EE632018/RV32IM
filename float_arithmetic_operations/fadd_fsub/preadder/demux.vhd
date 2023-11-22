library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demux is
    port ( 
        NumberA  : in std_logic_vector(36 downto 0);
        NumberB  : in std_logic_vector(36 downto 0);
        e_data   : in std_logic_vector(1 downto 0);
        NA0      : out std_logic_vector(36 downto 0);
        NB0      : out std_logic_vector(36 downto 0);
        NA1      : out std_logic_vector(36 downto 0);
        NB1      : out std_logic_vector(36 downto 0);
        NA2      : out std_logic_vector(36 downto 0);
        NB2      : out std_logic_vector(36 downto 0)
    );  
end entity;

architecture behavioral of demux is

begin

    process(NumberA, NumberB, e_data)
    begin
        case e_data is
            when "00"   =>
                NA0 <= NumberA;
                NB0 <= NumberB;
                NA1 <= (others => '-');
                NB1 <= (others => '-'); 
                NA2 <= (others => '-');
                NB2 <= (others => '-');
            when "01"   => 
                NA1 <= NumberA;
                NB1 <= NumberB;
                NA0 <= (others => '-');
                NB0 <= (others => '-'); 
                NA2 <= (others => '-');
                NB2 <= (others => '-');
            when "10"   =>
                NA2 <= NumberA;
                NB2 <= NumberB;
                NA1 <= (others => '-');
                NB1 <= (others => '-'); 
                NA0 <= (others => '-');
                NB0 <= (others => '-');
            when others =>
                NA0 <= (others => '-');
                NB0 <= (others => '-');
                NA1 <= (others => '-');
                NB1 <= (others => '-'); 
                NA2 <= (others => '-');
                NB2 <= (others => '-');
        end case;
    end process;

end behavioral;