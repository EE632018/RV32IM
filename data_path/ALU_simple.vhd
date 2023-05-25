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
      res_o  : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)); --rezultatinteger
      --zero_o : out STD_LOGIC; --signalni bit jednakosti nuli
      --of_o   : out STD_LOGIC); --signalni bit prekoracenja opsega
END ALU;

ARCHITECTURE behavioral OF ALU IS

   component divider
   Port (  N : in STD_LOGIC_VECTOR (31 downto 0); --numerator!
           D : in STD_LOGIC_VECTOR (31 downto 0);  --denominator 
           VALID: in STD_LOGIC; --valid bit
           clk1: in STD_LOGIC; --clock signal 
           reset:in STD_LOGIC;
           READY : inout STD_LOGIC;
           remainder : out STD_LOGIC_VECTOR (31 downto 0);
           divisor_zero: out std_logic;
           quotient : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component multiply
    Port (clk   : in std_logic;
      reset : in std_logic;
      a_in  : in std_logic_vector(31 downto 0);
      b_in  : in std_logic_vector(31 downto 0);
      c_out  : out std_logic_vector(63 downto 0)   
     );            
    end component;
    
    component multiply_s
    Port (clk   : in std_logic;
      reset : in std_logic;
      a_in  : in std_logic_vector(31 downto 0);
      b_in  : in std_logic_vector(31 downto 0);
      c_out  : out std_logic_vector(63 downto 0)  
     );            
    end component;
    
    component multiply_us
    Port (clk   : in std_logic;
      reset : in std_logic;
      a_in  : in std_logic_vector(31 downto 0);
      b_in  : in std_logic_vector(31 downto 0);
      c_out  : out std_logic_vector(63 downto 0)  
     );            
    end component;
   
   constant  l2WIDTH : natural := integer(ceil(log2(real(WIDTH))));
   signal    add_res, sub_res, or_res, and_res,res_s, eq_res :  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
   signal    sll_res, slt_res, sltu_res, xor_res, srl_res, sra_res: std_logic_vector(WIDTH-1 DOWNTO 0); 
   signal    b_u: integer;   
   signal    b_mul: integer;
   signal    a_mul: integer;
   signal    mul_res, mulhu_res, mulhsu_res  : std_logic_vector(2*WIDTH-1 downto 0);
   signal    rem_res, div_res : std_logic_vector(WIDTH-1 downto 0);
   signal    rem_res_s,div_res_s: signed(WIDTH-1 downto 0); 
   signal    rem_res_u,div_res_u: unsigned(WIDTH-1 downto 0); 
   attribute use_dsp: string;
   attribute use_dsp of Behavioral: architecture is "yes";

BEGIN
 
    -- Implementing shift left and right uses lower 5 bits from input b
    
   b_u <= to_integer(signed(b_i(4 downto 0)));

   inst_mul_s: multiply_s 
   port map(
       clk => clk,
       reset => reset,
       a_in => a_i,
       b_in => b_i,
       c_out =>  mul_res
   ); 
   
   inst_mul: multiply 
   port map(
       clk => clk,
       reset => reset,
       a_in => a_i,
       b_in => b_i,
       c_out =>  mulhu_res
   ); 
   
   inst_mul_us: multiply_us 
   port map(
       clk => clk,
       reset => reset,
       a_in => a_i,
       b_in => b_i,
       c_out =>  mulhsu_res
   ); 
       
   inst_div: divider
   port map
   (N => a_i,
    D => b_i,  --denominator 
    VALID => '1', --valid bit
    clk1 => clk, --clock signal 
    reset => reset,
    READY => open,
    remainder => rem_res,
    divisor_zero => open,
    quotient => div_res
   );    
   
   div_res_u <= unsigned(div_res);
   div_res_s <= signed(div_res);
   rem_res_u <= unsigned(rem_res);
   rem_res_s <= signed(rem_res);
   
   --mul_res <= std_logic_vector(signed(a_i) * signed(b_i));
   --mulhu_res <= std_logic_vector(unsigned(a_i) * unsigned(b_i));
   
   --mulhu_res <= std_logic_vector(to_signed(a_mul,width) * to_unsigned(b_mul,width)); 
   -- sabiranje
   add_res <= std_logic_vector(unsigned(a_i) + unsigned(b_i));
   -- oduzimanje
   sub_res <= std_logic_vector(unsigned(a_i) - unsigned(b_i));
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
               std_logic_vector(div_res_u) when divu_op,
               std_logic_vector(div_res_s) when divs_op,
               std_logic_vector(rem_res_u) when remu_op,
               std_logic_vector(rem_res_s) when rems_op,
               (others => '1') when others; 


   -- signalni izlazi
   -- postavi singnalni bit jednakosti nuli
   --zero_o <= '1' when res_s = std_logic_vector(to_unsigned(0,WIDTH)) else
     --        '0';
   -- postavi signalni bit prekoracenja
   --of_o <= '1' when ((op_i="00011" and (a_i(WIDTH-1)=b_i(WIDTH-1)) and ((a_i(WIDTH-1) xor res_s(WIDTH-1))='1')) or (op_i="10011" and (a_i(WIDTH-1)=res_s(WIDTH-1)) and ((a_i(WIDTH-1) xor b_i(WIDTH-1))='1'))) else
     --      '0';


END behavioral;
