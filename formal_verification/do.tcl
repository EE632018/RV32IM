#analyze -vhdl2k mux16na1.vhd
#analyze -vhdl2k dekoder2na4.vhd
#analyze -vhdl2k registar.vhd
#analyze -vhdl2k logika.vhd
analyze -vhdl2k ../control_path/alu_decoder.vhd
analyze -sv09 top.sv
elaborate -top {top}
clock clk
reset rst
prove -bg -all
