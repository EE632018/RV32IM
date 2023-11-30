library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb is
--  Port ( );
end tb;

architecture Behavioral of tb is

component FPU is
  Port (clk:   in std_logic;
        rst:   in std_logic;
        start: in std_logic;
        X:     in std_logic_vector(31 downto 0);
        Y:     in std_logic_vector(31 downto 0);
        R:     out std_logic_vector(31 downto 0);
        done:  out std_logic
        );
end component;

signal clk, rst, start, done : std_logic := '0';
signal X, Y, R: std_logic_vector(31 downto 0);

constant period : time := 20 ns;
shared variable end_sim: boolean := false;

begin

    UUT: FPU port map(clk => clk, rst => rst, start => start, X => X, Y => Y, R => R, done => done);
    
    clk_generator: process
    begin
        if not end_sim then
            clk <= '0';
            wait for period / 2;
            clk <= '1';
            wait for period / 2;
        else wait;
        end if;
    end process clk_generator;
    
    
    stimulus: process
    begin
        -- X = 2.25 = 40100000 (H)
        -- Y = 134.0625 = 43061000(H)
        -- R = 136.3125 = 4308500 (H)
        -- OBS: no normalization
        start <= '0';
        wait for 10 * period;
        X <= x"40100000";
        Y <= x"43061000";
        start <= '1';
        wait for 200 ns;

        -- X = 14.3 = 4164CCCD (H)
        -- Y = 2.5 = 40200000(H)
        -- R = 16.8 = 41866666 (H)
        -- OBS: normalized
        start <= '0';
        wait for 10 * period;
        X <= x"4164CCCD";
        Y <= x"40200000";
        start <= '1';
        wait for 200 ns;
        
        -- X = -4.5= C0900000 (H)
        -- Y = 132.7 = 4304B333 (H)
        -- R = 128.2 = 43003333 (H)
        start <= '0';
        wait for 10 * period;
        X <= x"C0900000";
        Y <= x"4304B333";
        start <= '1';
        wait for 200 ns;
        
        -- X = +23.75= 41BE0000 (H)
        -- Y = -108.25 = C2D88000 (H)
        -- R = -84.5 = C2A90000(H)
        start <= '0';
        wait for 10 * period;
        X <= x"41BE0000";
        Y <= x"C2D88000";
        start <= '1';
        wait for 200 ns;
        
        -- X = -128.2 = C3003333 (H)
        -- Y = -3.5 = C0600000 (H)
        -- R = -131.7 = C303B333  (H)
        start <= '0';
        wait for 10 * period;
        X <= x"C3003333";
        Y <= x"C0600000";
        start <= '1';
        wait for 200 ns;
        
        wait for 200 ns;
        end_sim := true;
        wait;
    end process;
    
end Behavioral;
