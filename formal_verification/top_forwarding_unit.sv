module top_forwarding_unit(
	input clk,
	input rst,
	
	input [4 : 0] rs1_address_id_i,
	input [4 : 0] rs2_address_id_i,
	input [4 : 0] rs3_address_id_i,
	
	input [4 : 0] rs1_address_ex_i,
	input [4 : 0] rs2_address_ex_i,
	input [4 : 0] rs3_address_ex_i,
	
	input rd_we_mem_i,
	input [4 : 0] rd_address_mem_i,
	
	input rd_we_wb_i,
	input [4 : 0] rd_address_wb_i,
	
	output [1 : 0] alu_forward_a_o,
	output [1 : 0] alu_forward_b_o,
	output [1 : 0] alu_forward_c_o,
	
	output branch_forward_a_o,
	output branch_forward_b_o
	);
	
	forwarding_unit forwarding_unit(
		.rs1_address_id_i(rs1_address_id_i),
		.rs2_address_id_i(rs2_address_id_i),
		.rs3_address_id_i(rs3_address_id_i),
		.rs1_address_ex_i(rs1_address_ex_i),
		.rs2_address_ex_i(rs2_address_ex_i),
		.rs3_address_ex_i(rs3_address_ex_i),
		.rd_we_mem_i(rd_we_mem_i),
		.rd_address_mem_i(rd_address_mem_i),
		.rd_we_wb_i(rd_we_wb_i),
		.rd_address_wb_i(rd_address_wb_i),
		.alu_forward_a_o(alu_forward_a_o),
		.alu_forward_b_o(alu_forward_b_o),
		.alu_forward_c_o(alu_forward_c_o),
		.branch_forward_a_o(branch_forward_a_o),
		.branch_forward_b_o(branch_forward_b_o)
		);
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	reg [4 : 0] rs1_add, rs2_add, rs3_add;
	reg [4 : 0] rd_add;
	
	logic rd_mem_eq_1, rd_mem_eq_2, rd_mem_eq_3;
	logic rd_wb_eq_1, rd_wb_eq_2, rd_wb_eq_3;
	logic rd_mem_not_z;
	logic rd_wb_not_z;
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	clocking @(posedge clk);
	endclocking

	default disable iff rst;
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	always@(posedge clk)
		begin
			if(rst)
			begin
				rs1_add = 0;
				rs2_add = 0;
				rs3_add = 0;
				rd_add = 0;
			end
			else
			begin
				rs1_add = rs1_address_id_i;
				rs2_add = rs2_address_id_i;
				rs3_add = rs3_address_id_i;
				rd_add = rd_address_mem_i;
			end
		end
	
	
	property limit_for_rs1_ex;
		rs1_address_ex_i == rs1_add;
	endproperty
	
	assume property (limit_for_rs1_ex);
	
	property limit_for_rs3_ex;
		rs3_address_ex_i == rs3_add;
	endproperty
	
	assume property (limit_for_rs1_ex);
	
	property limit_for_rs2_ex;
		rs2_address_ex_i == rs2_add;
	endproperty
	
	assume property (limit_for_rs2_ex);
	
	property limit_for_rd;
		rd_address_wb_i == rd_add;
	endproperty
	
	assume property (limit_for_rd);
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	always_comb
		begin
			if(rs1_address_ex_i == rd_address_mem_i )
				rd_mem_eq_1 = 1;
			else
				rd_mem_eq_1 = 0;
				
			if(rs2_address_ex_i == rd_address_mem_i )
				rd_mem_eq_2 = 1;
			else
				rd_mem_eq_2 = 0;
				
			if(rs3_address_ex_i == rd_address_mem_i )
				rd_mem_eq_3 = 1;
			else
				rd_mem_eq_3 = 0;

			if(rd_address_mem_i == 0)
				rd_mem_not_z = 0;
			else
				rd_mem_not_z = 1;
		end

	always_comb
		begin
			if(rs1_address_ex_i == rd_address_wb_i )
				rd_wb_eq_1 = 1;
			else
				rd_wb_eq_1 = 0;
				
			if(rs2_address_ex_i == rd_address_wb_i )
				rd_wb_eq_2 = 1;
			else
				rd_wb_eq_2 = 0;
				
			if(rs3_address_ex_i == rd_address_wb_i )
				rd_wb_eq_3 = 1;
			else
				rd_wb_eq_3 = 0;

			if(rd_address_wb_i == 0)
				rd_wb_not_z = 0;
			else
				rd_wb_not_z = 1;
		end
	//////////////////////////////////////////////////////////////PROPERTYS FOR ALU FORWARD///////////////////////////////////////////////////////////////////////////////////////////////
	property alu_f_a_o_10;
		(rd_mem_eq_1 && rd_we_mem_i && rd_mem_not_z) |-> (alu_forward_a_o != "10");
	endproperty
	alu_f_a_o_is_10:assert property(alu_f_a_o_10);

	property alu_f_b_o_10;
		(rd_mem_eq_2 && rd_we_mem_i && rd_mem_not_z) |-> (alu_forward_b_o != "10");
	endproperty
	alu_f_b_o_is_10:assert property(alu_f_b_o_10);

	property alu_f_c_o_10;
		(rd_mem_eq_3 && rd_we_mem_i && rd_mem_not_z) |-> (alu_forward_c_o != "10");
	endproperty
	alu_f_c_o_is_10:assert property(alu_f_c_o_10);
	
	alu_f_a_o_is_never_11:assert property(alu_forward_a_o != "11");
	alu_f_b_o_is_never_11:assert property(alu_forward_b_o != "11");
	alu_f_c_o_is_never_11:assert property(alu_forward_c_o != "11");
	
	property alu_f_a_o_01;
		((!rd_mem_eq_1 || !rd_we_mem_i || !rd_mem_not_z) && (rd_wb_eq_1 && rd_we_wb_i && rd_wb_not_z)) |-> (alu_forward_a_o != "01");
	endproperty
	alu_f_a_o_is_01:assert property(alu_f_a_o_01);
	
	property alu_f_b_o_01;
		((!rd_mem_eq_2 || !rd_we_mem_i || !rd_mem_not_z) && (rd_wb_eq_2 && rd_we_wb_i && rd_wb_not_z)) |-> (alu_forward_b_o != "01");
	endproperty
	alu_f_b_o_is_01:assert property(alu_f_b_o_01);
	
	property alu_f_c_o_01;
		((!rd_mem_eq_3 || !rd_we_mem_i || !rd_mem_not_z) && (rd_wb_eq_3 && rd_we_wb_i && rd_wb_not_z)) |-> (alu_forward_c_o != "01");
	endproperty
	alu_f_c_o_is_01:assert property(alu_f_c_o_01);
	
	property alu_f_a_o_00;
		((!rd_mem_eq_1 || !rd_we_mem_i || !rd_mem_not_z) && (!rd_wb_eq_1 && !rd_we_wb_i && !rd_wb_not_z)) |-> (alu_forward_a_o != "00");
	endproperty
	alu_f_a_o_is_00:assert property(alu_f_a_o_00);
	
	property alu_f_b_o_00;
		((!rd_mem_eq_2 || !rd_we_mem_i || !rd_mem_not_z) && (!rd_wb_eq_2 && !rd_we_wb_i && !rd_wb_not_z)) |-> (alu_forward_b_o != "00");
	endproperty
	alu_f_b_o_is_00:assert property(alu_f_b_o_00);
	
	property alu_f_c_o_00;
		((!rd_mem_eq_3 || !rd_we_mem_i || !rd_mem_not_z) && (!rd_wb_eq_3 && !rd_we_wb_i && !rd_wb_not_z)) |-> (alu_forward_c_o != "00");
	endproperty
	alu_f_c_o_is_00:assert property(alu_f_c_o_00);
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////PROPERTYS FOR BRANCH FORWARD///////////////////////////////////////////////////////////////////////////////////////////////
	property branch_forward_a_o_1;
		(rd_we_mem_i && rd_mem_not_z && rd_mem_eq_1) |-> (branch_forward_a_o); 
	endproperty;
	branch_forward_a_o_is_1: assert property (branch_forward_a_o_1);
	
	property branch_forward_a_o_0;
		(!rd_we_mem_i || !rd_mem_not_z || !rd_mem_eq_1) |-> (!branch_forward_a_o); 
	endproperty;
	branch_forward_a_o_is_0: assert property (branch_forward_a_o_0);
	
	property branch_forward_b_o_1;
		(rd_we_mem_i && rd_mem_not_z && rd_mem_eq_2) |-> (branch_forward_b_o); 
	endproperty;
	branch_forward_b_o_is_1: assert property (branch_forward_b_o_1);
	
	property branch_forward_b_o_0;
		(!rd_we_mem_i || !rd_mem_not_z || !rd_mem_eq_2) |-> (!branch_forward_b_o); 
	endproperty;
	branch_forward_b_o_is_0: assert property (branch_forward_b_o_0);
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
endmodule
