----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/08/2023 10:16:45 AM
-- Design Name: 
-- Module Name: fsqrt - Behavioral
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

entity fsqrt_c is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           start : in STD_LOGIC;
           a_i : in STD_LOGIC_VECTOR (31 downto 0);
           c_out : out STD_LOGIC_VECTOR (31 downto 0);
           stall_o : out STD_LOGIC);
end fsqrt_c;

architecture Behavioral of fsqrt_c is
    component FPP_DIVIDE 
      port (A        : in  std_logic_vector(31 downto 0);  --Dividend
            B        : in  std_logic_vector(31 downto 0);  --Divisor
            clk      : in  std_logic;       --Master clock
            reset    : in  std_logic;       --Global asynch reset
            go       : in  std_logic;       --Enable
            done     : out std_logic;       --Flag for done computing
            --ZD:         out std_logic;                                          --Flag for zero divisor
            overflow : out std_logic;       --Flag for overflow
            result   : out std_logic_vector(31 downto 0)   --Holds final FP result
            );
    end component;
    
    component FPU 
      Port (clk:   in std_logic;
            rst:   in std_logic;
            start: in std_logic;
            X:     in std_logic_vector(31 downto 0);
            Y:     in std_logic_vector(31 downto 0);
            R:     out std_logic_vector(31 downto 0);
            done:  out std_logic);
    end component;
    
    signal num2 : std_logic_vector(31 downto 0) := x"40000000";
    
    signal res_r, res_n: std_logic_vector(31 downto 0);
    
    signal start_a, stall_a: std_logic;
    signal res_add: std_logic_vector(31 downto 0);
    
    signal start_d, stall_d :std_logic;
    signal res_div : std_logic_vector(31 downto 0);
    
    signal start_d2, stall_d2 :std_logic;
    signal res_div2 : std_logic_vector(31 downto 0);
    
    signal cnt_en: std_logic;
    signal cnt_r, cnt_n: std_logic_vector(5 downto 0);
    
    type state is (IDLE, DIV, START_DIV, ADD, DIV2, START_DIV2,RES);
    signal state_r, state_n: state; 
begin

    add_i: FPU
    port map(clk => clk,
             rst => rst,
             start => start_a,
             X => res_r,
             Y => res_div,
             R => res_add,
             done => stall_a);
    
    div_i: FPP_DIVIDE
    port map(clk => clk,
             reset => rst,
             go => start_d,
             done => stall_d,
             overflow => open,
             A => a_i,
             B => res_r,
             result => res_div
             );
             
    div_2i: FPP_DIVIDE
    port map(clk => clk,
             reset => rst,
             go => start_d2,
             done => stall_d2,
             overflow => open,
             A => res_add,
             B => num2,
             result => res_div2
             );
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                cnt_r <= std_logic_vector(TO_UNSIGNED(31,6));
            else
                cnt_r <= cnt_n;
            end if;
        end if;
    end process;         
             
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state_r <= IDLE;
                res_r <= (others => '0');
            else
                state_r <= state_n;
                res_r <= res_n;
            end if;
        end if;
    end process;

    process(state_r, start, cnt_r, res_r, stall_d, stall_a, stall_d2, res_div2, a_i)
    begin
    
        cnt_n <= cnt_r;
        res_n <= res_r;
        start_a <= '0';
        start_d <= '0';
        start_d2 <= '0';
        stall_o <= '0';
        state_n <= state_r;
         
        case state_r is
            when IDLE =>
                cnt_n <= std_logic_vector(TO_UNSIGNED(31,6));
                stall_o <= '1';
                if start = '1' then
                    res_n <= a_i;
                    state_n <= START_DIV;
                    start_d <= '1';
                else
                    state_n <= IDLE; 
                end if;
                
            when START_DIV =>
                state_n <= DIV;
                start_d <= '1'; 
                if stall_d = '1' then
                   state_n <= START_DIV;
               else
                    state_n <= DIV;  
               end if;          
            when DIV =>
                if stall_d = '1' then
                    state_n <= ADD;
                    start_a <= '1';
                else
                    state_n <= DIV;
                    --start_d <= '1';
                end if;
                
            when ADD =>
                if stall_a = '1' then
                    state_n <= START_DIV2;
                    start_d2 <= '1';
                else
                    state_n <= ADD;
                end if;
                
            when START_DIV2 =>
                state_n <= DIV2;
                start_d2 <= '1'; 
                if stall_d2 = '1' then
                   state_n <= START_DIV2;
               else
                    state_n <= DIV2;
               end if;
            when DIV2 =>
                
                if stall_d2 = '1' then
                    state_n <= RES;
                else
                    state_n <= DIV2;
                    --start_d2 <= '1';
                end if; 
                
            when RES => 
                if( unsigned(cnt_r) = TO_UNSIGNED(0, 6)) then
                    state_n <= IDLE;
                    res_n <= res_div2;
                else
                    res_n <= res_div2;
                    state_n <= START_DIV;
                    start_d <= '1';
                    cnt_n <= std_logic_vector(unsigned(cnt_r) - TO_UNSIGNED(1,6)); 
                end if;
                
            when others =>
                cnt_n <= cnt_r;
                res_n <= res_r;
                start_a <= '0';
                start_d <= '0';
                start_d2 <= '0';
                stall_o <= '0';
                state_n <= state_r;
        end case;        
    end process;
    
    c_out <= res_r;
end Behavioral;
