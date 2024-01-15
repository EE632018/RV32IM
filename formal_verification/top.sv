`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2022 10:40:12 AM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input [1 : 0] alu_2bit_op_i,
    input [2 : 0] funct3_i,
    input [6 : 0] funct7_i,
    input clk,
    input rst,
    output logic [4 : 0] alu_op_o
    );
    
		logic [1 : 0] alu_2bit_op;
		logic [2 : 0] funct3;
		logic [6 : 0] funct7;
		logic funct7_5bit, funct7_0bit;
		
		logic and_operation;
		logic sub_operation;
		logic mulu_operation;
		logic mulhs_operation;
		logic sll_operation;
		logic mulhsu_operation;
		logic mulhu_operation;
		logic divs_operation;
		logic xor_operation;
		
		always @(alu_2bit_op_i)begin
			alu_2bit_op = alu_2bit_op_i;
		end	

		always @(funct3_i)begin
			funct3 = funct3_i;
		end 
		
		always @(funct7_i)begin
			funct7 = funct7_i;
			funct7_5bit = funct7_i[5];
			funct7_0bit = funct7_i[0];
		end

		alu_decoder alu_decoder
		(
		    .alu_2bit_op_i(alu_2bit_op_i),
		.funct3_i(funct3_i),
		.funct7_i(funct7_i),
		.alu_op_o(alu_op_o)
		        ); 
		        
	   	always_comb begin
			if (alu_2bit_op == "00") 
				and_operation = 1;
			else if (alu_2bit_op == "11")begin 
				if (funct3 == "000") 
					if (alu_2bit_op == "10")begin
						if (funct7_5bit == "1")
							and_operation = 0;
						else if (funct7_0bit == "1")
							and_operation = 0;
						else
							and_operation = 1;
					end
					else
						and_operation = 1;
				else 
					and_operation = 0;		
			end
			else 
				and_operation = 0;
		end         


		always_comb begin
			if(alu_2bit_op_i == "10" && funct7_5bit == "1" && funct3 == "000")
				sub_operation = 1;
			else
				sub_operation = 0;
		end
		
		always_comb begin
			if( alu_2bit_op_i == "10" && funct7_0bit == "1" && funct3 == "000")
				mulu_operation = 1;
			else
				mulu_operation = 0;
		end

		always_comb begin
			if(alu_2bit_op_i == "10"  && funct7_0bit == "1" && funct3 == "001")
				mulhs_operation = 1;
			else
				mulhs_operation = 0;
		end	
		
		always_comb begin
			if(funct3 == "001" && (funct7_0bit != "1" && alu_2bit_op_i != "10" ))
				sll_operation = 1;
			else
				sll_operation = 0;
		end	
		
		always_comb begin
			if(alu_2bit_op_i == "10"  && (funct7_0bit == "1" && funct3 == "010"))
				mulhsu_operation = 1;
			else
				mulhsu_operation = 0;
		end	
		
		always_comb begin
			if(alu_2bit_op_i == "10"  && (funct7_0bit == "1" && funct3 == "011"))
				mulhu_operation = 1;
			else
				mulhu_operation = 0;
		end	
		
		always_comb begin
			if(alu_2bit_op_i == "10"  && (funct7_0bit == "1" && funct3 == "100"))
				divs_operation = 1;
			else
				divs_operation = 0;
		end	
		
		always_comb begin
			if(funct3 == "100" && (funct7_0bit != "1" || alu_2bit_op_i != "10" ))
				xor_operation = 1;
			else
				xor_operation = 0;
		end	
	   const bit [4 : 0] and_op 	= "00000";  //---> bitwise and
	   const bit [4 : 0] or_op  	= "00001";  //---> bitwise or
	   const bit [4 : 0] add_op 	= "00010";  //---> add a_i and b_i +
	   const bit [4 : 0] sub_op 	= "00110";  //---> sub a_i and b_i +
	   const bit [4 : 0] eq_op  	= "10111";  //--->  set equal
	   const bit [4 : 0] xor_op 	= "00011";  //---> bitwise xor
	   const bit [4 : 0] lts_op 	= "10100";  //---> set less than signed
	   const bit [4 : 0] ltu_op 	= "10101";  //---> set less than unsigned
	   const bit [4 : 0] sll_op 	= "10110";  //---> shift left logic +
	   const bit [4 : 0] srl_op 	= "00111";  //---> shift right logic
	   const bit [4 : 0] sra_op 	= "01000";  //---> shift right arithmetic
	   const bit [4 : 0] mulu_op 	= "01001";  //---> multiply lower      +
	   const bit [4 : 0] mulhs_op 	= "01010";  //---> multiply higher signed +
	   const bit [4 : 0] mulhsu_op  = "01011";  //---> multiply higher signed and unsigned +
	   const bit [4 : 0] mulhu_op  	= "01100";  //---> multiply higher unsigned +
	   const bit [4 : 0] divu_op 	= "01101";  //---> divide unsigned
	   const bit [4 : 0] divs_op  	= "01110";  //---> divide signed
	   const bit [4 : 0] remu_op    = "01111";  //---> reminder unsigned
		
		clocking @(posedge clk);
		endclocking

		default disable iff rst;
		
		property limmitst_for_alu_2bit_op_i;
			 alu_2bit_op_i == ("00" || "01 "|| "11" || "10");
		endproperty
		
		assume property (limmitst_for_alu_2bit_op_i);
		
		/*property posible_outputs;
			alu_op_o == (and_op || or_op || add_op || sub_op || eq_op || xor_op || lts_op || ltu_op || sll_op || srl_op || sra_op || mulu_op || mulhs_op || mulhsu_op || mulhu_op || divu_op || divs_op || remu_op) ;
		endproperty

		assert property (posible_outputs);*/
		
		property add_output;
			 and_operation |-> (alu_op_o == and_op); 
		endproperty;
		
		assert property (add_output);
		
		property sub_output;
			sub_operation |-> (alu_op_o == sub_op); 
		endproperty;
		
		assert property (sub_output);
		
		property mulu_output;
			mulu_operation |-> (alu_op_o == mulu_op); 
		endproperty;
		
		assert property (mulu_output);
		
		property mulhs_output;
			mulhs_operation |-> (alu_op_o == mulhs_op); 
		endproperty;
		
		assert property (mulhs_output);
		
		property sll_output;
			sll_operation |-> (alu_op_o == sll_op); 
		endproperty;
		
		assert property (sll_output);
		
		property mulhsu_output;
			mulhsu_operation |-> (alu_op_o == mulhsu_op); 
		endproperty;
		
		assert property (mulhsu_output);
		
		property mulhu_output;
			mulhu_operation |-> (alu_op_o == mulhu_op); 
		endproperty;
		
		assert property (mulhu_output);
		
		property divs_output;
			divs_operation |-> (alu_op_o == divs_op); 
		endproperty;
		
		assert property (divs_output);
		
		property xor_output;
			xor_operation |-> (alu_op_o == divs_op); 
		endproperty;
		
		assert property (xor_output);
	endmodule
