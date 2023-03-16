library ieee;
use ieee.std_logic_1164.all;

package datapath_signals_pkg is


   --*********  INSTRUCTION FETCH  **************
   signal pc_reg_if_s             : std_logic_vector (31 downto 0) := (others=>'0');
   signal pc_next_if_s            : std_logic_vector (31 downto 0) := (others=>'0');
   signal pc_adder_if_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal instruction_if_s        : std_logic_vector (31 downto 0) := (others=>'0');

   --*********  INSTRUCTION DECODE **************
   signal instruction_id_s        : std_logic_vector (31 downto 0) := (others=>'0');
   signal pc_adder_id_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal pc_reg_id_s             : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs1_data_id_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs2_data_id_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal immediate_extended_id_s : std_logic_vector (31 downto 0) := (others=>'0');
   signal branch_condition_b_ex_s : std_logic_vector (31 downto 0) := (others=>'0');
   signal branch_condition_a_ex_s : std_logic_vector (31 downto 0) := (others=>'0');
   signal branch_adder_id_s       : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs1_address_id_s        : std_logic_vector (4 downto 0) := (others=>'0');
   signal rs2_address_id_s        : std_logic_vector (4 downto 0) := (others=>'0');
   signal rd_address_id_s         : std_logic_vector (4 downto 0) := (others=>'0');
   signal if_id_reg_flush_s       : std_logic := '0';

   --*********       EXECUTE       **************
   signal pc_adder_ex_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal immediate_extended_ex_s : std_logic_vector (31 downto 0) := (others=>'0');
   signal alu_forward_a_ex_s      : std_logic_vector(31 downto 0) := (others=>'0');
   signal alu_forward_b_ex_s      : std_logic_vector(31 downto 0) := (others=>'0');
   signal alu_zero_ex_s           : std_logic := '0';
   signal alu_of_ex_s             : std_logic := '0';
   signal b_ex_s, a_ex_s          : std_logic_vector(31 downto 0) := (others=>'0');
   signal alu_result_ex_s         : std_logic_vector(31 downto 0) := (others=>'0');
   signal rs1_data_ex_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs2_data_ex_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal rd_address_ex_s         : std_logic_vector (4 downto 0) := (others=>'0');

   --*********       MEMORY        **************
   signal pc_adder_mem_s          : std_logic_vector (31 downto 0) := (others=>'0');
   signal alu_result_mem_s        : std_logic_vector(31 downto 0) := (others=>'0');
   signal rd_address_mem_s        : std_logic_vector (4 downto 0) := (others=>'0');
   signal rs2_data_mem_s          : std_logic_vector (31 downto 0) := (others=>'0');
   signal data_mem_read_mem_s     : std_logic_vector (31 downto 0) := (others=>'0');

   --*********      WRITEBACK      **************
   signal pc_adder_wb_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal alu_result_wb_s         : std_logic_vector(31 downto 0) := (others=>'0');
   signal rd_data_wb_s            : std_logic_vector (31 downto 0) := (others=>'0');
   signal rd_address_wb_s         : std_logic_vector (4 downto 0) := (others=>'0');
   signal data_mem_read_wb_s      : std_logic_vector (31 downto 0) := (others=>'0');


end package datapath_signals_pkg;
