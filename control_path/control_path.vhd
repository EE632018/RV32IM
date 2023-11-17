library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.controlpath_signals_pkg.all;

entity control_path is
   port (
      -- sinhronizacija
      clk                : in  std_logic;
      reset              : in  std_logic;
      -- instrukcija dolazi iz datapah-a
      instruction_i      : in  std_logic_vector (31 downto 0);
      -- Statusni signaln iz datapath celine
      branch_condition_i : in  std_logic;
      -- kontrolni signali koji se prosledjiuju u datapath
      mem_to_reg_o       : out std_logic_vector(1 downto 0);
      alu_op_o           : out std_logic_vector(4 downto 0);
      alu_op_f_o         : out std_logic_vector(4 downto 0);
      alu_mux_o          : out std_logic;
      alu_src_b_o        : out std_logic;
      rd_we_o            : out std_logic;
      rd_we_f_o          : out std_logic;
      pc_next_sel_o      : out std_logic;
      data_mem_we_o      : out std_logic_vector(3 downto 0);
      -- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
      alu_forward_a_o    : out std_logic_vector (1 downto 0);
      alu_forward_b_o    : out std_logic_vector (1 downto 0);
      alu_forward_c_o    : out std_logic_vector (1 downto 0);
      branch_forward_a_o : out std_logic;  -- mux a 
      branch_forward_b_o : out std_logic;   -- mux b
      -- kontrolni signal za resetovanje if/id registra
      if_id_flush_o      : out std_logic;
      -- kontrolni signali za zaustavljanje protocne obrade
      pc_en_o            : out std_logic;
      if_id_en_o         : out std_logic;
      funct3_ex_o        : out std_logic_vector(2 downto 0);
      rd_mux_o           : out std_logic_vector(1 downto 0);
      funct3_mem_o       : out std_logic_vector(2 downto 0);
      load_mux_o         : out std_logic;
      stall_i            : in std_logic;
      -- csr contorl signals
      csr_op_o           : out std_logic_vector(2 downto 0);
      imm_clr_o          : out std_logic;
      rd_csr_we_o        : out std_logic;
      csr_int_mux_o      : out std_logic
      );
end entity;


