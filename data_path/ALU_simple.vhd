LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;
use work.alu_ops_pkg.all;

ENTITY ALU IS
   GENERIC(
      WIDTH : NATURAL := 32);
   PORT(
      clk    : in std_logic;
      reset  : in std_logic;  
      a_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --prvi operand
      b_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --drugi operand
      op_i   : in STD_LOGIC_VECTOR(4 DOWNTO 0); --selekcija operacije
      res_o  : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
      stall_o: out std_logic
      ); --rezultatinteger
      --zero_o : out STD_LOGIC; --signalni bit jednakosti nuli
      --of_o   : out STD_LOGIC); --signalni bit prekoracenja opsega
END ALU;

ARCHITECTURE behavioral OF ALU IS
    
    component multiply
    Port (clk   : in std_logic;
      reset : in std_logic;
      con_s : in std_logic_vector(1 downto 0);
      a_in  : in std_logic_vector(31 downto 0);
      b_in  : in std_logic_vector(31 downto 0);
      c_out  : out std_logic_vector(63 downto 0);
      stall_status: out std_logic;
      start_status: in std_logic   
     );            
    end component;
   
   component division_u
   Port (clk           : in std_logic;
      reset         : in std_logic;
      start_i       : in std_logic;
      SorU          : in std_logic;
      dividend_i    : in std_logic_vector(31 downto 0);
      divisor_i     : in std_logic_vector(31 downto 0);
      quotient_o    : out std_logic_vector(31 downto 0);
      remainder_o   : out std_logic_vector(31 downto 0);
      stall_o       : out std_logic);
   end component; 
   
   constant  l2WIDTH : natural := integer(ceil(log2(real(WIDTH))));
   signal    add_res, sub_res, or_res, and_res,res_s, eq_res :  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
   signal    sll_res, slt_res, sltu_res, xor_res, srl_res, sra_res: std_logic_vector(WIDTH-1 DOWNTO 0); 
   signal    b_u: integer := 0;  
   signal    mul_res, mulhu_res, mulhsu_res  : std_logic_vector(2*WIDTH-1 downto 0);
   signal    rem_res, div_res : std_logic_vector(WIDTH-1 downto 0);
   attribute use_dsp: string;
   attribute use_dsp of Behavioral: architecture is "yes";
   
      -- ALU OP CODE
   constant and_op: std_logic_vector (4 downto 0):="00000"; ---> bitwise and
   constant or_op: std_logic_vector (4 downto 0):="00001"; ---> bitwise or
   constant add_op: std_logic_vector (4 downto 0):="00010"; ---> add a_i and b_i
   constant sub_op: std_logic_vector (4 downto 0):="00110"; ---> sub a_i and b_i
   constant eq_op: std_logic_vector (4 downto 0):="10111"; --->  set equal
   constant xor_op: std_logic_vector (4 downto 0):="00011"; ---> bitwise xor
   constant lts_op: std_logic_vector (4 downto 0):="10100"; ---> set less than signed
   constant ltu_op: std_logic_vector (4 downto 0):="10101"; ---> set less than unsigned
   constant sll_op: std_logic_vector (4 downto 0):="10110"; ---> shift left logic
   constant srl_op: std_logic_vector (4 downto 0):="00111"; ---> shift right logic
   constant sra_op: std_logic_vector (4 downto 0):="01000"; ---> shift right arithmetic
   constant mulu_op: std_logic_vector (4 downto 0):="01001"; ---> multiply lower
   constant mulhs_op: std_logic_vector (4 downto 0):="01010"; ---> multiply higher signed
   constant mulhsu_op: std_logic_vector (4 downto 0):="01011"; ---> multiply higher signed and unsigned
   constant mulhu_op: std_logic_vector (4 downto 0):="01100"; ---> multiply higher unsigned
   constant divu_op: std_logic_vector (4 downto 0):="01101"; ---> divide unsigned
   constant divs_op: std_logic_vector (4 downto 0):="01110"; ---> divide signed
   constant remu_op: std_logic_vector (4 downto 0):="01111"; ---> reminder unsigned
   constant rems_op: std_logic_vector (4 downto 0):="10000"; ---> reminder signed	
   
   
   signal stall, start : std_logic;	
   signal ready_s,valid_s, SorU: std_logic; 
   signal con_s: std_logic_vector(1 downto 0) := (others => '0');
