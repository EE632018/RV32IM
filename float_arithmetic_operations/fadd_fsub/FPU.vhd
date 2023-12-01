library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FPU is
  Port (clk:   in std_logic;
        rst:   in std_logic;
        start: in std_logic;
        X:     in std_logic_vector(31 downto 0);
        Y:     in std_logic_vector(31 downto 0);
        R:     out std_logic_vector(31 downto 0);
        done:  out std_logic
        );
end FPU;

architecture Behavioral of FPU is

type state_type is (WAITING, ALIGN, ADD, NORMALIZE, OUTPUT);
signal state: state_type := WAITING;

signal Sx, Sy, Sr: std_logic;
signal Ex, Ey, Er: std_logic_vector(8 downto 0);
signal Mx, My, Mr: std_logic_vector(24 downto 0);

component cmp_exp is
  Port (Ex: in std_logic_vector(8 downto 0);
        Ey: in std_logic_vector(8 downto 0);
        EQ: out std_logic;
        GT: out std_logic;
        LT: out std_logic
        );
end component;

signal expEQ, expGT, expLT: std_logic;

begin

    exponent_comp: cmp_exp port map(Ex => Ex, Ey => Ey, EQ => expEQ, GT => expGT, LT => expLT);
    
    process(clk, rst)
        variable d: signed(8 downto 0);
        variable case3, case5: std_logic := '0';
    begin
        
        if rst = '1' then
            state <= WAITING;
            --done  <= '1';
        elsif rising_edge(clk) then
            case state is
                when WAITING =>
                    --done <= '1';
                    if start = '1' then
                        Sx <= X(31);
                        Sy <= Y(31);
                        Mx <= "01" & X(22 downto 0);
                        My <= "01" & Y(22 downto 0);
                        Ex <= '0' & X(30 downto 23);
                        Ey <= '0' & Y(30 downto 23);
                        state <= ALIGN;
                    else
                        state <= WAITING;
                    end if; 
                when ALIGN =>
                    --done <= '0';
                    if expGT = '1' then
                        d := signed(Ex) - signed(Ey);
                        if d < 23 then
                            Er <= Ex;
                            My <= std_logic_vector(shift_right(unsigned(My), to_integer(d)));
                            state <= ADD;
                        else
                            R <= X;
                            case3 := '1';
                            state <= OUTPUT;
                        end if;
                    elsif expLT = '1' then
                        d := signed(Ey) - signed(Ex);
                        if d < 23 then
                            Er <= Ey;
                            Mx <= std_logic_vector(shift_right(unsigned(Mx), to_integer(d)));
                            state <= ADD;
                        else
                            R <= Y;
                            case5 := '1';
                            state <= OUTPUT;
                        end if;
                    else
                        Er <= Ey;
                        state <= ADD;
                    end if;
                when ADD =>
                    --done <= '0';
                    state <= NORMALIZE;
                    if (Sx xor Sy) = '0' then -- X, Y have same sign
                        Mr <= std_logic_vector((unsigned(Mx) + unsigned(My)));
                        Sr <= Sx;
                    elsif (unsigned(Mx) >= unsigned(My)) then
                        Mr <= std_logic_vector((unsigned(Mx) - unsigned(My)));
                        Sr <= Sx;
                    else
                        Mr <= std_logic_vector((unsigned(My) - unsigned(Mx)));
                        Sr <= Sy;
                    end if;
                when NORMALIZE =>
                    --done <= '0';
                    if unsigned(Mr) = to_unsigned(0, 25) then
                        Mr <= (others => '0');
                        Er <= (others => '0');
                        state <= OUTPUT;
                    elsif (Mr(24) = '1') then
                        Mr <= '0' & Mr(24 downto 1);
                        Er <= std_logic_vector((unsigned(Er) + 1));
                        state <= OUTPUT;
                    elsif (Mr(23) = '0') then
                        Mr <= Mr(23 downto 0) & '0';
                        Er <= std_logic_vector((unsigned(Er) - 1));
                        state <= NORMALIZE;
                    else
                        state <= OUTPUT;
                    end if;
                when OUTPUT =>
                    if (case3 = '0' and case5 = '0') then
                        R(31) <= Sr;
                        R(30 downto 23) <= Er(7 downto 0);
                        R(22 downto 0) <= Mr(22 downto 0);
                        --done <= '0';
                    else
                        --done <= '0';
                    end if;
                    
                    if start = '0' then
                        state <= WAITING;
                    end if;
                when others => state <= WAITING;
            end case;
        end if;                              
    end process;

    process(state)
    begin
        case state is
            when WAITING => done <= '1';
            when ALIGN =>  done <= '0';
            when ADD =>  done <= '0';
            when NORMALIZE =>  done <= '0';
            when OUTPUT =>  done <= '0';
            when others =>  done <= '1';
        end case;
        
    end process;

end Behavioral;