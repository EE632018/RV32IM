library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_adder is
    port ( 
        NorSA    : in std_logic;
        NorSB    : in std_logic;

        SubSA    : in std_logic;
        SubSB    : in std_logic;

        CompN    : in std_logic;
        CompS    : in std_logic;

        NorE     : in std_logic_vecotr(7 downto 0);
        SubE     : in std_logic_vecotr(7 downto 0);

        NorMA    : in std_logic_vecotr(27 downto 0);
        SubMA    : in std_logic_vecotr(27 downto 0);
        NorMB    : in std_logic_vecotr(27 downto 0);
        SubMB    : in std_logic_vecotr(27 downto 0);

        e_data  : in std_logic_vector(1 downto 0);

        SA      : out std_logic;
        SB      : out std_logic;
        C       : out std_logic;
        E       : out std_logic_vecotr(7 downto 0);
        A      : out std_logic_vecotr(27 downto 0);
        B      : out std_logic_vecotr(27 downto 0)
    );  
end entity;

architecture behavioral of mux_adder is

begin

    --output mux for all
    A <= NorMA when e_data = "01" or e_data = "10" else
         SubMA when e_data = "00" else
         (others => '-');

    B <= NorMB when e_data = "01" or e_data = "10" else
         SubMB when e_data = "00" else
         (others => '-');     

    C <= CompN when e_data = "01" or e_data = "10" else
         CompS when e_data = "00" else
         (others => '-');   
    
    SA <= NorSA when e_data = "01" or e_data = "10" else
          SubSA when e_data = "00" else
          (others => '-'); 

    SB <= NorSB when e_data = "01" or e_data = "10" else
          SubSB when e_data = "00" else
          (others => '-'); 
          
    E <=  NorE when e_data = "01" or e_data = "10" else
          SubE when e_data = "00" else
          (others => '-');      

end behavioral;