architecture behavioral of control_path is


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
   signal rd_we_f_id_s        : std_logic := '0';
   signal rd_csr_we_id_s    : std_logic := '0'; 
   signal csr_int_mux_id_s  : std_logic := '0'; 
   signal mem_to_reg_id_s   : std_logic_vector(1 downto 0) := (others=>'0');
   signal rs1_address_id_s  : std_logic_vector (4 downto 0) := (others=>'0');
   signal rs2_address_id_s  : std_logic_vector (4 downto 0) := (others=>'0');
   signal rs3_address_id_s  : std_logic_vector (4 downto 0) := (others=>'0');
   signal rd_address_id_s   : std_logic_vector (4 downto 0) := (others=>'0');
   signal bcc_id_s          : std_logic := '0';
   signal rd_mux_s          : std_logic_vector (1 downto 0) := (others=>'0');
   signal load_mux_s        : std_logic  := '0';
   signal imm_clr_id_s      : std_logic  := '0';
   signal alu_mux_id_s      : std_logic  := '0';
   signal alu_f_bit_op_id_s : std_logic_vector(2 downto 0) := (others => '0');

   --*********       EXECUTE       **************
   signal branch_ex_s       : std_logic := '0';
   signal funct3_ex_s       : std_logic_vector(2 downto 0) := (others=>'0');
   signal funct7_ex_s       : std_logic_vector(6 downto 0) := (others=>'0');
   signal alu_2bit_op_ex_s  : std_logic_vector(1 downto 0) := (others=>'0');
   signal alu_src_b_ex_s    : std_logic := '0';
   signal data_mem_we_ex_s  : std_logic := '0';
   signal rd_we_ex_s        : std_logic := '0';
   signal rd_we_f_ex_s        : std_logic := '0';
   signal rd_csr_we_ex_s    : std_logic := '0';
   signal mem_to_reg_ex_s   : std_logic_vector(1 downto 0) := (others=>'0');


   signal rs1_address_ex_s  : std_logic_vector (4 downto 0) := (others=>'0');
   signal rs2_address_ex_s  : std_logic_vector (4 downto 0) := (others=>'0');
   signal rs3_address_ex_s  : std_logic_vector (4 downto 0) := (others=>'0');
   signal rd_address_ex_s   : std_logic_vector (4 downto 0) := (others=>'0');
   
   signal rd_mux_ex_s       : std_logic_vector(1 downto 0) := (others=>'0');
   signal imm_clr_ex_s      : std_logic  := '0';

   signal alu_mux_ex_s      : std_logic  := '0';
   signal alu_f_bit_op_ex_s : std_logic_vector(2 downto 0) := (others => '0');
   --*********       MEMORY        **************
   signal data_mem_we_mem_s : std_logic := '0';
   signal rd_we_mem_s       : std_logic := '0';
   signal rd_we_f_mem_s       : std_logic := '0';
   signal rd_csr_we_mem_s    : std_logic := '0';
   signal mem_to_reg_mem_s  : std_logic_vector(1 downto 0) := (others=>'0');
   signal rd_address_mem_s  : std_logic_vector (4 downto 0) := (others=>'0');
   signal funct3_mem_s       : std_logic_vector(2 downto 0) := (others=>'0');
	
   --*********      WRITEBACK      **************
   signal rd_we_wb_s        : std_logic := '0';
   signal rd_we_f_wb_s        : std_logic := '0';
   signal rd_csr_we_wb_s    : std_logic := '0'; 
   signal mem_to_reg_wb_s   : std_logic_vector(1 downto 0) := (others=>'0');
   signal rd_address_wb_s   : std_logic_vector (4 downto 0) := (others=>'0');


   component csr_decoder
   port (
      -- opcode instrukcije
      opcode_i      : in  std_logic_vector (6 downto 0);
      funct3_i      : in  std_logic_vector (2 downto 0);
      csr_op_o      : out std_logic_vector (2 downto 0);
      imm_clr_o     : out std_logic  
      );
   end component;

   component alu_decoder_float
   port ( 
      -- from data_path
      alu_f_bit_op_i : in std_logic_vector(2 downto 0);
      funct3_i       : in std_logic_vector (2 downto 0);
      funct5_i       : in std_logic_vector (4 downto 0);
      rs2_i          : in std_logic_vector (4 downto 0);
      -- to data_path
      alu_op_f_o       : out std_logic_vector(4 downto 0)); 
   end component; 
