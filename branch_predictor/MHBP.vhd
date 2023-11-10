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
            row :       integer := 4;
            cols:       integer := 16);
  Port (    clk                         : in STD_LOGIC;
            reset                       : in STD_LOGIC;
            branch_addr_4bit            : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
            branch_addr_bhr_local       : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
            branch_addr_pht_gshare      : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
            branch_addr_pht_pshare      : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
            branch_addr_pht_GAg         : in STD_LOGIC_VECTOR (WIDTH_PHT-1 DOWNTO 0);
            branch_addr_pht_PAp         : in STD_LOGIC_VECTOR (WIDTH_PHT-1 DOWNTO 0);
            
            branch_inst                 : in STD_LOGIC;
            bhr_i                       : in STD_LOGIC;
            taken_pred                  : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0); -- signal telling if predictor was correct
            predictions                 : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
            final_pred                  : out STD_LOGIC;
            
            -- pht
            pht_addr_4bit_gshare        : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
            pht_addr_4bit_GAg           : out STD_LOGIC_VECTOR(WIDTH_PHT-1 DOWNTO 0);
            pht_addr_4bit_pshare        : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
            pht_addr_4bit_PAp           : out STD_LOGIC_VECTOR(WIDTH_PHT-1 DOWNTO 0)
            );
end MHBP;

architecture Behavioral of MHBP is

    -- Instance of components
    -- 1 TOC
    COMPONENT TOC
    generic(row :   integer := 4;
            cols:   integer := 16);
    Port ( 
            clk                  : in STD_LOGIC;
            reset                : in STD_LOGIC;
            branch_addr_4bit     : in STD_LOGIC_VECTOR (3 DOWNTO 0);
            cnt_one              : out STD_LOGIC_VECTOR(1 DOWNTO 0);
            cnt_two              : out STD_LOGIC_VECTOR(1 DOWNTO 0);
            cnt_three            : out STD_LOGIC_VECTOR(1 DOWNTO 0);
            cnt_four             : out STD_LOGIC_VECTOR(1 DOWNTO 0);
            -- This index sel is not connected to index sel in priority encoder
            branch_addr_prev_loc : in STD_LOGIC_VECTOR (3 DOWNTO 0);  
            index_sel            : in STD_LOGIC_VECTOR (3 DOWNTO 0)
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
          branch_addr_prev_loc : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          pht_addr_4bit        : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
          branch_inst          : in STD_LOGIC;
          bhr_i                : in STD_LOGIC; 
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
          branch_addr_prev_loc : in STD_LOGIC_VECTOR (WIDTH_PHT-1 DOWNTO 0);
          pht_addr_4bit        : out STD_LOGIC_VECTOR(WIDTH_PHT-1 DOWNTO 0);
          branch_inst          : in STD_LOGIC;
          bhr_i                : in STD_LOGIC;
          GAg_pred             : out STD_LOGIC
          );
    END COMPONENT;
    
    -- 5 pshare
    COMPONENT pshare 
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
    END COMPONENT;
    
    -- 6 PAp
    COMPONENT PAp
    GENERIC(WIDTH: NATURAL := 4;
            WIDTH_BHR: NATURAL := 3;
            WIDTH_PHT: NATURAL := 7);
    Port (clk                  : in STD_LOGIC;
          reset                : in STD_LOGIC;
          branch_addr_4bit     : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          branch_addr_prev_loc : in STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
          branch_addr_prev_loc_local : in STD_LOGIC_VECTOR (WIDTH_PHT-1 DOWNTO 0);
          pht_addr_4bit        : out STD_LOGIC_VECTOR(WIDTH_PHT-1 DOWNTO 0);
          branch_inst          : in STD_LOGIC;
          bhr_i                : in STD_LOGIC;
          PAp_pred          : out STD_LOGIC
          );
    END COMPONENT;
    
    
    -- Signals for connectino
    signal cnt_one_s, cnt_two_s, cnt_three_s, cnt_four_s: std_logic_vector(1 downto 0);
    signal index_sel_s:  std_logic_vector (1 downto 0);
    signal gshare_pred_s, GAg_pred_s, pshare_pred_s, PAp_pred_s: std_logic;
    signal pht_addr_4bit_gshare_s, pht_addr_4bit_pshare_s: std_logic_vector(3 downto 0);  
    signal pht_addr_4bit_GAg_s, pht_addr_4bit_PAp_s: std_logic_vector(6 downto 0);  
