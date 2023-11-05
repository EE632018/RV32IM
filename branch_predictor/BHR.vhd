----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/02/2023 10:57:50 AM
-- Design Name: 
-- Module Name: BHR - Behavioral
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

entity BHR is
  GENERIC(WIDTH:    natural    := 3);  
  Port (clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        -- bhr_i indicates taken/not taken value branch condition
        bhr_i       : in STD_LOGIC;
        branch_inst : in STD_LOGIC;
        bhr_o       : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
        );
end BHR;

architecture Behavioral of BHR is
    signal gshare_r: std_logic_vector(WIDTH-1 downto 0);
begin
    shift_reg: process(clk, reset)
               begin
                    if reset = '0' then
                        gshare_r <= (others => '0');
                    elsif rising_edge(clk) then
                        if branch_inst = '1' then    
                            gshare_r <= gshare_r(WIDTH-2 downto 0) & bhr_i;
                        else
                            gshare_r <= gshare_r;
                        end if;               
                    end if;
               end process shift_reg;
               
    --output_val           
    bhr_o <= gshare_r;
end Behavioral;
