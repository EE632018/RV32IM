library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.datapath_signals_pkg.all;


entity data_path is
   port(
      -- sinhronizacioni signali
      clk                 : in  std_logic;
      reset               : in  std_logic;
      -- interfejs ka memoriji za instrukcije
      instr_mem_address_o : out std_logic_vector (31 downto 0);
      instr_mem_read_i    : in  std_logic_vector(31 downto 0);
      instruction_o       : out std_logic_vector(31 downto 0);
      -- interfejs ka memoriji za podatke
      data_mem_address_o  : out std_logic_vector(31 downto 0);
      data_mem_write_o    : out std_logic_vector(31 downto 0);
      data_mem_read_i     : in  std_logic_vector (31 downto 0);
      -- kontrolni signali
      mem_to_reg_i        : in  std_logic_vector(1 downto 0);
      alu_op_i            : in  std_logic_vector (4 downto 0);
      alu_op_f_i          : in  std_logic_vector (4 downto 0);
      alu_mux_i           : in  std_logic;
      alu_src_b_i         : in  std_logic;
      pc_next_sel_i       : in  std_logic;
      rd_we_i             : in  std_logic;
      rd_we_f_i           : in  std_logic;
      rd_csr_we_i         : in  std_logic;
      csr_int_mux_i       : in  std_logic;
      branch_condition_o  : out std_logic;
      -- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
      alu_forward_a_i     : in  std_logic_vector (1 downto 0);
      alu_forward_b_i     : in  std_logic_vector (1 downto 0);
      alu_forward_c_i     : in  std_logic_vector (1 downto 0);
      branch_forward_a_i  : in  std_logic;
      branch_forward_b_i  : in  std_logic;
      -- kontrolni signal za resetovanje if/id registra
      if_id_flush_i       : in  std_logic;
      -- kontrolni signali za zaustavljanje protocne obrade
      pc_en_i             : in  std_logic;
      if_id_en_i          : in  std_logic;
      rd_mux_i            : in  std_logic_vector(1 downto 0);
      load_mux_i          : in  std_logic;
      funct3_mem_i        : in  std_logic_vector(2 downto 0);
      funct3_ex_i         : in  std_logic_vector(2 downto 0);
      stall_o             : out std_logic;
      csr_op_i            : in std_logic_vector(2 downto 0);
      imm_clr_i           : in std_logic
      );

end entity;


