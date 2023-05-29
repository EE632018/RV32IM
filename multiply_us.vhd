----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/22/2023 03:14:53 PM
-- Design Name: 
-- Module Name: multiply - Behavioral
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

entity multiply_us is
Port (clk   : in std_logic;
      reset : in std_logic;
      a_in  : in std_logic_vector(31 downto 0);
      b_in  : in std_logic_vector(31 downto 0);
      c_out  : out std_logic_vector(63 downto 0)  
      stall_status: out std_logic
     );
end multiply_us;

architecture Behavioral of multiply_us is

    signal a_dsp1,b_dsp1: signed(15 downto 0);
    signal a_dsp2,b_dsp2: signed(15 downto 0);
    signal a_dsp3,b_dsp3,a_dsp3b,b_dsp3b: signed(31 downto 0);
    signal c_dsp3mul,c_dsp3mul_2: signed(31 downto 0);
    signal result: signed(31 downto 0);
    
    attribute use_dsp: string;
    attribute use_dsp of Behavioral: architecture is "yes";
    attribute use_dsp of a_dsp3b: signal is "yes";
    attribute use_dsp of b_dsp3b: signal is "yes";
    --attribute use_dsp of b_in: signal is "yes";
   
    signal cnt_status, cnt_status_next: std_logic_vector(1 downto 0);
begin

    register_process: process(clk,reset)
                      begin
                            if reset = '1' then
                                a_dsp1 <= (others => '0');
                                b_dsp1 <= (others => '0');
                                a_dsp2 <= (others => '0');
                                b_dsp2 <= (others => '0');
                                a_dsp3 <= (others => '0');
                                b_dsp3 <= (others => '0');
                                c_dsp3mul <= (others => '0');
                                c_dsp3mul_2 <= (others=> '0');
                            elsif rising_edge(clk) then
                                -- Stage1 first 16 bit
                                a_dsp1 <= signed(a_in(15 downto 0));                            
                                b_dsp1 <= signed(b_in(15 downto 0));        
                                -- Stage1 second 16bit 
                                a_dsp2 <=  signed(a_in(31 downto 16));                                                            
                                b_dsp2 <= '0' & signed(b_in(30 downto 16));                                                            
                                -- Stage2
                                a_dsp3 <= a_dsp3b;                            
                                b_dsp3 <= b_dsp3b;                            
                                --Stage3
                                c_dsp3mul <= result;                            
                                c_dsp3mul_2 <= a_dsp3;                            
                            end if;
                      
                      end process;
    
    
    cnt_process: process(clk, reset)
                 begin
                    if reset = '1' then
                        cnt_status <= (others => '0');
                    elsif rising_edge(clk) then
                        cnt_status <= std_logic_vector(unsigned(cnt_status) + TO_UNSIGNED(1,2));
                    end if;    
                 end process;
                 
    -- Izlaz prve faze
    a_dsp3b <= a_dsp1 * b_dsp1; -- donjih 32 bita
    b_dsp3b <= a_dsp2 * b_dsp2; -- gornjih 32 bita
    
    
    -- sabiranje za gornje bite druga faza 
    result <= a_dsp3 + b_dsp3;
    -- Izlaz iz trece faze
    c_out   <= std_logic_vector(c_dsp3mul & c_dsp3mul_2);
    stall_status    <= '1' when cnt_status = "11" else
                       '0';
    
    -- Status signal is generated with opcode, when instruction 
    -- is started we can start counting 3 cycles
    -- after that we can signalizes we finished. 
    -- Dodatno moze da se ubaci da radi i sa signed brojevima...
end Behavioral;
