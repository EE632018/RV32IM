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
      alu_src_b_i         : in  std_logic;
      pc_next_sel_i       : in  std_logic;
      rd_we_i             : in  std_logic;
      branch_condition_o  : out std_logic;
      -- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
      alu_forward_a_i     : in  std_logic_vector (1 downto 0);
      alu_forward_b_i     : in  std_logic_vector (1 downto 0);
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
      stall_o             : out std_logic
      );

end entity;


architecture Behavioral of data_path is

   --*********  INSTRUCTION FETCH  **************
   signal pc_reg_if_s             : std_logic_vector (31 downto 0) := (others=>'0');
   signal pc_next_if_s            : std_logic_vector (31 downto 0) := (others=>'0');
   signal pc_adder_if_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal instruction_if_s        : std_logic_vector (31 downto 0) := (others=>'0');

   signal  pht_addr_4bit_gshare_if_s, pht_addr_4bit_gshare_next_if_s : std_logic_vector(3 downto 0);        
   signal  pht_addr_4bit_pshare_if_s, pht_addr_4bit_pshare_next_if_s : std_logic_vector(3 downto 0);
   signal  pht_addr_4bit_GAg_if_s, pht_addr_4bit_GAg_next_if_s : std_logic_vector(6 downto 0);
   signal  pht_addr_4bit_PAp_if_s, pht_addr_4bit_PAp_next_if_s : std_logic_vector(6 downto 0);
   signal  predictions_next_if_s, predictions_if_s: std_logic_vector(3 downto 0);
   signal  final_pred_next_if_s, final_pred_if_s: std_logic;
   --*********  INSTRUCTION DECODE **************
   signal instruction_id_s        : std_logic_vector (31 downto 0) := (others=>'0');
   signal pc_adder_id_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal pc_reg_id_s             : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs1_data_id_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal rs2_data_id_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal immediate_extended_id_s : std_logic_vector (31 downto 0) := (others=>'0');
   signal immediate_extended_id_s2 : std_logic_vector (31 downto 0) := (others=>'0');
   signal branch_condition_b_ex_s : std_logic_vector (31 downto 0) := (others=>'0');
   signal branch_condition_a_ex_s : std_logic_vector (31 downto 0) := (others=>'0');
   
   signal rs1_address_id_s        : std_logic_vector (4 downto 0) := (others=>'0');
   signal rs2_address_id_s        : std_logic_vector (4 downto 0) := (others=>'0');
   signal rd_address_id_s         : std_logic_vector (4 downto 0) := (others=>'0');
   signal if_id_reg_flush_s       : std_logic := '0';
   signal funct3_id_s	           : std_logic_vector(2 downto 0) := (others=>'0');
   signal rd_mux_s                : std_logic_vector(1 downto 0) := (others=>'0');

   signal  pht_addr_4bit_gshare_ex_s: std_logic_vector(3 downto 0);        
   signal  pht_addr_4bit_pshare_ex_s: std_logic_vector(3 downto 0);
   signal  pht_addr_4bit_GAg_ex_s: std_logic_vector(6 downto 0);
   signal  pht_addr_4bit_PAp_ex_s: std_logic_vector(6 downto 0);

   signal predictions_id_s: std_logic_vector(3 downto 0);
   signal final_pred_id_s: std_logic;
   --*********       EXECUTE       **************
   signal instruction_ex_s        : std_logic_vector (31 downto 0) := (others=>'0');
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
   signal stall_s                 : std_logic;
   signal pc_reg_ex_s             : std_logic_vector (31 downto 0) := (others=>'0');
   signal branch_adder_ex_s       : std_logic_vector (31 downto 0) := (others=>'0');

   signal  branch_inst_ex_s, bhr_ex_s: std_logic;
   signal  taken_pred: std_logic_vector(3 downto 0); 

   signal  pht_addr_4bit_gshare_id_s: std_logic_vector(3 downto 0);        
   signal  pht_addr_4bit_pshare_id_s: std_logic_vector(3 downto 0);
   signal  pht_addr_4bit_GAg_id_s: std_logic_vector(6 downto 0);
   signal  pht_addr_4bit_PAp_id_s: std_logic_vector(6 downto 0);
   signal  final_pred_ex_s: std_logic;
   signal  predictions_ex_s: std_logic_vector(3 downto 0);
   --*********       MEMORY        **************
   signal pc_adder_mem_s          : std_logic_vector (31 downto 0) := (others=>'0');
   signal alu_result_mem_s        : std_logic_vector(31 downto 0) := (others=>'0');
   signal rd_address_mem_s        : std_logic_vector (4 downto 0) := (others=>'0');
   signal rs2_data_mem_s          : std_logic_vector (31 downto 0) := (others=>'0');
   signal data_mem_read_mem_s     : std_logic_vector (31 downto 0) := (others=>'0');
   signal funct3_mem_s		   : std_logic_vector (2 downto 0) := (others => '0');
   signal data_mem_read_mem_s2    : std_logic_vector (31 downto 0) := (others => '0');
   signal alu_forward_b_mem_s      : std_logic_vector(31 downto 0) := (others=>'0'); -- sa registra ex ulaz u memoriju kada radimo store operaciju. 
   

   --*********      WRITEBACK      **************
   signal pc_adder_wb_s           : std_logic_vector (31 downto 0) := (others=>'0');
   signal alu_result_wb_s         : std_logic_vector(31 downto 0) := (others=>'0');
   signal rd_data_wb_s            : std_logic_vector (31 downto 0) := (others=>'0');
   signal rd_address_wb_s         : std_logic_vector (4 downto 0) := (others=>'0');
   signal data_mem_read_wb_s      : std_logic_vector (31 downto 0) := (others=>'0');

   -- Instanca branch predictora MDBP
   COMPONENT MDBP
   GENERIC( WIDTH:      NATURAL := 4;
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
            pht_addr_4bit_gshare_if_s <= pht_addr_4bit_gshare_next_if_s;       
            pht_addr_4bit_pshare_if_s <= pht_addr_4bit_pshare_next_if_s;
            pht_addr_4bit_GAg_if_s <= pht_addr_4bit_GAg_next_if_s;
            pht_addr_4bit_PAp_if_s <= pht_addr_4bit_PAp_next_if_s;
            predictions_if_s <= predictions_next_if_s;
            final_pred_if_s <= final_pred_next_if_s;
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
            else
               pc_reg_id_s      <= pc_reg_if_s;
               pc_adder_id_s    <= pc_adder_if_s;
               instruction_id_s <= instruction_if_s;
               pht_addr_4bit_gshare_id_s <= pht_addr_4bit_gshare_if_s;       
               pht_addr_4bit_pshare_id_s <= pht_addr_4bit_pshare_if_s;
               pht_addr_4bit_GAg_id_s <= pht_addr_4bit_GAg_if_s;
               pht_addr_4bit_PAp_id_s <= pht_addr_4bit_PAp_if_s;
               predictions_id_s <= predictions_if_s;
               final_pred_id_s <= final_pred_if_s;
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
                immediate_extended_ex_s <= (others => '0');
                rd_address_ex_s         <= (others => '0');
                pc_reg_ex_s             <= (others => '0');
                instruction_ex_s        <= (others => '0');
             else
                pc_reg_ex_s               <= pc_reg_id_s;
                pc_adder_ex_s             <= pc_adder_id_s;
                rs1_data_ex_s             <= rs1_data_id_s;
                rs2_data_ex_s             <= rs2_data_id_s;
                immediate_extended_ex_s   <= immediate_extended_id_s2;
                rd_address_ex_s           <= rd_address_id_s;
                instruction_ex_s          <= instruction_id_s;
                pht_addr_4bit_gshare_ex_s <= pht_addr_4bit_gshare_id_s;       
                pht_addr_4bit_pshare_ex_s <= pht_addr_4bit_pshare_id_s;
                pht_addr_4bit_GAg_ex_s    <= pht_addr_4bit_GAg_id_s;
                pht_addr_4bit_PAp_ex_s    <= pht_addr_4bit_PAp_id_s;
                predictions_ex_s          <= predictions_id_s;
                final_pred_ex_s           <= final_pred_id_s;
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
         else
            alu_result_mem_s <= alu_result_ex_s;
            alu_forward_b_mem_s   <= alu_forward_b_ex_s;
            pc_adder_mem_s   <= pc_adder_ex_s;
            rd_address_mem_s <= rd_address_ex_s;
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
            data_mem_read_wb_s <= (others => '0');
         else
            alu_result_wb_s    <= alu_result_mem_s;
            pc_adder_wb_s      <= pc_adder_mem_s;
            rd_address_wb_s    <= rd_address_mem_s;
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
                         branch_condition_o <= '1';
                    else
                        branch_condition_o <= '0';
                    end if;
                when "001" =>
                    if  (signed(alu_forward_a_ex_s) = signed(alu_forward_b_ex_s)) then
                         branch_condition_o <= '0';
                    else
                        branch_condition_o <= '1';
                    end if;             
                when "100" => 
                    if (signed(alu_forward_a_ex_s) < signed(alu_forward_b_ex_s)) then
                        branch_condition_o <= '1';
                    else
                        branch_condition_o <= '0';
                    end if;
                when "101" => 
                    if  (signed(alu_forward_a_ex_s) >= signed(alu_forward_b_ex_s)) then
                         branch_condition_o <= '1';
                    else
                        branch_condition_o <= '0';
                    end if;                
                when "110" =>
                    if  (unsigned(alu_forward_a_ex_s) < unsigned(alu_forward_b_ex_s)) then
                         branch_condition_o <= '1';
                    else
                        branch_condition_o <= '0';
                    end if;    
                 when "111" =>
                    if (unsigned(alu_forward_a_ex_s) >= unsigned(alu_forward_b_ex_s)) then
                         branch_condition_o <= '1';
                    else
                        branch_condition_o <= '0';
                    end if;
                 when others =>
                    if  (signed(alu_forward_a_ex_s) = signed(alu_forward_b_ex_s)) then
                         branch_condition_o <= '1';
                    else
                        branch_condition_o <= '0';
                    end if;       
            end case;
        elsif(instruction_ex_s(6 downto 0) = "1101111") then
            branch_condition_o <= '1';
        elsif(instruction_ex_s(6 downto 0) = "1100111") then
            branch_condition_o <= '1';
        else
            branch_condition_o <= '0';
        end if;
   end process;
   
   
   --branch_condition_o <= '1' when (signed(branch_condition_a_ex_s) = signed(branch_condition_b_ex_s)) else
     --                    '0';

   -- multiplekser za azuriranje programskog brojaca
   
   with pc_next_sel_i select
      pc_next_if_s <= pc_adder_if_s         when '0',
                      branch_adder_ex_s     when others;

   -- multiplekseri za prosledjivanje operanada iz kasnijih faza pajplajna
   alu_forward_a_ex_s <= rd_data_wb_s when alu_forward_a_i = "01" else
                         alu_result_mem_s when alu_forward_a_i = "10" else
                         (others => '0') when alu_forward_a_i = "11" else -- Ovo ubacujemo za slucajeve LUI i AUIPC
                         rs1_data_ex_s;
   alu_forward_b_ex_s <= rd_data_wb_s when alu_forward_b_i = "01" else
                         alu_result_mem_s when alu_forward_b_i = "10" else
                         rs2_data_ex_s;

   -- multiplekser za biranje 'b' operanda alu jedinice
   b_ex_s <= immediate_extended_ex_s when alu_src_b_i = '1' else
             alu_forward_b_ex_s;

   a_ex_s <= alu_forward_a_ex_s;

   -- multiplekser koji selektuje sta se upisuje u odredisni registar
   rd_data_wb_s <= data_mem_read_wb_s when mem_to_reg_i = "01" else
                   pc_adder_wb_s      when mem_to_reg_i = "10" else
                   alu_result_wb_s;

   -- izdvoji adrese opereanada iz 32-bitne instrukcije
   rs1_address_id_s <= instruction_id_s(19 downto 15);
   rs2_address_id_s <= instruction_id_s(24 downto 20);
   rd_address_id_s  <= instruction_id_s(11 downto 7);
   stall_o <= stall_s;


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

   -- Jedinice za prosirivanje konstante (immediate)
   immediate_1 : entity work.immediate
      port map (
         instruction_i        => instruction_id_s,
         immediate_extended_o => immediate_extended_id_s);

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
   
   -- MDBP 
   MDBP_INST: MDBP
   GENERIC MAP(   WIDTH       => 4,
                  WIDTH_BHR   => 3,
                  WIDTH_PHT   => 7,
                  row         => 4,
                  cols        => 16);
  Port (    clk                        => clk,
            reset                      => reset,
            branch_addr_4bit           => pc_reg_if_s(WIDTH-1 downto 0),
            branch_addr_bhr_local      => pc_reg_ex_s(WIDTH-1 downto 0),
            branch_addr_pht_gshare     => pht_addr_4bit_gshare_ex_s,
            branch_addr_pht_pshare     => pht_addr_4bit_pshare_ex_s, 
            branch_addr_pht_GAg        => pht_addr_4bit_GAg_ex_s,
            branch_addr_pht_PAp        => pht_addr_4bit_PAp_ex_s,
            branch_inst                => branch_inst_ex_s,
            bhr_i                      => bhr_ex_s,
            taken_pred                 => taken_pred, -- signal telling if predictor was correct, this needs additional logic in data path
            predictions                => predictions_next_if_s,
            final_pred                 => final_pred_next_if_s,
            -- pht
            pht_addr_4bit_gshare       => pht_addr_4bit_gshare_next_if_s, 
            pht_addr_4bit_GAg          => pht_addr_4bit_GAg_next_if_s, 
            pht_addr_4bit_pshare       => pht_addr_4bit_pshare_next_if_s, 
            pht_addr_4bit_PAp          => pht_addr_4bit_PAp_next_if_s   
            );
end architecture;


