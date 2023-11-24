library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_ops_pkg.all;

entity alu_decoder_float is
   port ( 
      -- from data_path
      alu_f_bit_op_i : in std_logic_vector(2 downto 0);
      funct3_i       : in std_logic_vector (2 downto 0);
      funct5_i       : in std_logic_vector (4 downto 0);
      rs2_i          : in std_logic_vector (4 downto 0);
      -- to data_path
      alu_op_f_o       : out std_logic_vector(4 downto 0));  
end entity;

architecture behavioral of alu_decoder_float is
    constant fmadd:     std_logic_vector (4 downto 0):="00000";
    constant fmsub:     std_logic_vector (4 downto 0):="00001";
    constant fnmsub:    std_logic_vector (4 downto 0):="00011";
    constant fnmadd:    std_logic_vector (4 downto 0):="00010";
    constant fadd:      std_logic_vector (4 downto 0):="00100";
    constant fsub:      std_logic_vector (4 downto 0):="00101";
    constant fmul:      std_logic_vector (4 downto 0):="00110";
    constant fdiv:      std_logic_vector (4 downto 0):="00111";
    constant fsqrt:     std_logic_vector (4 downto 0):="01000";
    constant fsgnj:     std_logic_vector (4 downto 0):="01001";
    constant fsgnjn:    std_logic_vector (4 downto 0):="01010";
    constant fsgnjx:    std_logic_vector (4 downto 0):="01011";
    constant fmin:      std_logic_vector (4 downto 0):="01100";
    constant fmax:      std_logic_vector (4 downto 0):="01101";
    constant fcvt_w:    std_logic_vector (4 downto 0):="01110";
    constant fcvt_wu:   std_logic_vector (4 downto 0):="01111";
    constant fmv_x_w:   std_logic_vector (4 downto 0):="10000";
    constant feq:       std_logic_vector (4 downto 0):="10001";
    constant flts:      std_logic_vector (4 downto 0):="10010";
    constant fle:       std_logic_vector (4 downto 0):="10011";
    constant fclass:    std_logic_vector (4 downto 0):="10100";
    constant fcvt_s_w:  std_logic_vector (4 downto 0):="10101";
    constant fcvt_s_wu: std_logic_vector (4 downto 0):="10110";
    constant fmv_w_x:   std_logic_vector (4 downto 0):="10111";
   
begin
     
    alu_dec:process(alu_f_bit_op_i,funct3_i,funct5_i, rs2_i)is
        begin
            case alu_f_bit_op_i is
                when "000" =>
                    alu_op_f_o <= fmadd;
                when "001" =>
                    alu_op_f_o <= fmsub;
                when "010" =>
                    alu_op_f_o <= fnmsub;
                when "011" =>
                    alu_op_f_o <= fnmadd;
                when "100" =>
                    case funct5_i is
                        when "00000" =>
                            alu_op_f_o <= fadd;
                        when "00001" =>
                            alu_op_f_o <= fsub;
                        when "00010" =>
                            alu_op_f_o <= fmul;
                        when "00011" =>
                            alu_op_f_o <= fdiv;
                        when "01011" =>
                            alu_op_f_o <= fsqrt;
                        when "00100" =>
                            case funct3_i is
                                when "000" =>
                                    alu_op_f_o <= fsgnj;
                                when "001" =>
                                    alu_op_f_o <= fsgnjn;
                                when "010" =>
                                    alu_op_f_o <= fsgnjx;
                                when others => 
                                    alu_op_f_o <= fmadd;
                            end case;
                        when "00101" =>
                            case funct3_i is
                                when "000" =>
                                    alu_op_f_o <= fmin;
                                when "001" =>
                                    alu_op_f_o <= fmax;
                                when others => 
                                    alu_op_f_o <= fmadd;
                            end case;
                        when "11000" =>   
                            case rs2_i is
                                when "00000" =>
                                    alu_op_f_o <= fcvt_w;
                                when "00001" =>
                                    alu_op_f_o <= fcvt_wu;
                                when others => 
                                    alu_op_f_o <= fmadd;
                            end case;
                        when "11100" =>
                            case funct3_i is
                                when "000" =>
                                    alu_op_f_o <= fmv_x_w;
                                when "001" =>
                                    alu_op_f_o <= fclass;
                                when others => 
                                    alu_op_f_o <= fmadd;
                            end case;
                        when "10100" =>
                            case funct3_i is
                                when "000" =>
                                    alu_op_f_o <= fle;
                                when "001" =>
                                    alu_op_f_o <= flts;
                                when "010" =>
                                    alu_op_f_o <= feq;
                                when others => 
                                    alu_op_f_o <= fmadd;
                            end case;
                        when "11010" =>
                            case rs2_i is
                                when "00000" =>
                                    alu_op_f_o <= fcvt_s_w;
                                when "00001" =>
                                    alu_op_f_o <= fcvt_s_wu;
                                when others => 
                                    alu_op_f_o <= fmadd;
                            end case;
                        when "11110" =>
                            alu_op_f_o <= fmv_w_x;
                        when others =>
                            alu_op_f_o <= fmadd;
                        end case;
                    when "110" => 
                            alu_op_f_o <= fadd;
                    when others =>
                    alu_op_f_o <= fmadd;
            end case;
    end process;

end behavioral;