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

entity multiply is
Port (clk   : in std_logic;
      reset : in std_logic;
      con_s : in std_logic_vector(1 downto 0);
      a_in  : in std_logic_vector(31 downto 0);
      b_in  : in std_logic_vector(31 downto 0);
      c_out  : out std_logic_vector(63 downto 0);
      stall_status: out std_logic;
      start_status: in std_logic
     );
end multiply;

architecture Behavioral of multiply is

    attribute use_dsp: string;
    attribute use_dsp of Behavioral: architecture is "yes";
    
    signal a_s, b_s: std_logic_vector(31 downto 0);
    
    signal a_up,a_down,b_up,b_down: std_logic_vector(15 downto 0);
    signal res1,res2,res3,res4: std_logic_vector(31 downto 0);
    signal res5: std_logic_vector(31 downto 0);
    signal res6: std_logic_vector(47 downto 0);
    signal res7: std_logic_vector(47 downto 0);
    
    
    signal reg1,reg2,reg3,reg4,reg5,reg1_1: std_logic_vector(31 downto 0);
    signal reg6,reg7: std_logic_vector(47 downto 0);
    
    signal sign_reg, sign_next, sign2_reg, sign2_next : std_logic;
    
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


    process(con_s, a_in, b_in) 
    begin
    
        a_s <= a_in;
        b_s <= b_in;
        sign_next <= '0';
        
        case con_s is
        
            when "00" =>    --oba signed
            
                if(a_in(31) = '1') then
                    a_s <= std_logic_vector(signed(not a_in) + TO_SIGNED(1, 32));
                else
                    a_s <= a_in;
                end if;
                
                if(b_in(31) = '1') then
                    b_s <= std_logic_vector(signed(not b_in) + TO_SIGNED(1, 32));
                else
                    b_s <= b_in;
                end if;
                
                sign_next <= a_in(31) xor b_in(31);
                
            when "11" => -- oba unsigned
                a_s <= a_in;
                b_s <= b_in;
                
           when "01" => -- a_in signed, b_in unsigned
           
                if(a_in(31) = '1') then
                    a_s <= std_logic_vector(signed(not a_in) + TO_SIGNED(1, 32));
                else
                    a_s <= a_in;
                end if;
                b_s <= b_in;
                
                sign_next <= a_in(31);
                
            when "10" =>    -- b_in signed, a_in unsigned
               a_s <= a_in;
               
               if(b_in(31) = '1') then
                    b_s <= std_logic_vector(signed(not b_in) + TO_SIGNED(1, 32));
                else
                    b_s <= b_in;
                end if;    
                
                sign_next <= b_in(31);  
            when others =>   
        end case;
       
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

    a_up <= (a_s(31 downto 16));
    a_down <= (a_s(15 downto 0));
    b_up <= (b_s(31 downto 16));
    b_down <= (b_s(15 downto 0));
    
    res4 <= std_logic_vector(unsigned(a_up) * unsigned(b_up));
    res3 <= std_logic_vector(unsigned(b_up) * unsigned(a_down));
    res2 <= std_logic_vector(unsigned(b_down) * unsigned(a_up));
    res1 <= std_logic_vector(unsigned(a_down) * unsigned(b_down));
    
    
    res5 <= std_logic_vector(unsigned(reg2) + unsigned(x"0000" & reg1(31 downto 16)));
    res6 <= std_logic_vector(unsigned(reg4 & x"0000") + unsigned(x"0000" & reg3));

    res7 <= std_logic_vector(unsigned(reg6) + unsigned(reg5));

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
            
            sign_reg <= '0';
            sign2_reg <= '0';
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
            
            sign_reg <= sign_next;
            sign2_reg <= sign2_next;
            
        end if;
    end process;
    
    sign2_next <= sign_reg;
    
    process(con_s, sign2_reg, res7, reg1_1)
    begin
        c_out <= std_logic_vector(res7 & reg1_1(15 downto 0));
        
        case con_s is
            when "00" =>
            
                if(sign2_reg = '1') then
                    c_out <= std_logic_vector(signed(not(res7 & reg1_1(15 downto 0))) + TO_SIGNED(1,64));
                end if;
                
            when "01" =>
            
                if(sign2_reg = '1') then
                    c_out <= std_logic_vector(signed(not(res7 & reg1_1(15 downto 0))) + TO_SIGNED(1,64));
                end if;
                
            when "10" =>
            
                if(sign2_reg = '1') then
                    c_out <= std_logic_vector(signed(not(res7 & reg1_1(15 downto 0))) + TO_SIGNED(1,64));
                end if;
             
            when others =>   
        end case;
    end process;
    
end Behavioral;

