library ieee;
use ieee.std_logic_1164.all;

package controlpath_signals_pkg is

   --********** REGISTER CONTROL ***************
   signal if_id_en_s        : std_logic := '0';   
   signal if_id_flush_s     : std_logic := '0';   
   signal id_ex_flush_s     : std_logic := '0';   
   
   --*********  INSTRUCTION DECODE **************
   signal branch_id_s       : std_logic := '0';
   signal funct3_id_s       : std_logic_vector(2 downto 0) := (others=>'0');
   signal funct7_id_s       : std_logic_vector(6 downto 0) := (others=>'0');
   signal alu_2bit_op_id_s  : std_logic_vector(1 downto 0) := (others=>'0');
   signal control_pass_s    : std_logic := '0';
   signal rs1_in_use_id_s   : std_logic := '0';
   signal rs2_in_use_id_s   : std_logic := '0';
   signal alu_src_b_id_s    : std_logic := '0';
   signal data_mem_we_id_s  : std_logic := '0';
   signal rd_we_id_s        : std_logic := '0';
   signal mem_to_reg_id_s   : std_logic := '0';
   signal rs1_address_id_s  : std_logic_vector (4 downto 0) := (others=>'0');
   signal rs2_address_id_s  : std_logic_vector (4 downto 0) := (others=>'0');
   signal rd_address_id_s   : std_logic_vector (4 downto 0) := (others=>'0');
   signal bcc_id_s          : std_logic := '0';

   --*********       EXECUTE       **************
   signal branch_ex_s       : std_logic := '0';
   signal funct3_ex_s       : std_logic_vector(2 downto 0) := (others=>'0');
   signal funct7_ex_s       : std_logic_vector(6 downto 0) := (others=>'0');
   signal alu_2bit_op_ex_s  : std_logic_vector(1 downto 0) := (others=>'0');
   signal alu_src_b_ex_s    : std_logic := '0';
   signal data_mem_we_ex_s  : std_logic := '0';
   signal rd_we_ex_s        : std_logic := '0';
   signal mem_to_reg_ex_s   : std_logic := '0';


   signal rs1_address_ex_s  : std_logic_vector (4 downto 0) := (others=>'0');
   signal rs2_address_ex_s  : std_logic_vector (4 downto 0) := (others=>'0');
   signal rd_address_ex_s   : std_logic_vector (4 downto 0) := (others=>'0');

   --*********       MEMORY        **************
   signal data_mem_we_mem_s : std_logic := '0';
   signal rd_we_mem_s       : std_logic := '0';
   signal mem_to_reg_mem_s  : std_logic := '0';
   signal rd_address_mem_s  : std_logic_vector (4 downto 0) := (others=>'0');

   --*********      WRITEBACK      **************
   signal rd_we_wb_s        : std_logic := '0';
   signal mem_to_reg_wb_s   : std_logic := '0';
   signal rd_address_wb_s   : std_logic_vector (4 downto 0) := (others=>'0');


end package controlpath_signals_pkg;
