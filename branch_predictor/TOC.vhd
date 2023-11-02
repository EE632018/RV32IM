----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/01/2023 08:55:24 AM
-- Design Name: 
-- Module Name: TOC - Behavioral
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

entity TOC is
    generic(row :   integer := 16;
            cols:   integer := 4);
    Port ( 
           clk                  : in STD_LOGIC;
           reset                : in STD_LOGIC;
           branch_addr_4bit     : in STD_LOGIC_VECTOR (3 DOWNTO 0);
           cnt_one              : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           cnt_two              : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           cnt_three            : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           cnt_four             : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           index_sel            : in STD_LOGIC_VECTOR(1 DOWNTO 0)
           );
end TOC;

architecture Behavioral of TOC is
    type table is array(0 to row-1, 0 to cols-1) of std_logic_vector(1 downto 0);
    signal table_of_cnt: table := (others => (others => "11"));
begin
        
    output_cnt_p: process(branch_addr_4bit)
                  begin
                        case(branch_addr_4bit)is
                            when "0000" => 
                                cnt_one     <= table_of_cnt(0,0);
                                cnt_two     <= table_of_cnt(1,0);
                                cnt_three   <= table_of_cnt(2,0);
                                cnt_four    <= table_of_cnt(3,0);
                            when "0001" => 
                                cnt_one     <= table_of_cnt(0,1);
                                cnt_two     <= table_of_cnt(1,1);
                                cnt_three   <= table_of_cnt(2,1);
                                cnt_four    <= table_of_cnt(3,1);
                            when "0010" => 
                                cnt_one     <= table_of_cnt(0,2);
                                cnt_two     <= table_of_cnt(1,2);
                                cnt_three   <= table_of_cnt(2,2);
                                cnt_four    <= table_of_cnt(3,2);
                            when "0011" => 
                                cnt_one     <= table_of_cnt(0,3);
                                cnt_two     <= table_of_cnt(1,3);
                                cnt_three   <= table_of_cnt(2,3);
                                cnt_four    <= table_of_cnt(3,3);
                            when "0100" => 
                                cnt_one     <= table_of_cnt(0,4);
                                cnt_two     <= table_of_cnt(1,4);
                                cnt_three   <= table_of_cnt(2,4);
                                cnt_four    <= table_of_cnt(3,4);
                            when "0101" => 
                                cnt_one     <= table_of_cnt(0,5);
                                cnt_two     <= table_of_cnt(1,5);
                                cnt_three   <= table_of_cnt(2,5);
                                cnt_four    <= table_of_cnt(3,5);
                            when "0110" => 
                                cnt_one     <= table_of_cnt(0,6);
                                cnt_two     <= table_of_cnt(1,6);
                                cnt_three   <= table_of_cnt(2,6);
                                cnt_four    <= table_of_cnt(3,6);
                            when "0111" => 
                                cnt_one     <= table_of_cnt(0,7);
                                cnt_two     <= table_of_cnt(1,7);
                                cnt_three   <= table_of_cnt(2,7);
                                cnt_four    <= table_of_cnt(3,7);
                            when "1000" => 
                                cnt_one     <= table_of_cnt(0,8);
                                cnt_two     <= table_of_cnt(1,8);
                                cnt_three   <= table_of_cnt(2,8);
                                cnt_four    <= table_of_cnt(3,8);
                            when "1001" => 
                                cnt_one     <= table_of_cnt(0,9);
                                cnt_two     <= table_of_cnt(1,9);
                                cnt_three   <= table_of_cnt(2,9);
                                cnt_four    <= table_of_cnt(3,9);
                            when "1010" => 
                                cnt_one     <= table_of_cnt(0,10);
                                cnt_two     <= table_of_cnt(1,10);
                                cnt_three   <= table_of_cnt(2,10);
                                cnt_four    <= table_of_cnt(3,10);
                            when "1011" => 
                                cnt_one     <= table_of_cnt(0,11);
                                cnt_two     <= table_of_cnt(1,11);
                                cnt_three   <= table_of_cnt(2,11);
                                cnt_four    <= table_of_cnt(3,11);
                            when "1100" => 
                                cnt_one     <= table_of_cnt(0,12);
                                cnt_two     <= table_of_cnt(1,12);
                                cnt_three   <= table_of_cnt(2,12);
                                cnt_four    <= table_of_cnt(3,12);
                            when "1101" => 
                                cnt_one     <= table_of_cnt(0,13);
                                cnt_two     <= table_of_cnt(1,13);
                                cnt_three   <= table_of_cnt(2,13);
                                cnt_four    <= table_of_cnt(3,13);
                            when "1110" => 
                                cnt_one     <= table_of_cnt(0,14);
                                cnt_two     <= table_of_cnt(1,14);
                                cnt_three   <= table_of_cnt(2,14);
                                cnt_four    <= table_of_cnt(3,14);
                            when "1111" => 
                                cnt_one     <= table_of_cnt(0,15);
                                cnt_two     <= table_of_cnt(1,15);
                                cnt_three   <= table_of_cnt(2,15);
                                cnt_four    <= table_of_cnt(3,15);                                                            
                        end case;    
                  end process output_cnt_p;  

    change_of_table:process(index_sel,branch_addr_4bit)
                    begin
                        case branch_addr_4bit is
                            when "0000" =>
                               case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "0001" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "0010" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "0011" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "0100" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "0101" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "0110" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "0111" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "1000" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "1001" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "1010" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "1011" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "1100" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "1101" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "1110" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                           when "1111" =>
                                case index_sel is
                                    when "00" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "11" then
                                            table_of_cnt(0,0)<= "11";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;        
                                    when "01" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "11" then
                                            table_of_cnt(1,0)<= "11";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "10" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "11" then
                                            table_of_cnt(2,0)<= "11";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) + to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "00" then
                                            table_of_cnt(3,0)<= "00";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) - to_unsigned(1,2)); 
                                        end if;
                                      when "11" =>
                                        -- cnt_one logic                                        
                                        if table_of_cnt(0,0) = "00" then
                                            table_of_cnt(0,0)<= "00";
                                        else 
                                            table_of_cnt(0,0)<= std_logic_vector( unsigned(table_of_cnt(0,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_two logic
                                        if table_of_cnt(1,0) = "00" then
                                            table_of_cnt(1,0)<= "00";
                                        else 
                                            table_of_cnt(1,0)<= std_logic_vector( unsigned(table_of_cnt(1,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_three logic
                                        if table_of_cnt(2,0) = "00" then
                                            table_of_cnt(2,0)<= "00";
                                        else 
                                            table_of_cnt(2,0)<= std_logic_vector( unsigned(table_of_cnt(2,0)) - to_unsigned(1,2)); 
                                        end if;
                                        -- cnt_four logic
                                        if table_of_cnt(3,0) = "11" then
                                            table_of_cnt(3,0)<= "11";
                                        else 
                                            table_of_cnt(3,0)<= std_logic_vector( unsigned(table_of_cnt(3,0)) + to_unsigned(1,2)); 
                                        end if;           
                                end case;
                        end case;
                    end process change_of_table;
end Behavioral;
