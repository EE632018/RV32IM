library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_decoder is
   port (
      -- opcode instrukcije
      opcode_i      : in  std_logic_vector (6 downto 0);
      -- kontrolni signali
      branch_o      : out std_logic;
      mem_to_reg_o  : out std_logic;
      data_mem_we_o : out std_logic;
      alu_src_b_o   : out std_logic;
      rd_we_o       : out std_logic;
      rs1_in_use_o  : out std_logic;
      rs2_in_use_o  : out std_logic;
      alu_2bit_op_o : out std_logic_vector(1 downto 0)

      );
end entity;

architecture behavioral of ctrl_decoder is
begin

   contol_dec : process(opcode_i)is
   begin
      -- podrazumevane vrednosti
      branch_o      <= '0';
      mem_to_reg_o  <= '0';
      data_mem_we_o <= '0';
      alu_src_b_o   <= '0';
      rd_we_o       <= '0';
      alu_2bit_op_o <= "00";
      rs1_in_use_o  <= '0';
      rs2_in_use_o  <= '0';
      case opcode_i is
         when "0000011" =>              --LOAD
            alu_2bit_op_o <= "00";
            mem_to_reg_o  <= '1';
            alu_src_b_o   <= '1';
            rd_we_o       <= '1';
            rs1_in_use_o  <= '1';
         when "0100011" =>              --STORE
            alu_2bit_op_o <= "00";
            data_mem_we_o <= '1';
            alu_src_b_o   <= '1';
            rs1_in_use_o  <= '1';
            rs2_in_use_o  <= '1';
         when "0110011" =>              --R tip
            alu_2bit_op_o <= "10";
            rd_we_o       <= '1';
            rs1_in_use_o  <= '1';
            rs2_in_use_o  <= '1';
         when "0010011" =>              --I tip
            alu_2bit_op_o <= "11";
            alu_src_b_o   <= '1';
            rd_we_o       <= '1';
            rs1_in_use_o  <= '1';
         when "1100011" =>              --B tip
            alu_2bit_op_o <= "01";
            branch_o      <= '1';
         when others =>
      end case;
   end process;

end architecture;

