`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 07/09/2014 
// Design Name:    KH32 & KH16
// Module Name:    CPU_ID 
// Project Name:   Throughput Processor 
// Description:    This part is the Decoder of the CPU core
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module CPU_ID(
input wire clk,
input wire rst,
////////INPUT///////////

//input wire [0:0] ID_state_en, //No need, because of the no hit & FLUSH method.
input wire [31:0] PC_IF,
input wire [31:0] IR,


////////OUTPUT//////////
output reg [0:0] 	ALU_input_sel_Ra1,
output reg [1:0] 	ALU_input_sel_Rb1,
output reg [0:0] 	ALU_input_sel_Ra2,
output reg [1:0] 	ALU_input_sel_Rb2,
output reg [31:0] 	PC_ID,
output reg [3:0] 	COND,
output reg [4:0] 	ALU1_op,
output reg [4:0] 	ALU_Ra1,
output reg [4:0] 	ALU_Rb1,
output reg [31:0] 	ALU_Imm1,
output reg [4:0] 	ALU2_op,
output reg [4:0] 	ALU_Ra2,
output reg [4:0] 	ALU_Rb2,
output reg [31:0] 	ALU_Imm2,

output reg [4:0] 	ALU_Rd1_WB_sel,
output reg [0:0] 	ALU_Rd1_WB_en,
output reg [4:0] 	ALU_Rd2_WB_sel,
output reg [0:0] 	ALU_Rd2_WB_en,
output reg [0:0] 	ALU_FLAG_WB_en,
output reg [1:0] 	DMEM_Control_sel,
output reg [0:0] 	DMEM_ID_WE,
output reg [0:0] 	DMEM_Data_sel,
output reg [3:0] 	Rd_DMEM,//Memory data Register assign select
////////Program counter///////////
output reg [2:0] 	JUMP_sel,
output reg [3:0] 	JUMP_R_sel,
////////INPUT for LOAD/////////////
output reg [0:0] 	LOAD_EN, //for Load in second clock
output reg [0:0]  	LOAD_happened,
input wire [0:0] 	DMEM_no_hit


    );

reg [0:0] 	ALU_input_sel_Ra1_o;
reg [1:0] 	ALU_input_sel_Rb1_o;
reg [0:0] 	ALU_input_sel_Ra2_o;
reg [1:0] 	ALU_input_sel_Rb2_o;
reg [3:0] 	COND_o;
reg [4:0] 	ALU1_op_o;
reg [4:0] 	ALU_Ra1_o;
reg [4:0] 	ALU_Rb1_o;
reg [31:0] ALU_Imm1_o;
reg [4:0] 	ALU2_op_o;
reg [4:0] 	ALU_Ra2_o;
reg [4:0] 	ALU_Rb2_o;
reg [31:0] ALU_Imm2_o;

reg [4:0] 	ALU_Rd1_WB_sel_o;
reg [0:0] 	ALU_Rd1_WB_en_o;
reg [4:0] 	ALU_Rd2_WB_sel_o;
reg [0:0] 	ALU_Rd2_WB_en_o;
reg [0:0] 	ALU_FLAG_WB_en_o;
reg [1:0] 	DMEM_Control_sel_o;
reg [0:0] 	DMEM_ID_WE_o;
reg [0:0] 	DMEM_Data_sel_o;
reg [3:0] 	Rd_DMEM_o;//Memory data Register assign select
////////Program counter///////////
reg [2:0] 	JUMP_sel_o;
reg [3:0] 	JUMP_R_sel_o;
////////INPUT for LOAD/////////////
reg [0:0] 	LOAD_EN_o; //for Load in second clock

reg [15:0] IR16_first;  	// [31:16]
reg [15:0] IR16_second;	// [15:0]
////////Make ID know the LOAD happen
reg [0:0]  LOAD_happened_o;
//reg [0:0]  	LOAD_happened;
reg [3:0] 	LOAD_Rd_tmp_o;
reg [3:0] 	LOAD_Rd_tmp;
/*
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
parameter MVF = 4'b1111;
*/

always @(posedge clk or negedge rst )
if(!rst)
begin
ALU_input_sel_Ra1 <= 1'b0;
ALU_input_sel_Rb1 <= 2'b0;
ALU_input_sel_Ra2<= 1'b0;
ALU_input_sel_Rb2 <= 2'b0;
PC_ID <= 32'b0;
COND <= 4'b0;
ALU1_op <= 5'b0;
ALU_Ra1 <= 5'b0;
ALU_Rb1 <= 5'b0;
ALU_Imm1 <= 32'b0;
ALU2_op <= 5'b0;
ALU_Ra2 <= 5'b0;
ALU_Rb2 <= 5'b0;
ALU_Imm2 <= 32'b0;

ALU_Rd1_WB_sel <= 5'b0;
ALU_Rd1_WB_en <= 1'b0;
ALU_Rd2_WB_sel <= 5'b0;
ALU_Rd2_WB_en<= 1'b0;
ALU_FLAG_WB_en<= 1'b0;
DMEM_Control_sel <= 2'b0;
DMEM_ID_WE<= 1'b0;
DMEM_Data_sel<= 1'b0;
Rd_DMEM <= 4'b0;//Memory data Register assign select
////////Program counter///////////
JUMP_sel <= 3'b001;
JUMP_R_sel <= 4'b0;
////////INPUT for LOAD/////////////
LOAD_EN<= 1'b0; //for Load in second clock
LOAD_happened <= 1'b0;

end
else
begin
	if(!DMEM_no_hit)
	begin
		if(LOAD_happened)  //write back the LOAD value to Register
		begin
		PC_ID <= PC_ID;
		ALU_input_sel_Ra1	<=	1'b0;
		ALU_input_sel_Rb1	<=	2'b0;
		ALU_input_sel_Ra2	<=	1'b0;
		ALU_input_sel_Rb2	<=	2'b0;
		COND				<=	COND; //
		ALU1_op				<=	5'b00000;
		ALU_Ra1				<=	5'b00000;
		ALU_Rb1				<=	5'b00000;
		ALU_Imm1			<=	32'b0;
		ALU2_op				<=	5'b00000;
		ALU_Ra2				<=	5'b00000;
		ALU_Rb2				<=	5'b00000;
		ALU_Imm2			<=	32'b0;
		ALU_Rd1_WB_sel		<=	{1'b0,LOAD_Rd_tmp};
		ALU_Rd1_WB_en		<=	1'b1;
		ALU_Rd2_WB_sel		<=	5'b00000;
		ALU_Rd2_WB_en		<=	1'b0;
		ALU_FLAG_WB_en		<=	1'b0;
		DMEM_Control_sel	<=	2'b0;
		DMEM_ID_WE			<=	1'b0;
		DMEM_Data_sel		<=	1'b0;
		Rd_DMEM				<=	4'b0000;
			////////Program counter///////////
		JUMP_sel			<=	JUMP_sel_o;
		JUMP_R_sel			<=	JUMP_R_sel_o;
			////////INPUT for LOAD/////////////
		LOAD_EN				<=	1; //for Load in second clock
		LOAD_happened		<=	1'b0;	
		
		end
		else
		begin
		PC_ID <= PC_IF;
		ALU_input_sel_Ra1	<=	ALU_input_sel_Ra1_o;
		ALU_input_sel_Rb1	<=	ALU_input_sel_Rb1_o;
		ALU_input_sel_Ra2	<=	ALU_input_sel_Ra2_o;
		ALU_input_sel_Rb2	<=	ALU_input_sel_Rb2_o;
		COND				<=	COND_o;
		ALU1_op				<=	ALU1_op_o;
		ALU_Ra1				<=	ALU_Ra1_o;
		ALU_Rb1				<=	ALU_Rb1_o;
		ALU_Imm1			<=	ALU_Imm1_o;
		ALU2_op				<=	ALU2_op_o;
		ALU_Ra2				<=	ALU_Ra2_o;
		ALU_Rb2				<=	ALU_Rb2_o;
		ALU_Imm2			<=	ALU_Imm2_o;
				
		ALU_Rd1_WB_sel		<=	ALU_Rd1_WB_sel_o;
		ALU_Rd1_WB_en		<=	ALU_Rd1_WB_en_o;
		ALU_Rd2_WB_sel		<=	ALU_Rd2_WB_sel_o;
		ALU_Rd2_WB_en		<=	ALU_Rd2_WB_en_o;
		ALU_FLAG_WB_en		<=	ALU_FLAG_WB_en_o;
		DMEM_Control_sel	<=	DMEM_Control_sel_o;
		DMEM_ID_WE			<=	DMEM_ID_WE_o;
		DMEM_Data_sel		<=	DMEM_Data_sel_o;
		Rd_DMEM				<=	Rd_DMEM_o;
			////////Program counter///////////
		JUMP_sel			<=	JUMP_sel_o;
		JUMP_R_sel			<=	JUMP_R_sel_o;
			////////INPUT for LOAD/////////////
		LOAD_EN				<=	0; //for Load in second clock
		LOAD_happened		<=	LOAD_happened_o;	
		LOAD_Rd_tmp			<=	LOAD_Rd_tmp_o;
		
		end
	end
end

always @(*)
begin
	if(IR[31]) // KH16
	begin
		COND_o = 4'b1111;
		if(IR[14:12] == 3'b011 || IR[14:12] == 3'b100) //STR & LDR have to compute in ALU1.
		begin
			IR16_first	=	IR[15:0];
			IR16_second	= 	IR[31:16];
		end
		else 
		begin
			IR16_first	=	IR[31:16];
			IR16_second	= 	IR[15:0];
		end
			ALU_FLAG_WB_en_o		=	1'b0;
			JUMP_sel_o				=	(IR16_first[14:12] == 3'b011)? 3'b001 : 3'b000;	
			JUMP_R_sel_o			=	4'b0000;
			case(IR16_first[14:12]) // compute in ALU1
				3'b000: //ALU
					begin
						case(IR16_first[2:0])
							3'b000:  //ADD
								begin
									ALU1_op_o 	= 	5'b00001;
								end
							3'b010:  //SUB
								begin
									ALU1_op_o 	= 	5'b00010;
								end
							3'b100:  //AND
								begin
									ALU1_op_o 	= 	5'b00011;
								end
							3'b101:  //OR
								begin
									ALU1_op_o 	= 	5'b00100;
								end
							3'b110:  //XOR
								begin
									ALU1_op_o 	= 	5'b00101;
								end
							default:
								begin
									ALU1_op_o 	= 	5'b00000;
								end
						endcase
						ALU_input_sel_Ra1_o		= 	1'b1;
						ALU_input_sel_Rb1_o		=	2'b01;
					//	ALU1_op_o 				= 	5'b00001;
						ALU_Ra1_o				=	{2'b0,IR16_first[8:6]};
						ALU_Rb1_o				=	{2'b0,IR16_first[5:3]};
						ALU_Imm1_o				=	32'b0;	
						ALU_Rd1_WB_sel_o		=	{2'b0,IR16_first[11:9]};
						ALU_Rd1_WB_en_o			=	1'b1;
						////////////////////////////////////
						DMEM_Control_sel_o		=	2'b00;
						DMEM_ID_WE_o			=	1'b0;
						DMEM_Data_sel_o			=	1'b0;
						Rd_DMEM_o				=	4'b0000;								
						LOAD_happened_o			= 	1'b0;	
						LOAD_Rd_tmp_o			=	4'b0;
					end
				3'b001: //SHF
					begin
						case(IR16_first[2:0])
							3'b000:  //SHL
								begin
									ALU1_op_o 	= 	5'b00111;
								end
							3'b010:  //SHR
								begin
									ALU1_op_o 	= 	5'b01000;
								end
							3'b100:  //ROL
								begin
									ALU1_op_o 	= 	5'b01001;
								end
							3'b101:  //ROR
								begin
									ALU1_op_o 	= 	5'b01010;
								end
							3'b110:  //ASR
								begin
									ALU1_op_o 	= 	5'b01011;
								end
							default:
								begin
									ALU1_op_o 	= 	5'b00111;
								end
						endcase
						ALU_input_sel_Ra1_o		= 	1'b1;
						ALU_input_sel_Rb1_o		=	2'b10;
					//	ALU1_op_o 				= 	5'b00001;
						ALU_Ra1_o				=	{1'b0,IR16_first[11:8]};
						ALU_Rb1_o				=	5'b00000;
						ALU_Imm1_o				=	{27'b0,IR16_first[7:3]};
						ALU_Rd1_WB_sel_o		=	{1'b0,IR16_first[11:8]};
						ALU_Rd1_WB_en_o			=	1'b1;
						////////////////////////////////////
						DMEM_Control_sel_o		=	2'b00;
						DMEM_ID_WE_o			=	1'b0;
						DMEM_Data_sel_o			=	1'b0;
						Rd_DMEM_o				=	4'b0000;								
						LOAD_happened_o			= 	1'b0;	
						LOAD_Rd_tmp_o			=	4'b0;
					end
				3'b010: //MOV
					begin
						case(IR16_first[0])
							1'b0:  //MOV
								begin
									ALU1_op_o 	= 	5'b00000;
								end
							1'b1:  //MVN
								begin
									ALU1_op_o 	= 	5'b00110;
								end
						endcase
						ALU_input_sel_Ra1_o		= 	1'b1;
						ALU_input_sel_Rb1_o		=	2'b01;
					//	ALU1_op_o 				= 	5'b00000;
						ALU_Ra1_o				=	{IR16_first[1],IR16_first[7:4]};
						ALU_Rb1_o				=	5'b00000;
						ALU_Imm1_o				=	32'b0;	
						ALU_Rd1_WB_sel_o		=	{IR16_first[2],IR16_first[11:8]};
						ALU_Rd1_WB_en_o			=	1'b1;
						////////////////////////////////////
						DMEM_Control_sel_o		=	2'b00;
						DMEM_ID_WE_o			=	1'b0;
						DMEM_Data_sel_o			=	1'b0;
						Rd_DMEM_o				=	4'b0000;								
						LOAD_happened_o			= 	1'b0;	
						LOAD_Rd_tmp_o			=	4'b0;
					end
				3'b011: //LDR
					begin
						ALU_input_sel_Ra1_o		= 	1'b1;
						ALU_input_sel_Rb1_o		=	2'b10; //Imm
						ALU1_op_o 				= 	5'b00001;
						ALU_Ra1_o				=	{1'b0,IR16_first[7:4]};
						ALU_Rb1_o				=	5'b00000;
						ALU_Imm1_o				=	{28'b0,IR16_first[3:0]};	
						ALU_Rd1_WB_sel_o		=	{1'b0,IR16_first[7:4]};  // first write back the address counting
						////////////////////////////////////
						DMEM_Control_sel_o		=	2'b10;
						DMEM_ID_WE_o			=	1'b0;
						DMEM_Data_sel_o			=	1'b0;
						Rd_DMEM_o				=	4'b0000;								
						LOAD_happened_o			= 	1'b1;
						LOAD_Rd_tmp_o			=	IR16_first[11:8];
					end
				3'b100: //STR
					begin
						ALU_input_sel_Ra1_o		= 	1'b1;
						ALU_input_sel_Rb1_o		=	2'b10; //Imm
						ALU1_op_o 				= 	5'b00001;
						ALU_Ra1_o				=	{1'b0,IR16_first[7:4]};
						ALU_Rb1_o				=	5'b00000;
						ALU_Imm1_o				=	{28'b0,IR16_first[3:0]};
						ALU_Rd1_WB_sel_o		=	{1'b0,IR16_first[11:8]};  // first write back the address counting
						ALU_Rd1_WB_en_o			=	1'b0;
						////////////////////////////////////
						DMEM_Control_sel_o		=	2'b10;
						DMEM_ID_WE_o			=	1'b1;
						DMEM_Data_sel_o			=	1'b1;
						Rd_DMEM_o				=	IR16_first[11:8];								
						LOAD_happened_o			= 	1'b0;
						LOAD_Rd_tmp_o			=	4'b0;
					end
				3'b101: //CUST2
					begin
						ALU_input_sel_Ra1_o		= 	1'b0;
						ALU_input_sel_Rb1_o		=	2'b00;
						ALU1_op_o 				= 	5'b00000;
						ALU_Ra1_o				=	5'b0;
						ALU_Rb1_o				=	5'b0;
						ALU_Imm1_o				=	32'b0;	
						ALU_Rd1_WB_sel_o		=	5'b0;
						ALU_Rd1_WB_en_o			=	1'b0;
						////////////////////////////////////
						DMEM_Control_sel_o		=	2'b00;
						DMEM_ID_WE_o			=	1'b0;
						DMEM_Data_sel_o			=	1'b0;
						Rd_DMEM_o				=	4'b0000;								
						LOAD_happened_o			= 	1'b0;	
						LOAD_Rd_tmp_o			=	4'b0;
					end
				3'b110: //MOVi
					begin
						ALU_input_sel_Ra1_o		= 	1'b1;
						ALU_input_sel_Rb1_o		=	2'b10;
						ALU1_op_o 				= 	5'b01100;
						ALU_Ra1_o				=	5'b00000;
						ALU_Rb1_o				=	5'b00000;
						ALU_Imm1_o				=	{24'b0,IR16_first[7:0]};	
						ALU_Rd1_WB_sel_o		=	{1'b0,IR16_first[11:8]};
						ALU_Rd1_WB_en_o			=	1'b1;
						////////////////////////////////////
						DMEM_Control_sel_o		=	2'b00;
						DMEM_ID_WE_o			=	1'b0;
						DMEM_Data_sel_o			=	1'b0;
						Rd_DMEM_o				=	4'b0000;								
						LOAD_happened_o			= 	1'b0;	
						LOAD_Rd_tmp_o			=	4'b0;
					end
				3'b111: //CUST3
					begin
						ALU_input_sel_Ra1_o		= 	1'b0;
						ALU_input_sel_Rb1_o		=	2'b00;
						ALU1_op_o 				= 	5'b00000;
						ALU_Ra1_o				=	5'b0;
						ALU_Rb1_o				=	5'b0;
						ALU_Imm1_o				=	32'b0;	
						ALU_Rd1_WB_sel_o		=	5'b0;
						ALU_Rd1_WB_en_o			=	1'b0;
						////////////////////////////////////
						DMEM_Control_sel_o		=	2'b00;
						DMEM_ID_WE_o			=	1'b0;
						DMEM_Data_sel_o			=	1'b0;
						Rd_DMEM_o				=	4'b0000;								
						LOAD_happened_o			= 	1'b0;	
						LOAD_Rd_tmp_o			=	4'b0;
					end
			endcase
			
			
			case(IR16_second[14:12]) // compute in ALU2
				3'b000: //ALU
					begin
						case(IR16_second[2:0])
							3'b000:  //ADD
								begin
									ALU2_op_o 	= 	5'b00001;
								end
							3'b010:  //SUB
								begin
									ALU2_op_o 	= 	5'b00010;
								end
							3'b100:  //AND
								begin
									ALU2_op_o 	= 	5'b00011;
								end
							3'b101:  //OR
								begin
									ALU2_op_o 	= 	5'b00100;
								end
							3'b110:  //XOR
								begin
									ALU2_op_o 	= 	5'b00101;
								end
							default:
								begin
									ALU2_op_o 	= 	5'b00000;
								end
						endcase
					
						ALU_input_sel_Ra2_o		=	1'b1;
						ALU_input_sel_Rb2_o		=	2'b01;
					//	ALU2_op_o				=	{5'b0};
						ALU_Ra2_o				=	{2'b0,IR16_second[8:6]};
						ALU_Rb2_o				=	{2'b0,IR16_second[5:3]};
						ALU_Imm2_o				=	{32'b0};		
						ALU_Rd2_WB_sel_o		= 	{2'b0,IR16_second[11:9]};
						ALU_Rd2_WB_en_o			=	1'b1;
					end
				3'b001: //SHF
					begin
						case(IR16_second[2:0])
							3'b000:  //SHL
								begin
									ALU2_op_o 	= 	5'b00111;
								end
							3'b010:  //SHR
								begin
									ALU2_op_o 	= 	5'b01000;
								end
							3'b100:  //ROL
								begin
									ALU2_op_o 	= 	5'b01001;
								end
							3'b101:  //ROR
								begin
									ALU2_op_o 	= 	5'b01010;
								end
							3'b110:  //ASR
								begin
									ALU2_op_o 	= 	5'b01011;
								end
							default:
								begin
									ALU2_op_o 	= 	5'b00111;
								end
						endcase
						ALU_input_sel_Ra2_o		=	1'b1;
						ALU_input_sel_Rb2_o		=	2'b10;
					//	ALU2_op_o				=	{5'b0};
						ALU_Ra2_o				=	{1'b0,IR16_second[11:8]};
						ALU_Rb2_o				=	5'b00000;
						ALU_Imm2_o				=	{27'b0,IR16_second[7:3]};		
						ALU_Rd2_WB_sel_o		= 	{1'b0,IR16_second[11:8]};
						ALU_Rd2_WB_en_o			=	1'b1;
					end
				3'b010: //MOV
					begin
						case(IR16_second[0])
							1'b0:  //MOV
								begin
									ALU2_op_o 	= 	5'b00000;
								end
							1'b1:  //MVN
								begin
									ALU2_op_o 	= 	5'b00110;
								end
						endcase
						ALU_input_sel_Ra2_o		=	1'b1;
						ALU_input_sel_Rb2_o		=	2'b01;
					//	ALU2_op_o				=	{5'b0};
						ALU_Ra2_o				=	{IR16_second[1],IR16_second[7:4]};
						ALU_Rb2_o				=	5'b00000;
						ALU_Imm2_o				=	32'b0;	
						ALU_Rd2_WB_sel_o		= 	{IR16_second[2],IR16_second[11:8]};
						ALU_Rd2_WB_en_o			=	1'b1;
					end
				3'b011: //LDR **Nothing happend here
					begin
						ALU_input_sel_Ra2_o		=	1'b0;
						ALU_input_sel_Rb2_o		=	2'b00;
						ALU2_op_o				=	{5'b0};
						ALU_Ra2_o				=	{5'b0};
						ALU_Rb2_o				=	{5'b0};
						ALU_Imm2_o				=	{32'b0};		
						ALU_Rd2_WB_sel_o		= 	{5'b0};
						ALU_Rd2_WB_en_o			=	1'b0;
					end
				3'b100: //STR **Nothing happend here
					begin
						ALU_input_sel_Ra2_o		=	1'b0;
						ALU_input_sel_Rb2_o		=	2'b00;
						ALU2_op_o				=	{5'b0};
						ALU_Ra2_o				=	{5'b0};
						ALU_Rb2_o				=	{5'b0};
						ALU_Imm2_o				=	{32'b0};		
						ALU_Rd2_WB_sel_o		= 	{5'b0};
						ALU_Rd2_WB_en_o			=	1'b0;
					end
				3'b101: //CUST2
					begin
						ALU_input_sel_Ra2_o		=	1'b0;
						ALU_input_sel_Rb2_o		=	2'b00;
						ALU2_op_o				=	{5'b0};
						ALU_Ra2_o				=	{5'b0};
						ALU_Rb2_o				=	{5'b0};
						ALU_Imm2_o				=	{32'b0};		
						ALU_Rd2_WB_sel_o		= 	{5'b0};
						ALU_Rd2_WB_en_o			=	1'b0;
					end
				3'b110: //MOVi
					begin
						ALU_input_sel_Ra2_o		=	1'b1;
						ALU_input_sel_Rb2_o		=	2'b10;
						ALU2_op_o				=	5'b01100;
						ALU_Ra2_o				=	{5'b0};
						ALU_Rb2_o				=	{5'b0};
						ALU_Imm2_o				=	{24'b0,IR16_second[7:0]};		
						ALU_Rd2_WB_sel_o		= 	{1'b0,IR16_second[11:8]};
						ALU_Rd2_WB_en_o			=	1'b1;
					end
				3'b111: //CUST3
					begin
						ALU_input_sel_Ra2_o		=	1'b0;
						ALU_input_sel_Rb2_o		=	2'b00;
						ALU2_op_o				=	{5'b0};
						ALU_Ra2_o				=	{5'b0};
						ALU_Rb2_o				=	{5'b0};
						ALU_Imm2_o				=	{32'b0};		
						ALU_Rd2_WB_sel_o		= 	{5'b0};
						ALU_Rd2_WB_en_o			=	1'b0;
					end
			endcase
	end
	
	
	else 		//KH32
	begin
		COND_o = IR[27:24];
		case(IR[30:28])
			3'b000: //ALU
				begin
					LOAD_Rd_tmp_o			=	4'b0;
					case(IR[11])
						1'b0:
							begin
								casex(IR[3:0]) // ALU1_op_o
									4'b?00? : //ADD
										begin
											ALU1_op_o = {IR[0],4'b0001};
										end
									4'b?01? : //SUB
										begin
											ALU1_op_o = {IR[0],4'b0010};
										end
									4'b?100 : //AND
										begin
											ALU1_op_o = 5'b00011;
										end
									4'b?101 : //OR
										begin
											ALU1_op_o = 5'b00100;
										end
									4'b?110 ://XOR
										begin
											ALU1_op_o = 5'b00101;
										end
									4'b0111://CMP
										begin
											ALU1_op_o = 5'b00010;
										end
									4'b1111://CMN
										begin
											ALU1_op_o = 5'b00001;
										end
								endcase	
								ALU_input_sel_Ra1_o		= 	1'b1;
								ALU_input_sel_Rb1_o		=	2'b01;
								ALU_input_sel_Ra2_o		=	1'b0;
								ALU_input_sel_Rb2_o		=	2'b00;
								ALU_Ra1_o				=	{1'b0,IR[19:16]};
								ALU_Rb1_o				=	{1'b0,IR[15:12]};
								ALU_Imm1_o				=	{25'b0,IR[10:4]};
								ALU2_op_o				=	{5'b0};
								ALU_Ra2_o				=	{5'b0};	
								ALU_Rb2_o				=	{5'b0};
								ALU_Imm2_o				=	{32'b0};		
								ALU_Rd1_WB_sel_o		=	{1'b0,IR[23:20]};
								ALU_Rd1_WB_en_o			=	~(IR[2] & IR[1] & IR[0]); 
								ALU_Rd2_WB_sel_o		= 	{5'b0};
								ALU_Rd2_WB_en_o			=	1'b0;
								ALU_FLAG_WB_en_o		=	IR[3] | (IR[2] & IR[1] & IR[0]);
								////////////////////////////////////
								DMEM_Control_sel_o		=	2'b00;
								DMEM_ID_WE_o			=	1'b0;
								DMEM_Data_sel_o			=	1'b0;
								Rd_DMEM_o				=	4'b0000;								
								JUMP_sel_o				=	3'b000;	
								JUMP_R_sel_o			=	4'b0000;
								LOAD_happened_o			= 	1'b0;
							end
						1'b1:
							begin
								casex(IR[3:0]) // ALU1_op_o
									4'b?00? : //ADD
										begin
											ALU2_op_o = {IR[0],4'b0001};
										end
									4'b?01? : //SUB
										begin
											ALU2_op_o = {IR[0],4'b0010};
										end
									4'b?100 : //AND
										begin
											ALU2_op_o = 5'b00011;
										end
									4'b?101 : //OR
										begin
											ALU2_op_o = 5'b00100;
										end
									4'b?110 ://XOR
										begin
											ALU2_op_o = 5'b00101;
										end
									4'b0111://CMP
										begin
											ALU2_op_o = 5'b00010;
										end
									4'b1111://CMN
										begin
											ALU2_op_o = 5'b00001;
										end
								endcase	
								ALU_input_sel_Ra1_o		= 	1'b1;
								ALU_input_sel_Rb1_o		=	2'b10;  // Imm
								ALU_input_sel_Ra2_o		=	1'b1;
								ALU_input_sel_Rb2_o		=	2'b01;  // R
								ALU1_op_o				=	{5'b00001};
								ALU_Ra1_o				=	{1'b0,IR[23:20]};
								ALU_Rb1_o				=	{5'b0};
								ALU_Imm1_o				=	{25'b0,IR[10:4]};
								ALU_Ra2_o				=	{1'b0,IR[19:16]};	
								ALU_Rb2_o				=	{1'b0,IR[15:12]};
								ALU_Imm2_o				=	{32'b0};		
								ALU_Rd1_WB_sel_o		=	{1'b0,IR[23:20]};
								ALU_Rd1_WB_en_o			=	~(IR[2] & IR[1] & IR[0]); 
								ALU_Rd2_WB_sel_o		= 	{5'b0};
								ALU_Rd2_WB_en_o			=	1'b0;
								ALU_FLAG_WB_en_o		=	IR[3] | (IR[2] & IR[1] & IR[0]);
								////////////////////////////////////
								DMEM_Control_sel_o		=	2'b10;
								DMEM_ID_WE_o			=	1'b1;
								DMEM_Data_sel_o			=	1'b0;
								Rd_DMEM_o				=	4'b0000;								
								JUMP_sel_o				=	3'b000;	
								JUMP_R_sel_o			=	4'b0000;
								LOAD_happened_o			= 	1'b0;
							end
					endcase
				end
			3'b001: //ALU
				begin 
					casex(IR[3:0]) // ALU1_op_o
						4'b000? : //ADDi
							begin
								ALU1_op_o = {IR[0],4'b0001};
							end
						4'b001? : //SUBi
							begin
								ALU1_op_o = {IR[0],4'b0010};
							end
						4'b0100://CMPi
							begin
								ALU1_op_o = 5'b00010;
							end
						4'b0101://CMNi
							begin
								ALU1_op_o = 5'b00001;
							end
						4'b1000://SHL
							begin
								ALU1_op_o = 5'b00111;
							end
						4'b1001://SHR
							begin
								ALU1_op_o = 5'b01000;
							end
						4'b1010://ROL
							begin
								ALU1_op_o = 5'b01001;
							end
						4'b1011://ROR
							begin
								ALU1_op_o = 5'b01010;
							end
						4'b1100://ASR
							begin
								ALU1_op_o = 5'b01011;
							end
						default:
							begin
								ALU1_op_o = 5'b00000;
							end
					endcase	
					ALU_input_sel_Ra1_o		= 	1'b1;
					ALU_input_sel_Rb1_o		=	2'b10;
					ALU_input_sel_Ra2_o		=	1'b0;
					ALU_input_sel_Rb2_o		=	2'b00;
					ALU_Ra1_o				=	IR[3]? {1'b0,IR[23:20]} :{1'b0,IR[19:16]} ;
					ALU_Rb1_o				=	{1'b0,IR[15:12]};
					ALU_Imm1_o				=	{20'b0,IR[15:4]};
					ALU2_op_o				=	{5'b0};
					ALU_Ra2_o				=	{5'b0};	
					ALU_Rb2_o				=	{5'b0};
					ALU_Imm2_o				=	{32'b0};		
					ALU_Rd1_WB_sel_o		=	{1'b0,IR[23:20]};
					ALU_Rd1_WB_en_o			=	(IR[3]) | (~IR[2]);
					ALU_Rd2_WB_sel_o		= 	{5'b0};
					ALU_Rd2_WB_en_o			=	1'b0;
					ALU_FLAG_WB_en_o		=	(~IR[3]) & IR[2];
					//////////////////////////////////////////////
					DMEM_Control_sel_o		=	2'b00;
					DMEM_ID_WE_o			=	1'b0;
					DMEM_Data_sel_o			=	1'b0;
					Rd_DMEM_o				=	4'b0000;								
					JUMP_sel_o				=	3'b000;	
					JUMP_R_sel_o			=	4'b0000;
					LOAD_happened_o			= 	1'b0;
					LOAD_Rd_tmp_o			=	4'b0;
				end
			3'b010: //MOV
				begin
					case(IR[3]) // ALU1_op_o
						1'b0:
							begin
								case(IR[2:0]) // ALU1_op_o
		/*							3'b000: //MOV
										begin
											ALU1_op_o 				=	5'b00000;
											ALU_Ra1_o				=	{1'b0,IR[19:16]} ;
										end*/
									3'b001: //MVN
										begin
											ALU1_op_o 				= 	5'b00110;
											ALU_Ra1_o				=	{1'b0,IR[19:16]} ;
										end
									3'b010: //MVSR
										begin
											ALU1_op_o 				= 	5'b00000;
											ALU_Ra1_o				=	{1'b1,IR[19:16]} ;
										end
									3'b100: //MVRS
										begin
											ALU1_op_o 				= 	5'b00000;
											ALU_Ra1_o				=	{1'b0,IR[19:16]} ;
										end
									default: //MOV
										begin
											ALU1_op_o 				=	5'b00000;
											ALU_Ra1_o				=	{1'b0,IR[19:16]} ;
										end
								endcase
							end
						1'b1:
							begin
								casex(IR[1:0]) // ALU1_op_o
									2'b00: //MOVi
										begin
											ALU1_op_o 				=	5'b01100;
											ALU_Ra1_o				=	{1'b0,IR[23:20]} ;
										end
									2'b01: //MVHi
										begin
											ALU1_op_o 				= 	5'b01101;
											ALU_Ra1_o				=	{1'b0,IR[23:20]} ;
										end
									2'b1?: //MVLi
										begin
											ALU1_op_o 				= 	5'b01110;
											ALU_Ra1_o				=	{1'b0,IR[23:20]} ;
										end
								endcase
							end
					endcase		
					ALU_input_sel_Ra1_o		= 	1'b1;
					ALU_input_sel_Rb1_o		=	2'b10;
					ALU_input_sel_Ra2_o		=	1'b0;
					ALU_input_sel_Rb2_o		=	2'b00;
					ALU_Rb1_o				=	{1'b0,IR[15:12]};
					ALU_Imm1_o				= 	{16'b0,IR[19:4]};
					ALU2_op_o				=	{5'b0};
					ALU_Ra2_o				=	{5'b0};	
					ALU_Rb2_o				=	{5'b0};
					ALU_Imm2_o				=	{32'b0};		
					ALU_Rd1_WB_sel_o		=	{IR[2],IR[23:20]};
					ALU_Rd1_WB_en_o			=	1'b1;
					ALU_Rd2_WB_sel_o		= 	{5'b0};
					ALU_Rd2_WB_en_o			=	1'b0;
					ALU_FLAG_WB_en_o		=	1'b0;
					//////////////////////////////////////////////
					DMEM_Control_sel_o		=	2'b00;
					DMEM_ID_WE_o			=	1'b0;
					DMEM_Data_sel_o			=	1'b0;
					Rd_DMEM_o				=	4'b0000;								
					JUMP_sel_o				=	3'b000;	
					JUMP_R_sel_o			=	4'b0000;
					LOAD_happened_o			= 	1'b0;
					LOAD_Rd_tmp_o			=	4'b0;
				end
			3'b011: //LDR & STR
				begin
					case(IR[3])
						1'b0:  //LDR
							begin
								case(IR[2:0]) // ALU1_op_o
	/*								3'b000 : //LDR
										begin
											DMEM_Control_sel_o		=	2'b10;  //Ra1
											ALU1_op_o 				= 	5'b00001;
											ALU_Rd1_WB_en_o			=	1'b0;
										end*/
									3'b001 : //LDRIA
										begin
											DMEM_Control_sel_o		=	2'b01;  //Ra1
											ALU1_op_o 				= 	5'b00001;
											ALU_Rd1_WB_en_o			=	1'b1;
										end
									3'b010 : //LDRDA
										begin
											DMEM_Control_sel_o		=	2'b01;  //Ra1
											ALU1_op_o 				= 	5'b00010;
											ALU_Rd1_WB_en_o			=	1'b1;
										end
									3'b011 : //LDRIB
										begin
											DMEM_Control_sel_o		=	2'b10;  //Ra1
											ALU1_op_o 				= 	5'b00001;
											ALU_Rd1_WB_en_o			=	1'b1;
										end
									3'b100 : //LDRDB
										begin
											DMEM_Control_sel_o		=	2'b10;  //Ra1
											ALU1_op_o 				= 	5'b00010;
											ALU_Rd1_WB_en_o			=	1'b1;
										end
									default:
										begin
											DMEM_Control_sel_o		=	2'b10;  //Ra1
											ALU1_op_o 				= 	5'b00001;
											ALU_Rd1_WB_en_o			=	1'b0;
										end
								endcase	
								ALU_input_sel_Ra1_o		= 	1'b1;
								ALU_input_sel_Rb1_o		=	2'b10; //Imm
								ALU_input_sel_Ra2_o		=	1'b0;
								ALU_input_sel_Rb2_o		=	2'b00;
						//		ALU1_op_o 				= 	5'b00001;
								ALU_Ra1_o				=	{1'b0,IR[19:16]};
								ALU_Rb1_o				=	5'b00000;
								ALU_Imm1_o				=	{20'b0,IR[15:4]};
								ALU2_op_o				=	{5'b0};
								ALU_Ra2_o				=	{5'b0};	
								ALU_Rb2_o				=	{5'b0};
								ALU_Imm2_o				=	{32'b0};		
								ALU_Rd1_WB_sel_o		=	{1'b0,IR[19:16]};  // first write back the address counting
						//		ALU_Rd1_WB_en_o			=	1'b0;
								ALU_Rd2_WB_sel_o		= 	{5'b0};
								ALU_Rd2_WB_en_o			=	1'b0;
								ALU_FLAG_WB_en_o		=	1'b0;
								////////////////////////////////////
							//	DMEM_Control_sel_o		=	2'b10;
								DMEM_ID_WE_o			=	1'b0;
								DMEM_Data_sel_o			=	1'b0;
								Rd_DMEM_o				=	4'b0000;								
								JUMP_sel_o				=	3'b001;	
								JUMP_R_sel_o			=	4'b0000;
								LOAD_happened_o			= 	1'b1;
								LOAD_Rd_tmp_o			=	IR[23:20];
							end
						1'b1: //STR
							begin
								case(IR[2:0]) // ALU1_op_o
	/*								3'b000 : //STR
										begin
											DMEM_Control_sel_o		=	2'b10;  //Ra1
											ALU1_op_o 				= 	5'b00001;
											ALU_Rd1_WB_en_o			=	1'b0;
										end*/
									3'b001 : //STRIA
										begin
											DMEM_Control_sel_o		=	2'b01;  //Ra1
											ALU1_op_o 				= 	5'b00001;
											ALU_Rd1_WB_en_o			=	1'b1;
										end
									3'b010 : //STRDA
										begin
											DMEM_Control_sel_o		=	2'b01;  //Ra1
											ALU1_op_o 				= 	5'b00010;
											ALU_Rd1_WB_en_o			=	1'b1;
										end
									3'b011 : //STRIB
										begin
											DMEM_Control_sel_o		=	2'b10;  //Ra1
											ALU1_op_o 				= 	5'b00001;
											ALU_Rd1_WB_en_o			=	1'b1;
										end
									3'b100 : //STRDB
										begin
											DMEM_Control_sel_o		=	2'b10;  //Ra1
											ALU1_op_o 				= 	5'b00010;
											ALU_Rd1_WB_en_o			=	1'b1;
										end
									default:
										begin
											DMEM_Control_sel_o		=	2'b10;  //Ra1
											ALU1_op_o 				= 	5'b00001;
											ALU_Rd1_WB_en_o			=	1'b0;
										end
								endcase	
								ALU_input_sel_Ra1_o		= 	1'b1;
								ALU_input_sel_Rb1_o		=	2'b10; //Imm
								ALU_input_sel_Ra2_o		=	1'b0;
								ALU_input_sel_Rb2_o		=	2'b00;
						//		ALU1_op_o 				= 	5'b00001;
								ALU_Ra1_o				=	{1'b0,IR[19:16]};
								ALU_Rb1_o				=	5'b00000;
								ALU_Imm1_o				=	{20'b0,IR[15:4]};
								ALU2_op_o				=	{5'b0};
								ALU_Ra2_o				=	{5'b0};	
								ALU_Rb2_o				=	{5'b0};
								ALU_Imm2_o				=	{32'b0};		
								ALU_Rd1_WB_sel_o		=	{1'b0,IR[19:16]};  // first write back the address counting
						//		ALU_Rd1_WB_en_o			=	1'b0;
								ALU_Rd2_WB_sel_o		= 	{5'b0};
								ALU_Rd2_WB_en_o			=	1'b0;
								ALU_FLAG_WB_en_o		=	1'b0;
								////////////////////////////////////
							//	DMEM_Control_sel_o		=	2'b10;
								DMEM_ID_WE_o			=	1'b1;
								DMEM_Data_sel_o			=	1'b1;
								Rd_DMEM_o				=	IR[23:20];								
								JUMP_sel_o				=	3'b000;	
								JUMP_R_sel_o			=	4'b0000;
								LOAD_happened_o			= 	1'b0;
								LOAD_Rd_tmp_o			=	4'b0;
							end
					endcase		
				end
			3'b100: //B
				begin  
					case(IR[23])
						1'b0:
							begin
								JUMP_sel_o				=	3'b010;	
							end
						1'b1:
							begin
								JUMP_sel_o				=	3'b011;	
							end
					endcase
					ALU_input_sel_Ra1_o		= 	1'b0;
					ALU_input_sel_Rb1_o		=	2'b00;
					ALU_input_sel_Ra2_o		=	1'b0;
					ALU_input_sel_Rb2_o		=	2'b00;
					ALU1_op_o 				= 	5'b00000;
					ALU_Ra1_o				=	{5'b0};
					ALU_Rb1_o				=	{5'b0};
					ALU_Imm1_o				=	{9'b0,IR[22:0]};
					ALU2_op_o				=	{5'b0};
					ALU_Ra2_o				=	{5'b0};	
					ALU_Rb2_o				=	{5'b0};
					ALU_Imm2_o				=	{32'b0};		
					ALU_Rd1_WB_sel_o		=	{5'b0};
					ALU_Rd1_WB_en_o			=	1'b0;
					ALU_Rd2_WB_sel_o		= 	{5'b0};
					ALU_Rd2_WB_en_o			=	1'b0;
					ALU_FLAG_WB_en_o		=	1'b0;
					//////////////////////////////////////////////
					DMEM_Control_sel_o		=	2'b00;
					DMEM_ID_WE_o			=	1'b0;
					DMEM_Data_sel_o			=	1'b0;
					Rd_DMEM_o				=	4'b0000;	
				//	JUMP_sel_o				=	3'b000;	
					JUMP_R_sel_o			=	4'b0000;
					LOAD_happened_o			= 	1'b0;
					LOAD_Rd_tmp_o			=	4'b0;
				end
			3'b101: //JP
				begin  
					ALU_input_sel_Ra1_o		= 	1'b0;
					ALU_input_sel_Rb1_o		=	2'b00;
					ALU_input_sel_Ra2_o		=	1'b0;
					ALU_input_sel_Rb2_o		=	2'b00;
					ALU1_op_o 				= 	5'b00000;
					ALU_Ra1_o				=	{5'b0};
					ALU_Rb1_o				=	{5'b0};
					ALU_Imm1_o				=	{32'b0};
					ALU2_op_o				=	{5'b0};
					ALU_Ra2_o				=	{5'b0};	
					ALU_Rb2_o				=	{5'b0};
					ALU_Imm2_o				=	{32'b0};		
					ALU_Rd1_WB_sel_o		=	{5'b0};
					ALU_Rd1_WB_en_o			=	1'b0;
					ALU_Rd2_WB_sel_o		= 	{5'b0};
					ALU_Rd2_WB_en_o			=	1'b0;
					ALU_FLAG_WB_en_o		=	1'b0;
					//////////////////////////////////////////////
					DMEM_Control_sel_o		=	2'b00;
					DMEM_ID_WE_o			=	1'b0;
					DMEM_Data_sel_o			=	1'b0;
					Rd_DMEM_o				=	4'b0000;	
					JUMP_sel_o				=	3'b100;	
					JUMP_R_sel_o			=	IR[19:16];
					LOAD_happened_o			= 	1'b0;
					LOAD_Rd_tmp_o			=	4'b0;
				end
			3'b110: //CUST1
				begin 
					ALU_input_sel_Ra1_o		= 	1'b0;
					ALU_input_sel_Rb1_o		=	2'b00;
					ALU_input_sel_Ra2_o		=	1'b0;
					ALU_input_sel_Rb2_o		=	2'b00;
					ALU1_op_o 				= 	5'b00000;
					ALU_Ra1_o				=	{5'b0};
					ALU_Rb1_o				=	{5'b0};
					ALU_Imm1_o				=	{32'b0};
					ALU2_op_o				=	{5'b0};
					ALU_Ra2_o				=	{5'b0};	
					ALU_Rb2_o				=	{5'b0};
					ALU_Imm2_o				=	{32'b0};		
					ALU_Rd1_WB_sel_o		=	{5'b0};
					ALU_Rd1_WB_en_o			=	1'b0;
					ALU_Rd2_WB_sel_o		= 	{5'b0};
					ALU_Rd2_WB_en_o			=	1'b0;
					ALU_FLAG_WB_en_o		=	1'b0;
					//////////////////////////////////////////////
					DMEM_Control_sel_o		=	2'b00;
					DMEM_ID_WE_o			=	1'b0;
					DMEM_Data_sel_o			=	1'b0;
					Rd_DMEM_o				=	4'b0000;	
					JUMP_sel_o				=	3'b000;	
					JUMP_R_sel_o			=	4'b0000;
					LOAD_happened_o			= 	1'b0;
					LOAD_Rd_tmp_o			=	4'b0;
				end
			3'b111: //HALT
				begin 
					ALU_input_sel_Ra1_o		= 	1'b0;
					ALU_input_sel_Rb1_o		=	2'b00;
					ALU_input_sel_Ra2_o		=	1'b0;
					ALU_input_sel_Rb2_o		=	2'b00;
					ALU1_op_o 				= 	5'b00000;
					ALU_Ra1_o				=	{5'b0};
					ALU_Rb1_o				=	{5'b0};
					ALU_Imm1_o				=	{32'b0};
					ALU2_op_o				=	{5'b0};
					ALU_Ra2_o				=	{5'b0};	
					ALU_Rb2_o				=	{5'b0};
					ALU_Imm2_o				=	{32'b0};		
					ALU_Rd1_WB_sel_o		=	{5'b0};
					ALU_Rd1_WB_en_o			=	1'b0;
					ALU_Rd2_WB_sel_o		= 	{5'b0};
					ALU_Rd2_WB_en_o			=	1'b0;
					ALU_FLAG_WB_en_o		=	1'b0;
					//////////////////////////////////////////////
					DMEM_Control_sel_o		=	2'b00;
					DMEM_ID_WE_o			=	1'b0;
					DMEM_Data_sel_o			=	1'b0;
					Rd_DMEM_o				=	4'b0000;	
					JUMP_sel_o				=	3'b000;	
					JUMP_R_sel_o			=	4'b0000;
					LOAD_happened_o			= 	1'b0;
					LOAD_Rd_tmp_o			=	4'b0;
				end
		endcase
	end
end


endmodule
