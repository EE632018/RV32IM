library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.utils_pkg.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fcvt_i is
    Port ( a_in : in STD_LOGIC_VECTOR (31 downto 0);
           c_s_out : out STD_LOGIC_VECTOR (31 downto 0);
           c_u_out : out STD_LOGIC_VECTOR (31 downto 0));
end fcvt_i;

architecture behavioral of fcvt_i is
    constant EXPONENT_BIAS : integer := 127;  -- Single-precision float exponent bias
    constant EXPONENT_WIDTH : integer := 8;   -- Width of the exponent field
    constant FRACTION_WIDTH : integer := 23;  -- Width of the fraction field
    
    signal exponent_s : unsigned(EXPONENT_WIDTH - 1 downto 0);
    signal fraction_s : unsigned(FRACTION_WIDTH - 1 downto 0);
    signal exponent_u : unsigned(EXPONENT_WIDTH - 1 downto 0);
    signal fraction_u : unsigned(FRACTION_WIDTH - 1 downto 0);
    signal int_s    : integer;
    signal int_s2   : integer;
    signal int_u    : integer;
    signal int_u2   : integer;
begin

    process(a_in, int_s, int_s2)
    begin
        int_s := to_integer(signed(a_in));

        int_u := to_integer(unsigned(a_in));
        if a_in(31) = '0'  then
            int_s2 <= -int_s;
            int_u2 <= -int_u;
            c_s_out(31) <= '0'; 
        else
            int_s2 <= int_s;
            int_u2 <= int_u;
            c_s_out(31) <= '1';  
        end if;

        if int_s2 /= 0 then
            exponent_s <= to_unsigned(integer(log2c(real(int_s2)))) + EXPONENT_BIAS;
            fraction_s <= to_unsigned(int_s2 - 2**(integer(log2c(real(int_s2)))), FRACTION_WIDTH);
        else
            exponent_s <= to_unsigned(EXPONENT_BIAS, EXPONENT_WIDTH);
            fraction_s <= (others => '0');
        end if;  
        
        if int_u2 /= 0 then
            exponent_u <= to_unsigned(integer(log2c(real(int_u2)))) + EXPONENT_BIAS;
            fraction_u <= to_unsigned(int_u2 - 2**(integer(log2c(real(int_u2)))), FRACTION_WIDTH);
        else
            exponent_u <= to_unsigned(EXPONENT_BIAS, EXPONENT_WIDTH);
            fraction_u <= (others => '0');
        end if;
        
        c_s_out(30 downto 0) <= std_logic_vector(exponent_s) & std_logic_vector(fraction_s);
        c_u_out <= '0' & std_logic_vector(exponent_u) & std_logic_vector(fraction_u);
    end process;
end behavioral;