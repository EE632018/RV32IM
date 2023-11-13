----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/02/2023 10:57:50 AM
-- Design Name: 
-- Module Name: PHT - Behavioral
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

entity PHT is
    GENERIC(WIDTH: NATURAL  := 4);
    Port ( 
           clk              : in STD_LOGIC;
           reset            : in STD_LOGIC;
           -- en signal indicates taken/not taken, '1' for taken and '0' for not taken
           en_i             : in STD_LOGIC; 
           branch_inst      : in STD_LOGIC;
           branch_addr_prev_loc : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
           pht_addr_4bit    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
           pred             : out STD_LOGIC       
     );
end PHT;

architecture Behavioral of PHT is

    component two_bit_pred
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               branch_inst : in STD_LOGIC;
               en_i : in STD_LOGIC;
               pred : out STD_LOGIC);
    end component;
    type pht is array(0 to 2**WIDTH - 1) of std_logic;
    signal pattern_r, en_s, branch_inst_s: pht := (others => '1');
    signal final_pred   : std_logic;
    
    type fsm_state is (SN,WN,WT,ST); 
    signal state, state_n: fsm_state;
begin

    -- Implementing FSM for two_bit branch predictor
    -- There are four states SN - strongly not taken, WN - weakly not taken
    -- WT - weakly taken, ST - strongly taken
    --         -         T           -        
    --      /  SN \  ---------->   / WN \ 
    --         -     <----------     - 
    --                   N          | ^
    --                              | |
    --                            T | | N
    --                              ? |
    --         -         N           -        
    --      /  ST \  ---------->   / WT \ 
    --         -     <----------     - 
    --                   T
    
--    first_fsm: process(clk,reset)
--               begin
--                    if reset = '0' then
--                        state <= ST;
--                        pattern_r <= (others => "11");
--                    elsif rising_edge(clk)then
--                        state <= state_n;
--                        pattern_r <= pattern_n;    
--                    end if;
--               end process first_fsm; 
    
--    next_output_fsm: process(state,en_i, pht_addr_4bit, pattern_r)
--                     begin
--                            pattern_n <= pattern_r;
--                            case(state)is
--                                when SN =>
--                                    if en_i = '1' then
--                                        state_n <= WN;
--                                        pattern_n(to_integer(unsigned(pht_addr_4bit))) <= "01";
--                                        --pred    <= '0';
--                                    else 
--                                        state_n <= SN;
--                                        pattern_n(to_integer(unsigned(pht_addr_4bit))) <= "00";
--                                        --pred    <= '0';    
--                                    end if;      
--                                when WN =>
--                                    if en_i = '1' then
--                                        state_n <= WT;
--                                        pattern_n(to_integer(unsigned(pht_addr_4bit))) <= "10";
--                                        --pred    <= '0';
--                                    else 
--                                        state_n <= SN;
--                                        pattern_n(to_integer(unsigned(pht_addr_4bit))) <= "00";
--                                        --pred    <= '0';    
--                                    end if;
--                                when WT =>
--                                    if en_i = '1' then
--                                        state_n <= ST;
--                                        pattern_n(to_integer(unsigned(pht_addr_4bit))) <= "11";
--                                        --pred    <= '1';
--                                    else 
--                                        state_n <= WN;
--                                        pattern_n(to_integer(unsigned(pht_addr_4bit))) <= "01";
--                                        --pred    <= '1';    
--                                    end if;
--                                when ST =>  
--                                    if en_i = '1' then
--                                        state_n <= ST;
--                                        pattern_n(to_integer(unsigned(pht_addr_4bit))) <= "11";
--                                        --pred    <= '1';
--                                    else 
--                                        state_n <= WT;
--                                        pattern_n(to_integer(unsigned(pht_addr_4bit))) <= "10";
--                                        --pred    <= '1';    
--                                    end if;
--                            end case;      
--                     end process next_output_fsm;
                     
                     -- output pred
                     pred <= pattern_r(to_integer(unsigned(pht_addr_4bit))); 
                      
                     process(en_i, branch_addr_prev_loc, branch_inst)begin
                        for i in 0 to 2**WIDTH - 1 loop
                            en_s(i) <= '0';
                            branch_inst_s(i) <= '0';
                        end loop;
                        en_s(to_integer(unsigned(branch_addr_prev_loc))) <= en_i;
                        branch_inst_s(to_integer(unsigned(branch_addr_prev_loc))) <= branch_inst;
                     end process;
                    
                     two_bit: for i in 0 to 2**WIDTH - 1 generate
                        two_bit_pred_i : two_bit_pred
                        port map (  clk => clk,
                                    reset => reset,
                                    en_i => en_s(i),
                                    branch_inst => branch_inst_s(i),
                                    pred => pattern_r(i));
                        end generate;

end Behavioral;
