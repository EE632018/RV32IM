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
    
    component Ilog
        Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           start : in std_logic;
           a_in : in STD_LOGIC_VECTOR (31 downto 0);
           c_out : out STD_LOGIC_VECTOR (31 downto 0);
           stall_o : out STD_LOGIC);
    end component;

    constant EXPONENT_BIAS : natural := 127;  -- Single-precision float exponent bias
    constant EXPONENT_WIDTH : natural := 8;   -- Width of the exponent field
    constant FRACTION_WIDTH : natural := 23;  -- Width of the fraction field
    
    signal exponent_s : unsigned(EXPONENT_WIDTH - 1 downto 0);
    signal fraction_s : unsigned(FRACTION_WIDTH - 1 downto 0);
    signal sign_s     : std_logic;      
    signal exponent_u : unsigned(EXPONENT_WIDTH - 1 downto 0);
    signal fraction_u : unsigned(FRACTION_WIDTH - 1 downto 0);
    signal int_s    : integer;
    signal int_s2   : natural;
    signal int_s3   : natural;
    signal int_u    : integer;
    signal int_u2   : natural;
    
    
begin

    process(a_in, int_s3, int_u2, int_u, sign_s, exponent_s, fraction_s, exponent_u, fraction_u, int_s, int_s2)
    begin
        
        int_s <= to_integer(signed(a_in));
        sign_s <= a_in(31);
        int_s2 <= abs(int_s);
        int_s3     <= log2c(int_s2);
        
        int_u <= to_integer(unsigned(a_in));
        int_u2     <= log2c(int_u);

        if int_s2 /= 0 then    
            exponent_s <= resize(to_unsigned(int_s3 + EXPONENT_BIAS, exponent_s'length), EXPONENT_WIDTH);
            fraction_s <= resize(to_unsigned(int_s2 - 2**int_s3, fraction_s'length), FRACTION_WIDTH);
        else
            exponent_s <= resize(to_unsigned(EXPONENT_BIAS, exponent_s'length), EXPONENT_WIDTH);
            fraction_s <= (others => '0');
        end if;  
        
        if int_u2 /= 0 then     
            exponent_u <= resize(to_unsigned(int_u2 + EXPONENT_BIAS, exponent_u'length), EXPONENT_WIDTH) ;
            fraction_u <= resize(to_unsigned(int_u - 2**(int_u2), fraction_u'length), FRACTION_WIDTH);
        else
            exponent_u <= resize(to_unsigned(EXPONENT_BIAS, exponent_u'length), EXPONENT_WIDTH);
            fraction_u <= (others => '0');
        end if;
        
        c_s_out <= sign_s & std_logic_vector(exponent_s) & std_logic_vector(fraction_s);
        c_u_out <= '0' & std_logic_vector(exponent_u) & std_logic_vector(fraction_u);
    end process;
end behavioral;