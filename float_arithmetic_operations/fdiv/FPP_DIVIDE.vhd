library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
--use WORK.FloatPt.all;
---Uncomment the following library declaration if instantiating any Xilinx primitives.
---library UNISIM;
---use UNISIM.VComponents.all;

entity FPP_DIVIDE is
  port (A        : in  std_logic_vector(31 downto 0);  --Dividend
        B        : in  std_logic_vector(31 downto 0);  --Divisor
        clk      : in  std_logic;       --Master clock
        reset    : in  std_logic;       --Global asynch reset
        go       : in  std_logic;       --Enable
        done     : out std_logic;       --Flag for done computing
        --ZD:         out std_logic;                                          --Flag for zero divisor
        overflow : out std_logic;       --Flag for overflow
        result   : out std_logic_vector(31 downto 0)   --Holds final FP result
        );
end FPP_DIVIDE;

architecture Arch of FPP_DIVIDE is
--=======Constants===========
  constant ZERO_FP : std_logic_vector(30 downto 0) := (others => '0');
  constant EBIAS   : unsigned(8 downto 0)          := to_unsigned(127, 9);  --exponent bias
--=======Floating Point Divide State Machine===
  type FPDiv is (FPDivIdle,             --Waits for GO signal to be set
                 FPDivAlign,            --Align dividend
                 FPDivSetExponent,      --Set the quotient exponent
                 FPDivStart,            --start mantissa divider
                 FPDivWaitTilDone,      --wait for completion
                 FPDivDone,             --Done with calculation
                 FPDivPause             --Wait for GO signal to be cleared
                 );
  signal FPD            : FPDiv;
  attribute init        : string;
  attribute init of FPD : signal is "FPDivIdle";

 component MantissaDivision   -- XSA board driver usb dram operations.
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
 end component;
--==== Hardware/Registers=====
  signal Ae                : unsigned(8 downto 0);  --Dividend exponent
  signal Be                : unsigned(8 downto 0);  --Divisor exponent
--Quotient parts 
  signal Qs                : std_logic;
  signal Qm                : std_logic_vector(22 downto 0);  --final mantissa with leading 1 gone
  signal Qe                : std_logic_vector(8 downto 0);
--unsigned actual Mantissa of Dividend and Divisor with leading 1 restored 
  signal rdAm, rdBm        : unsigned(23 downto 0);
--normalized mantissa Quotient with leading 1
  signal rdQm              : unsigned(23 downto 0);
--Required exponent reduction from quotient normalization
  signal expShift          : unsigned(7 downto 0);
--===== Clock Signals=====
  signal fpClk0            : std_logic := '0';
  signal fpClk             : std_logic := '0';  --25MHz Clock for DIV state machine
--=====  Miscellaneous ===
  signal restoringDivStart : std_logic;
  signal restoringDivDone  : std_logic;
----------------------------------
begin
------------------------------------------
-- Divided Clock to Drive Floating Point steps
  process (CLK) is
  begin
    if (rising_edge(CLK)) then
      fpClk0 <= not fpClk0;
    end if;
  end process;

  process (fpClk0) is
  begin
    if (rising_edge(fpClk0)) then
      fpClk <= not fpClk;
    end if;
  end process;
---------------------------------------
  UDIV : MantissaDivision  --instantiate module for mantissa division
    generic map(NBIT => 24, EBIT => 8)
    port map(clkin => fpClk,
             reset => reset,
             start => restoringDivStart,
             done  => restoringDivDone,
             as    => rdAm,  --full mantissas with hidden leading 1 restored
             bs    => rdBm,
             qs    => rdQm,
             shift => expShift
             );              
