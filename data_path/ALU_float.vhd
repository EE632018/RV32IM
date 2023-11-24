LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;
use work.alu_ops_pkg.all;

ENTITY ALU_float IS
   GENERIC(
      WIDTH : NATURAL := 32);
   PORT(
      clk    : in std_logic;
      reset  : in std_logic; 
      a_ii    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); 
      a_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --prvi operand
      b_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --drugi operand
      c_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);  
      op_i   : in STD_LOGIC_VECTOR(4 DOWNTO 0); --selekcija operacije
      res_o  : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
      stall_o: out std_logic
      ); 
END ALU_float;

ARCHITECTURE behavioral OF ALU_float IS

   ------------------------------------------------------------- COMPONENT 
    component fpadder
    port ( 
        NumberA : in std_logic_vector(31 downto 0);
        NumberB : in std_logic_vector(31 downto 0);
        A_S     : in std_logic;
        Result  : out std_logic_vector(31 downto 0)
    ); 
    end component;

    ------------------------------------------------------------ CONSTANT OP
    constant fmadd:     std_logic_vector (4 downto 0):="00000";
    constant fmsub:     std_logic_vector (4 downto 0):="00001";
    constant fnmsub:    std_logic_vector (4 downto 0):="00010";
    constant fnmadd:    std_logic_vector (4 downto 0):="00011";
    constant fadd:      std_logic_vector (4 downto 0):="00100"; --
    constant fsub:      std_logic_vector (4 downto 0):="00101"; --
    constant fmul:      std_logic_vector (4 downto 0):="00110";
    constant fdiv:      std_logic_vector (4 downto 0):="00111";
    constant fsqrt:     std_logic_vector (4 downto 0):="01000";
    constant fsgnj:     std_logic_vector (4 downto 0):="01001"; --
    constant fsgnjn:    std_logic_vector (4 downto 0):="01010"; --
    constant fsgnjx:    std_logic_vector (4 downto 0):="01011"; --
    constant fmin:      std_logic_vector (4 downto 0):="01100";
    constant fmax:      std_logic_vector (4 downto 0):="01101";
    constant fcvt_w:    std_logic_vector (4 downto 0):="01110";
    constant fcvt_wu:   std_logic_vector (4 downto 0):="01111";
    constant fmv_x_w:   std_logic_vector (4 downto 0):="10000";
    constant feq:       std_logic_vector (4 downto 0):="10001";
    constant flts:      std_logic_vector (4 downto 0):="10010";
    constant fle:       std_logic_vector (4 downto 0):="10011";
    constant fclass:    std_logic_vector (4 downto 0):="10100";
    constant fcvt_s_w:  std_logic_vector (4 downto 0):="10101";
    constant fcvt_s_wu: std_logic_vector (4 downto 0):="10110";
    constant fmv_w_x:   std_logic_vector (4 downto 0):="10111";

    signal fpadd_sub : std_logic_vector(WIDTH - 1 downto 0);
    signal fsgnj_res : std_logic_vector(WIDTH - 1 downto 0);
    signal fsgnjn_res : std_logic_vector(WIDTH - 1 downto 0);
    signal fsgnjx_res : std_logic_vector(WIDTH - 1 downto 0);
    signal res_s     : std_logic_vector(WIDTH - 1 downto 0);
begin

   fadd_fsub: fpadder
   port map (NumberA => a_i, NumberB => b_i, A_S => op_i(0), Result => fpadd_sub);

   fsgnj_res <= b_i(31) & a_i(30 downto 0);
   fsgnjn_res <= not(b_i(31)) & a_i(30 downto 0);
   fsgnjx_res <= (a_i(31) xor b_i(31)) & a_i(30 downto 0);



   with op_i select
      res_s <= fpadd_sub when (fadd or fsub),
               fsgnj_res when fsgnj,
               fsgnjn_res when fsgnjn,
               fsgnjx_res when fsgnjx,
               (others => '1') when others;   
               

   res_o <= res_s;            
end behavioral;    