library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_ops_pkg.all;

entity alu_decoder is
   port ( 
      -- from data_path
      alu_2bit_op_i  : in std_logic_vector(1 downto 0);
      funct3_i       : in std_logic_vector (2 downto 0);
      funct7_i       : in std_logic_vector (6 downto 0);
      -- to data_path
      alu_op_o       : out std_logic_vector(4 downto 0));  
end entity;

architecture behavioral of alu_decoder is
begin 

   -- pronalazi odgovarajucu operaciju ALU jedinice u odnosu na:
   --    dvobitni signal alu_2bit_op koji dolazi iz control decodera
   --    funct3 i funct7 polja u instrukciji
   alu_dec:process(alu_2bit_op_i,funct3_i,funct7_i)is
   begin
      -- podrazumevane vrednosti
      alu_op_o <= "00000";
      case alu_2bit_op_i is
         when "00" => 
            alu_op_o <= add_op;
         when "01" =>
            alu_op_o <= eq_op;
         when "11" => -- I type
                            
         when others =>
            case funct3_i is
               when "000" =>
                  alu_op_o <= add_op;
                  if(funct7_i(5)='1')then 
                     alu_op_o <= sub_op;
                  end if;
                  if (funct7_i(0) = '1') then
                    alu_op_o <= mulu_op;
                  end if;  
               when "001" =>
                  alu_op_o <= sll_op; 
                  if (funct7_i(0) = '1') then
                    alu_op_o <= mulhs_op;
                  end if; 
               when "101" =>
                  case funct7_i is
                    when "0000000" => 
                        alu_op_o <= srl_op;
                    when "0100000" =>
                        alu_op_o <= sra_op;
                    when others =>
                        alu_op_o <= srl_op;                    
                  end case;                      
               when "100" =>
                  alu_op_o <= xor_op;
               when "010" =>
                  alu_op_o <= lts_op;
                  if (funct7_i(0) = '1') then
                    alu_op_o <= mulhsu_op;
                  end if;
               when "011" =>
                  alu_op_o <= ltu_op; 
                  if (funct7_i(0) = '1') then
                    alu_op_o <= mulhu_op;
                  end if;                                                         
               when "110" =>
                  alu_op_o <= or_op;
               when others =>
                  alu_op_o <= and_op;
            end case;
      end case;
   end process;

end architecture;
