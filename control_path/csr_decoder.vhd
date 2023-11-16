library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity csr_decoder is
   port (
      -- opcode instrukcije
      opcode_i      : in  std_logic_vector (6 downto 0);
      funct3_i      : in  std_logic_vector (2 downto 0);
      csr_op_o      : out std_logic_vector (2 downto 0);
      imm_clr_o     : out std_logic  
      );
end entity;

architecture behavioral of csr_decoder is
begin

    -- csr_op_i how it works
    -- value 000 - nothnig
    -- value 001 - set rs1
    -- value 010 - clear rs1
    -- value 011 - nothing imm
    -- value 100 - set imm
    -- value 101 - celar imm
    -- value others - nothing /

    process(opcode_i,funct3_i)
    begin
        csr_op_o    <= "000";
        imm_clr_o   <= '0';
        case opcode_i is
            when "1110011" => 

                case funct3_i is
                    when "001" =>
                        imm_clr_o   <= '1';
                    when "010" =>
                        csr_op_o    <= "001";
                        imm_clr_o   <= '1';
                    when "011" =>
                        csr_op_o    <= "010";
                        imm_clr_o   <= '1';
                    when "101" =>
                        csr_op_o    <= "011";
                        imm_clr_o   <= '1';
                    when "110" =>
                        csr_op_o    <= "100";
                        imm_clr_o   <= '1'; 
                    when "111" =>
                        csr_op_o    <= "101";
                        imm_clr_o   <= '1';
                    when others =>    
                end case;    
            when others =>
        end case;
    end process;    

end architecture;