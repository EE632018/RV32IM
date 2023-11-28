----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/28/2023 02:29:26 PM
-- Design Name: 
-- Module Name: Ilog - Behavioral
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

entity Ilog is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           start : in std_logic;
           a_in : in STD_LOGIC_VECTOR (31 downto 0);
           c_out : out STD_LOGIC_VECTOR (31 downto 0);
           stall_o : out STD_LOGIC);
end Ilog;

architecture Behavioral of Ilog is
    signal m_reg: std_logic_vector(31 downto 0);
    signal p_reg, p_next: std_logic_vector(63 downto 0);
    
    signal comp_s: std_logic;
    signal en_s: std_logic;
    signal reset_s : std_logic;
    
    type state is (IDLE, RESET, CAL);
    signal state_r, state_next : state;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state_r <= IDLE;
            else
                state_r <= state_next;
            end if;        
        end if;
    end process;
    
    process(state_r, comp_s, start)
    begin
        case state_r is
            when IDLE =>
                en_s <= '0';
                reset_s <= '0';
                stall_o <= '0';
                if start = '1' then
                    state_next <= RESET;
                else
                    state_next <= IDLE;
                end if;
            when RESET =>
                en_s <= '0';
                reset_s <= '1';
                stall_o <= '1';
                state_next <= CAL;
            when CAL =>
                en_s <= '1';
                reset_s <= '0';
                stall_o <= '1';
                if comp_s = '1' then
                    state_next <= CAl;
                else
                    state_next <= IDLE;
                end if;
            when others =>
                en_s <= '0';
                reset_s <= '0';
                stall_o <= '0';
                state_next <= IDLE;
        end case;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1' or reset_s = '1') then
                m_reg <= (others => '0');
                p_reg <= std_logic_vector(TO_UNSIGNED(1,64));
            else
                if en_s = '1' then
                    m_reg <= std_logic_vector(UNSIGNED(m_reg) + 1);
                    p_reg <= p_next;
                end if;
            end if;            
        end if;
    end process;
    
    process(p_reg)
    begin
        p_next <= std_logic_vector(UNSIGNED(p_reg(31 downto 0)) * 2);
    end process;
    
    process(a_in, p_next)
    begin
        if (unsigned(a_in) > unsigned(p_next)) then
            comp_s <= '1';
        else
            comp_s <= '0';
        end if;
    end process; 
    
    c_out <= m_reg;

end Behavioral;
