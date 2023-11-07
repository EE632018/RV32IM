----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/02/2023 10:57:50 AM
-- Design Name: 
-- Module Name: pshare - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pshare is
    GENERIC(WIDTH: NATURAL := 4);
    Port (clk                  : in STD_LOGIC;
          reset                : in STD_LOGIC;
          branch_addr_4bit     : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          branch_addr_prev_loc : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          branch_addr_prev_loc_local : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          pht_addr_4bit        : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
          branch_inst          : in STD_LOGIC;
          bhr_i                : in STD_LOGIC;
          pshare_pred          : out STD_LOGIC
          );
end pshare;

architecture Behavioral of pshare is
    -- Component in pshare
    -- BHR
    COMPONENT BHR_local
    GENERIC(WIDTH:    natural    := 4;
            WIDTH_BHR:  natural  := 3);  
    Port (  clk                  : in STD_LOGIC;
            reset                : in STD_LOGIC;
            -- bhr_i indicates taken not taken value that is put to system
            bhr_i                : in STD_LOGIC;
            branch_inst      : in STD_LOGIC;
            branch_addr_4bit     : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
            branch_addr_prev_loc : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
            bhr_o                : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
          );
    end component;
    
    --PHT
    COMPONENT PHT
    GENERIC(WIDTH: NATURAL  := 4);
    Port ( 
           clk              : in STD_LOGIC;
           reset            : in STD_LOGIC;
           -- en signal indicates taken/not taken, '1' for taken and '0' for not taken
           en_i             : in STD_LOGIC; 
           branch_inst      : in STD_LOGIC;
           branch_addr_prev_loc : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
           pht_addr_4bit    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
           pred             : out STD_LOGIC       
     );
    END COMPONENT;
    
    -- Signals
    --signal branch_addr_prev_loc  : std_logic_vector(WIDTH-1 downto 0);
    signal en_s             : std_logic;
    signal pshare_bhr_s     : std_logic_vector(WIDTH-1 downto 0);
    signal pht_addr_4bit_s  : std_logic_vector(WIDTH-1 downto 0);
begin

    -- Instations of component
    BHR_INST:BHR_local
             GENERIC MAP(WIDTH              => WIDTH,
                         WIDTH_BHR          => WIDTH)
             PORT MAP(
                       clk                  => clk,
                       reset                => reset,
                       bhr_i                => bhr_i,
                       branch_inst          => branch_inst,
                       branch_addr_prev_loc => branch_addr_prev_loc_local,
                       branch_addr_4bit     => branch_addr_4bit,
                       bhr_o                => pshare_bhr_s  
             );
    PHT_INST:PHT
             GENERIC MAP(WIDTH      => WIDTH)
             PORT MAP(
                      clk           => clk,
                      reset         => reset,
                      en_i          => bhr_i,  
                      pht_addr_4bit => pht_addr_4bit_s,
                      branch_addr_prev_loc => branch_addr_prev_loc,
                      branch_inst   => branch_inst,
                      pred          => pshare_pred   
             );       
    -- XOR branch_add and gshare_bhr to get pht_addr
    pht_addr_4bit_s <= pshare_bhr_s xor branch_addr_4bit;
    pht_addr_4bit   <= pht_addr_4bit_s;
end Behavioral;
