----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/01/2023 12:01:20 PM
-- Design Name: 
-- Module Name: fixedDiv - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fixedDiv is
    Port ( a_in : in STD_LOGIC_VECTOR (23 downto 0);
           b_in : in STD_LOGIC_VECTOR (23 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           r_out : out STD_LOGIC_VECTOR (47 downto 0);
           stall : out STD_LOGIC;
           start : in STD_LOGIC);
end fixedDiv;

architecture Behavioral of fixedDiv is
    type state is (INIT, CAL, SHIFT);
    signal state_r, state_next : state;
    
    signal cnt: std_logic_vector(7 downto 0);
    signal en_s: std_logic;
    
    signal q,r, r_r : std_logic_vector(23 downto 0);
    signal q_next, r_next : std_logic_vector(23 downto 0);
    signal e, e_next : std_logic;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                state_r <= INIT;
            else    
                state_r <= state_next;
            end if;
        end if;
    end process;
    
    process(state_r, start, a_in, b_in, r,cnt, q, e)
    begin
        en_s <= '0';
        stall <= '0';
        case state_r is
            when INIT =>
                r_next <= r;
                q_next <= q;
                e_next <= e;
                if start = '1' then
                    state_next <= SHIFT;
                    r_next <= (others => '0');
                    q_next <= a_in;
                    e_next <= '0';
                else
                    state_next <= INIT;
                end if;
                stall <= '1';
            when CAL =>
                q_next <= q;
                r_next <= r;
                if(unsigned(b_in) < unsigned(r)) then
                    r_next <= std_logic_vector(unsigned(r) - unsigned(b_in));
                    q_next(0)<= '1';
                    e_next <= '1';
                else
                    e_next <= '0';
                    q_next(0) <= '0';
                end if;
                
                if(unsigned(cnt) = TO_UNSIGNED(24,8)) then
                    state_next <= INIT;
                else
                    state_next <= SHIFT;
                end if;
            when SHIFT =>
                e_next <= r(23);
                en_s <= '1';
                r_next <= r(22 downto 0) & q(23);
                q_next <= q(22 downto 0) & '0';
                state_next <= CAL;
            when others =>
                r_next <= (others => '0');
                q_next <= a_in;
                e_next <= '0';
                state_next <= INIT;
        end case;
    end process;


    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                cnt <= (others => '0');
                q <= (others => '0');
                r <= (others => '0');
                e <= '0';
            else
                q <= q_next;
                r <= r_next;
                e <= e_next;
                if en_s = '1' then
                    cnt <= std_logic_vector(unsigned(cnt) + 1);
                    
                end if;    
            end if;
        end if;
    end process;
    
    process(r) 
    begin
        for i in 0 to 23 loop
        r_r(i) <= r(23 - i);
        end loop;
    end process;
    r_out <=  q  & r_r;
end Behavioral;