architecture Behavioral of data_path is

   --*********  INSTRUCTION FETCH  **************
   signal pc_reg_if_s             : std_logic_vector (31 downto 0) := (others=>'0');
   signal pc_next_if_s            : std_logic_vector (31 downto 0) := (others=>'0');
   signal pc_adder_if_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal instruction_if_s        : std_logic_vector (31 downto 0) := (others=>'0');
   signal immediate_extended_if_s : std_logic_vector (31 downto 0) := (others=>'0');
   
   signal  pht_addr_4bit_gshare_if_s, pht_addr_4bit_gshare_next_if_s : std_logic_vector(3 downto 0) := (others=>'0');        
   signal  pht_addr_4bit_pshare_if_s, pht_addr_4bit_pshare_next_if_s : std_logic_vector(3 downto 0) := (others=>'0');
   signal  pht_addr_4bit_GAg_if_s, pht_addr_4bit_GAg_next_if_s : std_logic_vector(6 downto 0) := (others=>'0');
   signal  pht_addr_4bit_PAp_if_s, pht_addr_4bit_PAp_next_if_s : std_logic_vector(6 downto 0) := (others=>'0');
   signal  predictions_next_if_s, predictions_if_s: std_logic_vector(3 downto 0) := (others=>'0');
   signal  final_pred_next_if_s, final_pred_if_s ,final_pred_s: std_logic := '0';
   signal  branch_inst_if_s: std_logic := '0';
   signal branch_adder_if_s       : std_logic_vector (31 downto 0) := (others=>'0');
   
   --*********  INSTRUCTION DECODE **************
   signal instruction_id_s        : std_logic_vector (31 downto 0) := (others=>'0');
   signal pc_adder_id_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal pc_reg_id_s             : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs1_data_id_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs1_data_mux_id_s       : std_logic_vector (31 downto 0) := (others=>'0');  
   signal rs1_csr_data_id_s       : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs2_data_id_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs1_data_f_id_s         : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs2_data_f_id_s         : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs3_data_f_id_s         : std_logic_vector (31 downto 0) := (others=>'0');
   signal immediate_extended_id_s : std_logic_vector (31 downto 0) := (others=>'0');
   signal immediate_extended_id_s2 : std_logic_vector (31 downto 0) := (others=>'0');
   signal branch_condition_b_ex_s : std_logic_vector (31 downto 0) := (others=>'0');
   signal branch_condition_a_ex_s : std_logic_vector (31 downto 0) := (others=>'0');
   
   signal rs1_address_id_s        : std_logic_vector (4 downto 0) := (others=>'0');
   signal rs2_address_id_s        : std_logic_vector (4 downto 0) := (others=>'0');
   signal rs3_address_id_s        : std_logic_vector (4 downto 0) := (others=>'0');
   signal rd_address_id_s         : std_logic_vector (4 downto 0) := (others=>'0');
   signal rd_data_csr_id_s        : std_logic_vector (31 downto 0) := (others=>'0');
   signal csr_address_id_s        : std_logic_vector (11 downto 0) := (others => '0');
   signal if_id_reg_flush_s       : std_logic := '0';
   signal funct3_id_s	           : std_logic_vector(2 downto 0) := (others=>'0');
   signal rd_mux_s                : std_logic_vector(1 downto 0) := (others=>'0');

   signal  pht_addr_4bit_gshare_ex_s: std_logic_vector(3 downto 0) := (others=>'0');        
   signal  pht_addr_4bit_pshare_ex_s: std_logic_vector(3 downto 0) := (others=>'0');
   signal  pht_addr_4bit_GAg_ex_s: std_logic_vector(6 downto 0) := (others=>'0');
   signal  pht_addr_4bit_PAp_ex_s: std_logic_vector(6 downto 0) := (others=>'0');

   signal predictions_id_s: std_logic_vector(3 downto 0) := (others=>'0');
   signal final_pred_id_s: std_logic := '0'; 
   signal  branch_inst_id_s: std_logic := '0';
   
    
   --*********       EXECUTE       **************
   signal instruction_ex_s        : std_logic_vector (31 downto 0) := (others=>'0');
   signal pc_adder_ex_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal immediate_extended_ex_s : std_logic_vector (31 downto 0) := (others=>'0');
   signal immediate_extended_ex_s2 : std_logic_vector (31 downto 0) := (others=>'0');
   signal alu_forward_a_ex_s      : std_logic_vector(31 downto 0) := (others=>'0');
   signal alu_forward_b_ex_s      : std_logic_vector(31 downto 0) := (others=>'0');
   signal alu_forward_a_f_ex_s      : std_logic_vector(31 downto 0) := (others=>'0');
   signal alu_forward_b_f_ex_s      : std_logic_vector(31 downto 0) := (others=>'0');
   signal alu_forward_c_f_ex_s      : std_logic_vector(31 downto 0) := (others=>'0');
   signal alu_zero_ex_s           : std_logic := '0';
   signal alu_of_ex_s             : std_logic := '0';
   signal b_ex_s, a_ex_s          : std_logic_vector(31 downto 0) := (others=>'0');
   signal b_ex_f_s, a_ex_f_s      : std_logic_vector(31 downto 0) := (others=>'0');
   signal c_ex_f_s                : std_logic_vector(31 downto 0) := (others=>'0'); 
   signal alu_result_ex_s         : std_logic_vector(31 downto 0) := (others=>'0');
   signal alu_result_f_ex_s       : std_logic_vector(31 downto 0) := (others=>'0');
   signal alu_result_mux_ex_s     : std_logic_vector(31 downto 0) := (others=>'0');
   signal rs1_data_ex_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs2_data_ex_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs1_data_f_ex_s         : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs2_data_f_ex_s         : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs3_data_f_ex_s         : std_logic_vector (31 downto 0) := (others=>'0'); 
   signal rd_data_csr_ex_s        : std_logic_vector (31 downto 0) := (others=>'0');
   signal rd_address_ex_s         : std_logic_vector (4 downto 0) := (others=>'0');
   signal csr_address_ex_s        : std_logic_vector (11 downto 0) := (others => '0');
   signal stall_s                 : std_logic;
   signal stall_f_s               : std_logic;
   signal pc_reg_ex_s             : std_logic_vector (31 downto 0) := (others=>'0');
   signal branch_adder_ex_s       : std_logic_vector (31 downto 0) := (others=>'0');

   signal  branch_inst_ex_s, bhr_ex_s: std_logic := '0';
   signal  taken_pred: std_logic_vector(3 downto 0) := (others=>'0');
   signal  branch_condition_s: std_logic := '0'; 

   signal  pht_addr_4bit_gshare_id_s: std_logic_vector(3 downto 0) := (others=>'0');        
   signal  pht_addr_4bit_pshare_id_s: std_logic_vector(3 downto 0) := (others=>'0');
   signal  pht_addr_4bit_GAg_id_s: std_logic_vector(6 downto 0) := (others=>'0');
   signal  pht_addr_4bit_PAp_id_s: std_logic_vector(6 downto 0) := (others=>'0');
   signal  final_pred_ex_s: std_logic := '0';
   signal  predictions_ex_s: std_logic_vector(3 downto 0) := (others=>'0');

   --*********       MEMORY        **************
   signal pc_adder_mem_s          : std_logic_vector (31 downto 0) := (others=>'0');
   signal alu_result_mem_s        : std_logic_vector(31 downto 0) := (others=>'0');
   signal rd_address_mem_s        : std_logic_vector (4 downto 0) := (others=>'0');
   signal rd_data_csr_mem_s       : std_logic_vector (31 downto 0) := (others=>'0');
   signal csr_address_mem_s       : std_logic_vector (11 downto 0) := (others => '0');
   signal rs2_data_mem_s          : std_logic_vector (31 downto 0) := (others=>'0');
   signal data_mem_read_mem_s     : std_logic_vector (31 downto 0) := (others=>'0');
   signal funct3_mem_s		      : std_logic_vector (2 downto 0) := (others => '0');
   signal data_mem_read_mem_s2    : std_logic_vector (31 downto 0) := (others => '0');
   signal alu_forward_b_mem_s     : std_logic_vector(31 downto 0) := (others=>'0'); -- sa registra ex ulaz u memoriju kada radimo store operaciju. 
   

   --*********      WRITEBACK      **************
   signal pc_adder_wb_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal alu_result_wb_s         : std_logic_vector(31 downto 0) := (others=>'0');
   signal rd_data_wb_s            : std_logic_vector (31 downto 0) := (others=>'0');
   signal rd_data_csr_wb_s        : std_logic_vector (31 downto 0) := (others=>'0');  
   signal rd_address_wb_s         : std_logic_vector (4 downto 0) := (others=>'0');
   signal csr_address_wb_s        : std_logic_vector (11 downto 0) := (others => '0');
   signal data_mem_read_wb_s      : std_logic_vector (31 downto 0) := (others=>'0');

   
    COMPONENT MHBP
     GENERIC(  WIDTH:      NATURAL := 4;
            WIDTH_BHR:  NATURAL := 3;
            WIDTH_PHT:  NATURAL := 7;
            row :       integer := 4;
            cols:       integer := 16);
  Port (    clk                         : in STD_LOGIC;
            reset                       : in STD_LOGIC;
            branch_addr_4bit            : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
            branch_addr_bhr_local       : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
            branch_addr_pht_gshare      : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
            branch_addr_pht_pshare      : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
            branch_addr_pht_GAg         : in STD_LOGIC_VECTOR (WIDTH_PHT-1 DOWNTO 0);
            branch_addr_pht_PAp         : in STD_LOGIC_VECTOR (WIDTH_PHT-1 DOWNTO 0);
            
            branch_inst                 : in STD_LOGIC;
            bhr_i                       : in STD_LOGIC;
            taken_pred                  : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0); -- signal telling if predictor was correct
            predictions                 : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
            final_pred                  : out STD_LOGIC;
            
            -- pht
            pht_addr_4bit_gshare        : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
            pht_addr_4bit_GAg           : out STD_LOGIC_VECTOR(WIDTH_PHT-1 DOWNTO 0);
            pht_addr_4bit_pshare        : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
            pht_addr_4bit_PAp           : out STD_LOGIC_VECTOR(WIDTH_PHT-1 DOWNTO 0)
            );
  END COMPONENT;  

  component csr
    generic(WIDTH:      positive := 32;
            WIDTH_ADDR: positive := 12);
    port   (clk            : in std_logic;
            reset          : in std_logic;

            rs1_address_i  : in std_logic_vector(WIDTH_ADDR - 1 downto 0);
            rs1_data_o     : out std_logic_vector(WIDTH - 1 downto 0);

            rd_we_i        : in std_logic;
            rd_address_i   : in std_logic_vector(WIDTH_ADDR - 1 downto 0);
            rd_data_i      : in std_logic_vector(WIDTH - 1 downto 0));
  end component;
  
  component register_bank_float
  generic (WIDTH: positive:= 32);
  port (clk            : in std_logic;
        reset          : in std_logic;
        
        rs1_address_i  : in std_logic_vector(4 downto 0);
        rs2_address_i  : in std_logic_vector(4 downto 0);
        rs3_address_i  : in std_logic_vector(4 downto 0);
        
        rs1_data_o     : out std_logic_vector(WIDTH - 1 downto 0);
        rs2_data_o     : out std_logic_vector(WIDTH - 1 downto 0);
        rs3_data_o     : out std_logic_vector(WIDTH - 1 downto 0);
        
        rd_we_i        : in std_logic;
        rd_address_i   : in std_logic_vector(4 downto 0);
        rd_data_i      : in std_logic_vector(WIDTH - 1 downto 0)
    );
  end component;

  component ALU_float
  GENERIC(
      WIDTH : NATURAL := 32);
   PORT(
      clk    : in std_logic;
      reset  : in std_logic;
      a_ii   : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);  
      a_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --prvi operand
      b_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --drugi operand
      c_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);  
      op_i   : in STD_LOGIC_VECTOR(4 DOWNTO 0); --selekcija operacije
      res_o  : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
      stall_o: out std_logic
      );
  end component;    