begin
    
    -- Inst of component
    -- TOC - table of counters 
    TOC_INST: TOC
    GENERIC MAP (row                      =>  row,
                 cols                     =>  cols)
    PORT MAP    (clk                      =>  clk,
                 reset                    =>  reset,
                 branch_addr_4bit         =>  branch_addr_4bit,   
                 cnt_one                  =>  cnt_one_s,
                 cnt_two                  =>  cnt_two_s,
                 cnt_three                =>  cnt_three_s,
                 cnt_four                 =>  cnt_four_s,
                 branch_addr_prev_loc     =>  branch_addr_bhr_local,
                 index_sel                =>  taken_pred
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
                     branch_addr_prev_loc     =>  branch_addr_pht_gshare,
                     pht_addr_4bit      => pht_addr_4bit_gshare_s,
                     branch_inst        => branch_inst,
                     bhr_i              => bhr_i,       
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
                    branch_addr_prev_loc     =>  branch_addr_pht_GAg,
                    pht_addr_4bit      => pht_addr_4bit_GAg_s,   
                    branch_inst        => branch_inst,
                    bhr_i              => bhr_i,
                    GAg_pred           => GAg_pred_s
                    );
                    
    -- pshare
    PSHARE_INST: pshare
    GENERIC MAP    (WIDTH              => WIDTH)
    PORT MAP       (clk                => clk,
                    reset              => reset,
                    branch_addr_4bit   => branch_addr_4bit,
                    branch_addr_prev_loc     =>  branch_addr_pht_pshare,
                    branch_addr_prev_loc_local => branch_addr_bhr_local,
                    pht_addr_4bit      => pht_addr_4bit_pshare_s,
                    branch_inst        => branch_inst,   
                    bhr_i              => bhr_i,
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
                    branch_addr_prev_loc     =>  branch_addr_bhr_local,
                    branch_addr_prev_loc_local => branch_addr_pht_PAp,
                    pht_addr_4bit      => pht_addr_4bit_PAp_s,
                    branch_inst        => branch_inst,   
                    bhr_i              => bhr_i,
                    PAp_pred           => PAp_pred_s
                    );
    
    
    -- Output pht_addr this logic will be multiplexed and send to input branch_addr_prev_loc to see if we catch that or not.
    pht_addr_4bit_gshare <= pht_addr_4bit_gshare_s;
    pht_addr_4bit_GAg  <= pht_addr_4bit_GAg_s;
    pht_addr_4bit_pshare <= pht_addr_4bit_pshare_s; 
    pht_addr_4bit_PAp    <= pht_addr_4bit_PAp_s;
    -- Additional logic mux 4 on 1 choosing one of branch predictors for final prediction
    -- output final_pred
    
    finale_prediction_process: process(index_sel_s,gshare_pred_s,GAg_pred_s,pshare_pred_s,PAp_pred_s)
                               begin
                                    case(index_sel_s)is
                                        when "00" => final_pred <= gshare_pred_s;
                                        when "01" => final_pred <= GAg_pred_s;
                                        when "10" => final_pred <= pshare_pred_s;
                                        when "11" => final_pred <= PAp_pred_s;
                                        when others => final_pred <= GAg_pred_s;
                                    end case;
                               end process finale_prediction_process;
                               
     predictions <= gshare_pred_s & GAg_pred_s & pshare_pred_s & PAp_pred_s;                                                       
end Behavioral;




