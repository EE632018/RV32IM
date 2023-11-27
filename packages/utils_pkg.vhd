----------------------------------------------------------------------------------
-- File : utilis_pkg.vhd
-- Project: Template matching
-- Create Date: 06/02/2022 01:05:19 PM
-- Target Devices: Zybo Z7000
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package utils_pkg is
    function log2c (n: natural) return natural;
end utils_pkg;

--package body
package body utils_pkg is

    function log2c (n: natural) return natural is
    variable m : natural := n;
    variable p : natural := 0;

begin
--    if n = 0 then
--        return 0;
--    elsif n = 1 then
--        return 0;
--    else
--        while m /= 1 loop
--            m := m(31 downto 1);
--            p := p + 1;   
--        end loop;
--    end if;    
--    return p;
    for i in 31 downto 0 loop
        if n >= 2**i then
            return i;
        end if;
    end loop;
    return 0;
end log2c;

end utils_pkg;