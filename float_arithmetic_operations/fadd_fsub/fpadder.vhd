library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fpadder is
    port ( 
        NumberA : in std_logic_vector(31 downto 0);
        NumberB : in std_logic_vector(31 downto 0);
        A_S     : in std_logic;
        Result  : out std_logic_vector(31 downto 0)
    );  
end entity;

architecture behavioral of fpadder is

    component n_case 
    generic(WIDTH: integer:= 32);
    port ( 
        NumberA : in std_logic_vector(WIDTH - 1 downto 0);
        NumberB : in std_logic_vector(WIDTH - 1 downto 0);
        enable  : out std_logic;
        S       : out std_logic_vector(WIDTH - 1 downto 0)
    );
    end component;

    component preadder
    port ( 
        NumberA : in std_logic_vector(31 downto 0);
        NumberB : in std_logic_vector(31 downto 0);
        enable  : in std_logic;
        SA      : out std_logic;
        SB      : out std_logic;
        C       : out std_logic;
        EOut    : out std_logic_vector(7 downto 0);
        MAout   : out std_logic_vector(27 downto 0);
        MBout   : out std_logic_vector(27 downto 0)
    );
    end component;

    component vector
    port ( 
        M: in std_logic_vector(22 downto 0);
        E: in std_logic_vector(7 downto 0);
        S: in std_logic;
        N: out std_logic_vector(31 downto 0)
    );
    end component;

    component block_norm
    port ( 
        MS: in std_logic_vector(27 downto 0);
        ES: in std_logic_vector(7 downto 0);
        Co: in std_logic;
        E: out std_logic_vector(7 downto 0);
        M: out std_logic_vector(22 downto 0)
    );
    end component;

    component block_adder
    port (
        SA: in std_logic;
        SB: in std_logic;
        A_S: in std_logic; 
        A: in std_logic_vector(27 downto 0);
        B: in std_logic_vector(27 downto 0);
        Comp: in std_logic;
        CO: out std_logic;
        SO: out std_logic;
        S: out std_logic_vector(27 downto 0)
    );
    end component;

    signal enable_s, SA_s, SB_s, C_s, CO_s, SO_s: std_logic;
    signal EOut_s, Enor_s: std_logic_vector(7 downto 0);
    signal MAout_s, MBout_s, S_s: std_logic_vector(27 downto 0);
    signal Mnor_s: std_logic_vector(22 downto 0);
    signal Ncase, Nadder: std_logic_vector(31 downto 0);
begin
    
    comp0: n_case
    generic map (WIDTH => 32)
    port map (NumberA => NumberA, NumberB => NumberB, enable => enable_s, S => Ncase); 

    comp1: preadder
    port map(NumberA => NumberA, NumberB => NumberB, enable => enable_s, SA => SA_s, 
             SB => SB_s, C => C_s, EOut => EOut_s, MAout => MAout_s, MBout => MBout_s); 
    
    comp2: block_adder
    port map (SA => SA_s, SB => SB_s, A_S => A_S, A => MAout_s, B => MBout_s, Comp => C_s, 
              CO => CO_s, SO => SO_s, S => S_s); 
    
    comp3: block_norm
    port map (MS => S_s, ES => EOut_s, Co => CO_s, E => Enor_s , M => Mnor_s);    
    
    comp4: vector
    port map(M => Mnor_s, E => Enor_s, S => SO_s, N => Nadder); 

    process(enable_s, Nadder, Ncase)
    begin
        case enable_s is
            when '1' => Result <= Nadder;
            when '0' => Result <= Ncase;
        end case;
    end process; 
end behavioral;