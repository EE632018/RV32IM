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
    	
	   	const bit [4 : 0] and_op 	= "00000";  //---> bitwise and
	   	const bit [4 : 0] or_op  	= "00001";  //---> bitwise or
	   	const bit [4 : 0] add_op 	= "00010";  //---> add a_i and b_i 
	   	const bit [4 : 0] sub_op 	= "00110";  //---> sub a_i and b_i 
	   	const bit [4 : 0] eq_op  	= "10111";  //--->  set equal
	   	const bit [4 : 0] xor_op 	= "00011";  //---> bitwise xor
	   	const bit [4 : 0] lts_op 	= "10100";  //---> set less than signed
	   	const bit [4 : 0] ltu_op 	= "10101";  //---> set less than unsigned
	   	const bit [4 : 0] sll_op 	= "10110";  //---> shift left logic 
	   	const bit [4 : 0] srl_op 	= "00111";  //---> shift right logic
	   	const bit [4 : 0] sra_op 	= "01000";  //---> shift right arithmetic
	   	const bit [4 : 0] mulu_op 	= "01001";  //---> multiply lower      
	   	const bit [4 : 0] mulhs_op 	= "01010";  //---> multiply higher signed 
	   	const bit [4 : 0] mulhsu_op 	= "01011";  //---> multiply higher signed and unsigned 
   		const bit [4 : 0] mulhu_op  	= "01100";  //---> multiply higher unsigned 
  	 	const bit [4 : 0] divu_op 	= "01101";  //---> divide unsigned
	   	const bit [4 : 0] divs_op  	= "01110";  //---> divide signed
	   	const bit [4 : 0] remu_op   	= "01111";  //---> reminder unsigned
		const bit [4 : 0] rems_op	= "10000";  //---> reminder signed
    	
    	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    	
		logic [1 : 0] alu_2bit_op;
		logic [2 : 0] funct3;
		logic [6 : 0] funct7;
		logic funct7_5bit, funct7_0bit;
		logic [1 : 0] fun3_2MSB;
		
		logic and_operation;
		logic eq_operation;
		logic lts_operation;
		logic ltu_operation;
		logic sub_operation;
		logic mulu_operation;
		logic mulhs_operation;
		logic sll_operation;
		logic mulhsu_operation;
		logic mulhu_operation;
		logic divs_operation;
		logic xor_operation;
		logic srl_operation;
		logic sra_operation;
		logic divu_operation;
		logic or_operation;
		logic rems_operation;
		logic and_operation;
		logic remu_operation;
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		always @(alu_2bit_op_i)begin
			alu_2bit_op = alu_2bit_op_i;
		end	

		always @(funct3_i)begin
			funct3 = funct3_i;
			fun3_2MSB = funct3_i[2 :1];
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
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		        
	   	always_comb begin
			if (alu_2bit_op == "00") 
				and_operation = 1;
			else if (alu_2bit_op != "01")begin 
				if (funct3 == "000")begin
					if(alu_2bit_op_i == "10" && funct7_5bit == "1")
						and_operation = 0;	
					else
						and_operation = 1;	
				end
				else
					and_operation = 0;	
			end
			else
				and_operation = 0;
		end         
		
		always_comb begin
			if (alu_2bit_op == "01" && fun3_2MSB == "00")
				eq_operation = 1;
			else
				eq_operation = 0;
		end

		always_comb begin
			if (alu_2bit_op == "01" && fun3_2MSB == "10")
				lts_operation = 1;
			else if (funct3 == "010" && ((funct7_0bit == "1" && alu_2bit_op_i == "11" ) || (funct7_0bit != "1" && alu_2bit_op_i == "10" )))
				lts_operation = 1;
			else
				lts_operation = 0;
		end

		always_comb begin
			if (alu_2bit_op == "01" && fun3_2MSB != "10" && fun3_2MSB != "00" )
				ltu_operation = 1;
			else if (funct3 == "011" && ((funct7_0bit == "1" && alu_2bit_op_i == "11" ) || (funct7_0bit != "1" && alu_2bit_op_i == "10" )))
				ltu_operation = 0;
			else
				ltu_operation = 0;
		end

		always_comb begin
			if (alu_2bit_op_i == "10" && funct7_5bit == "1" && funct3 == "000")
				sub_operation = 1;
			else
				sub_operation = 0;
		end
		
		always_comb begin
			if (alu_2bit_op_i == "10" && funct7_0bit == "1" && funct7_5bit == "0"  && funct3 == "000")
				mulu_operation = 1;
			else
				mulu_operation = 0;
		end

		always_comb begin
			if (alu_2bit_op_i == "10"  && funct7_0bit == "1" && funct3 == "001")
				mulhs_operation = 1;
			else
				mulhs_operation = 0;
		end	
		
		always_comb begin
			if (funct3 == "001" && ((funct7_0bit == "1" && alu_2bit_op_i == "11" ) || (funct7_0bit != "1" && alu_2bit_op_i == "10" )))
				sll_operation = 1;
			else
				sll_operation = 0;
		end	
		
		always_comb begin
			if (alu_2bit_op_i == "10"  && funct7_0bit == "1" && funct3 == "010")
				mulhsu_operation = 1;
			else
				mulhsu_operation = 0;
		end	
		
		always_comb begin
			if (alu_2bit_op_i == "10"  && funct7_0bit == "1" && funct3 == "011")
				mulhu_operation = 1;
			else
				mulhu_operation = 0;
		end	
		
		always_comb begin
			if (alu_2bit_op_i == "10"  && funct7_0bit == "1" && funct3 == "100")
				divs_operation = 1;
			else
				divs_operation = 0;
		end	
		
		always_comb begin
			if (funct3 == "100" && ((funct7_0bit == "1" && alu_2bit_op_i == "11" ) || (funct7_0bit != "1" && alu_2bit_op_i == "10" )))
				xor_operation = 1;
			else
				xor_operation = 0;
		end	
		
		always_comb begin
			if (funct3 == "101" && funct7_5bit == "0" && ((funct7_0bit == "1" && alu_2bit_op_i == "11" ) || (funct7_0bit != "1" && alu_2bit_op_i == "10" )))
				srl_operation = 1;
			else
				srl_operation = 0;
		end	
		
		always_comb begin
			if (funct3 == "101" && funct7_5bit == "1" && ((funct7_0bit == "1" && alu_2bit_op_i == "11" ) || (funct7_0bit != "1" && alu_2bit_op_i == "10" )))
				sra_operation = 1;
			else
				sra_operation = 0;
		end
		
		always_comb begin
			if (alu_2bit_op_i == "10"  && funct7_0bit == "1" && funct3 == "101")
				divu_operation = 0;
			else
				divu_operation = 0;
		end
		
		always_comb begin
			if (funct3 == "110" && ((funct7_0bit == "1" && alu_2bit_op_i == "11" ) || (funct7_0bit != "1" && alu_2bit_op_i == "10" )))
				or_operation = 1;
			else
				or_operation = 0;
		end 
		
		always_comb begin
			if (alu_2bit_op_i == "10"  && funct7_0bit == "1" && funct3 == "110")
				rems_operation = 0;
			else
				rems_operation = 0;
		end
		
		always_comb begin
			if (funct3 == "111" && ((funct7_0bit == "1" && alu_2bit_op_i == "11" ) || (funct7_0bit != "1" && alu_2bit_op_i == "10" )))
				and_operation = 1;
			else
				and_operation = 0;
		end 
		
		always_comb begin
			if (alu_2bit_op_i == "10"  && funct7_0bit == "1" && funct3 == "111")
				remu_operation = 0;
			else
				remu_operation = 0;
		end
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
		clocking @(posedge clk);
		endclocking

		default disable iff rst;
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//////LIMITS FOR INPUT ////////////////
		property limmitst_for_alu_2bit_op_i;
			 alu_2bit_op_i == ("00" || "01 "|| "11" || "10");
		endproperty
		
		property limits_for_fun7;
			funct7_i == ("0000000" || "0000001" || "0100000" || "0100001");
		endproperty
		
		assume property (limmitst_for_alu_2bit_op_i);
		assume property (limits_for_fun7);
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////CHEKING FOR ALL POSIBLE OUTPUTS////////
		property add_output;
			 and_operation |-> (alu_op_o == and_op); 
		endproperty;
		
		add_output_s:assert property (add_output);
		
		property eq_output;
			eq_operation |-> (alu_op_o == eq_op);
		endproperty;
		
		eq_output_s:assert property(eq_output);
		
		property lts_output;
			lts_operation |-> (alu_op_o == lts_op);
		endproperty;
		
		lts_output_s:assert property (lts_output);
		
		property ltu_output;
			ltu_operation |-> (alu_op_o == ltu_op);
		endproperty;
		
		ltu_output_s:assert property (ltu_output);
		
		property sub_output;
			sub_operation |-> (alu_op_o == sub_op); 
		endproperty;
		
		sub_output_s:assert property (sub_output);
		
		property mulu_output;
			mulu_operation |-> (alu_op_o == mulu_op); 
		endproperty;
		
		mulu_output_s:assert property (mulu_output);
		
		property mulhs_output;
			mulhs_operation |-> (alu_op_o == mulhs_op); 
		endproperty;
		
		mulhs_output_s:assert property (mulhs_output);
		
		property sll_output;
			sll_operation |-> (alu_op_o == sll_op); 
		endproperty;
		
		sll_output_s:assert property (sll_output);
		
		property mulhsu_output;
			mulhsu_operation |-> (alu_op_o == mulhsu_op); 
		endproperty;
		
		mulhsu_output_s:assert property (mulhsu_output);
		
		property mulhu_output;
			mulhu_operation |-> (alu_op_o == mulhu_op); 
		endproperty;
		
		mulhu_output_s:assert property (mulhu_output);
		
		property divs_output;
			divs_operation |-> (alu_op_o == divs_op); 
		endproperty;
		
		divs_output_s:assert property (divs_output);
		
		property xor_output;
			xor_operation |-> (alu_op_o == xor_op); 
		endproperty;
		
		xor_output_s:assert property (xor_output);
		
		property srl_output;
			srl_operation |-> (alu_op_o == srl_op); 
		endproperty;
		
		srl_output_s:assert property (srl_output);
		
		property sra_output;
			sra_operation |-> (alu_op_o == sra_op); 
		endproperty;
		
		sra_output_s:assert property (sra_output);
		
		property divu_output;
			divu_operation |-> (alu_op_o == divu_op); 
		endproperty;
		
		divu_output_s:assert property (divu_output);
		
		property or_output;
			or_operation |-> (alu_op_o == or_op); 
		endproperty;
		
		or_output_s:assert property (or_output);
		
		property rems_output;
			rems_operation |-> (alu_op_o == rems_op); 
		endproperty;
		
		rems_output_s:assert property (rems_output);
		
		property and_output;
			and_operation |-> (alu_op_o == and_op); 
		endproperty;
		
		and_output_s:assert property (and_output);
		
		property remu_output;
			remu_operation |-> (alu_op_o == remu_op); 
		endproperty;
		
		remu_output_s:assert property (remu_output);
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	endmodule
