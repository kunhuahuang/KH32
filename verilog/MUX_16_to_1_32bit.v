`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 07/09/2014 
// Design Name:    KH32 & KH16
// Module Name:    MUX_16_to_1_32bit  
// Project Name:   Throughput Processor 
// Description:    This part is the MUX.
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module MUX_16_to_1_32bit(
sel_i_16,
out,
i0,
i1,
i2,
i3,
i4,
i5,
i6,
i7,
i8,
i9,
i10,
i11,
i12,
i13,
i14,
i15
    );

input wire [31:0] i0;
input wire [31:0] i1;
input wire [31:0] i2;
input wire [31:0] i3;
input wire [31:0] i4;
input wire [31:0] i5;
input wire [31:0] i6;
input wire [31:0] i7;
input wire [31:0] i8;
input wire [31:0] i9;
input wire [31:0] i10;
input wire [31:0] i11;
input wire [31:0] i12;
input wire [31:0] i13;
input wire [31:0] i14;
input wire [31:0] i15;

input wire [3:0] sel_i_16;
output [31:0] out;


reg  [31:0] out;

always@(*)
begin
	case(sel_i_16)
	4'b0000:
		begin
			out = i0;
		end
	4'b0001:
		begin
			out = i1;
		end
	4'b0010:
		begin
			out = i2;
		end
	4'b0011:
		begin
			out = i3;
		end
	4'b0100:
		begin
			out = i4;
		end
	4'b0101:
		begin
			out = i5;
		end
	4'b0110:
		begin
			out = i6;
		end
	4'b0111:
		begin
			out = i7;
		end
	4'b1000:
		begin
			out = i8;
		end
	4'b1001:
		begin
			out = i9;
		end
	4'b1010:
		begin
			out = i10;
		end
	4'b1011:
		begin
			out = i11;
		end
	4'b1100:
		begin
			out = i12;
		end
	4'b1101:
		begin
			out = i13;
		end
	4'b1110:
		begin
			out = i14;
		end
	4'b1111:
		begin
			out = i15;
		end
	endcase
end
endmodule
