library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TOP_RISCV is
   port(
      -- Globalna sinhronizacija
      clk                 : in  std_logic;
      reset               : in  std_logic;
      -- Interfejs ka memoriji za instrukcije
      instr_mem_address_o : out std_logic_vector(31 downto 0);
      instr_mem_read_i    : in  std_logic_vector(31 downto 0);
      -- Interfejs ka memoriji za podatke
      data_mem_address_o  : out std_logic_vector(31 downto 0);
      data_mem_read_i     : in  std_logic_vector(31 downto 0);
      data_mem_write_o    : out std_logic_vector(31 downto 0);
      data_mem_we_o       : out std_logic_vector(3 downto 0));  
end entity;

architecture structural of TOP_RISCV is

   signal instruction_s      : std_logic_vector(31 downto 0);

   signal mem_to_reg_s       : std_logic_vector(1 downto 0);
   signal alu_op_s           : std_logic_vector(4 downto 0);
   signal alu_op_f_s         : std_logic_vector(4 downto 0);
   signal alu_mux_s          : std_logic;
   signal alu_src_b_s        : std_logic;
   signal rd_we_s            : std_logic;
   signal pc_next_sel_s      : std_logic;

   signal if_id_flush_s      : std_logic;

   signal alu_forward_a_s    : std_logic_vector(1 downto 0);
   signal alu_forward_b_s    : std_logic_vector(1 downto 0);
   signal alu_forward_c_s    : std_logic_vector(1 downto 0);
   signal branch_forward_a_s : std_logic;
   signal branch_forward_b_s : std_logic;
   signal branch_condition_s : std_logic;

   signal pc_en_s            : std_logic;
   signal if_id_en_s         : std_logic;
   signal funct3_mem_s       : std_logic_vector(2 downto 0);
   signal funct3_ex_s        : std_logic_vector(2 downto 0);
   signal rd_mux_s           : std_logic_vector(1 downto 0);
   signal load_mux_s         : std_logic;
   signal stall_s            : std_logic;   
   signal csr_int_mux_s      : std_logic; 
   signal rd_csr_we_s        : std_logic;
   signal csr_op_s           : std_logic_vector(2 downto 0);
   signal imm_clr_s          : std_logic;  
   signal rd_we_f_s          : std_logic;
            
begin
   -- Instanca datapath-a
   data_path_1: entity work.data_path
      port map (
         -- sinhronizacija
         clk                 => clk,
         reset               => reset,
         -- interfejs ka memoriji za instrukcije
         instr_mem_address_o => instr_mem_address_o,
         instr_mem_read_i    => instr_mem_read_i,
         instruction_o       => instruction_s,
         -- interfejs ka memoriji za podatke
         data_mem_address_o  => data_mem_address_o,
         data_mem_write_o    => data_mem_write_o,
         data_mem_read_i     => data_mem_read_i,
         -- kontrolni signali koji dolaze iz controlpath-a
         mem_to_reg_i        => mem_to_reg_s,
         alu_op_i            => alu_op_s,
         alu_op_f_i          => alu_op_f_s,
         alu_mux_i           => alu_mux_s,
         alu_src_b_i         => alu_src_b_s,
         rd_we_i             => rd_we_s,
         rd_we_f_i           => rd_we_f_s,
         pc_next_sel_i       => pc_next_sel_s,
         branch_condition_o  => branch_condition_s,
         -- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
         alu_forward_a_i     => alu_forward_a_s,
         alu_forward_b_i     => alu_forward_b_s,
         alu_forward_c_i     => alu_forward_c_s,
         branch_forward_a_i  => branch_forward_a_s,
         branch_forward_b_i  => branch_forward_b_s,
         -- kontrolni signal za resetovanje if/id registra
         if_id_flush_i       => if_id_flush_s,
         -- kontrolni signali za zaustavljanje protocne obrade
         pc_en_i             => pc_en_s,
         funct3_mem_i        => funct3_mem_s,
         rd_mux_i            => rd_mux_s,
         rd_csr_we_i         => rd_csr_we_s,
         csr_int_mux_i       => csr_int_mux_s,
         if_id_en_i          => if_id_en_s,
         load_mux_i          => load_mux_s,
         funct3_ex_i         => funct3_ex_s,
         stall_o             => stall_s,
         csr_op_i            => csr_op_s,
         imm_clr_i           => imm_clr_s
         ); 


   -- Instanca controlpath-a
   control_path_1: entity work.control_path
      port map (
         -- sinhronizacija
         clk                 => clk,
         reset               => reset,
         -- instrukcija dolazi iz datapah-a
         instruction_i       => instruction_s,
         -- kontrolni signali koji se prosledjiuju u datapath
         mem_to_reg_o        => mem_to_reg_s,
         alu_op_o            => alu_op_s,
         alu_op_f_o          => alu_op_f_s,
         alu_mux_o           => alu_mux_s,   
         alu_src_b_o         => alu_src_b_s,
         rd_we_o             => rd_we_s,
         rd_we_f_o           => rd_we_f_s,
         pc_next_sel_o       => pc_next_sel_s,
         branch_condition_i  => branch_condition_s,
         -- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
         alu_forward_a_o     => alu_forward_a_s,
         alu_forward_b_o     => alu_forward_b_s,
         alu_forward_c_o     => alu_forward_c_s,
         branch_forward_a_o  => branch_forward_a_s,
         branch_forward_b_o  => branch_forward_b_s,
         -- kontrolni signal za resetovanje if/id registra
         data_mem_we_o       => data_mem_we_o,
         if_id_flush_o       => if_id_flush_s,
         -- kontrolni signali za zaustavljanje protocne obrade
         pc_en_o             => pc_en_s,
         rd_mux_o            => rd_mux_s,
         rd_csr_we_o         => rd_csr_we_s,
         csr_int_mux_o       => csr_int_mux_s,
         funct3_mem_o        => funct3_mem_s,
         funct3_ex_o         => funct3_ex_s,
         if_id_en_o          => if_id_en_s,
         load_mux_o          => load_mux_s,
         stall_i             => stall_s,
         csr_op_o            => csr_op_s,
         imm_clr_o           => imm_clr_s
         );
   
end architecture;
