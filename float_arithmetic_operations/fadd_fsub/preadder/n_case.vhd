library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity n_case is
    generic(WIDTH: integer:= 32);
    port ( 
        NumberA : in std_logic_vector(WIDTH - 1 downto 0);
        NumberB : in std_logic_vector(WIDTH - 1 downto 0);
        enable  : out std_logic;
        S       : out std_logic_vector(WIDTH - 1 downto 0)
    );  
 end entity;

architecture behavioral of n_case is

    signal EA, EB, ES : std_logic_vector(7 downto 0);
    signal MA, MB, MS : std_logic_vector(22 downto 0);
    signal SA, SB, SS : std_logic;

    signal outA, outB: std_logic_vector(2 downto 0);
begin

    -- Number A
    SA <= NumberA(31);
    EA <= NumberA(30 downto 23);
    MA <= NumberA(22 downto 0);

    -- Number B
    SB <= NumberB(31);
    EB <= NumberB(30 downto 23);
    MB <= NumberB(22 downto 0);

    outA <= "000" when EA = x"00" and MA = std_logic_vector(to_unsigned(0,23)) else  -- Zero
            "001" when EA = x"00" and MA > std_logic_vector(to_unsigned(0,23)) else  -- Subnormal
            "011" when (EA > x"00" and EA < x"ff") and MA > std_logic_vector(to_unsigned(0,23)) else  -- Normal
            "100" when EA = x"ff" and MA = std_logic_vector(to_unsigned(0,23)) else  --Infinity
            "101" when EA = x"ff" and MA > std_logic_vector(to_unsigned(0,23)) else  -- NaN
            "000";

    outB <= "000" when EB = x"00" and MB = std_logic_vector(to_unsigned(0,23)) else  -- Zero
            "001" when EB = x"00" and MB > std_logic_vector(to_unsigned(0,23)) else  -- Subnormal
            "011" when (EB > x"00" and EB < x"ff") and MB > std_logic_vector(to_unsigned(0,23)) else  -- Normal
            "100" when EB = x"ff" and MB = std_logic_vector(to_unsigned(0,23)) else  -- Infinity
            "101" when EB = x"ff" and MB > std_logic_vector(to_unsigned(0,23)) else  -- NaN
            "000";

    process(SA, SB, outA, outB, EA, EB, MA, MB)
    begin
    
        SS <= '-';
        MS <= (others => '-');
        ES <= (others => '-');
        ------------------------
        --        ZERO
        ------------------------
        if outA = "000" then
            SS <= SB;
            ES <= EB;
            MS <= MB;
        elsif outA = "000" then
            SS <= SA;
            ES <= EA;
            MS <= MA;    
        end if;    

        ------------------------
        --        INFINITY
        ------------------------
        if outA(0) = '1' and outB = "100" then
            SS <= SB;
            ES <= EB;
            MS <= MB;
        elsif outB(0) = '1' and outA = "100" then
            SS <= SA;
            ES <= EA;
            MS <= MA;
        end if;      
        
        if (outA and outB) = "100" and SA = SB then
            SS <= SA;
            ES <= EA;
            MS <= MA;
        elsif (outA and outB) = "100" and SA /= SB then
            SS <= '1';
            ES <= x"ff";
            MS <= "00000000000000000000001";
        end if;

        if outA = "110" or outB = "110" then
            SS <= '1';
            ES <= x"ff";
            MS <= "00000000000000000000001";
        end if;

        if (outA(0) and outB(0)) = '1' then
            SS <= '-';
            ES <= (others => '-');
            MS <= (others => '-');    
        end if;    
    end process;

    -- OUtput signals
    enable <= '1' when (outA(0) and outB(0)) = '1' else 
              '0';
    S <= SS & ES & MS;          
end behavioral;