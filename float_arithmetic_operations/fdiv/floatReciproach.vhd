----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/28/2023 10:45:31 AM
-- Design Name: 
-- Module Name: floatReciproach - Behavioral
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

entity floatReciproach is
    Port ( b_in : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           start : in STD_LOGIC;
           stall_o : out std_logic;
           r_out : out STD_LOGIC_VECTOR (31 downto 0));
end floatReciproach;

architecture Behavioral of floatReciproach is
    component floatM
        Port ( a_in : in std_logic_vector(31 downto 0);
               b_in : in std_logic_vector(31 downto 0);
               c_out : out std_logic_vector(31 downto 0));
    end component;
    
    component FPU
    Port (clk:   in std_logic;
          rst:   in std_logic;
          start: in std_logic;
          X:     in std_logic_vector(31 downto 0);
          Y:     in std_logic_vector(31 downto 0);
          R:     out std_logic_vector(31 downto 0);
          done:  out std_logic
        );
    end component;
    
    signal x_reg, x_next : std_logic_vector(31 downto 0);
    signal mul1_out, mul1_out_s, sub_out: std_logic_vector(31 downto 0);
    signal num2: std_logic_vector(31 downto 0) := x"40000000";
    
    type state is (IDLE, RESET, CAL, CAL_SUB);
    signal state_r, state_next : state;
    
    signal en_s, reset_s, done_s, start_s, done_sub: std_logic;
    signal cnt : std_logic_vector(7 downto 0);
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
    
    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1' or reset_s = '1') then
                cnt <= (others => '0');
            else
                if en_s = '1' then 
                    cnt <= std_logic_vector(unsigned(cnt) + TO_UNSIGNED(1, 8));
                end if;
            end if;
        end if;
    end process;
    
    process(cnt)
    begin
        if(unsigned(cnt) = TO_UNSIGNED(32,8)) then
            done_s <= '1';
        else
            done_s <= '0';    
        end if;
    end process;
    
    process(state_r, start, done_s, done_sub)
    begin

        start_s <= '0';
        case state_r is
            when IDLE =>
                stall_o <= '1';
                en_s <= '0';
                reset_s <= '0';
                if start = '1' then
                    state_next <= RESET;
                else
                    state_next <= IDLE;
                end if;
            when RESET =>
                en_s <= '0';
                stall_o <= '0';
                reset_s <= '1';
                state_next <= CAL;
            when CAL =>
                stall_o <= '0';
                en_s <= '0';
                reset_s <= '0';
                start_s <= '1';
                if done_s = '1' then
                    state_next <= IDLE;
                else
                    state_next <= CAL_SUB;
                end if;
            when CAL_SUB => 
                en_s <= '0';
                stall_o <= '0';
                reset_s <= '0';

                if done_sub = '1' then
                    state_next <= CAL;
                    en_s       <= '1';
                else
                    state_next <= CAL_SUB;
                end if;            
            when others =>
                en_s <= '0';
                stall_o <= '1';
                reset_s <= '0';
                state_next <= IDLE;
       end case;
    end process;
    
    process(clk)
    begin
        if(rising_edge(clk))then
            if (rst = '1' or reset_s = '1')  then
                x_reg <= x"3f800000";
            else
                if en_s = '1' then
                    x_reg <= x_next;
                end if;
            end if;
        end if;
    end process;

    mul1: floatM
    port map(a_in => x_reg, b_in => b_in, c_out => mul1_out);
    
    mul1_out_s <= ('1' xor mul1_out(31)) & mul1_out(30 downto 0);
    
    sub1_i:FPU
    port map(clk => clk, rst => rst, start => start_s, X => num2, Y => mul1_out_s, R => sub_out, done => done_sub);
    
    mul2: floatM
    port map(a_in => x_reg, b_in => sub_out, c_out => x_next);
    
    r_out <= x_reg;
end Behavioral;
