library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mantissa_sqrt is
  Port (clk:   in std_logic;
        rst:   in std_logic;
        start: in std_logic;
        m_i:   in std_logic_vector(23 downto 0);
        m_o:   out std_logic_vector(23 downto 0);
        stall:  out std_logic
        );
end mantissa_sqrt;

architecture Behavioral of mantissa_sqrt is

    signal tmp_r, tmp_n, ans_r, ans_n: std_logic_vector(26 downto 0);
    signal m_r, m_n: std_logic_vector(23 downto 0);
    signal point_r, point_n: std_logic_vector(5 downto 0);
    signal sub_tmp, shift_ans: std_logic_vector(26 downto 0);

    type state_type is (INIT, COMP, RES);
    signal state, state_next: state_type := INIT;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                state <= INIT;
                tmp_r <= (others => '0');
                ans_r <= (others => '0');
                point_r <= std_logic_vector(to_unsigned(25,6));
                m_r   <= (others => '0');
            else
                state <= state_next;
                tmp_r <= tmp_n;
                ans_r <= ans_n;
                point_r <= point_n;
                m_r <= m_n;
            end if;
        end if;    
    end process;

    process(state, start, tmp_r, ans_r,point_r, m_r, m_i, sub_tmp, shift_ans)
    begin
        m_n <= m_r;
        sub_tmp <= (others => '0');
        shift_ans <= (others => '0');
        point_n <= point_r;
        case state is
            when INIT =>
                stall <= '1'; 
                if start = '1' then
                    state_next <= COMP;
                    tmp_n <= "000" & m_i;
                    ans_n <= "010000000000000000000000000";
                else
                    state_next <= INIT;
                    tmp_n <= (others => '0');
                    ans_n <= (others => '0');
                end if;
            when COMP =>
                stall <= '0';
                point_n <= std_logic_vector(unsigned(point_r) - to_unsigned(1,6));
                if unsigned(tmp_r) >= unsigned(ans_r) then
                    sub_tmp <= std_logic_vector(unsigned(tmp_r) - unsigned(ans_r));
                    tmp_n <= sub_tmp(25 downto 0) & '0';
                    shift_ans <= ans_r(25 downto 0) & '0';
                    for i in 0 to 26 loop
                        if i = TO_INTEGER(unsigned(point_r)) then
                            ans_n(i) <= '1';
                        else
                            ans_n(i) <= shift_ans(i);
                        end if;
                    end loop;
                else
                    tmp_n <= tmp_r(25 downto 0) & '0';
                    shift_ans <= '0' & ans_r(26 downto 1);
                    for i in 0 to 26 loop
                        if i = TO_INTEGER(unsigned(point_r)) then
                            ans_n(i) <= '0';
                        else
                            ans_n(i) <= shift_ans(i);
                        end if;
                    end loop;
                end if;
                
                if point_r = std_logic_vector(to_unsigned(0,6)) then
                    state_next <= RES;    
                else
                    state_next <= COMP;
                end if;
            when RES  =>
                m_n <= ans_r(25 downto 2);
                point_n <=  std_logic_vector(to_unsigned(25,6));
                state_next <= INIT;
                stall <= '0';
                ans_n <= ans_r;
                tmp_n <= tmp_r;
            when others =>
                state_next <= INIT;
                stall <= '1';
                tmp_n <= tmp_r;
                ans_n <= ans_r;
        end case;
    end process;    

    m_o <= m_r;

end Behavioral;