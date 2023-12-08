LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;
use work.alu_ops_pkg.all;

ENTITY ALU_float IS
   GENERIC(
      WIDTH : NATURAL := 32);
   PORT(
      clk    : in std_logic;
      reset  : in std_logic; 
      a_ii    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); 
      a_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --prvi operand
      b_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --drugi operand
      c_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);  
      op_i   : in STD_LOGIC_VECTOR(4 DOWNTO 0); --selekcija operacije
      res_o  : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
      stall_o: out std_logic
      ); 
END ALU_float;

ARCHITECTURE behavioral OF ALU_float IS

   ------------------------------------------------------------- COMPONENT 
   component FPU is
    Port (clk:   in std_logic;
          rst:   in std_logic;
          start: in std_logic;
          X:     in std_logic_vector(31 downto 0);
          Y:     in std_logic_vector(31 downto 0);
          R:     out std_logic_vector(31 downto 0);
          done:  out std_logic
          );
  end component;

    component floatM
    Port ( a_in : in std_logic_vector(31 downto 0);
           b_in : in std_logic_vector(31 downto 0);
           c_out : out std_logic_vector(31 downto 0)
   );
    end component;
    
    component floatComp
        Port ( a_in : in STD_LOGIC_VECTOR (31 downto 0);
           b_in : in STD_LOGIC_VECTOR (31 downto 0);
           c_max_out : out STD_LOGIC_VECTOR (31 downto 0);
           c_min_out : out STD_LOGIC_VECTOR (31 downto 0);
           c_feq_out : out STD_LOGIC_VECTOR (31 downto 0);
           c_flts_out: out STD_LOGIC_VECTOR (31 downto 0);
           c_fle_out : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    component fcvt
    Port ( a_in : in STD_LOGIC_VECTOR (31 downto 0);
           c_s_out : out STD_LOGIC_VECTOR (31 downto 0);
           c_u_out : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    component fcvt_i
    Port ( a_in : in STD_LOGIC_VECTOR (31 downto 0);
           c_s_out : out STD_LOGIC_VECTOR (31 downto 0);
           c_u_out : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    component fclass_c
    Port ( a_in : in STD_LOGIC_VECTOR (31 downto 0);
           c_out : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component FPP_DIVIDE 
      port (A        : in  std_logic_vector(31 downto 0);  --Dividend
            B        : in  std_logic_vector(31 downto 0);  --Divisor
            clk      : in  std_logic;       --Master clock
            reset    : in  std_logic;       --Global asynch reset
            go       : in  std_logic;       --Enable
            done     : out std_logic;       --Flag for done computing
            --ZD:         out std_logic;                                          --Flag for zero divisor
            overflow : out std_logic;       --Flag for overflow
            result   : out std_logic_vector(31 downto 0)   --Holds final FP result
            );
    end component;
    
    component fsqrt_c
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               start : in STD_LOGIC;
               a_i : in STD_LOGIC_VECTOR (31 downto 0);
               c_out : out STD_LOGIC_VECTOR (31 downto 0);
               stall_o : out STD_LOGIC);
    end component;
    ------------------------------------------------------------ CONSTANT OP
    constant fmadd:     std_logic_vector (4 downto 0):="00000"; --
    constant fmsub:     std_logic_vector (4 downto 0):="00001"; --
    constant fnmsub:    std_logic_vector (4 downto 0):="00011"; --
    constant fnmadd:    std_logic_vector (4 downto 0):="00010"; --
    constant fadd:      std_logic_vector (4 downto 0):="00100"; --
    constant fsub:      std_logic_vector (4 downto 0):="00101"; --
    constant fmul:      std_logic_vector (4 downto 0):="00110"; --
    constant fdiv:      std_logic_vector (4 downto 0):="00111"; --
    constant fsqrt:     std_logic_vector (4 downto 0):="01000"; --
    constant fsgnj:     std_logic_vector (4 downto 0):="01001"; --
    constant fsgnjn:    std_logic_vector (4 downto 0):="01010"; --
    constant fsgnjx:    std_logic_vector (4 downto 0):="01011"; --
    constant fmin:      std_logic_vector (4 downto 0):="01100"; --
    constant fmax:      std_logic_vector (4 downto 0):="01101"; --
    constant fcvt_w:    std_logic_vector (4 downto 0):="01110"; --
    constant fcvt_wu:   std_logic_vector (4 downto 0):="01111"; --
    constant fmv_x_w:   std_logic_vector (4 downto 0):="10000"; --
    constant feq:       std_logic_vector (4 downto 0):="10001"; --
    constant flts:      std_logic_vector (4 downto 0):="10010"; --
    constant fle:       std_logic_vector (4 downto 0):="10011"; --
    constant fclass:    std_logic_vector (4 downto 0):="10100"; --
    constant fcvt_s_w:  std_logic_vector (4 downto 0):="10101"; --
    constant fcvt_s_wu: std_logic_vector (4 downto 0):="10110"; --
    constant fmv_w_x:   std_logic_vector (4 downto 0):="10111"; --
    
    signal a_mux_i, b_mux_i, a_mux_m_i : std_logic_vector(WIDTH - 1 downto 0);

    signal fpadd      : std_logic_vector(WIDTH - 1 downto 0);
    signal fpsub      : std_logic_vector(WIDTH - 1 downto 0);
    signal fsgnj_res : std_logic_vector(WIDTH - 1 downto 0);
    signal fsgnjn_res : std_logic_vector(WIDTH - 1 downto 0);
    signal fsgnjx_res : std_logic_vector(WIDTH - 1 downto 0);
    signal fmul_res   : std_logic_vector(WIDTH - 1 downto 0);
    signal fmax_res   : std_logic_vector(WIDTH - 1 downto 0);
    signal fmin_res   : std_logic_vector(WIDTH - 1 downto 0);
    signal fcvt_res_s : std_logic_vector(WIDTH - 1 downto 0); 
    signal fcvt_res_u : std_logic_vector(WIDTH - 1 downto 0); 
    signal fcvt_i_res_s : std_logic_vector(WIDTH - 1 downto 0); 
    signal fcvt_i_res_u : std_logic_vector(WIDTH - 1 downto 0); 
    signal fmv_res_f  : std_logic_vector(WIDTH - 1 downto 0); -- float to integer
    signal fmv_res_i  : std_logic_vector(WIDTH - 1 downto 0); -- integer to float
    signal feq_res    : std_logic_vector(WIDTH - 1 downto 0);
    signal flts_res   : std_logic_vector(WIDTH - 1 downto 0);
    signal fle_res    : std_logic_vector(WIDTH - 1 downto 0);
    signal fclass_res : std_logic_vector(WIDTH - 1 downto 0);
    signal res_s     : std_logic_vector(WIDTH - 1 downto 0);
    signal fdiv_res  : std_logic_vector(WIDTH - 1 downto 0);
    signal fsqrt_res  : std_logic_vector(WIDTH - 1 downto 0);
    
    signal start_s : std_logic;
    
    signal fdiv_stall : std_logic;
    signal fadd_stall : std_logic;
    signal fsub_stall : std_logic;
    signal fsqrt_stall : std_logic;
    
    signal b_sub      : std_logic_vector(31 downto 0);
begin

   -- Logic xor b input for subtraction
   b_sub <= ('1' xor b_i(31)) & b_i(30 downto 0); 

   fadd_inst: FPU
   port map (clk => clk, rst => reset, start => start_s, X => a_mux_i, Y => b_mux_i, R => fpadd, done => fadd_stall);

   fsub_inst: FPU
   port map (clk => clk, rst => reset, start => start_s, X => a_i, Y => b_sub, R => fpsub, done => fsub_stall);
   
   fmul_ins: floatM
   port map (a_in => a_mux_m_i, b_in => b_i, c_out => fmul_res);

   floatComp_inst: floatComp
   port map (a_in => a_i, b_in => b_i, c_max_out => fmax_res, c_min_out => fmin_res, c_feq_out => feq_res,
             c_flts_out => flts_res, c_fle_out => fle_res); 

   fcvt_inst: fcvt
   port map (a_in => a_i, c_s_out => fcvt_res_s, c_u_out => fcvt_res_u);
   
   fcvt_i_inst: fcvt_i
   port map (a_in => a_ii, c_s_out => fcvt_i_res_s, c_u_out => fcvt_i_res_u); 

   fclass_inst: fclass_c
   port map (a_in => a_i, c_out => fclass_res);
   
   fdiv_i:FPP_DIVIDE
   port map (A => a_i, B => b_i, result => fdiv_res, clk => clk, reset => reset, go => start_s, done => fdiv_stall, overflow => open);

   fsqrt_i: fsqrt_c
   port map(a_i => a_i, clk => clk, rst => reset, start => start_s, stall_o => fsqrt_stall, c_out => fsqrt_res); 

   fsgnj_res <= b_i(31) & a_i(30 downto 0);
   fsgnjn_res <= not(b_i(31)) & a_i(30 downto 0);
   fsgnjx_res <= (a_i(31) xor b_i(31)) & a_i(30 downto 0);
   fmv_res_f <= a_i;
   fmv_res_i <= a_ii;


    process(op_i, a_i, b_i, fmul_res, c_i)
    begin
        if op_i = fadd then
            a_mux_i <= a_i;
            b_mux_i <= b_i;
        else
            a_mux_i <= fmul_res;
            b_mux_i <= c_i;
            if op_i = fnmsub or op_i = fmsub then
                b_mux_i <= ('1' xor c_i(31)) & c_i(30 downto 0);
            end if;    
        end if;
        
        if op_i = fnmadd or op_i = fnmsub then
            a_mux_m_i <= ('1' xor a_i(31)) & a_i(30 downto 0);
        else
            a_mux_m_i <= a_i;
        end if;
    end process;

   with op_i select
      res_s <= fpadd            when fadd,
               fpadd            when fnmsub, 
               fpadd            when fmsub, 
               fpadd            when fnmadd, 
               fpadd            when fmadd,
               fpsub            when fsub,
               fsgnj_res        when fsgnj,
               fsgnjn_res       when fsgnjn,
               fsgnjx_res       when fsgnjx,
               fmul_res         when fmul,
               fmax_res         when fmax,
               fmin_res         when fmin,
               fcvt_res_u       when fcvt_wu,
               fcvt_res_s       when fcvt_w, 
               fmv_res_f        when fmv_x_w,
               fmv_res_i        when fmv_w_x,
               feq_res          when feq,
               flts_res         when flts,
               fle_res          when fle,
               fclass_res       when fclass,
               fcvt_i_res_s     when fcvt_s_w,
               fcvt_i_res_u     when fcvt_s_wu,
               fdiv_res         when fdiv,
               fsqrt_res        when fsqrt,
               (others => '1')  when others;   
               
    with op_i select
        stall_o <= fdiv_stall   when fdiv,
                   fadd_stall   when fadd,
                   fadd_stall   when fnmsub, 
                   fadd_stall   when fmsub, 
                   fadd_stall   when fnmadd, 
                   fadd_stall   when fmadd,
                   fsub_stall   when fsub, 
                   fsqrt_stall  when fsqrt,
                    '1'         when others;
    with op_i select
        start_s <= '1' when fdiv,
                   '1' when fadd,
                   '1' when fsub, 
                   '1' when fmadd, 
                   '1' when fnmadd, 
                   '1' when fmsub, 
                   '1' when fnmsub,
                   '1' when fsqrt, 
                   '0' when others;                
   res_o <= res_s;            
end behavioral;    