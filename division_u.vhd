----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/30/2023 02:15:24 PM
-- Design Name: 
-- Module Name: division_u - Behavioral
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

entity division_u is
Port (clk           : in std_logic;
      reset         : in std_logic;
      start_i       : in std_logic;
      dividend_i    : in std_logic_vector(31 downto 0);
      divisor_i     : in std_logic_vector(31 downto 0);
      quotient_o    : out std_logic_vector(31 downto 0);
      remainder_o   : out std_logic_vector(31 downto 0);
      stall_o       : out std_logic);
end division_u;

architecture Behavioral of division_u is

    type fsm_state is (start,work,work2,done);
    signal state,state_next: fsm_state;
    
    signal dividend_s, divisor_s, remainder_s               : signed(63 downto 0);
    signal remainder_next, divisor_next, dividend_next      : signed(63 downto 0);
    signal quotient_next, quotient_s                        : signed(31 downto 0);
    signal cnt_clk, cnt_next                                : signed(6 downto 0);

begin

    -- Input on registers
   
    process(clk,reset)
    begin
        if reset = '1' then
            state       <= start;
            dividend_s  <= (others => '0');
            divisor_s   <= (others => '0');
            quotient_s  <= (others => '0');
            remainder_s <= (others => '0');
            cnt_clk     <= (others => '0');
        elsif rising_edge(clk) then
            state       <= state_next;  
            dividend_s  <= signed(dividend_next);
            divisor_s   <= signed(divisor_next);
            quotient_s  <= signed(quotient_next);
            remainder_s <= signed(remainder_next);
            cnt_clk     <= cnt_next;  
        end if;
    end process;

    process(state,start_i,cnt_clk,remainder_next,quotient_s,divisor_s,remainder_s,dividend_s)
    begin
        -- default values
        state_next      <= state;
        dividend_next   <= dividend_s;
        divisor_next    <= divisor_s;
        quotient_next   <= quotient_s;
        remainder_next  <= remainder_s;
        cnt_next        <= cnt_clk;
        stall_o         <= '0';
        
        
        case state is
            when start => 
                if start_i = '1' then
                    state_next <= work;
                else
                    state_next <= start;
                end if;
                cnt_next        <= (others => '0');
                quotient_next   <= (others => '0');
                if dividend_i(31) = '1' then
                    dividend_next <= not(signed(dividend_i)) + 1 & x"00000000";
                    remainder_next  <= x"00000000" & not(signed(dividend_i)) + 1; 
                else
                    dividend_next <= signed(dividend_i) & x"00000000";
                    remainder_next  <= x"00000000" & signed(dividend_i); 
                end if;  
                if divisor_i(31) = '1' then
                    divisor_next <= not(signed(divisor_i)) + 1 & x"00000000";
                else    
                    divisor_next <= signed(divisor_i) & x"00000000";
                end if;                
           when work =>
                if cnt_clk = 33 then
                    state_next <= done;
                else
                    state_next <= work2;
                    cnt_next <= cnt_clk + 1;
                    remainder_next <= remainder_s - divisor_s;  
--                    if remainder_next >= 0 then
--                       --quotient_next <= shift_left(quotient_s,1);
--                       quotient_next <= quotient_s(30 downto 0) & '1'; 
--                       divisor_next  <= '0' & divisor_s(63 downto 1);
--                    else
--                       --divisor_next  <= shift_right(divisor_s,1);
--                       divisor_next  <= '0' & divisor_s(63 downto 1);
--                       quotient_next <= quotient_s(30 downto 0) & '0';
--                       remainder_next <= remainder_s + divisor_s;                       
--                    end if;  
                end if;
           when work2 =>
                state_next <= work;
                if remainder_s >= 0 then
                   --quotient_next <= shift_left(quotient_s,1);
                   quotient_next <= quotient_s(30 downto 0) & '1'; 
                   divisor_next  <= '0' & divisor_s(63 downto 1);
                else
                   --divisor_next  <= shift_right(divisor_s,1);
                   divisor_next  <= '0' & divisor_s(63 downto 1);
                   quotient_next <= quotient_s(30 downto 0) & '0';
                   remainder_next <= remainder_s + divisor_s;                       
                end if;                 
           when done => 
                state_next <= start;
                stall_o <= '1';
           when others =>   
                state_next <= state;           
        end case;
    end process;

    process(remainder_s,quotient_s,dividend_i,divisor_i)
    begin
        if (dividend_i(31) xor divisor_i(31)) = '0' then
            quotient_o  <= std_logic_vector(quotient_s);
        else
            quotient_o  <= std_logic_vector(not(quotient_s) + to_signed(1,32));    
        end if;
        
        if dividend_i(31) = '0' then
            remainder_o <= std_logic_vector(remainder_s(31 downto 0));
        else
            remainder_o <= std_logic_vector(not(remainder_s(31 downto 0)) + to_signed(1,32));        
        end if;    
    end process;

end Behavioral;
