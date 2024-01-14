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

    output logic [4 : 0]alu_op_o
    );
    
    logic pomin;
    logic pomout;   
    
    logika alu_decoder
    (
        .*(*)
            ); 
    
//   assign pomin = (( !a) & (!b) & (!c) & (!e) & (!f) | a & !b & !c & e & !f |
//                     !a & b & !c & e & f | a & b & !c & e & f | !a & b & !c & e & f |
//                     !a & !b & c & !g & !h | a & !b & c & g & !h | !a & b & c & !g & h |
//                     a & c & c & g & h) & !d | d;
//    always_ff @(posedge clk) begin
//        if(rst) begin
//            pomout <= 1'b0;
//        end 
            
//        else begin
//            pomout <= pomin;
//        end
//    end
//    assign out1 = pomout;

    /*default
	clocking @(posedge clk);
	endclocking

	default disable iff rst;*/
	
    property p1;
		 alu_2bit_op_i == ("00" || "01 "|| "11");
	endproperty
	
	assert property (p1);
	
endmodule
