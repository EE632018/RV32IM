library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_decoder is
   port (
      -- opcode instrukcije
      opcode_i      : in  std_logic_vector (6 downto 0);
      funct5_i      : in  std_logic_vector (4 downto 0);
      -- kontrolni signali
      branch_o      : out std_logic;
      mem_to_reg_o  : out std_logic_vector(1 downto 0);
      data_mem_we_o : out std_logic;
      alu_src_b_o   : out std_logic;
      rd_we_o       : out std_logic;
      rd_we_f_o     : out std_logic;
      rd_csr_we_o   : out std_logic;
      csr_int_mux_o : out std_logic;
      rs1_in_use_o  : out std_logic;
      rs2_in_use_o  : out std_logic;
      rd_mux_o      : out std_logic_vector(1 downto 0);
      alu_2bit_op_o : out std_logic_vector(1 downto 0);
      alu_f_bit_op_o: out std_logic_vector(2 downto 0);
      load_mux_o    : out std_logic;
      alu_mux_o     : out std_logic

      );
end entity;

architecture behavioral of ctrl_decoder is
begin

   contol_dec : process(opcode_i, funct5_i)is
   begin
      -- podrazumevane vrednosti
      alu_f_bit_op_o<= "000";
      alu_mux_o     <= '0';
      branch_o      <= '0';
      load_mux_o    <= '0';
      mem_to_reg_o  <= "00";
      data_mem_we_o <= '0';
      alu_src_b_o   <= '0';
      rd_we_o       <= '0';
      alu_2bit_op_o <= "00";
      rs1_in_use_o  <= '0';
      rs2_in_use_o  <= '0';
      rd_mux_o <= "00";
      rd_csr_we_o  <= '0';
      csr_int_mux_o <= '0';
      rd_we_f_o     <= '0';
      case opcode_i is
         when "0000011" =>              --LOAD
            alu_2bit_op_o <= "00";
            mem_to_reg_o  <= "01";
            alu_src_b_o   <= '1';
            rd_we_o       <= '1';
            rs1_in_use_o  <= '1';
         when "0000111" =>              --LOAD FLOAT
            alu_f_bit_op_o<= "110";
            mem_to_reg_o  <= "01";
            alu_src_b_o   <= '1';
            rd_we_f_o     <= '1';
            rs1_in_use_o  <= '1';   
         when "0110111" =>              --LUI
            alu_2bit_op_o <= "00";
            --mem_to_reg_o  <= '1';
            alu_src_b_o   <= '1';
            rd_we_o       <= '1';
            --rs1_in_use_o  <= '1';   
         when "0010111" =>              --AUIPC
            alu_2bit_op_o <= "00";
            --mem_to_reg_o  <= '1';
            alu_src_b_o   <= '1';
            rd_we_o       <= '1';
            rs1_in_use_o  <= '1';
            load_mux_o    <= '1';     
         when "0100011" =>              --STORE
            alu_2bit_op_o <= "00";
            data_mem_we_o <= '1';
            alu_src_b_o   <= '1';
            rs1_in_use_o  <= '1';
            rs2_in_use_o  <= '1';
         when "0100111" =>              --STORE FLOAT
            alu_f_bit_op_o<= "110";
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
         when "1101111" =>              -- J tip
            rd_mux_o      <= "01";
            rd_we_o       <= '1';
            mem_to_reg_o  <= "10";
            branch_o      <= '1';
         when "1100111" =>              -- J tip
            rd_mux_o      <= "10";
            mem_to_reg_o  <= "10";
            branch_o      <= '1';
            rd_we_o       <= '1';
         when "1110011" =>              -- CSR tip
            alu_2bit_op_o <= "00";
            mem_to_reg_o  <= "00";
            alu_src_b_o   <= '1';
            rd_csr_we_o   <= '1';
            csr_int_mux_o <= '1';
            rd_we_o       <= '1';
         when "1000011" =>             -- F type
            alu_f_bit_op_o <= "000";
            alu_mux_o     <= '1';
            rd_we_f_o     <= '1';
            rs1_in_use_o  <= '1';
            rs2_in_use_o  <= '1';
         when "1000111" =>
            alu_f_bit_op_o <= "001";
            alu_mux_o     <= '1';
            rd_we_f_o     <= '1';
            rs1_in_use_o  <= '1';
            rs2_in_use_o  <= '1';
         when "1001011" =>
            alu_f_bit_op_o <= "010";
            alu_mux_o     <= '1';
            rd_we_f_o     <= '1';
            rs1_in_use_o  <= '1';
            rs2_in_use_o  <= '1';
         when "1001111" =>
            alu_f_bit_op_o <= "011";
            alu_mux_o     <= '1';
            rd_we_f_o     <= '1';
            rs1_in_use_o  <= '1';
            rs2_in_use_o  <= '1';
         when "1010011" =>
            alu_f_bit_op_o <= "100";
            alu_mux_o     <= '1';
            rs1_in_use_o  <= '1';
            rs2_in_use_o  <= '1';
            if funct5_i(4) = '0' then
               rd_we_f_o     <= '1';
            else
               if(funct5_i = "11010" or funct5_i = "11110") then
                  rd_we_f_o     <= '1';
               else
                  rd_we_o       <= '1';
               end if;
            end if;
         when others =>
      end case;
   end process;

end architecture;

