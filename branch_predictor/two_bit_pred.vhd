----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/05/2023 02:48:22 PM
-- Design Name: 
-- Module Name: two_bit_pred - Behavioral
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

entity two_bit_pred is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           en_i : in STD_LOGIC;        -- VALUE OF JUMP INSTRUCTION
           branch_inst : in STD_LOGIC; -- IF INSTUCTION WAS JUMP
           pred : out STD_LOGIC);
end two_bit_pred;

architecture Behavioral of two_bit_pred is

    type fsm_state is (SN,WN,WT,ST); 
    signal state, state_n: fsm_state;

begin

    first_fsm: process(clk,reset)
               begin
                    if reset = '0' then
                        state <= WN;
                    elsif rising_edge(clk)then
                        state <= state_n;  
                    end if;
               end process first_fsm;
               
            
    next_output_fsm: process(state,en_i, branch_inst)
                     begin
                            if (branch_inst = '0') then
                                state_n <= state;
                                pred    <= '0';
                            else 
                                case(state)is
                                    when SN =>
                                        if en_i = '1' then
                                            state_n <= WN;
                                            --pred    <= '0';
                                        else 
                                            state_n <= SN;
                                            --pred    <= '0';    
                                        end if; 
                                        pred <= '0';     
                                    when WN =>
                                        if en_i = '1' then
                                            state_n <= WT;
                                            --pred    <= '0';
                                        else 
                                            state_n <= SN;
                                            --pred    <= '0';    
                                        end if;
                                        pred <= '0';
                                    when WT =>
                                        if en_i = '1' then
                                            state_n <= ST;
                                            --pred    <= '1';
                                        else 
                                            state_n <= WN;
                                            --pred    <= '1';    
                                        end if;
                                        pred <= '1';
                                    when ST =>  
                                        if en_i = '1' then
                                            state_n <= ST;
                                            --pred    <= '1';
                                        else 
                                            state_n <= WT;
                                            --pred    <= '1';    
                                        end if;
                                        pred <= '1';
                                end case;
                            end if;      
                     end process next_output_fsm;
end Behavioral;
