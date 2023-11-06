----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/05/2023 02:05:37 PM
-- Design Name: 
-- Module Name: PHT_test - Behavioral
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

entity PHT_test is
--  Port ( );
end PHT_test;

architecture Behavioral of PHT_test is

    COMPONENT PHT
    GENERIC(WIDTH: NATURAL  := 4);
    Port ( 
        clk              : in STD_LOGIC;
           reset            : in STD_LOGIC;
           -- en signal indicates taken/not taken, '1' for taken and '0' for not taken
           en_i             : in STD_LOGIC; 
           branch_inst      : in STD_LOGIC;
           branch_addr_prev_loc : in STD_LOGIC_VECTOR (3 DOWNTO 0);
           pht_addr_4bit    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
           pred             : out STD_LOGIC       
    );
    END COMPONENT;

    signal clk, reset, bhr_s: std_logic;
    signal pht_addr_4bit_s : std_logic_vector(3 downto 0);
    signal gshare_pred: std_logic;
    signal branch_inst_s: std_logic;
    signal branch_addr_prev_loc_s: std_logic_vector(3 downto 0);
    constant  period : time := 20ns;
    
begin


    PHT_INST:PHT
             GENERIC MAP(WIDTH      => 4)
             PORT MAP(
                      clk                  => clk,
                      reset                => reset,
                      en_i                 => bhr_s,  
                      pht_addr_4bit        => pht_addr_4bit_s,
                      branch_inst          => branch_inst_s,
                      branch_addr_prev_loc => branch_addr_prev_loc_s,
                      pred                 => gshare_pred   
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
        branch_inst_s     <= '1'; 
        pht_addr_4bit_s <= (others => '0');
        wait until reset = '1';
        for i in 0 to 100 loop
--            /*if i%2 == 0 then
--                bhr_s <= '1';
--                wait until rising_edge(clk);
--            else
--                bhr_s <= '0';
--                wait until rising_edge(clk);    
--            end if;    */

            pht_addr_4bit_s <= std_logic_vector(to_unsigned(i,4));
            if i > 2 then
                branch_addr_prev_loc_s <= std_logic_vector(to_unsigned(i,4) - to_unsigned(2,4));
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
