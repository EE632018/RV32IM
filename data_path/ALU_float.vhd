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
      ); --rezultatinteger
      --zero_o : out STD_LOGIC; --signalni bit jednakosti nuli
      --of_o   : out STD_LOGIC); --signalni bit prekoracenja opsega
END ALU_float;

ARCHITECTURE behavioral OF ALU_float IS

    
begin


end behavioral;    