begin


   --*********** Kombinaciona logika ******************

   -- izdvoji adrese operanada iz instrukcije
   rs1_address_id_s <= instruction_i(19 downto 15);
   rs2_address_id_s <= instruction_i(24 downto 20);
   rs3_address_id_s <= instruction_i(31 downto 27);
   rd_address_id_s  <= instruction_i(11 downto 7);

   funct7_id_s <= instruction_i(31 downto 25);
   funct3_id_s <= instruction_i(14 downto 12);

   -- signal upisa 32-bitnog podatka u memoriju se prosiruje na cetiri 
   -- memorija je bajt-adresibilna pa postoji we signal za svaki bajt na lokaciji sirine 32 bita  
   data_mem_write_enable :
      data_mem_we_o <= "1111" when data_mem_we_mem_s = '1' else
                       "0000";

   -- ovaj proces nadzire instrukcije skokova
   -- za uslovni skok
   --    kontrolise multiplekser za sledecu adresu PC-a
   --    resetuje if/id registar ukoliko je uslov zadovoljen
   pc_next_if_s : process(branch_ex_s, branch_condition_i, bcc_id_s)
   begin
      if_id_flush_s <= '0';
      pc_next_sel_o <= '0';
      if (branch_ex_s = '1' and branch_condition_i = '1')then
         pc_next_sel_o <= '1';
         if_id_flush_s <= '1';
      end if;
   end process;



   --*********** Sekvencijalna logika ******************
   --ID/EX registar
   id_ex : process (clk) is
   begin
      if (rising_edge(clk)) then
         if (reset = '0' or control_pass_s = '0' or if_id_flush_s = '1')then
            branch_ex_s      <= '0';
            funct3_ex_s      <= (others => '0');
            funct7_ex_s      <= (others => '0');
            alu_src_b_ex_s   <= '0';
            mem_to_reg_ex_s  <= (others => '0');
            alu_2bit_op_ex_s <= (others => '0');
            rs1_address_ex_s <= (others => '0');
            rs2_address_ex_s <= (others => '0');
            rs3_address_ex_s <= (others => '0');
            rd_address_ex_s  <= (others => '0');
            rd_mux_ex_s      <= (others => '0');
            rd_we_ex_s       <= '0';
            rd_we_f_ex_s       <= '0';
            rd_csr_we_ex_s   <= '0'; 
            data_mem_we_ex_s <= '0';
            imm_clr_ex_s     <= '0';
            alu_mux_ex_s     <= '0';
            alu_f_bit_op_ex_s<= (others => '0');
         else
            rd_mux_ex_s      <= rd_mux_s;
            branch_ex_s      <= branch_id_s;
            funct7_ex_s      <= funct7_id_s;
            funct3_ex_s      <= funct3_id_s;
            alu_src_b_ex_s   <= alu_src_b_id_s;
            mem_to_reg_ex_s  <= mem_to_reg_id_s;
            alu_2bit_op_ex_s <= alu_2bit_op_id_s;
            rs1_address_ex_s <= rs1_address_id_s;
            rs2_address_ex_s <= rs2_address_id_s;
            rs3_address_ex_s <= rs3_address_id_s;
            rd_address_ex_s  <= rd_address_id_s;
            rd_we_ex_s       <= rd_we_id_s;
            rd_we_f_ex_s     <= rd_we_f_id_s;
            rd_csr_we_ex_s   <= rd_csr_we_id_s;
            data_mem_we_ex_s <= data_mem_we_id_s;
            imm_clr_ex_s     <= imm_clr_id_s;
            alu_mux_ex_s     <= alu_mux_id_s;
            alu_f_bit_op_ex_s<= alu_f_bit_op_id_s;
         end if;
      end if;
   end process;

   --EX/MEM registar
   ex_mem : process (clk) is
   begin
      if (rising_edge(clk)) then
         if (reset = '0' or id_ex_flush_s = '1')then
            data_mem_we_mem_s <= '0';
            rd_we_mem_s       <= '0';
            rd_we_f_mem_s       <= '0';
            rd_csr_we_mem_s   <= '0';
            mem_to_reg_mem_s  <= (others => '0');
            funct3_mem_s      <= (others => '0');  
            rd_address_mem_s  <= (others => '0');
         else
            data_mem_we_mem_s <= data_mem_we_ex_s;
            rd_we_mem_s       <= rd_we_ex_s;
            rd_we_f_mem_s       <= rd_we_f_ex_s;
            rd_csr_we_mem_s   <= rd_csr_we_ex_s;
            funct3_mem_s      <= funct3_ex_s;
            mem_to_reg_mem_s  <= mem_to_reg_ex_s;
            rd_address_mem_s  <= rd_address_ex_s;
         end if;
      end if;
   end process;

   --MEM/WB registar
   mem_wb : process (clk) is
   begin
      if (rising_edge(clk)) then
         if (reset = '0')then
            rd_we_wb_s      <= '0';
            rd_we_f_wb_s      <= '0';
            rd_csr_we_wb_s   <= '0';
            mem_to_reg_wb_s <= (others => '0');
            rd_address_wb_s <= (others => '0');
         else
            rd_we_wb_s      <= rd_we_mem_s;
            rd_we_f_wb_s      <= rd_we_f_mem_s;
            rd_csr_we_wb_s   <= rd_csr_we_mem_s;
            mem_to_reg_wb_s <= mem_to_reg_mem_s;
            rd_address_wb_s <= rd_address_mem_s;
         end if;
      end if;
   end process;



   --*********** Instanciranje ******************

   -- Dekoder za kontrolne signale
   ctrl_dec : entity work.ctrl_decoder(behavioral)
      port map(
         opcode_i      => instruction_i(6 downto 0),
         funct5_i      => instruction_i(31 downto 27),
         branch_o      => branch_id_s,
         mem_to_reg_o  => mem_to_reg_id_s,
         data_mem_we_o => data_mem_we_id_s,
         alu_src_b_o   => alu_src_b_id_s,
         rd_we_o       => rd_we_id_s,
         rd_we_f_o     => rd_we_f_id_s,
         rd_csr_we_o   => rd_csr_we_id_s,
         csr_int_mux_o => csr_int_mux_id_s,
         rs1_in_use_o  => rs1_in_use_id_s,
         rs2_in_use_o  => rs2_in_use_id_s,
         rd_mux_o      => rd_mux_s,
         load_mux_o    => load_mux_s,
         alu_f_bit_op_o => alu_f_bit_op_id_s,
         alu_mux_o     => alu_mux_id_s,
         alu_2bit_op_o => alu_2bit_op_id_s);

   -- Dekoder za ALU operaciju
   alu_dec : entity work.alu_decoder(behavioral)
      port map(
         alu_2bit_op_i => alu_2bit_op_ex_s,
         funct3_i      => funct3_ex_s,
         funct7_i      => funct7_ex_s,
         alu_op_o      => alu_op_o);

   -- Jedinica za prosledjivanje operanada
   forwarding_u : entity work.forwarding_unit(behavioral)
      port map (
         rd_we_mem_i        => rd_we_mem_s,
         rd_address_mem_i   => rd_address_mem_s,
         rd_we_wb_i         => rd_we_wb_s,
         rd_address_wb_i    => rd_address_wb_s,
         rs1_address_ex_i   => rs1_address_ex_s,
         rs2_address_ex_i   => rs2_address_ex_s,
         rs3_address_ex_i   => rs3_address_ex_s,
         rs1_address_id_i   => rs1_address_id_s,
         rs2_address_id_i   => rs2_address_id_s,
         rs3_address_id_i   => rs3_address_id_s,
         alu_forward_a_o    => alu_forward_a_o,
         alu_forward_b_o    => alu_forward_b_o,
         alu_forward_c_o    => alu_forward_c_o,
         branch_forward_a_o => branch_forward_a_o,
         branch_forward_b_o => branch_forward_b_o);

   -- Jedinica za razresavanje hazarda
   hazard_u : entity work.hazard_unit(behavioral)
      port map (
         rs1_address_id_i => rs1_address_id_s,
         rs2_address_id_i => rs2_address_id_s,
         rs1_in_use_i     => rs1_in_use_id_s,
         rs2_in_use_i     => rs2_in_use_id_s,
         branch_id_i      => branch_id_s,

         rd_address_ex_i => rd_address_ex_s,
         mem_to_reg_ex_i => mem_to_reg_ex_s,
         rd_we_ex_i      => rd_we_ex_s,

         rd_address_mem_i => rd_address_mem_s,
         mem_to_reg_mem_i => mem_to_reg_mem_s,

         pc_en_o        => pc_en_o,
         if_id_en_o     => if_id_en_s,
         control_pass_o => control_pass_s,
         stall_i        => stall_i);

   crs_decoder_inst: csr_decoder
   port map(
      opcode_i => instruction_i(6 downto 0),
      funct3_i => funct3_id_s,
      csr_op_o => csr_op_o,
      imm_clr_o => imm_clr_id_s  
      );

   alu_decoder_float_inst: alu_decoder_float
   port map(
      alu_f_bit_op_i => alu_f_bit_op_ex_s,
      funct3_i => funct3_ex_s,
      funct5_i => funct7_ex_s(6 downto 2),
      rs2_i =>  rs2_address_ex_s,  
      alu_op_f_o => alu_op_f_o
   ); 
   --********** Izlazi **************

   -- prosledi kontrolne signale datapath-u
   if_id_en_o    <= if_id_en_s;
   mem_to_reg_o  <= mem_to_reg_wb_s;
   alu_src_b_o   <= alu_src_b_ex_s;
   rd_we_o       <= rd_we_wb_s;
   rd_we_f_o     <= rd_we_f_wb_s;
   if_id_flush_o <= if_id_flush_s;
   funct3_mem_o  <= funct3_mem_s;
   rd_mux_o      <= rd_mux_ex_s;
   load_mux_o    <= load_mux_s;
   funct3_ex_o   <= funct3_ex_s;
   imm_clr_o     <= imm_clr_ex_s;
   rd_csr_we_o   <= rd_csr_we_wb_s;
   csr_int_mux_o <= csr_int_mux_id_s; 
   alu_mux_o     <= alu_mux_ex_s;         
end architecture;

