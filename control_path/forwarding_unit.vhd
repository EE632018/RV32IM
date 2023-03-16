library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity forwarding_unit is
   port (
      -- ulazi iz ID faze
      rs1_address_id_i   : in  std_logic_vector(4 downto 0);
      rs2_address_id_i   : in  std_logic_vector(4 downto 0);
      -- ulazi iz EX faze
      rs1_address_ex_i   : in  std_logic_vector(4 downto 0);
      rs2_address_ex_i   : in  std_logic_vector(4 downto 0);
      -- ulazi iz MEM faze
      rd_we_mem_i        : in  std_logic;
      rd_address_mem_i   : in  std_logic_vector(4 downto 0);
      -- ulazi iz WB faze
      rd_we_wb_i         : in  std_logic;
      rd_address_wb_i    : in  std_logic_vector(4 downto 0);
      -- izlazi za prosledjivanje operanada ALU jedinici
      alu_forward_a_o    : out std_logic_vector (1 downto 0);
      alu_forward_b_o    : out std_logic_vector(1 downto 0);
      -- izlazi za prosledjivanje operanada komparatoru za odredjivanje uslova skoka
      branch_forward_a_o : out std_logic;
      branch_forward_b_o : out std_logic);
end entity;

architecture Behavioral of forwarding_unit is
   constant zero_c : std_logic_vector (4 downto 0) := std_logic_vector(to_unsigned(0, 5));
begin

   -- proces koji kontrolise da li je potrebno prosledjivanje operanada ALU jedinici
   -- prosledjivanje iz MEM faze ima veci prioritet od prosledjivanja iz WB faze,
   -- zato sto je vrednost novija ('svezija')
   forward_proc : process(rd_we_mem_i, rd_address_mem_i, rd_we_wb_i, rd_address_wb_i,
                          rs1_address_ex_i, rs2_address_ex_i)is
   begin
      alu_forward_a_o <= "00";
      alu_forward_b_o <= "00";
      -- prosledjivanje signala iz WB faze
      if (rd_we_wb_i = '1' and rd_address_wb_i /= zero_c)then
         if (rd_address_wb_i = rs1_address_ex_i)then
            alu_forward_a_o <= "01";
         end if;
         if(rd_address_wb_i = rs2_address_ex_i)then
            alu_forward_b_o <= "01";
         end if;
      end if;
      -- prosledjivanje signala iz MEM faze
      if (rd_we_mem_i = '1' and rd_address_mem_i /= zero_c)then
         if (rd_address_mem_i = rs1_address_ex_i)then
            alu_forward_a_o <= "10";
         end if;
         if (rd_address_mem_i = rs2_address_ex_i)then
            alu_forward_b_o <= "10";
         end if;
      end if;
   end process;

   -- proces koji kontrolise da li je potrebno prosledjivanje operanada komparatoru za uslovne skokove
   -- prosledjivanje iz MEM faze ima veci prioritet od prosledjivanja iz WB faze,
   -- zato sto je vrednost novija ('svezija')
   forward_branch_proc : process(rd_we_mem_i, rd_address_mem_i, rd_we_wb_i, rd_address_wb_i,
                                 rs1_address_id_i, rs2_address_id_i)is
   begin
      branch_forward_b_o <= '0';
      branch_forward_a_o <= '0';      
      -- prosledjivanje signala iz MEM faze
      if (rd_we_mem_i = '1' and rd_address_mem_i /= zero_c)then
         if (rd_address_mem_i = rs1_address_id_i)then
            branch_forward_a_o <= '1'; --
         end if;
         if (rd_address_mem_i = rs2_address_id_i)then
            branch_forward_b_o <= '1';
         end if;
      end if;
   end process;
end architecture;
