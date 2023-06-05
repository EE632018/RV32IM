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
   -- ALU OP CODE
   constant and_op: std_logic_vector (4 downto 0):="00000"; ---> bitwise and
   constant or_op: std_logic_vector (4 downto 0):="00001"; ---> bitwise or
   constant add_op: std_logic_vector (4 downto 0):="00010"; ---> add a_i and b_i
   constant sub_op: std_logic_vector (4 downto 0):="00110"; ---> sub a_i and b_i
   constant eq_op: std_logic_vector (4 downto 0):="10111"; --->  set equal
   constant xor_op: std_logic_vector (4 downto 0):="00011"; ---> bitwise xor
   constant lts_op: std_logic_vector (4 downto 0):="10100"; ---> set less than signed
   constant ltu_op: std_logic_vector (4 downto 0):="10101"; ---> set less than unsigned
   constant sll_op: std_logic_vector (4 downto 0):="10110"; ---> shift left logic
   constant srl_op: std_logic_vector (4 downto 0):="00111"; ---> shift right logic
   constant sra_op: std_logic_vector (4 downto 0):="01000"; ---> shift right arithmetic
   constant mulu_op: std_logic_vector (4 downto 0):="01001"; ---> multiply lower
   constant mulhs_op: std_logic_vector (4 downto 0):="01010"; ---> multiply higher signed
   constant mulhsu_op: std_logic_vector (4 downto 0):="01011"; ---> multiply higher signed and unsigned
   constant mulhu_op: std_logic_vector (4 downto 0):="01100"; ---> multiply higher unsigned
   constant divu_op: std_logic_vector (4 downto 0):="01101"; ---> divide unsigned
   constant divs_op: std_logic_vector (4 downto 0):="01110"; ---> divide signed
   constant remu_op: std_logic_vector (4 downto 0):="01111"; ---> reminder unsigned
   constant rems_op: std_logic_vector (4 downto 0):="10000"; ---> reminder signed	
   	

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
            case funct3_i(2 downto 1) is
                when "00" =>
                    alu_op_o <= eq_op;    
                when "10" =>
                    alu_op_o <= lts_op;
                when others =>
                    alu_op_o <= ltu_op;
            end case;                                                                    
         when others =>
            case funct3_i is
               when "000" =>
                  alu_op_o <= add_op;
                  if(alu_2bit_op_i = "10" and funct7_i(5)='1' )then 
                     alu_op_o <= sub_op;
                  elsif alu_2bit_op_i = "10" and funct7_i(0) = '1' then
                     alu_op_o <= mulu_op;   
                  end if;
               when "001" =>
                  alu_op_o <= sll_op; 
                  if (alu_2bit_op_i = "10" and funct7_i(0) = '1') then
                    alu_op_o <= mulhs_op;
                  end if; 
               when "010" =>
                  alu_op_o <= lts_op;
                  if (alu_2bit_op_i = "10" and funct7_i(0) = '1') then
                    alu_op_o <= mulhsu_op;
                  end if;
               when "011" =>
                  alu_op_o <= ltu_op;
                  if (alu_2bit_op_i = "10" and funct7_i(0) = '1') then
                    alu_op_o <= mulhu_op;
                  end if;
               when "100" =>
                  alu_op_o <= xor_op;
                  if (alu_2bit_op_i = "10" and funct7_i(0) = '1') then
                    alu_op_o <= divs_op;
                  end if;                       
               when "101" =>
                  alu_op_o <= srl_op;  
                  if funct7_i(5) = '1' then
                    alu_op_o <= sra_op;
                  end if;                        
                  if (alu_2bit_op_i = "10" and funct7_i(0) = '1') then
                    alu_op_o <= divu_op;
                  end if;  
               when "110" =>
                  alu_op_o <= or_op;
                  if (alu_2bit_op_i = "10" and funct7_i(0) = '1') then
                    alu_op_o <= rems_op;
                  end if;  
               when others =>
                  alu_op_o <= and_op;
                  if (alu_2bit_op_i = "10" and funct7_i(0) = '1') then
                    alu_op_o <= remu_op;
                  end if;     
            end case;
      end case;
   end process;

end architecture;
