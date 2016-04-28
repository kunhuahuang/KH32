`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 07/09/2014 
// Design Name:    KH32 & KH16
// Module Name:    CPU_EX 
// Project Name:   Throughput Processor 
// Description:    This part is the ALU of the CPU core
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module CPU_ALU(
////////INPUT///////////
input wire [4:0] 	ALU_op,//5-bit :{C , operand}
input wire [31:0]	ALU_Ra,
input wire [31:0]	ALU_Rb,
input wire [3:0]	FLAG_i,
////////OUTPUT///////////
output reg [3:0]	FLAG_o,
output reg [31:0]	ALU_Rd
    );
/////FLAG  //////////
//////Z C V N////////
parameter MOV = 4'b0000;
parameter ADD = 4'b0001;
parameter SUB = 4'b0010;
parameter AND = 4'b0011;
parameter OR  = 4'b0100;
parameter XOR = 4'b0101;
parameter NOT = 4'b0110;//MVN
parameter SHL = 4'b0111;
parameter SHR = 4'b1000;
parameter ROL = 4'b1001;
parameter ROR = 4'b1010;
parameter ASR = 4'b1011;
parameter MOVi = 4'b1100;
parameter MVHi = 4'b1101;
parameter MVLi = 4'b1110;

wire [31:0] Rb;
reg [31:0] carry;
wire [31:0] sum_a;
wire [31:0] sum_s;
wire CY_o_a;
wire CY_o_s;
wire overflow_a;
wire overflow_s;

assign {CY_o_a,sum_a} = ALU_Ra + ALU_Rb + carry;
assign {CY_o_s,sum_s} = ({1'b0,ALU_Ra} + {1'b0,(~ALU_Rb + 1'b1)}) - {32'b0,carry};
xor x1(overflow_a, sum_a[30], sum_a[31]);
xor x2(overflow_s, sum_s[30], sum_s[31]);
always @(ALU_op or FLAG_i or ALU_Ra or ALU_Rb or sum_s or sum_a)
begin
	case(ALU_op[3:0])
/*		MOV:
			begin
				ALU_Rd = ALU_Ra;
			end*/
		ADD:
			begin
				carry = ALU_op[4]?FLAG_i[2] : 1'b0;
				ALU_Rd = sum_a;
			end
		SUB:
			begin
				carry = ALU_op[4]?FLAG_i[2] : 1'b0;
				ALU_Rd = sum_s;
			end
		AND:
			begin
				ALU_Rd = ALU_Ra & ALU_Rb;
			end
		OR:
			begin
				ALU_Rd = ALU_Ra | ALU_Rb;
			end
		XOR:
			begin
				ALU_Rd = ALU_Ra ^ ALU_Rb;
			end
		NOT:
			begin
				ALU_Rd = ~ALU_Ra;
			end
		SHL:
			begin
				ALU_Rd = ALU_Ra << ALU_Rb[4:0] ;
			end
		SHR:
			begin
				ALU_Rd = ALU_Ra >> ALU_Rb[4:0] ;
			end
		ROL:
			begin
				ALU_Rd = (ALU_Ra << (6'd32-{1'b0, ALU_Rb[4:0]})) | (ALU_Ra >> ALU_Rb[4:0]);
			end		
		ROR:
			begin
				ALU_Rd = ({32{ALU_Ra[31]}} << (6'd32-{1'b0, ALU_Rb[4:0]})) | ALU_Ra >> ALU_Rb[4:0];
			end		
		ASR:
			begin
				ALU_Rd = ALU_Ra >>> 1;
			end	
		MOVi:
			begin
				ALU_Rd = ALU_Rb;
			end
		MVHi:
			begin
				ALU_Rd = {ALU_Rb[15:0] , ALU_Ra[15:0]};
			end
		MVLi:
			begin
				ALU_Rd = {ALU_Ra[15:0] , ALU_Rb[15:0]};
			end
		default:
			begin
				ALU_Rd = ALU_Ra; // MOV
			end
	endcase
end

always @(CY_o_a or CY_o_s or overflow_a or overflow_s or ALU_Rd or ALU_op)
begin
	case(ALU_op[3:0])
		ADD:
			begin
				FLAG_o = {(ALU_Rd == 0)? 1'b1 : 1'b0/*Zero*/,CY_o_a/*Carry*/,overflow_a/*overflow*/,ALU_Rd[31]/*negtive*/};
			end
		SUB:
			begin
				FLAG_o = {(ALU_Rd == 0)? 1'b1 : 1'b0/*Zero*/,CY_o_s/*Carry*/,overflow_s/*overflow*/,ALU_Rd[31]/*negtive*/};
			end
		default:
			begin
				FLAG_o = {(ALU_Rd == 0)? 1'b1 : 1'b0/*Zero*/,1'b0/*Carry*/,1'b0/*overflow*/,1'b0/*negtive*/};
			end
	endcase
end
endmodule
