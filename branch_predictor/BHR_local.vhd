----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/02/2023 01:46:02 PM
-- Design Name: 
-- Module Name: BHR_local - Behavioral
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

entity BHR_local is
    GENERIC(WIDTH:    natural    := 4;
            WIDTH_BHR:  natural  := 3);
    Port (clk                   : in STD_LOGIC;
          reset                 : in STD_LOGIC;
          -- bhr_i indicates taken/not taken value branch condition
          bhr_i                 : in STD_LOGIC;
          branch_inst           : in STD_LOGIC;
          branch_addr_prev_loc : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          branch_addr_4bit      : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          bhr_o                 : out STD_LOGIC_VECTOR(WIDTH_BHR-1 downto 0)
          );
end BHR_local;

architecture Behavioral of BHR_local is
    type bhr is array(0 to 2**WIDTH - 1) of std_logic_vector(WIDTH_BHR-1 downto 0);
    signal pattern: bhr := (others => (others => '0'));
begin
    shift_reg: process(clk, reset)
                begin
                    if reset = '0' then
                        pattern <= (others => (others => '0'));
                    elsif rising_edge(clk) then
                        -- Maybe it is neccasary to put enable signal, because this don't need to be changes each cycle
                        if branch_inst = '1' then
                            pattern(to_integer(unsigned(branch_addr_prev_loc))) <=  pattern(to_integer(unsigned(branch_addr_prev_loc)))(WIDTH_BHR-2 downto 0) & bhr_i;       
                        else
                            pattern(to_integer(unsigned(branch_addr_prev_loc))) <=  pattern(to_integer(unsigned(branch_addr_prev_loc)));
                        end if;    
                end if;
    end process shift_reg;
               
    --output_val           
    sel_bhr:process(branch_addr_4bit, pattern)
            begin
                bhr_o <= pattern(to_integer(unsigned(branch_addr_4bit)));
            end process sel_bhr;

end Behavioral;