begin

   --***********  Sekvencijalna logika  ******************
   --Programski brojac
   pc_proc : process (clk) is
   begin
      if (rising_edge(clk)) then
         if (reset = '0')then
            pc_reg_if_s <= (others => '0');
         elsif (pc_en_i = '1') then
            pc_reg_if_s <= pc_next_if_s;
         end if;
      end if;
   end process;

   --IF/ID registar
   if_id : process (clk) is
   begin
      if (rising_edge(clk)) then
         if(if_id_en_i = '1')then
            if (reset = '0' or if_id_flush_i = '1')then
               pc_reg_id_s      <= (others => '0');
               pc_adder_id_s    <= (others => '0');
               instruction_id_s <= (others => '0');
               immediate_extended_id_s <= (others => '0');
               pht_addr_4bit_gshare_id_s <= (others => '0');       
               pht_addr_4bit_pshare_id_s <= (others => '0');
               pht_addr_4bit_GAg_id_s <= (others => '0');
               pht_addr_4bit_PAp_id_s <= (others => '0');
               predictions_id_s <= (others => '0');
               final_pred_id_s <= '0';
               branch_inst_id_s <= '0';
            else
               pc_reg_id_s      <= pc_reg_if_s;
               pc_adder_id_s    <= pc_adder_if_s;
               instruction_id_s <= instruction_if_s;
               immediate_extended_id_s <= immediate_extended_if_s;
               pht_addr_4bit_gshare_id_s <= pht_addr_4bit_gshare_if_s;       
               pht_addr_4bit_pshare_id_s <= pht_addr_4bit_pshare_if_s;
               pht_addr_4bit_GAg_id_s <= pht_addr_4bit_GAg_if_s;
               pht_addr_4bit_PAp_id_s <= pht_addr_4bit_PAp_if_s;
               predictions_id_s <= predictions_if_s;
               final_pred_id_s <= final_pred_if_s;
               branch_inst_id_s <= branch_inst_if_s;
            end if;
         end if;
      end if;
   end process;

   --ID/EX registar
   id_ex : process (clk) is
   begin
      if (rising_edge(clk)) then
          if(if_id_en_i = '1')then
             if (reset = '0' or if_id_flush_i = '1')then
                pc_adder_ex_s           <= (others => '0');
                rs1_data_ex_s           <= (others => '0');
                rs2_data_ex_s           <= (others => '0');
                rs1_data_f_ex_s         <= (others => '0');
                rs2_data_f_ex_s         <= (others => '0');
                rs3_data_f_ex_s         <= (others => '0');
                rd_data_csr_ex_s        <= (others => '0');
                immediate_extended_ex_s <= (others => '0');
                rd_address_ex_s         <= (others => '0');   
                csr_address_ex_s        <= (others => '0');
                pc_reg_ex_s             <= (others => '0');
                instruction_ex_s        <= (others => '0');
                pht_addr_4bit_gshare_ex_s <= (others => '0');       
                pht_addr_4bit_pshare_ex_s <= (others => '0');
                pht_addr_4bit_GAg_ex_s    <= (others => '0');
                pht_addr_4bit_PAp_ex_s    <= (others => '0');
                predictions_ex_s          <= (others => '0');
                final_pred_ex_s           <= '0';
                branch_inst_ex_s          <= '0';  
            else
                pc_reg_ex_s               <= pc_reg_id_s;
                pc_adder_ex_s             <= pc_adder_id_s;
                rs1_data_ex_s             <= rs1_data_mux_id_s;
                rs2_data_ex_s             <= rs2_data_id_s;
                rs1_data_f_ex_s           <= rs1_data_f_id_s;
                rs2_data_f_ex_s           <= rs2_data_f_id_s;
                rs3_data_f_ex_s           <= rs3_data_f_id_s;
                rd_data_csr_ex_s          <= rd_data_csr_id_s;  
                immediate_extended_ex_s   <= immediate_extended_id_s2;
                rd_address_ex_s           <= rd_address_id_s;
                csr_address_ex_s          <= csr_address_id_s;
                instruction_ex_s          <= instruction_id_s;
                pht_addr_4bit_gshare_ex_s <= pht_addr_4bit_gshare_id_s;       
                pht_addr_4bit_pshare_ex_s <= pht_addr_4bit_pshare_id_s;
                pht_addr_4bit_GAg_ex_s    <= pht_addr_4bit_GAg_id_s;
                pht_addr_4bit_PAp_ex_s    <= pht_addr_4bit_PAp_id_s;
                predictions_ex_s          <= predictions_id_s;
                final_pred_ex_s           <= final_pred_id_s;
                branch_inst_ex_s          <= branch_inst_id_s;  
             end if;
          end if;
      end if;
   end process;


   --EX/MEM registar
   ex_mem : process (clk) is
   begin
      if (rising_edge(clk)) then
         if (reset = '0')then
            alu_result_mem_s <= (others => '0');
            alu_forward_b_mem_s   <= (others => '0');
            pc_adder_mem_s   <= (others => '0');
            rd_address_mem_s <= (others => '0');
            csr_address_mem_s <= (others => '0');
            rd_data_csr_mem_s <= (others => '0');  
         else
            alu_result_mem_s <= alu_result_mux_ex_s;
            alu_forward_b_mem_s   <= alu_forward_b_ex_s;
            pc_adder_mem_s   <= pc_adder_ex_s;
            rd_address_mem_s <= rd_address_ex_s;
            rd_data_csr_mem_s          <= rd_data_csr_ex_s; 
            csr_address_mem_s <= csr_address_ex_s;
         end if;
      end if;
   end process;

   --MEM/WB registar
   mem_wb : process (clk) is
   begin
      if (rising_edge(clk)) then
         if (reset = '0')then
            alu_result_wb_s    <= (others => '0');
            pc_adder_wb_s      <= (others => '0');
            rd_address_wb_s    <= (others => '0');
            csr_address_wb_s   <= (others => '0');
            rd_data_csr_wb_s   <= (others => '0');
            data_mem_read_wb_s <= (others => '0');
         else
            alu_result_wb_s    <= alu_result_mem_s;
            pc_adder_wb_s      <= pc_adder_mem_s;
            rd_address_wb_s    <= rd_address_mem_s;
            rd_data_csr_wb_s          <= rd_data_csr_mem_s;
            csr_address_wb_s <= csr_address_mem_s;
            data_mem_read_wb_s <= data_mem_read_mem_s2;
         end if;
      end if;
   end process;


   --***********  Kombinaciona logika  ***************
   -- sabirac za uvecavanje programskog brojaca (sledeca instrukcija)
   pc_adder_if_s <= std_logic_vector(unsigned(pc_reg_if_s) + to_unsigned(4, 32));

   

   -- multiplekseri za prosledjivanje operanada komparatoru za proveravanje uslova za skok
   branch_condition_a_ex_s <= alu_result_mem_s when branch_forward_a_i = '1' else
                              rs1_data_ex_s;
   branch_condition_b_ex_s <= alu_result_mem_s when branch_forward_b_i = '1' else
                              rs2_data_ex_s;        

   -- provera uslova za skok
   funct3_id_s  <= instruction_id_s(14 downto 12);
   
   process(funct3_ex_i,alu_forward_a_ex_s,alu_forward_b_ex_s, instruction_ex_s)
   begin
        if(instruction_ex_s(6 downto 0) = "1100011") then
            case funct3_ex_i is
                when "000" => 
                    if  (signed(alu_forward_a_ex_s) = signed(alu_forward_b_ex_s)) then
                         branch_condition_s <= '1';
                    else
                        branch_condition_s <= '0';
                    end if;
                when "001" =>
                    if  (signed(alu_forward_a_ex_s) = signed(alu_forward_b_ex_s)) then
                         branch_condition_s <= '0';
                    else
                        branch_condition_s <= '1';
                    end if;             
                when "100" => 
                    if (signed(alu_forward_a_ex_s) < signed(alu_forward_b_ex_s)) then
                        branch_condition_s <= '1';
                    else
                        branch_condition_s <= '0';
                    end if;
                when "101" => 
                    if  (signed(alu_forward_a_ex_s) >= signed(alu_forward_b_ex_s)) then
                         branch_condition_s <= '1';
                    else
                        branch_condition_s <= '0';
                    end if;                
                when "110" =>
                    if  (unsigned(alu_forward_a_ex_s) < unsigned(alu_forward_b_ex_s)) then
                         branch_condition_s <= '1';
                    else
                        branch_condition_s <= '0';
                    end if;    
                 when "111" =>
                    if (unsigned(alu_forward_a_ex_s) >= unsigned(alu_forward_b_ex_s)) then
                         branch_condition_s <= '1';
                    else
                        branch_condition_s <= '0';
                    end if;
                 when others =>
                    if  (signed(alu_forward_a_ex_s) = signed(alu_forward_b_ex_s)) then
                         branch_condition_s <= '1';
                    else
                        branch_condition_s <= '0';
                    end if;       
            end case;
        elsif(instruction_ex_s(6 downto 0) = "1101111") then
            branch_condition_s <= '1';
        elsif(instruction_ex_s(6 downto 0) = "1100111") then
            branch_condition_s <= '1';
        else
            branch_condition_s <= '0';
        end if;
   end process;

   -- multiplekseri za prosledjivanje operanada iz kasnijih faza pajplajna
   alu_forward_a_ex_s <= rd_data_wb_s when alu_forward_a_i = "01" else
                         alu_result_mem_s when alu_forward_a_i = "10" else
                         (others => '0') when alu_forward_a_i = "11" else -- Ovo ubacujemo za slucajeve LUI i AUIPC
                         rs1_data_ex_s;
   alu_forward_b_ex_s <= rd_data_wb_s when alu_forward_b_i = "01" else
                         alu_result_mem_s when alu_forward_b_i = "10" else
                         (others => '0') when alu_forward_b_i = "11" else
                         rs2_data_ex_s;

    alu_forward_a_f_ex_s <= rd_data_wb_s when alu_forward_a_i = "01" else
                         alu_result_mem_s when alu_forward_a_i = "10" else
                         (others => '0') when alu_forward_a_i = "11" else -- Ovo ubacujemo za slucajeve LUI i AUIPC
                         rs1_data_f_ex_s;
    alu_forward_b_f_ex_s <= rd_data_wb_s when alu_forward_b_i = "01" else
                         alu_result_mem_s when alu_forward_b_i = "10" else
                         (others => '0') when alu_forward_b_i = "11" else
                         rs2_data_f_ex_s;                     
    alu_forward_c_f_ex_s <= rd_data_wb_s when alu_forward_c_i = "01" else
                            alu_result_mem_s when alu_forward_c_i = "10" else
                            (others => '0') when alu_forward_c_i = "11" else
                            rs3_data_f_ex_s;        
   -- multiplekser za biranje 'b' operanda alu jedinice
   b_ex_s <= immediate_extended_ex_s2 when alu_src_b_i = '1' else
             alu_forward_b_ex_s;

   a_ex_s <= alu_forward_a_ex_s;

   a_ex_f_s <= alu_forward_a_f_ex_s;
   b_ex_f_s <= alu_forward_b_f_ex_s when alu_src_b_i = '1' else
               immediate_extended_ex_s2;
   c_ex_f_s <= alu_forward_c_f_ex_s;

   -- Multiplekser koji bira izmedju operacija float i integer
   alu_result_mux_ex_s <= alu_result_ex_s when alu_mux_i = '0' else
                          alu_result_f_ex_s;  
   -- multiplekser koji selektuje sta se upisuje u odredisni registar
   rd_data_wb_s <= data_mem_read_wb_s when mem_to_reg_i = "01" else
                   pc_adder_wb_s      when mem_to_reg_i = "10" else
                   alu_result_wb_s;
   -- Ovo je podatak koji vracamo na csr registarsku banku, write faza izvrsavanja         
   --rd_data_csr_id_s <= rs1_data_id_s; 

   -- izdvoji adrese opereanada iz 32-bitne instrukcije
   rs1_address_id_s <= instruction_id_s(19 downto 15);
   rs2_address_id_s <= instruction_id_s(24 downto 20);
   rs3_address_id_s <= instruction_id_s(31 downto 27);
   rd_address_id_s  <= instruction_id_s(11 downto 7);
   csr_address_id_s <= instruction_id_s(31 downto 20);

   --***********  Instanciranje modula ***********
   -- Registarska banka
   register_bank_1 : entity work.register_bank
      generic map (
         WIDTH => 32)
      port map (
         clk           => clk,
         reset         => reset,
         rd_we_i       => rd_we_i,
         rs1_address_i => rs1_address_id_s,
         rs2_address_i => rs2_address_id_s,
         rs1_data_o    => rs1_data_id_s,
         rs2_data_o    => rs2_data_id_s,
         rd_address_i  => rd_address_wb_s,
         rd_data_i     => rd_data_wb_s);

    register_bank_float_1: register_bank_float
    generic map (
        WIDTH => 32)
     port map (
        clk           => clk,
        reset         => reset,
        rd_we_i       => rd_we_f_i,
        rs1_address_i => rs1_address_id_s,
        rs2_address_i => rs2_address_id_s,
        rs3_address_i => rs3_address_id_s,
        rs1_data_o    => rs1_data_f_id_s,
        rs2_data_o    => rs2_data_f_id_s,
        rs3_data_o    => rs3_data_f_id_s,
        rd_address_i  => rd_address_wb_s,
        rd_data_i     => rd_data_wb_s);

   -- Jedinice za prosirivanje konstante (immediate)
   immediate_1 : entity work.immediate
      port map (
         instruction_i        => instruction_if_s,
         immediate_extended_o => immediate_extended_if_s);

   -- ALU jedinica
   ALU_1 : entity work.ALU
      generic map (
         WIDTH => 32)
      port map (
         clk    => clk,
         reset  => reset,
         a_i    => a_ex_s,
         b_i    => b_ex_s,
         op_i   => alu_op_i,
         res_o  => alu_result_ex_s,
         stall_o=> stall_s
         --zero_o => alu_zero_ex_s,
         --of_o   => alu_of_ex_s
         );
    ALU_2  : ALU_float 
    generic map (
         WIDTH => 32)
      port map (
         clk    => clk,
         reset  => reset,
         a_ii   => a_ex_s,
         a_i    => a_ex_f_s, -- Mora da se napravi logika za povezivanje ovih signala, koju vrednost ce primati 
         b_i    => b_ex_f_s,
         c_i    => c_ex_f_s,
         op_i   => alu_op_f_i,
         res_o  => alu_result_f_ex_s,
         stall_o=> stall_f_s
         );       
    MHBP_INST:MHBP
    GENERIC MAP(WIDTH       => 4,
                WIDTH_BHR   => 3,
                WIDTH_PHT   => 7,
                row         => 4,
                cols        => 16)
    PORT MAP    (clk        => clk,
                 reset      => reset,
                 branch_addr_4bit           => pc_reg_if_s(3 downto 0),
                 branch_addr_bhr_local      => pc_reg_ex_s(3 downto 0),
                 branch_addr_pht_gshare     => pht_addr_4bit_gshare_ex_s,
                 branch_addr_pht_pshare     => pht_addr_4bit_pshare_ex_s, 
                 branch_addr_pht_GAg        => pht_addr_4bit_GAg_ex_s,
                 branch_addr_pht_PAp        => pht_addr_4bit_PAp_ex_s,
                 branch_inst                => branch_inst_ex_s,
                 bhr_i                      => branch_condition_s,
                 taken_pred                 => taken_pred, -- signal telling if predictor was correct, this needs additional logic in data path
                 predictions                => predictions_if_s,
                 final_pred                 => final_pred_s,
            -- pht
                 pht_addr_4bit_gshare       => pht_addr_4bit_gshare_if_s, 
                 pht_addr_4bit_GAg          => pht_addr_4bit_GAg_if_s, 
                 pht_addr_4bit_pshare       => pht_addr_4bit_pshare_if_s, 
                 pht_addr_4bit_PAp          => pht_addr_4bit_PAp_if_s
                 ); 
    
    CSR_INST: csr
    generic map(WIDTH       => 32,
                WIDTH_ADDR  => 12)
    port  map (clk  => clk,
            reset => reset,

            rs1_address_i  => csr_address_id_s,
            rs1_data_o     => rs1_csr_data_id_s,

            rd_we_i        => rd_csr_we_i,
            rd_address_i   => csr_address_wb_s,
            rd_data_i      => rd_data_csr_wb_s);
                 
    -- *******************************************************************        
    --                          ENDCOMPONENT             
    -- *******************************************************************   
    
    -- *******************************************************************        
    --       MUX INDICATING IF WE TAKE VALUE FOR REG_BANK OR CSR_BANK             
    -- *******************************************************************   
    process(csr_int_mux_i,rs1_data_id_s,rs1_csr_data_id_s)
    begin
        if csr_int_mux_i = '0' then
            rs1_data_mux_id_s <= rs1_data_id_s;
        else
            rs1_data_mux_id_s <= rs1_csr_data_id_s;
        end if;
    end process;

    -- *******************************************************************        
    --       MUX INDICATING SET/CLEAR IMM in EX phase             
    -- *******************************************************************          

    process(immediate_extended_ex_s, imm_clr_i)
    begin
        if imm_clr_i = '1' then
            immediate_extended_ex_s2 <= (others => '0');
        else
            immediate_extended_ex_s2 <= immediate_extended_ex_s;
        end if;
    end process;
    
    -- *******************************************************************        
    --       MUX INDICATING WHAT value will be written to CSR             
    -- ******************************************************************* 

    process(csr_op_i, rs1_data_id_s, rs1_csr_data_id_s, immediate_extended_id_s)
    begin
        case csr_op_i is
            when "000" =>
                rd_data_csr_id_s <= rs1_data_id_s;
            when "001" =>
                rd_data_csr_id_s <= rs1_data_id_s or rs1_csr_data_id_s;
            when "010" =>
                rd_data_csr_id_s <= not(rs1_data_id_s) and rs1_csr_data_id_s;
            when "011" =>
                rd_data_csr_id_s <= immediate_extended_id_s;
            when "100" =>
                rd_data_csr_id_s <= immediate_extended_id_s or rs1_csr_data_id_s;
            when "101" =>
                rd_data_csr_id_s <= not(immediate_extended_id_s) and rs1_csr_data_id_s;
            when others =>    
                rd_data_csr_id_s <= rs1_data_id_s;
        end case;
    end process;

    process(final_pred_s, branch_inst_if_s)
    begin
        if branch_inst_if_s = '1' then
            final_pred_if_s <= final_pred_s;
        else
            final_pred_if_s <= '0';
        end if; 
    end process;

    process(predictions_ex_s,branch_condition_s,branch_inst_ex_s)
    begin
        for i in 0 to 3 loop
            if branch_inst_ex_s = '1' then
                if predictions_ex_s(i) = branch_condition_s then
                    taken_pred(i) <= '1'; 
                else
                    taken_pred(i) <= '0';
                end if;
            else
                taken_pred(i) <= '0';
            end if;          
        end loop;
    end process;

    process(instruction_if_s, immediate_extended_if_s, pc_reg_if_s)
    begin
        branch_adder_if_s <= std_logic_vector(signed(immediate_extended_if_s) + signed(pc_reg_if_s));
        branch_inst_if_s <= '0';
        if instruction_if_s(6 downto 0) = "1100011" then
            branch_inst_if_s <= '1';
            branch_adder_if_s <= std_logic_vector(signed(immediate_extended_if_s) + signed(pc_reg_if_s));
        end if;
        if instruction_if_s(6 downto 0) = "1101111" then
            branch_inst_if_s <= '1';
            branch_adder_if_s <= std_logic_vector(signed(immediate_extended_if_s) + signed(pc_reg_if_s));
        end if;
