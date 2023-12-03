library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MantissaDivision is  -- XSA board driver usb dram operations.
  generic (NBIT : integer := 24;
           EBIT : integer := 8);
  port(
    clkin : in  std_logic;              --50 mhz expected in
    reset : in  std_logic;  --only needed to initialize state machine 
    start : in  std_logic;              --external start request
    done  : out std_logic;              --division complete signal out
    as    : in  unsigned(NBIT-1 downto 0);  --aligned dividend
    bs    : in  unsigned(NBIT-1 downto 0);  --divisor
    qs    : out unsigned(NBIT-1 downto 0);  --normalized quotient with leading 1 supressed
    shift : out unsigned(EBIT-1 downto 0)
    );
end MantissaDivision;

architecture arch of MantissaDivision is
---state machine signals---
  type SM_type is (IDLE, NORM, TEST, CHKBO, FINI);
  signal state                  : SM_type;  --division process state machine
  attribute INIT                : string;
  attribute INIT of state       : signal is "IDLE";  --we powerup in IDLE state
  signal sm_clk                 : std_logic;
--- registers-------------
  signal acc                    : unsigned(NBIT-1 downto 0);  --accumulated quotient
  signal numerator, denominator : unsigned(2*NBIT-1 downto 0);
  signal diff                   : unsigned(2*NBIT-1 downto 0);  --difference between current num. and denom.
  signal shift_I                : unsigned(EBIT-1 downto 0);  --reduction of final exponent for normalization
  signal count                  : integer range 0 to NBIT;  --iteration count.
--- SR inference----
  attribute shreg_extract       : string;   --Don't infer primitive SR's
--attribute shreg_extract of acc: signal is "no";               --To avoid reset problems.
--attribute shreg_extract of numerator: signal is "no"; 

begin
  shift  <= shift_I;
----- division state machine--------------
  diff   <= numerator - denominator;
  sm_clk <= clkin;
  MDIV : process (sm_clk, reset, state, start, as, bs) is
  begin
    if reset = '1' then
      state <= IDLE;  --reset into the idle state to wait for a memory operation.
      done  <= '0';
      
    elsif rising_edge(sm_clk) then      --
      case state is
        when IDLE =>  --we remain in idle till we get a start signal.
          if start = '1' then
            acc                               <= (others => '0');
            numerator(NBIT-1 downto 0)        <= as;
            numerator(2*NBIT-1 downto NBIT)   <= (others => '0');
            denominator(NBIT-1 downto 0)      <= bs;
            denominator(2*NBIT-1 downto NBIT) <= (others => '0');
            count                             <= 0;
            state                             <= TEST;
            done                              <= '0';
            shift_I                           <= (others => '0');
          end if;
                                        -------
        when TEST =>  -- Test, shift, and apply subtraction to numerator if necessary.
          if numerator < denominator then
            acc       <= acc(NBIT-2 downto 0) & '0';
            numerator <= numerator(2*NBIT-2 downto 0) & '0';
          else
            acc       <= acc(NBIT-2 downto 0) & '1';  --next quotient bit is a 1
            numerator <= diff(2*NBIT-2 downto 0) & '0';  --diff = numerator - denominator;
          end if;
          state <= CHKBO;
                                        --------
        when CHKBO =>  --check count for breakout. (this conveniently creates a 1-clk delay)
          if count < NBIT-1 then
            count <= count + 1;
            state <= TEST;
          else
            state <= NORM;
          end if;
                                        ---------
        when NORM =>  --normalize the 24-bit accumulated quotient
          if (acc(NBIT-1) = '0') then
            acc     <= acc(NBIT-2 downto 0) & '0';
            shift_I <= shift_I + 1;
            state   <= NORM;
          else
            qs    <= acc;  --latch normalized quotient for output. Leading bit will be dropped
            done  <= '1';
            state <= FINI;
          end if;
                                        ---------
        when FINI =>  --to avoid a race condition, we wait till start goes off
          if start = '0' then  --this means the upper entity has latched the answer
            state <= IDLE;              --Go wait for next request
            done  <= '0';
          end if;
                                        ---------  
        when others => state <= IDLE;
      end case;
    end if;
  end process MDIV;
---------------------------------
end arch;