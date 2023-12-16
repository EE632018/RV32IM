----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2023 12:09:09 PM
-- Design Name: 
-- Module Name: TBP - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TBP is
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
            branch_addr_pht_PAp         : in STD_LOGIC_VECTOR (WIDTH_PHT-1 DOWNTO 0);
            
            branch_inst                 : in STD_LOGIC;
            bhr_i                       : in STD_LOGIC;
            taken_pred                  : in STD_LOGIC;-- signal telling if predictor was correct
            final_pred                  : out STD_LOGIC;
            
            -- pht
            pht_addr_4bit_gshare        : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
            pht_addr_4bit_PAp           : out STD_LOGIC_VECTOR(WIDTH_PHT-1 DOWNTO 0)
           
            );
end TBP;

architecture Behavioral of TBP is
    -- Instance of components
    --TOC
    COMPONENT TOC
    generic(row :   integer := 4;
            cols:   integer := 16);
    Port ( 
            clk                  : in STD_LOGIC;
            reset                : in STD_LOGIC;
            branch_addr_4bit     : in STD_LOGIC_VECTOR (3 DOWNTO 0);
            cnt_one              : out STD_LOGIC_VECTOR(1 DOWNTO 0);
            -- This index sel is not connected to index sel in priority encoder
            branch_addr_prev_loc : in STD_LOGIC_VECTOR (3 DOWNTO 0);  
            index_sel            : in STD_LOGIC
           );
    END COMPONENT;


    --Gshare
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
   
    --PAp
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
    signal cnt_one_s: std_logic_vector(1 downto 0);
    signal gshare_pred_s,  PAp_pred_s: std_logic;
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

                 branch_addr_prev_loc     =>  branch_addr_bhr_local,
                 index_sel                =>  taken_pred
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

    pht_addr_4bit_PAp    <= pht_addr_4bit_PAp_s;
    -- Additional logic mux 4 on 1 choosing one of branch predictors for final prediction
    -- output final_pred
    
    finale_prediction_process: process(cnt_one_s,gshare_pred_s,PAp_pred_s)
                               begin
                                    case(cnt_one_s)is
                                        when "00" => final_pred <= gshare_pred_s;
                                        when "01" => final_pred <= gshare_pred_s;
                                        when "10" => final_pred <= PAp_pred_s;
                                        when "11" => final_pred <= PAp_pred_s;
                                        when others => final_pred <= gshare_pred_s;
                                    end case;
                               end process finale_prediction_process;
                               
          

end Behavioral;
