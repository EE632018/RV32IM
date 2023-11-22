library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity selector is
    port ( 
        NumberA : in std_logic_vector(31 downto 0);
        NumberB : in std_logic_vector(31 downto 0);
        enable  : in std_logic;
        e_data  : out std_logic_vector(1 downto 0);
        NA      : out std_logic_vector(36 downto 0);
        NB      : out std_logic_vector(36 downto 0)
    );  
end entity;

architecture behavioral of selector is

    signal EA, EB : std_logic_vector(7 downto 0);
    signal MA, MB : std_logic_vector(22 downto 0);
    signal SA, SB : std_logic;
begin

    -- Number A
    SA <= NumberA(31);
    EA <= NumberA(30 downto 23);
    MA <= NumberA(22 downto 0);

    -- Number B
    SB <= NumberB(31);
    EB <= NumberB(30 downto 23);
    MB <= NumberB(22 downto 0);

    process(SA, SB, EA, EB, MA, MB, enable)
    begin
        if enable = '1' then
            NA(36)<= SA;
            NB(36)<= SB;
            NA(35 downto 28) <= EA;
            NB(35 downto 28) <= EB;
            if EA > x"00" then
                NA(27) <= '1';
                NA(26 downto 4) <= MA;
                NA(3 downto 0)  <= x"0";
            elsif EA = x"00" then
                NA(27) <= '0';
                NA(26 downto 4) <= MA;
                NA(3 downto 0)  <= x"0";
            else
                NA <= (others => '-');
            end if;

            if EB > x"00" then
                NB(27) <= '1';
                NB(26 downto 4) <= MB;
                NB(3 downto 0)  <= x"0";
            elsif EB = x"00" then
                NB(27) <= '0';
                NB(26 downto 4) <= MB;
                NB(3 downto 0)  <= x"0";
            else
                NB <= (others => '-');
            end if;
        else
            NA <= (others => '-');
            NB <= (others => '-');
        end if;
    end process;

    e_data <= "00" when EA = x"00" and EB = x"00" and enable = '1' else
              "01" when EA > x"00" and EB > x"00" and enable = '1' else
              "10" when (EA = x"00" or EB = x"00") and enable = '1' else  
              "--";
              
end behavioral;