---------------------------------------
-- State Machine for Division Control
----------------------------------------
  process (fpClk, reset) is             --, FPD, GO, A, B
  begin
    if (reset = '1') then
      FPD               <= FPDivIdle;
      --done              <= '0';
      overflow          <= '0';
      restoringDivStart <= '0';
    elsif (rising_edge(fpClk)) then
      --done              <= '0';
      case FPD is
                                        ------------------------------------
                           -- Wait for GO signal, then begin the FPP division algorithm. 
                           -- If divisor is zero, return all 1's.
                           -- If dividend is zero, return zero. 
                           ------------------------------------
        when FPDivIdle =>
          restoringDivStart <= '0';
         --done              <= '1';
          if (go = '1') then
            Qs <= A(31) xor B(31);      --Set sign of quotient
            if (B(30 downto 0) = ZERO_FP) then
              Qm       <= (others => '1');  --Divide by zero, return Max number
              Qe       <= (others => '1');
              overflow <= '1';    --we make no distinction on cause of overflow
              FPD      <= FPDivDone;    --go to done
            elsif (A(30 downto 0) = ZERO_FP) then
              Qm  <= (others => '0');   --Zero dividend, return zero
              Qe  <= (others => '0');
              FPD <= FPDivDone;         --go to done
            else                        --initialize internal registers
              rdAm <= unsigned('1' & A(22 downto 0));  --Actual normalized mantissas
              rdBm <= unsigned('1' & B(22 downto 0));
              Ae   <= unsigned('0' & A(30 downto 23));  --biased exponents with extra msb
              Be   <= unsigned('0' & B(30 downto 23));
              FPD  <= FPDivAlign;
            end if;
          else
            FPD <= FPDivIdle;           --continue waiting
          end if;
                                        ----------
        when FPDivAlign =>   -- Check mantissas and align if Am greater than Bm
          FPD <= FPDivSetExponent;      --default next state
          if rdAm > rdBm then
            rdAm <= '0' & rdAm(23 downto 1);  --downshift to make Am less than Bm
                                              --if Ae < 255 then
            Ae   <= Ae + 1;
                                        --else 
                           -- Qreg                    <= A(31) & NAN; --Exponent overflow, return NaN
                           -- overflow                <= '1'; --we make no distinction on cause of overflow
                           -- FPD                     <= FPDivDone;  --go to Calculation done
                           --end if;  
          end if;
                                        ---------
                           --Maybe we should break the exponent subtract into two pieces for speed
        when FPDivSetExponent =>
          if Ae > Be then
            Qe <= std_logic_vector(unsigned(Ae) - unsigned(Be) + EBIAS);
          else
            Qe <= std_logic_vector(EBIAS - (unsigned(Be) - unsigned(Ae)));
          end if;
          FPD <= FPDivStart;
                                        -----------  
        when FPDivStart =>              --Start the mantissa division
          restoringDivStart <= '1';
          FPD               <= FPDivWaitTilDone;  --Wait for mantissa division to complete
                                                  ----------   
        when FPDivWaitTilDone =>  --Latch normalized mantissa quotient, and new exponent
          if (restoringDivDone = '1') then
            Qe  <= std_logic_vector(unsigned(Qe) - expShift);
            Qm  <= std_logic_vector(rdQm(22 downto 0));  --drop the mantissa leading 1
            FPD <= FPDivDone;
          end if;
                                        ---------
        when FPDivDone =>  --Paste together and latch the final result,  signal done.
          --done              <= '1';
          result            <= Qs & Qe(7 downto 0) & Qm;
          restoringDivStart <= '0';
          FPD               <= FPDivPause;
                                        ----------
        when FPDivPause =>   --Pause for the done signal to be recognized
          if (go = '0') then      --request should reset after done goes high
            --done <= '0';
            fpd  <= FPDivIdle;
          end if;
                                        ---------            
        when others =>                  --  Default state is FPDivIdle
          FPD <= FPDivIdle;
      end case;
    end if;
  end process;
  
  process(FPD)
  begin
    if(FPD = FPDivIdle) then
        done <= '1';
        
    else
        done <= '0';
    end if;
  end process;
end architecture Arch;