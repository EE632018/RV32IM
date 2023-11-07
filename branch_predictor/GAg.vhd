----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/02/2023 10:57:50 AM
-- Design Name: 
-- Module Name: GAg - Behavioral
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

entity GAg is
    GENERIC(WIDTH_BHR: NATURAL := 3;
            WIDTH_PHT: NATURAL := 7;
            WIDTH    : NATURAL := 4 );
    Port (clk                  : in STD_LOGIC;
          reset                : in STD_LOGIC;
          branch_addr_4bit     : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          branch_addr_prev_loc : in STD_LOGIC_VECTOR (WIDTH_PHT-1 DOWNTO 0);
          pht_addr_4bit        : out STD_LOGIC_VECTOR(WIDTH_PHT-1 DOWNTO 0);
          branch_inst          : in STD_LOGIC;
          bhr_i                : in STD_LOGIC;
          GAg_pred             : out STD_LOGIC
          );
end GAg;

architecture Behavioral of GAg is
    -- Component in Gshare
    -- BHR
    COMPONENT BHR
    GENERIC(WIDTH:    natural    := 3);  
    Port (  clk         : in STD_LOGIC;
            reset       : in STD_LOGIC;
            -- bhr_i indicates taken not taken value that is put to system
            bhr_i       : in STD_LOGIC;
            branch_inst      : in STD_LOGIC;
            bhr_o       : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
          );
    end component;
    
    --PHT
    COMPONENT PHT
    GENERIC(WIDTH: NATURAL  := 7);
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
    signal GAg_bhr_s        : std_logic_vector(WIDTH_BHR-1 downto 0);
    signal pht_addr_7bit_s  : std_logic_vector(WIDTH_PHT-1 downto 0);
    signal pht_addr_4bit_s  : std_logic_vector(WIDTH-1 downto 0);
    signal en_s             : std_logic;
   
begin

    -- Instations of component
    BHR_INST:BHR
             GENERIC MAP(WIDTH      => WIDTH_BHR)
             PORT MAP(
                       clk          => clk,
                       reset        => reset,
                       bhr_i        => bhr_i,
                       branch_inst   => branch_inst,
                       bhr_o        => GAg_bhr_s  
             );
    PHT_INST:PHT
             GENERIC MAP(WIDTH      => WIDTH_PHT)
             PORT MAP(
                      clk           => clk,
                      reset         => reset,
                      en_i          => bhr_i,  
                      pht_addr_4bit => pht_addr_7bit_s,
                      branch_addr_prev_loc => branch_addr_prev_loc,
                      branch_inst   => branch_inst,
                      pred          => GAg_pred   
             );       
    -- Concatenation branch_add and gshare_bhr to get pht_addr
    pht_addr_7bit_s <= GAg_bhr_s & branch_addr_4bit;
    pht_addr_4bit   <= pht_addr_7bit_s;
end Behavioral;
