variable dispScriptFile [file normalize [info script]]

proc getScriptDirectory {} {
    variable dispScriptFile
    set scriptFolder [file dirname $dispScriptFile]
    return $scriptFolder
}

set sdir [getScriptDirectory]
cd [getScriptDirectory]


set resultDir .\/RV32IM
file mkdir $resultDir
create_project RV32IM_tcl $resultDir -part xc7z010clg400-1 -force
#set_property board_part em.avnet.com:zed:part0:1.4 [current_project]
#set_property board_part em.avnet.com:zed:part0:2.0 [current_project]
set_property target_language VHDL [current_project]

add_files -norecurse ../packages/alu_ops_pkg.vhd
add_files -norecurse ../packages/controlpath_signals_pkg.vhd
add_files -norecurse ../packages/datapath_signals_pkg.vhd
add_files -norecurse ../packages/txt_util.vhd
add_files -norecurse ../control_path/alu_decoder.vhd
add_files -norecurse ../control_path/ctrl_decoder.vhd
add_files -norecurse ../control_path/forwarding_unit.vhd
add_files -norecurse ../control_path/hazard_unit.vhd
add_files -norecurse ../control_path/control_path.vhd
add_files -norecurse ../data_path/ALU_simple.vhd
add_files -norecurse ../data_path/immediate.vhd
add_files -norecurse ../data_path/register_bank.vhd
add_files -norecurse ../data_path/data_path.vhd
add_files -norecurse ../branch_predictor/BHR.vhd
add_files -norecurse ../branch_predictor/BHR_local.vhd
add_files -norecurse ../branch_predictor/PHT.vhd
add_files -norecurse ../branch_predictor/TOC.vhd
add_files -norecurse ../branch_predictor/priority_encoder.vhd
add_files -norecurse ../branch_predictor/two_bit_pred.vhd
add_files -norecurse ../branch_predictor/Gshare.vhd
add_files -norecurse ../branch_predictor/GAg.vhd
add_files -norecurse ../branch_predictor/pshare.vhd
add_files -norecurse ../branch_predictor/PAp.vhd
add_files -norecurse ../branch_predictor/MHBP.vhd
add_files -norecurse ../division_u.vhd
add_files -norecurse ../multiply.vhd
add_files -norecurse ../TOP_RISCV.vhd
add_files -norecurse ../RISCV_tb/BRAM_byte_addressable.vhd
add_files -fileset sim_1 ../RISCV_tb/TOP_RISCV_tb.vhd
add_files -fileset constrs_1 -norecurse ../constraints/clk_constraint.xdc

update_compile_order -fileset sources_1

set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]

