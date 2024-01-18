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
	
	reg [4 : 0] rs1_add, rs2_add, rs3_add;
	reg [4 : 0] rd_add;
	
	logic rd_mem_eq_1, rd_mem_eq_2, rd_mem_eq_3;
	logic rd_mem_not_z;
	
	clocking @(posedge clk);
	endclocking

	default disable iff rst;
	
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
	
	property alu_f_a_o;
		(rd_mem_eq_1 && rd_we_mem_i && rd_mem_not_z) |=> (alu_forward_a_o == "10");
	endproperty
	assert property(alu_f_a_o);
	
	//cover property(alu_forward_a_o == "00");
endmodule
