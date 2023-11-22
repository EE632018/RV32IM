library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity preadder is
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
end entity;

architecture behavioral of preadder is

    --------------------------------------------------- Normal numbers
    component n_normal
    generic(WIDTH: integer:= 37);
    port ( 
        NumberA : in std_logic_vector(WIDTH - 1 downto 0);
        NumberB : in std_logic_vector(WIDTH - 1 downto 0);
        SA      : out std_logic;
        SB      : out std_logic;
        Comp    : out std_logic;
        EO      : out std_logic_vector(7 downto 0);
        MA      : out std_logic_vector(27 downto 0);
        MB      : out std_logic_vector(27 downto 0)
    ); 
    end component;

    ------------------------------------------------------ MUX/DEMUX
    component demux
    port ( 
        NumberA  : in std_logic_vector(36 downto 0);
        NumberB  : in std_logic_vector(36 downto 0);
        e_data   : in std_logic_vector(1 downto 0);
        NA0      : out std_logic_vector(36 downto 0);
        NB0      : out std_logic_vector(36 downto 0);
        NA1      : out std_logic_vector(36 downto 0);
        NB1      : out std_logic_vector(36 downto 0);
        NA2      : out std_logic_vector(36 downto 0);
        NB2      : out std_logic_vector(36 downto 0)
    );
    end component;

    component mux_ns
    port ( 
        NorA    : in std_logic_vector(36 downto 0);
        NorB    : in std_logic_vector(36 downto 0);
        MixA    : in std_logic_vector(36 downto 0);
        MixB    : in std_logic_vector(36 downto 0);
        e_data  : in std_logic_vector(1 downto 0);
        NA      : out std_logic_vector(36 downto 0);
        NB      : out std_logic_vector(36 downto 0)
    ); 
    end component;

    component mux_adder
    port ( 
        NorSA    : in std_logic;
        NorSB    : in std_logic;

        SubSA    : in std_logic;
        SubSB    : in std_logic;

        CompN    : in std_logic;
        CompS    : in std_logic;

        NorE     : in std_logic_vector(7 downto 0);
        SubE     : in std_logic_vector(7 downto 0);

        NorMA    : in std_logic_vector(27 downto 0);
        SubMA    : in std_logic_vector(27 downto 0);
        NorMB    : in std_logic_vector(27 downto 0);
        SubMB    : in std_logic_vector(27 downto 0);

        e_data  : in std_logic_vector(1 downto 0);

        SA      : out std_logic;
        SB      : out std_logic;
        C       : out std_logic;
        E       : out std_logic_vector(7 downto 0);
        A      : out std_logic_vector(27 downto 0);
        B      : out std_logic_vector(27 downto 0)
    );
    end component;

    ------------------------------------------------- Mixed Numbers
    component norm
    generic(WIDTH: integer:= 37);
    port ( 
        NumberA : in std_logic_vector(WIDTH - 1 downto 0);
        NumberB : in std_logic_vector(WIDTH - 1 downto 0);
        MA      : out std_logic_vector(WIDTH - 1 downto 0);
        MB      : out std_logic_vector(WIDTH - 1 downto 0)
    );
    end component;
    ------------------------------------------------- Subnormal numbers
    component n_subn
    generic(WIDTH: integer:= 37);
    port ( 
        NumberA : in std_logic_vector(WIDTH - 1 downto 0);
        NumberB : in std_logic_vector(WIDTH - 1 downto 0);
        SA      : out std_logic;
        SB      : out std_logic;
        Comp    : out std_logic;
        EO      : out std_logic_vector(7 downto 0);
        MA      : out std_logic_vector(27 downto 0);
        MB      : out std_logic_vector(27 downto 0)
    );
    end component;
    ------------------------------------------------ Selector
    component selector
    port ( 
        NumberA : in std_logic_vector(31 downto 0);
        NumberB : in std_logic_vector(31 downto 0);
        enable  : in std_logic;
        e_data  : out std_logic_vector(1 downto 0);
        NA      : out std_logic_vector(36 downto 0);
        NB      : out std_logic_vector(36 downto 0)
    ); 
    end component;

    signal Amux, Bmux, A_sub, B_sub, A_mix, B_mix, MixAaux, MixBaux, NA_out_select, NB_out_select: std_logic_vector(36 downto 0);
    signal A_nor, B_nor: std_logic_vector(36 downto 0); 
    signal NComp, SAnor, SBnor, SAsub, SBsub, SComp: std_logic;
    signal edata: std_logic_vector(1 downto 0);
    signal Enor, Esub: std_logic_vector(7 downto 0);
    signal MAnor, MBnor, MAsub, MBsub: std_logic_vector(27 downto 0);
begin

    ---------------------------------------------- Connecting all components
    comp0: n_normal
    generic map (WIDTH => 37)
    port map( 
        NumberA => Amux,
        NumberB => Bmux,
        SA      => SAnor,
        SB      => SBnor,
        Comp    => NComp,
        EO      => Enor,
        MA      => MAnor,
        MB      => MBnor
    ); 

    comp1: n_subn
    generic map (WIDTH => 37)
    port map ( 
        NumberA => A_sub,
        NumberB => B_sub,
        SA      => SAsub,
        SB      => SBsub,
        Comp    => SComp,
        EO      => Esub,
        MA      => MAsub,
        MB      => MBsub
    );

    comp2: norm
    generic map(WIDTH => 37)
    port map( 
        NumberA => A_mix,
        NumberB => B_mix,
        MA      => MixAaux,
        MB      => MixBaux
    );

    comp3: demux
    port map( 
        NumberA  => NA_out_select,
        NumberB  => NB_out_select,
        e_data   => edata,
        NA0      => A_sub,
        NB0      => B_sub,
        NA1      => A_nor,
        NB1      => B_nor,
        NA2      => A_mix,
        NB2      => B_mix
    );

    comp4: mux_ns
    port map( 
        NorA    => A_nor,
        NorB    => B_nor,
        MixA    => MixAaux,
        MixB    => MixBaux, 
        e_data  => edata,
        NA      => Amux,
        NB      => Bmux
    );

    comp5: selector
    port map( 
        NumberA => NumberA,
        NumberB => NumberB,
        enable  => enable,
        e_data  => edata,
        NA      => NA_out_select,
        NB      => NB_out_select
    );

    comp6: mux_adder
    port map( 
        NorSA    => SAnor,
        NorSB    => Sbnor,
        SubSA    => SAsub,
        SubSB    => SBsub,
        CompN    => NComp,
        CompS    => SComp,
        NorE     => Enor, 
        SubE     => Esub,
        NorMA    => MAnor,
        SubMA    => MAsub,
        NorMB    => MBnor,
        SubMB    => MBsub,
        e_data   => edata,
        SA       => SA,
        SB       => SB,
        C        => C,
        E        => EOut,
        A        => MAout,
        B        => MBout
    );
end behavioral;