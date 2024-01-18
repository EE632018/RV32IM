
analyze -vhdl2k ../control_path/alu_decoder.vhd
analyze -vhdl2k ../control_path/forwarding_unit.vhd

#analyze -sv09 top.sv
#elaborate -top {top}
analyze -sv09 top_forwarding_unit.sv
elaborate -top {top_forwarding_unit}

clock clk
reset rst
prove -bg -all