BEGIN
 
    -- Implementing shift left and right uses lower 5 bits from input b
    
   b_u <= to_integer(unsigned(b_i(4 downto 0)));
   
   inst_mul: multiply 
   port map(
       clk => clk,
       reset => reset,
       a_in => a_i,
       b_in => b_i,
       con_s => con_s,
       c_out =>  mul_res,
       stall_status => stall,
       start_status => start
   ); 
   
   
       
   inst_div_s: division_u
   port map(
      clk => clk,
      reset => reset,
      start_i => valid_s,
      SorU    => SorU,
      dividend_i => a_i,
      divisor_i  => b_i,
      quotient_o => div_res,
      remainder_o => rem_res,
      stall_o  =>  ready_s
   );   
   
   -- sabiranje
   add_res <= std_logic_vector(signed(a_i) + signed(b_i));
   -- oduzimanje
   sub_res <= std_logic_vector(signed(a_i) - signed(b_i));
   -- i kolo
   and_res <= a_i and b_i;
   -- ili kolo
   or_res <= a_i or b_i;
   -- xor gate
   xor_res <= a_i xor b_i;
   
   sll_res <= std_logic_vector(shift_left(unsigned(a_i),b_u));  
   srl_res <= std_logic_vector(shift_right(unsigned(a_i),b_u));
   sra_res <= to_stdlogicvector(to_bitvector(a_i) sra b_u);
   
   -- jednakost
   eq_res <= std_logic_vector(to_unsigned(1,WIDTH)) when (signed(a_i) = signed(b_i)) else
             std_logic_vector(to_unsigned(0,WIDTH));
   slt_res <= std_logic_vector(to_unsigned(1,WIDTH)) when (signed(a_i) < signed(b_i)) else
              std_logic_vector(to_unsigned(0,WIDTH));
   sltu_res <= std_logic_vector(to_unsigned(1,WIDTH)) when (unsigned(a_i) < unsigned(b_i)) else
              std_logic_vector(to_unsigned(0,WIDTH));
   
   -- prosledi jedan od rezultata na izlaz u odnosu na operaciju
   res_o <= res_s;
   with op_i select
      res_s <= and_res when and_op,
               or_res  when or_op,
               add_res when add_op,
               sub_res when sub_op,
               eq_res  when eq_op,
               xor_res when xor_op,
               sll_res when sll_op,
               srl_res when srl_op,
               sra_res when sra_op,
               slt_res when lts_op,
               sltu_res when ltu_op,
               mul_res(31 downto 0) when mulu_op, --signed lower
               mul_res(63 downto 32) when mulhs_op, -- signed high
               mulhu_res(63 downto 32) when mulhu_op,-- unsigned high
               mulhsu_res (63 downto 32) when mulhsu_op,
               std_logic_vector(div_res) when divu_op,
               std_logic_vector(div_res) when divs_op,
               std_logic_vector(rem_res) when remu_op,
               std_logic_vector(rem_res) when rems_op,
               (others => '1') when others; 


    process(op_i, stall, ready_s)
    begin
        start <= '0';
        valid_s <= '0';
        stall_o <= '1';
        SorU    <= '0';
        con_s <= "00";
        case op_i is
            when mulu_op => 
                start <= '1';
                stall_o <= stall;
                con_s <= "00";
            when mulhs_op =>
                start <= '1';
                stall_o <= stall; 
                con_s <= "00";
            when mulhu_op =>
                start <= '1';
                stall_o <= stall;
                con_s <= "11";
            when mulhsu_op =>
                start <= '1';
                stall_o <= stall;
                con_s <= "01";
            when divu_op =>
                valid_s <= '1';
                stall_o <= ready_s;
                SorU    <= '0';
            when divs_op =>
                valid_s <= '1';
                stall_o <= ready_s;
                SorU    <= '1';
            when remu_op =>
                valid_s <= '1';
                stall_o <= ready_s;
                SorU    <= '0';
            when rems_op =>    
                valid_s <= '1';
                stall_o <= ready_s;
                SorU    <= '1';
            when others => 
                start <= '0';
                stall_o <= '1';
                valid_s <= '0';
        end case;
    end process;
   -- signalni izlazi
   -- postavi singnalni bit jednakosti nuli
   --zero_o <= '1' when res_s = std_logic_vector(to_unsigned(0,WIDTH)) else
     --        '0';
   -- postavi signalni bit prekoracenja
   --of_o <= '1' when ((op_i="00011" and (a_i(WIDTH-1)=b_i(WIDTH-1)) and ((a_i(WIDTH-1) xor res_s(WIDTH-1))='1')) or (op_i="10011" and (a_i(WIDTH-1)=res_s(WIDTH-1)) and ((a_i(WIDTH-1) xor b_i(WIDTH-1))='1'))) else
     --      '0';


END behavioral;
