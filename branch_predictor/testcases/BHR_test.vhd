----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/05/2023 01:43:30 PM
-- Design Name: 
-- Module Name: BHR_test - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BHR_test is
    generic (WIDTH: NATURAL := 4);
--  Port ( );
end BHR_test;

architecture Behavioral of BHR_test is

    COMPONENT BHR
    GENERIC(WIDTH:    natural    := 4);  
    Port (  clk         : in STD_LOGIC;
            reset       : in STD_LOGIC;
            -- bhr_i indicates taken not taken value that is put to system
            bhr_i       : in STD_LOGIC;
            bhr_o       : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
          );
    end component;
    
    signal clk, reset, bhr_s: std_logic;
    signal gshare_bhr_s: std_logic_vector(WIDTH-1 downto 0);
    constant  period : time := 20ns;
begin

    -- Instations of component
    BHR_INST:BHR
             GENERIC MAP(WIDTH      => WIDTH)
             PORT MAP(
                       clk          => clk,
                       reset        => reset,
                       bhr_i        => bhr_s,
                       bhr_o        => gshare_bhr_s  
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
        bhr_s <= '0';
        wait until reset = '1';
        for i in 0 to 100 loop
--            /*if i%2 == 0 then
--                bhr_s <= '1';
--                wait until rising_edge(clk);
--            else
--                bhr_s <= '0';
--                wait until rising_edge(clk);    
--            end if;    */
            bhr_s <= not bhr_s;
            wait until rising_edge(clk);   
        end loop;
    
        wait;
    
    end process;

end Behavioral;
