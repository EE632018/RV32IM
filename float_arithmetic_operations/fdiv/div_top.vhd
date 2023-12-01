----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/01/2023 02:42:57 PM
-- Design Name: 
-- Module Name: div_top - Behavioral
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

entity div_top is
  Port (a_in : in std_logic_vector(31 downto 0);
        b_in : in std_logic_vector(31 downto 0);
        clk  : in std_logic;
        rst  : in std_logic;
        r_out: out std_logic_vector(31 downto 0);
        stall: out std_logic;
        start: in std_logic 
        );
end div_top;

architecture Behavioral of div_top is

    component fixedDiv
    Port ( a_in : in STD_LOGIC_VECTOR (23 downto 0);
           b_in : in STD_LOGIC_VECTOR (23 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           r_out : out STD_LOGIC_VECTOR (47 downto 0);
           stall : out STD_LOGIC;
           start : in STD_LOGIC);
   end component;

    signal sign_a, sign_b, sign, sign_r: std_logic;
    signal exponent_a, exponent_b, exponent, exponent_r, exponent_r2, exponent_r2_next, exponent_r3, exponent_r3_next: std_logic_vector(7 downto 0);
    signal mantissa_a, mantissa_b: std_logic_vector(23 downto 0);
    signal mantissa_r, mantissa_r2, mantissa_r2_next: std_logic_vector(47 downto 0);
    signal start_s: std_logic;
    signal stall_s: std_logic;

    type state_type is (INIT, DIV, NORMALIZE, OUTPUT);
    signal state, state_next: state_type;

begin

    sign_a <= a_in(31);
    sign_b <= b_in(31);
    exponent_a <= a_in(30 downto 23);
    exponent_b <= b_in(30 downto 23);
    mantissa_a <= '1' & a_in(22 downto 0);
    mantissa_b <= '1' & b_in(22 downto 0);
    

    fixdiv_inst: fixedDiv
    port map(a_in => mantissa_a, b_in => mantissa_b, clk => clk, rst => rst, r_out => mantissa_r, stall => stall_s, start => start_s);

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                state <= INIT;
                sign_r <= '0';
                exponent_r <= (others => '0');
                exponent_r2 <= (others => '0');
                exponent_r3 <= (others => '0');
                mantissa_r2 <= (others => '0');
            else    
                sign_r <= sign;
                state <= state_next;
                exponent_r  <= exponent;
                exponent_r2 <= exponent_r2_next;
                exponent_r3 <= exponent_r3_next;
                mantissa_r2 <= mantissa_r2_next;
            end if;
        end if;
    end process;

    process(mantissa_r2_next, state, start, a_in, b_in, exponent_r, sign_a, sign_b, exponent_r2, sign, stall_s, mantissa_r, exponent_r3, mantissa_r2, exponent_a, exponent_b, sign_r)
    begin
        start_s <= '0';
        exponent <= exponent_r;
        exponent_r2_next <= exponent_r2;
        exponent_r3_next <= exponent_r3;
        mantissa_r2_next <= mantissa_r2;
        case state is
            when INIT =>
                sign <= sign_a xor sign_b;
                exponent <= std_logic_vector(unsigned(exponent_b) - unsigned(exponent_a));
                stall <= '1';
                if start = '1' then
                    start_s <= '1';
                    state_next <= DIV;
                else
                    state_next <= INIT;
                end if;
            when DIV =>
                sign <= sign_r;
                if exponent_b < exponent_a then
                    exponent_r2_next <= std_logic_vector(to_unsigned(127,8) - unsigned(exponent_r));
                else
                    exponent_r2_next <= std_logic_vector(to_unsigned(127,8) + unsigned(exponent_r));
                end if;
                stall <= '0';
                if stall_s = '1' then
                    state_next <= OUTPUT;
                else
                    state_next <= DIV;
                end if;
            when NORMALIZE => 
               sign <= sign_r; 
               stall <= '0';
               if mantissa_r2(47) = '0' then
                  exponent_r3_next <=  std_logic_vector(unsigned(exponent_r2) - to_unsigned(1,8)); 
                  mantissa_r2_next <= mantissa_r2(46 downto 0) & '0';
               else
                  exponent_r3_next <=  std_logic_vector(unsigned(exponent_r2)); 
                  mantissa_r2_next <= mantissa_r2; 
               end if;
               
                 if  mantissa_r2_next(47) = '0' then
                     state_next <= NORMALIZE;
                 else
                     state_next <= INIT;
                 end if;      
            when OUTPUT =>
               sign <= sign_r; 
               stall <= '0';
               if mantissa_r(47) = '0' then
                  exponent_r3_next <=  std_logic_vector(unsigned(exponent_r2) - to_unsigned(1,8)); 
                  mantissa_r2_next <= mantissa_r(46 downto 0) & '0';
               else
                  exponent_r3_next <=  std_logic_vector(unsigned(exponent_r2)); 
                  mantissa_r2_next <= mantissa_r; 
               end if;
               
                 if  mantissa_r2_next(47) = '0' then
                     state_next <= NORMALIZE;
                 else
                     state_next <= INIT;
                 end if;    
            when others =>
                stall <= '1';
                sign <= sign_r;
                state_next <= INIT;
        end case;
    end process;

    r_out <= sign & exponent_r3 & mantissa_r2(46 downto 24);
end Behavioral;
