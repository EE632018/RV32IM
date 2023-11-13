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
    generic(row :   integer := 4;
            cols:   integer := 16);
    Port ( 
           clk                  : in STD_LOGIC;
           reset                : in STD_LOGIC;
           branch_addr_4bit     : in STD_LOGIC_VECTOR (3 DOWNTO 0);
           cnt_one              : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           cnt_two              : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           cnt_three            : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           cnt_four             : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           -- This index sel is not connected to index sel in priority encoder
           branch_addr_prev_loc : in STD_LOGIC_VECTOR (3 DOWNTO 0);  
           index_sel            : in STD_LOGIC_VECTOR (3 DOWNTO 0)
           );
end TOC;

architecture Behavioral of TOC is
    type table is array(0 to cols-1, 0 to row-1) of std_logic_vector(1 downto 0);
    signal table_of_cnt_r, table_of_cnt: table := (others => (others => "11"));
begin
    
    generating_table_2bit_cnt: process(clk,reset)
                               begin
                                    if reset = '0' then
                                        for i in 0 to row-1 loop
                                            for j in 0 to cols-1 loop
                                                table_of_cnt_r(j,i) <= "11";
                                            end loop;
                                        end loop;                                 
                                    elsif rising_edge(clk) then
                                        for i in 0 to row-1 loop
                                            for j in 0 to cols-1 loop
                                                    table_of_cnt_r(j,i) <= table_of_cnt(j,i);      
                                            end loop;
                                        end loop;
                                    end if; 
                               
                               end process generating_table_2bit_cnt; 
    
        
    output_cnt_p: process(branch_addr_4bit,table_of_cnt_r)
                  begin
                        cnt_one     <= table_of_cnt_r(to_integer(unsigned(branch_addr_4bit)),0);
                        cnt_two     <= table_of_cnt_r(to_integer(unsigned(branch_addr_4bit)),1);
                        cnt_three   <= table_of_cnt_r(to_integer(unsigned(branch_addr_4bit)),2);
                        cnt_four    <= table_of_cnt_r(to_integer(unsigned(branch_addr_4bit)),3);    
                  end process output_cnt_p;  

    process(index_sel,table_of_cnt_r,table_of_cnt,branch_addr_prev_loc)
    begin
        table_of_cnt <= table_of_cnt_r;
        
        for i in 0 to 3 loop
           if index_sel(i) = '0' then
                if table_of_cnt_r(to_integer(unsigned(branch_addr_prev_loc)),i) = "00" then
                    table_of_cnt(to_integer(unsigned(branch_addr_prev_loc)),i) <= "00";
                else
                    table_of_cnt(to_integer(unsigned(branch_addr_prev_loc)),i) <= std_logic_vector( unsigned(table_of_cnt_r(to_integer(unsigned(branch_addr_prev_loc)),i)) - to_unsigned(1,2));
                end if;
           else
                if table_of_cnt_r(to_integer(unsigned(branch_addr_prev_loc)),i) = "11" then
                    table_of_cnt(to_integer(unsigned(branch_addr_prev_loc)),i) <= "11";
                else
                    table_of_cnt(to_integer(unsigned(branch_addr_prev_loc)),i) <= std_logic_vector( unsigned(table_of_cnt_r(to_integer(unsigned(branch_addr_prev_loc)),i)) + to_unsigned(1,2));    
                end if;
           end if;     
        end loop;        
    end process;

end Behavioral;
