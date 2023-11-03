----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/03/2023 08:24:03 AM
-- Design Name: 
-- Module Name: MHBP - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: MHBP - Multihybrid branch predictor represents top level.
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

entity MHBP is
  GENERIC(  WIDTH:      NATURAL := 4;
            WIDTH_BHR:  NATURAL := 3;
            WIDTH_PHT:  NATURAL := 7;
            row :       integer := 16;
            cols:       integer := 4);
  Port (    clk                  : in STD_LOGIC;
            reset                : in STD_LOGIC;
            branch_addr_4bit     : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
            final_pred           : out STD_LOGIC 
            );
end MHBP;

architecture Behavioral of MHBP is

    -- Instance of components
    -- 1 TOC
    COMPONENT TOC
    generic(row :   integer := 16;
            cols:   integer := 4);
    Port ( 
           clk                  : in STD_LOGIC;
           reset                : in STD_LOGIC;
           branch_addr_4bit     : in STD_LOGIC_VECTOR (3 DOWNTO 0);
           cnt_one              : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           cnt_two              : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           cnt_three            : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           cnt_four             : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           index_sel            : in STD_LOGIC_VECTOR(1 DOWNTO 0)
           );
    END COMPONENT;

    -- 2 priority_encoder
    COMPONENT priority_encoder
    Port (  cnt_one : in STD_LOGIC_VECTOR (1 downto 0);
            cnt_two : in STD_LOGIC_VECTOR (1 downto 0);
            cnt_three : in STD_LOGIC_VECTOR (1 downto 0);
            cnt_four : in STD_LOGIC_VECTOR (1 downto 0);
            index_sel : out STD_LOGIC_VECTOR (1 downto 0)
            ); 
    END COMPONENT;

    -- 3 Gshare
    COMPONENT Gshare
    GENERIC(WIDTH: NATURAL := 4);
    Port (clk                  : in STD_LOGIC;
          reset                : in STD_LOGIC;
          branch_addr_4bit     : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          gshare_pred          : out STD_LOGIC
          );
    END COMPONENT;
    
    -- 4 GAg
    COMPONENT GAg
    GENERIC(WIDTH_BHR: NATURAL := 3;
            WIDTH_PHT: NATURAL := 7;
            WIDTH    : NATURAL := 4 );
    Port (clk                  : in STD_LOGIC;
          reset                : in STD_LOGIC;
          branch_addr_4bit     : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          GAg_pred             : out STD_LOGIC
          );
    END COMPONENT;
    
    -- 5 pshare
    COMPONENT pshare
    GENERIC(WIDTH: NATURAL := 4);
    Port (clk                  : in STD_LOGIC;
          reset                : in STD_LOGIC;
          branch_addr_4bit     : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          pshare_pred          : out STD_LOGIC
          );
    END COMPONENT;
    
    -- 6 PAp
    COMPONENT PAp
    GENERIC(WIDTH: NATURAL := 4;
            WIDTH_BHR: NATURAL := 3;
            WIDTH_PHT: NATURAL := 7);
    Port (clk                  : in STD_LOGIC;
          reset                : in STD_LOGIC;
          branch_addr_4bit     : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          PAp_pred          : out STD_LOGIC
          );
    END COMPONENT;
    
    
    -- Signals for connectino
    signal cnt_one_s, cnt_two_s, cnt_three_s, cnt_four_s: std_logic_vector(1 downto 0);
    signal index_sel_s: std_logic_vector(1 downto 0);
    signal gshare_pred_s, GAg_pred_s, pshare_pred_s, PAp_pred_s: std_logic;
    
begin
    
    -- Inst of component
    -- TOC - table of counters 
    TOC_INST: TOC
    GENERIC MAP (row                => row,
                 cols               => cols)
    PORT MAP    (clk                => clk,
                 reset              => reset,
                 branch_addr_4bit   =>  branch_addr_4bit,   
                 cnt_one            =>  cnt_one_s,
                 cnt_two            =>  cnt_two_s,
                 cnt_three          =>  cnt_three_s,
                 cnt_four           =>  cnt_four_s,
                 index_sel          =>  index_sel_s
                );
    -- Priority encoder
    PE_INST:priority_encoder
    PORT MAP    (cnt_one            =>  cnt_one_s,
                 cnt_two            =>  cnt_two_s,
                 cnt_three          =>  cnt_three_s,
                 cnt_four           =>  cnt_four_s,
                 index_sel          =>  index_sel_s
                );
     
     -- Gshare
     GSHARE_INST: Gshare            
     GENERIC MAP    (WIDTH              => WIDTH)
     PORT MAP       (clk                => clk,
                     reset              => reset,
                     branch_addr_4bit   => branch_addr_4bit,   
                     gshare_pred        => gshare_pred_s
                     );
                     
    -- GAg                  
    GAg_INST: GAg
    GENERIC MAP    (WIDTH              => WIDTH,
                    WIDTH_BHR          => WIDTH_BHR,
                    WIDTH_PHT          => WIDTH_PHT)
    PORT MAP       (clk                => clk,
                    reset              => reset,
                    branch_addr_4bit   => branch_addr_4bit,   
                    GAg_pred           => GAg_pred_s
                    );
                    
    -- pshare
    PSHARE_INST: pshare
    GENERIC MAP    (WIDTH              => WIDTH)
    PORT MAP       (clk                => clk,
                    reset              => reset,
                    branch_addr_4bit   => branch_addr_4bit,   
                    pshare_pred        => pshare_pred_s
                    );
                    
    -- PAp
    PAp_INST: PAp
    GENERIC MAP    (WIDTH              => WIDTH,
                    WIDTH_BHR          => WIDTH_BHR,
                    WIDTH_PHT          => WIDTH_PHT)
    PORT MAP       (clk                => clk,
                    reset              => reset,
                    branch_addr_4bit   => branch_addr_4bit,   
                    PAp_pred           => PAp_pred_s
                    );
    
    -- Additional logic mux 4 on 1 choosing one of branch predictors for final prediction
    -- output final_pred
    
    finale_prediction_process: process(index_sel_s)
                               begin
                                    case(index_sel_s)is
                                        when "00" => final_pred <= gshare_pred_s;
                                        when "01" => final_pred <= GAg_pred_s;
                                        when "10" => final_pred <= pshare_pred_s;
                                        when "11" => final_pred <= PAp_pred_s;
                                    end case;
                               end process finale_prediction_process;                                                
end Behavioral;
