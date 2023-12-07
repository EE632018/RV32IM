----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2023 08:03:51 PM
-- Design Name: 
-- Module Name: floatComp - Behavioral
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

entity floatComp is
    Port ( a_in : in STD_LOGIC_VECTOR (31 downto 0);
           b_in : in STD_LOGIC_VECTOR (31 downto 0);
           c_max_out : out STD_LOGIC_VECTOR (31 downto 0);
           c_min_out : out STD_LOGIC_VECTOR (31 downto 0);
           c_feq_out : out STD_LOGIC_VECTOR (31 downto 0);
           c_flts_out: out STD_LOGIC_VECTOR (31 downto 0);
           c_fle_out : out STD_LOGIC_VECTOR (31 downto 0));
end floatComp;

architecture Behavioral of floatComp is

    signal a_s, b_s : std_logic;
    signal a_e, b_e : std_logic_vector(7 downto 0);
    signal a_m, b_m : std_logic_vector(22 downto 0);
begin

    a_m <= a_in(22 downto 0);
    b_m <= b_in(22 downto 0);
    
    a_e <= a_in(30 downto 23);
    b_e <= b_in(30 downto 23);
    
    a_s <= a_in(31);
    b_s <= b_in(31);
    process(a_e, b_e, a_s, b_s, a_m, b_m) --NAN
        begin
        if(a_e = "01111111" or b_e = "01111111" ) then
            c_max_out  <= "10111111111111111111111111111111";
            c_min_out  <= "10111111111111111111111111111111";
            --c_feq_out  <= (others => '0');
            --c_flts_out <= (others => '0');
            --c_fle_out  <= (others => '0');
        else
            if(a_s = b_s) then                                  -- SAME SIGN
                if(a_e = b_e) then                              -- SAME EXSPONAT
                    if(unsigned(a_m) >= unsigned(b_m)) then     
                        c_max_out <= a_s & a_e & a_m;
                        c_min_out <= b_s & b_e & b_m;
                    else
                        c_min_out <= a_s & a_e & a_m;
                        c_max_out <= b_s & b_e & b_m;
                    end if;
                elsif(unsigned(a_e) > unsigned(b_e)) then
                    c_max_out <= a_s & a_e & a_m;
                    c_min_out <= b_s & b_e & b_m;
                else
                    c_min_out <= a_s & a_e & a_m;
                    c_max_out <= b_s & b_e & b_m;
                end if;
            else
                if(a_s = '1') then
                    c_max_out <= a_s & a_e & a_m;
                    c_min_out <= b_s & b_e & b_m;
                else
                    c_min_out <= a_s & a_e & a_m;
                    c_max_out <= b_s & b_e & b_m;
                end if;
            end if;
        end if;
    end process;

    process(a_e, b_e, a_in, b_in) --NAN
        begin
        if(a_e = "01111111" or b_e = "01111111" ) then
            c_feq_out  <= (others => '0');
            c_flts_out <= (others => '0');
            c_fle_out  <= (others => '0');
        else
            if a_in = b_in then
                c_feq_out  <= (others => '1');
            else
                c_feq_out  <= (others => '0');    
            end if; 
            
            if a_in < b_in then
                c_flts_out  <= (others => '1');
            else
                c_flts_out  <= (others => '0');    
            end if;

            if a_in <= b_in then
                c_fle_out  <= (others => '1');
            else
                c_fle_out  <= (others => '0');    
            end if;
        end if;
    end process;
    
end Behavioral;
