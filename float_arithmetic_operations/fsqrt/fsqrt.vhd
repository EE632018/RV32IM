library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsqrt is
  Port (clk:   in std_logic;
        rst:   in std_logic;
        start: in std_logic;
        a_i:   in std_logic_vector(31 downto 0);
        a_o:   out std_logic_vector(31 downto 0);
        stall:  out std_logic
        );
end fsqrt;

architecture Behavioral of fsqrt is

    component mantissa_sqrt
    Port (clk:   in std_logic;
          rst:   in std_logic;
          start: in std_logic;
          m_i:   in std_logic_vector(23 downto 0);
          m_o:   out std_logic_vector(23 downto 0);
          stall:  out std_logic
        );
    end component;

    component fclass_c
    Port ( a_in : in STD_LOGIC_VECTOR (31 downto 0);
           c_out : out STD_LOGIC_VECTOR (31 downto 0));
    end component;       

    type state_type is (INIT, COMP, RES);
    signal state, state_next: state_type := INIT;
    
    signal mo_s, m_sqrt: std_logic_vector(23 downto 0);
    signal m_s: std_logic_vector(22 downto 0); 
    signal c_s : std_logic_vector(31 downto 0);
    signal e_s: std_logic_vector(7 downto 0);
    signal e_add, e_sqrt: std_logic_vector(8 downto 0);
    signal sign, start_s, stall_s: std_logic;
    signal a_r, a_n : std_logic_vector(31 downto 0);
begin

    mantissa_inst: mantissa_sqrt
    port map (clk => clk, rst => rst, start => start_s, m_i => m_sqrt, m_o => mo_s, stall => stall_s);
    
    fcalss_inst: fclass_c
    port map (a_in => a_i, c_out => c_s);
    
    sign <= a_i(31);
    e_s <= a_i(30 downto 23);
    m_s <= a_i(22 downto 0);
    
    
    process(e_s, m_s, e_add)
    begin
        if e_s(0) = '1' then
            e_add <= std_logic_vector(unsigned(e_s) + to_unsigned(127,9));
            m_sqrt <= '1' & m_s(21 downto 0) & '0';
        else
            e_add <= std_logic_vector(unsigned(e_s) + to_unsigned(126,9));
            m_sqrt <= '1' & m_s;
        end if;
        
        e_sqrt <= '0' & e_add(8 downto 1);
        
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                state <= INIT;
                a_r <= (others => '0');
            else
                state <= state_next;
                a_r <= a_n;
            end if;
        end if;    
    end process;
    
    process(state, start, a_r, c_s, sign, e_sqrt, mo_s, stall_s)
    begin
        a_n <= a_r;
        start_s <= '0';
        case state is
            when INIT =>
                stall <= '1'; 
                if start = '1' then
                    state_next <= COMP;
                    if c_s(4) = '1' or c_s(5) = '1' or c_s(6) = '1' then
                        state_next <= COMP;
                        start_s <= '1';
                    else
                        state_next <= INIT;
                        a_n <= (others => '1');     
                    end if;
                else
                    state_next <= INIT;
                end if;
            when COMP =>
                stall <= '0'; 
                if stall_s = '0' then
                    state_next <= COMP;
                else
                    state_next <= RES;
                end if;
            when RES  =>
                a_n <= sign & e_sqrt(7 downto 0) & mo_s(22 downto 0);
                state_next <= INIT;
                stall <= '0';
            when others =>
                state_next <= INIT;
                stall <= '1';
        end case;
    end process;    

    a_o <= a_r;
    
end Behavioral;