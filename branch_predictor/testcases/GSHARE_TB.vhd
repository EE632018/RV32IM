----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2023 11:27:23 AM
-- Design Name: 
-- Module Name: GSHARE_TB - Behavioral
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

entity GSHARE_TB is
--  Port ( );
end GSHARE_TB;

architecture Behavioral of GSHARE_TB is

    COMPONENT Gshare
    GENERIC(WIDTH: NATURAL := 4);
    Port (clk                  : in STD_LOGIC;
          reset                : in STD_LOGIC;
          branch_addr_4bit     : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          branch_addr_prev_loc : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          pht_addr_4bit        : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
          branch_inst          : in STD_LOGIC;
          bhr_i                : in STD_LOGIC;
          gshare_pred          : out STD_LOGIC
          );
    END COMPONENT;

    signal clk, reset, branch_inst, gshare_pred, bhr_s: std_logic;
    signal branch_addr_4bit, branch_addr_prev_loc, pht_addr_4bit_s: std_logic_vector(3 downto 0);
    type pht_arr is array (0 to 100) of std_logic_vector(3 downto 0);
    signal arr: pht_arr;
    constant  period : time := 20ns;

begin

    PHT_INST:Gshare
             GENERIC MAP(WIDTH      => 4)
             PORT MAP(
                      clk                  => clk,
                      reset                => reset,
                      bhr_i                => bhr_s,  
                      branch_inst          => branch_inst,
                      branch_addr_prev_loc => branch_addr_prev_loc,
                      pht_addr_4bit        => pht_addr_4bit_s, 
                      gshare_pred          => gshare_pred,
                      branch_addr_4bit     => branch_addr_4bit    
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
        branch_inst     <= '1'; 
        branch_addr_4bit     <= (others => '0');
        branch_addr_prev_loc <= (others => '0');
        wait until reset = '1';
        for i in 0 to 100 loop
--            /*if i%2 == 0 then
--                bhr_s <= '1';
--                wait until rising_edge(clk);
--            else
--                bhr_s <= '0';
--                wait until rising_edge(clk);    
--            end if;    */

            branch_addr_4bit <= std_logic_vector(to_unsigned(i,4));
            arr(i) <= pht_addr_4bit_s;
            
            if i > 1 then
               branch_addr_prev_loc <= arr(i-1); 
            end if;
            
            wait until rising_edge(clk);
        end loop;
        wait;
    end process;
 
    process
    begin
        bhr_s <= '0';
        wait until reset = '1';
        bhr_s <= not bhr_s;
        wait;
    end process;
    
end Behavioral;