--        if instruction_if_s(6 downto 0) = "1100111" then
--            branch_inst_if_s <= '1';
--        end if; 
    end process;

    process(branch_condition_s, final_pred_ex_s)
    begin
        if branch_condition_s = final_pred_ex_s then
            branch_condition_o <= '0';
        else
            branch_condition_o <= '1';
        end if;
    end process;
    
    process(pc_next_sel_i, final_pred_if_s, branch_condition_s, branch_adder_ex_s, pc_adder_ex_s, branch_adder_if_s, pc_adder_if_s)
    begin
        if pc_next_sel_i = '1' then
            if branch_condition_s = '1' then
                pc_next_if_s <= branch_adder_ex_s;
            else
                pc_next_if_s <= pc_adder_ex_s;
            end if;
        else
            if final_pred_if_s = '1' then
                pc_next_if_s <= branch_adder_if_s;
            else
                pc_next_if_s <= pc_adder_if_s;
            end if;
        end if;
    end process;
    
    stall_o <= stall_s or stall_f_s;


   --***********  Ulazi/Izlazi  ***************
   -- Ka controlpath-u
   instruction_o       <= instruction_id_s;
   -- Sa memorijom za instrukcije
   instr_mem_address_o <= pc_reg_if_s;
   instruction_if_s    <= instr_mem_read_i;
   -- Sa memorijom za podatke
   data_mem_address_o  <= alu_result_mem_s;
   data_mem_write_o    <= rs2_data_mem_s;
   data_mem_read_mem_s <= data_mem_read_i;
   funct3_mem_s        <= funct3_mem_i;
   rd_mux_s            <= rd_mux_i;
   

   
   -- Logika koja nam multipleksira koji tip Load instrukcije cemo raditi u sistemu
   process(funct3_mem_s,data_mem_read_mem_s)
   begin
        case funct3_mem_s is
            when "010" =>  data_mem_read_mem_s2 <= data_mem_read_mem_s;
            when "001" => data_mem_read_mem_s2 <=  (31 downto 16 => data_mem_read_mem_s(15)) & data_mem_read_mem_s(15 downto 0);
            when "101" => data_mem_read_mem_s2 <= (31 downto 16 => '0') & data_mem_read_mem_s(15 downto 0);
            when "000" => data_mem_read_mem_s2 <= (31 downto 8 => data_mem_read_mem_s(7)) & data_mem_read_mem_s(7 downto 0);
            when "100" => data_mem_read_mem_s2 <= (31 downto 8 => '0') & data_mem_read_mem_s(7 downto 0);
            when others => data_mem_read_mem_s2 <= data_mem_read_mem_s;
        end case;
   end process;

    -- Logika koja nam multipleksira koji tip Stoar instrukcije 
   process(funct3_mem_s,alu_forward_b_mem_s)
   begin
        case funct3_mem_s is
            when "010" =>  rs2_data_mem_s <= alu_forward_b_mem_s;
            when "001" => rs2_data_mem_s <=  (31 downto 16 => '0') & alu_forward_b_mem_s(15 downto 0);
            when "000" => rs2_data_mem_s <= (31 downto 8 => '0') & alu_forward_b_mem_s(7 downto 0);
            when others => rs2_data_mem_s <= alu_forward_b_mem_s;
        end case;
   end process;
   
   -- Logika za promenu adrese PC brojaca prilikom branch logike i skok
   process(rd_mux_s, immediate_extended_ex_s, pc_reg_ex_s, alu_forward_a_ex_s)
   begin
        case rd_mux_s is
        when "00" => -- sabirac za uslovne skokove
            branch_adder_ex_s <= std_logic_vector(signed(immediate_extended_ex_s) + signed(pc_reg_ex_s));
        when "01" =>
            -- sabirac za uslovne skokove jal
            branch_adder_ex_s <= std_logic_vector(signed(immediate_extended_ex_s) + signed(pc_reg_ex_s));
        when "10" => -- sabirac za uslovne skokove jalr
            branch_adder_ex_s <= std_logic_vector(signed(immediate_extended_ex_s) + signed(alu_forward_a_ex_s));
        when others => 
            -- sabirac za uslovne skokove
            branch_adder_ex_s <= std_logic_vector(signed(immediate_extended_ex_s) + signed(pc_reg_ex_s));
        end case;
   end process;

    immediate_extended_id_s2 <= std_logic_vector(signed(immediate_extended_id_s) + signed(pc_reg_id_s)) when load_mux_i = '1' else
                                std_logic_vector(signed(immediate_extended_id_s));
end architecture;


