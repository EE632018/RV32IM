library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazard_unit is
   port (
      -- ulazni signali
      rs1_address_id_i : in std_logic_vector(4 downto 0);
      rs2_address_id_i : in std_logic_vector(4 downto 0);
      rs1_in_use_i     : in std_logic;
      rs2_in_use_i     : in std_logic;
      branch_id_i      : in std_logic;
      rd_address_ex_i  : in std_logic_vector(4 downto 0);
      mem_to_reg_ex_i  : in std_logic;
      rd_we_ex_i       : in std_logic;
      rd_address_mem_i : in std_logic_vector(4 downto 0);
      mem_to_reg_mem_i : in std_logic;
      -- izlazni kontrolni signali
      -- pc_en_o je signal dozvole rada za pc registar
      pc_en_o          : out std_logic; 
      -- if_id_en_o je signal dozvole rada za if/id registar
      if_id_en_o       : out std_logic; 
      -- control_pass_o kontrolise da li ce u execute fazu biti prosledjeni
      --   kontrolni signali iz ctrl_decoder-a ili sve nule 
      control_pass_o   : out std_logic 
      );
end entity;


architecture behavioral of hazard_unit is
   signal en_s:std_logic:='0';
   signal pass_ctrl_s:std_logic:='0';
begin

   
   -- protocna obrada se zaustavlja kada se detektuje hazard tako sto se:
   -- 1) enable signali PC i IF/ID registara postavljaju na nulu
   -- 2) kontrolni signali u ID/EX fazi resetuju cime se ne propagira njihov uticaj u dalje faze protocne orade
   process (rs1_address_id_i, rs2_address_id_i, branch_id_i, rd_address_ex_i, rd_we_ex_i,
            rd_address_mem_i, mem_to_reg_ex_i, mem_to_reg_mem_i, rs1_in_use_i, rs2_in_use_i) is
   begin
      en_s <= '1';
      if (branch_id_i = '0') then -- instrukcija u ID fazi nije skok
         if(((rs1_address_id_i = rd_address_ex_i and rs1_in_use_i = '1') or
            (rs2_address_id_i = rd_address_ex_i and rs2_in_use_i = '1')) and
            mem_to_reg_ex_i = '1' and rd_we_ex_i = '1')then -- load instrukcija je u EX fazi
            en_s <='0';
         end if;
      elsif(branch_id_i = '1')then -- instrukcija u ID fazi je uslovni skok (branch)
         if((rs1_address_id_i = rd_address_ex_i or rs2_address_id_i = rd_address_ex_i)
            and rd_we_ex_i = '1')then -- load ili R-tip u EX fazi
            en_s <='0';
         elsif((rs1_address_id_i = rd_address_mem_i or rs2_address_id_i = rd_address_mem_i)
            and mem_to_reg_mem_i = '1')then -- load u MEM fazi
            en_s <='0';
         end if;
      end if;
   end process;

   -- prosledi kontrolni signal na izlaze za zaustavljanje protocne obrade
   pc_en_o         <= en_s;
   if_id_en_o      <= en_s;
   control_pass_o  <= en_s;
   
end architecture;
