`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 07/09/2014 
// Design Name:    KH32 & KH16
// Module Name:    MUX_2_to_1_32bit  
// Project Name:   Throughput Processor 
// Description:    This part is the MUX.
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module MUX_2_to_1_32bit(
sel_i_2,
out,
i0,
i1
    );

input [31:0] i0;
input [31:0] i1;
input sel_i_2;
output [31:0] out;


wire [31:0] i0;
wire [31:0] i1;
wire sel_i_2;
reg [31:0] out;

always@(*)
begin
	case(sel_i_2)
	1'b0:
		begin
			out = i0;
		end
	1'b1:
		begin
			out = i1;
		end
	endcase
end


endmodule
