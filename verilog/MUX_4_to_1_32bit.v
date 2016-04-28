`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 07/09/2014 
// Design Name:    KH32 & KH16
// Module Name:    MUX_4_to_1_32bit  
// Project Name:   Throughput Processor 
// Description:    This part is the MUX.
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module MUX_4_to_1_32bit(
sel_i_4,
out,
i0,
i1,
i2,
i3
    );

input [31:0] i0;
input [31:0] i1;
input [31:0] i2;
input [31:0] i3;
input [1:0] sel_i_4;
output [31:0] out;


wire [31:0] i0;
wire [31:0] i1;
wire [31:0] i2;
wire [31:0] i3;
wire [1:0]sel_i_4;
reg  [31:0] out;

always@(*)
begin
	case(sel_i_4)
	2'b00:
		begin
			out = i0;
		end
	2'b01:
		begin
			out = i1;
		end
	2'b10:
		begin
			out = i2;
		end
	2'b11:
		begin
			out = i3;
		end
	endcase
end


endmodule
