library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift is
    generic(WIDTH: integer:= 28);
    port ( 
        T       : in std_logic_vector(WIDTH - 1 downto 0);
        shift   : in std_logic_vector(4 downto 0);
        S       : out std_logic_vector(WIDTH - 1 downto 0)
    );  
 end entity;

architecture behavioral of shift is
    component mux2on1
    port ( 
        A       : in std_logic;
        B       : in std_logic;
        Sel     : in std_logic;
        Z       : out std_logic
    ); 
    end component;

    signal Z1,Z2,Z3,Z4,Z5: std_logic_vector(WIDTH - 1 downto 0);
begin

    comp1: for i in 0 to 27 generate
            s0_0: if i=0 generate 
                    mux0: mux2on1 port map(A => '0', B => T(0), Sel => shift(0), Z => Z1(i));
                  end generate;
            s0_i: if i > 0 and i < 28 generate
                    mux0_i: mux2on1 port map(A => T(i-1), B => T(i), Sel => shift(0), Z => Z1(i));
                  end generate;
            
            s1_0: if i>=0 and i < 2 generate 
                    mux1: mux2on1 port map(A => '0', B => Z1(i), Sel => shift(1), Z => Z2(i));
                  end generate;
            s1_i: if i > 1 and i < 28 generate
                    mux1_i: mux2on1 port map(A => Z1(i-2), B => Z1(i), Sel => shift(1), Z => Z2(i));
                  end generate;
                  
            s2_0: if i>=0 and i < 4 generate 
                    mux2: mux2on1 port map(A => '0', B => Z2(i), Sel => shift(2), Z => Z3(i));
                  end generate;
            s2_i: if i > 3 and i < 28 generate
                    mux2_i: mux2on1 port map(A => Z2(i-4), B => Z2(i), Sel => shift(2), Z => Z3(i));
                  end generate;  
            
            s3_0: if i>=0 and i < 8 generate 
                    mux3: mux2on1 port map(A => '0', B => Z3(i), Sel => shift(3), Z => Z4(i));
                  end generate;
            s3_i: if i > 7 and i < 28 generate
                    mux3_i: mux2on1 port map(A => Z3(i-8), B => Z3(i), Sel => shift(3), Z => Z4(i));
                  end generate;
            
            s4_0: if i>=0 and i < 16 generate 
                    mux4: mux2on1 port map(A => '0', B => Z4(i), Sel => shift(4), Z => Z5(i));
                  end generate;
            s4_i: if i > 15 and i < 28 generate
                    mux4_i: mux2on1 port map(A => Z4(i-16), B => Z4(i), Sel => shift(4), Z => Z5(i));
                  end generate;      
        end generate;

        -- Output    
        S <= Z5;
end behavioral;    