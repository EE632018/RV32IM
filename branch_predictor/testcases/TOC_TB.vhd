----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/07/2023 09:54:10 AM
-- Design Name: 
-- Module Name: TOC_TB - Behavioral
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

entity TOC_TB is
--  Port ( );
end TOC_TB;

architecture Behavioral of TOC_TB is
    COMPONENT TOC
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
    END COMPONENT;
    
    signal clk, reset: std_logic;
    signal cnt_one_s, cnt_two_s, cnt_three_s, cnt_four_s: std_logic_vector(1 downto 0); 
    signal branch_addr_4bit ,branch_addr_prev_loc, taken_pred : std_logic_vector(3 downto 0);   
    constant  period : time := 20ns;
    
    type pht_arr is array (0 to 100) of std_logic_vector(3 downto 0);
    signal arr: pht_arr;
    
begin

        TOC_INST: TOC
        GENERIC MAP (row                      =>  4,
                    cols                      =>  16)
        PORT MAP    (clk                      =>  clk,
                     reset                    =>  reset,
                     branch_addr_4bit         =>  branch_addr_4bit,   
                     cnt_one                  =>  cnt_one_s,
                     cnt_two                  =>  cnt_two_s,
                     cnt_three                =>  cnt_three_s,
                     cnt_four                 =>  cnt_four_s,
                     branch_addr_prev_loc     =>  branch_addr_prev_loc,
                     index_sel                =>  taken_pred
                    );

    process
    begin
        clk <= '0'; 
        wait for period/2;
        clk <= '1';
        wait for period/2;
    end process;         

    process
    begin
        reset <= '0';
        wait until rising_edge(clk);
        reset <= '1';
        wait;
    end process;

    process
    begin
--        bhr_s <= '0';
        branch_addr_4bit <= (others => '0');
        branch_addr_prev_loc <= (others => '0');
        wait until reset = '1';
        for i in 0 to 15 loop
            branch_addr_4bit <= std_logic_vector(to_unsigned(i,4));
            arr(i) <= branch_addr_4bit;
            if i > 2 then
                branch_addr_prev_loc <= arr(i-2);
            end if;
            wait until rising_edge(clk);   
        end loop;
        wait;
    end process;
    
    
    process
    begin
        for i in 0 to 15 loop
            taken_pred <= std_logic_vector(to_unsigned(i,4));
            wait until rising_edge(clk);
        end loop;
        wait;
    end process;
end Behavioral;
