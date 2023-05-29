----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/29/2023 05:42:44 PM
-- Design Name: 
-- Module Name: mul_new - Behavioral
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

entity multiply_u is
Port (clk   : in std_logic;
      reset : in std_logic;
      a_in  : in std_logic_vector(31 downto 0);
      b_in  : in std_logic_vector(31 downto 0);
      c_out  : out std_logic_vector(63 downto 0);
      stall_status: out std_logic;
      start_status: in std_logic
     );
end multiply_u;

architecture Behavioral of multiply_u is

    attribute use_dsp: string;
    attribute use_dsp of Behavioral: architecture is "yes";
    
    signal a_up,a_down,b_up,b_down: unsigned(15 downto 0);
    signal res1,res2,res3,res4: unsigned(31 downto 0);
    signal res5: unsigned(31 downto 0);
    signal res6: unsigned(47 downto 0);
    signal res7: unsigned(47 downto 0);
    
    
    signal reg1,reg2,reg3,reg4,reg5,reg1_1: unsigned(31 downto 0);
    signal reg6,reg7: unsigned(47 downto 0);
    
    type fsm_state is (start,work,done);
    signal state,state_next: fsm_state; 
begin

    process(clk,reset)
    begin
        if reset = '1' then
            state <= start;
        elsif rising_edge(clk) then
            state <= state_next;
        end if;    
    end process;


    process(state, start_status)
    begin
        state_next <= state;
        stall_status <= '0';
        case state is
            when start =>
                if start_status = '1' then
                    state_next <= work;
                else 
                    state_next <= start;    
                end if;
            when work => state_next <= done;
            when done => 
                state_next <= start;
                stall_status <= '1'; 
            when others => state_next <= state;      
        end case;
    
    end process;

    a_up <= unsigned(a_in(31 downto 16));
    a_down <= unsigned(a_in(15 downto 0));
    b_up <= unsigned(b_in(31 downto 16));
    b_down <= unsigned(b_in(15 downto 0));
    
    res4 <= a_up * b_up;
    res3 <= b_up * a_down;
    res2 <= b_down * a_up;
    res1 <= a_down * b_down;
    
    
    res5 <= reg2 + (x"0000" & reg1(31 downto 16));
    res6 <= (reg4 & x"0000") + (x"0000" & reg3);

    res7 <= reg6 + reg5;

    process(clk,reset)
    begin
        if reset = '1' then
            reg1 <= (others => '0');
            reg2 <= (others => '0');
            reg3 <= (others => '0');
            reg4 <= (others => '0');
            reg6 <= (others => '0');
            reg5 <= (others => '0');
            reg1_1 <= (others => '0');
        elsif rising_edge(clk) then
            -- Stage 1
            reg1 <= res1;
            reg2 <= res2;
            reg3 <= res3;
            reg4 <= res4;
            --Stage 2
            reg5 <= res5;
            reg6 <= res6;
            reg1_1 <= reg1;
            
        end if;
    end process;
    
    c_out <= std_logic_vector(res7 & reg1_1(15 downto 0));
end Behavioral;

