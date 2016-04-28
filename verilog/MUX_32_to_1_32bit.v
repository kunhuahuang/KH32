`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 07/09/2014 
// Design Name:    KH32 & KH16
// Module Name:    MUX_32_to_1_32bit  
// Project Name:   Throughput Processor 
// Description:    This part is the MUX.
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module MUX_32_to_1_32bit(
sel_i_32,
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
i15,
i16,
i17,
i18,
i19,
i20,
i21,
i22,
i23,
i24,
i25,
i26,
i27,
i28,
i29,
i30,
i31
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
input wire [31:0] i16;
input wire [31:0] i17;
input wire [31:0] i18;
input wire [31:0] i19;
input wire [31:0] i20;
input wire [31:0] i21;
input wire [31:0] i22;
input wire [31:0] i23;
input wire [31:0] i24;
input wire [31:0] i25;
input wire [31:0] i26;
input wire [31:0] i27;
input wire [31:0] i28;
input wire [31:0] i29;
input wire [31:0] i30;
input wire [31:0] i31;
input wire [4:0] sel_i_32;
output [31:0] out;


reg  [31:0] out;

always@(*)
begin
	case(sel_i_32)
	5'b00000:
		begin
			out = i0;
		end
	5'b00001:
		begin
			out = i1;
		end
	5'b00010:
		begin
			out = i2;
		end
	5'b00011:
		begin
			out = i3;
		end
	5'b00100:
		begin
			out = i4;
		end
	5'b00101:
		begin
			out = i5;
		end
	5'b00110:
		begin
			out = i6;
		end
	5'b00111:
		begin
			out = i7;
		end
	5'b01000:
		begin
			out = i8;
		end
	5'b01001:
		begin
			out = i9;
		end
	5'b01010:
		begin
			out = i10;
		end
	5'b01011:
		begin
			out = i11;
		end
	5'b01100:
		begin
			out = i12;
		end
	5'b01101:
		begin
			out = i13;
		end
	5'b01110:
		begin
			out = i14;
		end
	5'b01111:
		begin
			out = i15;
		end
	5'b10000:
		begin
			out = i16;
		end
	5'b10001:
		begin
			out = i17;
		end
	5'b10010:
		begin
			out = i18;
		end
	5'b10011:
		begin
			out = i19;
		end
	5'b10100:
		begin
			out = i20;
		end
	5'b10101:
		begin
			out = i21;
		end
	5'b10110:
		begin
			out = i22;
		end
	5'b10111:
		begin
			out = i23;
		end
	5'b11000:
		begin
			out = i24;
		end
	5'b11001:
		begin
			out = i25;
		end
	5'b11010:
		begin
			out = i26;
		end
	5'b11011:
		begin
			out = i27;
		end
	5'b11100:
		begin
			out = i28;
		end
	5'b11101:
		begin
			out = i29;
		end
	5'b11110:
		begin
			out = i30;
		end
	5'b11111:
		begin
			out = i31;
		end
	endcase
end
endmodule
