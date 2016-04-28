`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 07/09/2014 
// Design Name:    KH32 & KH16
// Module Name:    CPU_EX 
// Project Name:   Throughput Processor 
// Description:    This part is the Execute of the CPU core
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module CPU_EX(
input wire clk ,
input wire rst,
////////INPUT from ID///////////
input wire [0:0] 	ALU_input_sel_Ra1,
input wire [1:0] 	ALU_input_sel_Rb1,
input wire [0:0] 	ALU_input_sel_Ra2,
input wire [1:0] 	ALU_input_sel_Rb2,
input wire [31:0] 	PC_ID,
input wire [3:0] 	COND,
input wire [4:0] 	ALU1_op,
input wire [4:0] 	ALU_Ra1,
input wire [4:0] 	ALU_Rb1,
input wire [31:0] 	ALU_Imm1,
input wire [4:0] 	ALU2_op,
input wire [4:0] 	ALU_Ra2,
input wire [4:0] 	ALU_Rb2,
input wire [31:0] 	ALU_Imm2,
input wire [4:0] 	ALU_Rd1_WB_sel,
input wire [0:0] 	ALU_Rd1_WB_en,
input wire [4:0] 	ALU_Rd2_WB_sel,
input wire [0:0] 	ALU_Rd2_WB_en,
input wire [0:0] 	ALU_FLAG_WB_en,
input wire [1:0] 	DMEM_Control_sel ,
input wire [0:0] 	DMEM_ID_WE,
input wire [0:0] 	DMEM_Data_sel,
input wire [3:0] 	Rd_DMEM,//Memory data Register assign select
////////Program counter///////////
input wire [2:0] 	JUMP_sel,
input wire [3:0] 	JUMP_R_sel,
////////INPUT from DMEM///////////
input wire [31:0] 	DMEM_DATA_WB_w,
input wire [31:0] 	DMEM_Base_Addr,
input wire [31:0] 	DMEM_High_Addr,
////////INPUT for LOAD/////////////
input wire [0:0] 	LOAD_EN,

////////OUTPUT//////////
output reg [0:0] 	DMEM_WE,
output reg [31:0] 	DMEM_Addr,
output reg [31:0] 	DMEM_Data,
output reg [0:0] 	DMEM_no_hit,

////////SPR IO//////////
//special register Output part
input wire [0:0]	IMEM_no_hit,//ICache no hit

output reg [31:0] R17,//PC
output reg[31:0] R19,//output device value
output reg [31:0] R20,//output data value
//special register Input part
input wire [31:0] R21,//input device value
input wire [31:0] R22//input data value
////You can add your design here



    );
/////////////////////////////////////////////
/*FLUSH is use for counting the Flush time.*/
/////////////////////////////////////////////
//output reg [31:0] R17 = 32'b0;//PC
/*
output reg[31:0] R19 = 32'b0;//output device value
output reg [31:0] R20 = 32'b0;//output data value
//special register Input part
input [31:0] R21;//input device value
input [31:0] R22;//input data value
*/

reg [2:0] FLUSH;
reg [31:0] R00;//R0~R15 for compute
reg [31:0] R01;
reg [31:0] R02;
reg [31:0] R03;
reg [31:0] R04;
reg [31:0] R05;
reg [31:0] R06;
reg [31:0] R07;
reg [31:0] R08;
reg [31:0] R09;
reg [31:0] R10;
reg [31:0] R11;
reg [31:0] R12;
reg [31:0] R13;
reg [31:0] R14;
reg [31:0] R15;

reg [31:0] R16;//FALG 
reg [31:0] R18;//PC_LINK

/*
reg [31:0] R17 = 32'b0;//PC 
reg [31:0] R18 = 32'b0;//PC_LINK
reg [31:0] R19 = 32'b0;//output device value
reg [31:0] R20 = 32'b0;//output data value*/
/*
wire [31:0] R21 ;//input device value
wire [31:0] R22 ;//input data value*/
reg [31:0] R23;//R23 ~ R31 can make for INT ,floating compute
reg [31:0] R24;
reg [31:0] R25;
reg [31:0] R26;
reg [31:0] R27;
reg [31:0] R28;
reg [31:0] R29;
reg [31:0] R30;
reg [31:0] R31;

wire [31:0] MUX_to_Ra1;	 
wire [31:0] MUX_to_Rb1;
wire [31:0] MUX_to_ALU_Ra1;
wire [31:0] MUX_to_ALU_Rb1;
wire [31:0] MUX_to_Ra2;	 
wire [31:0] MUX_to_Rb2;
wire [31:0] MUX_to_ALU_Ra2;
wire [31:0] MUX_to_ALU_Rb2;
wire [31:0] Reg32_Ra1;
wire [31:0] Reg32_Rb1;
wire [31:0] Reg32_Ra2;
wire [31:0] Reg32_Rb2;
wire [31:0] ALU1_Rd;
wire [31:0] ALU2_Rd;
wire [3:0] FLAG_Rd;
wire [31:0] DMEM_Addr_o;
wire [31:0] DMEM_Data_o;
wire [31:0] Rd_DMEM_r;
reg [0:0] 	COND_en;

wire [31:0] JUMP_R_o;

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
always @(*)
begin
	case(COND)
		4'b0000://NT
			begin
				COND_en = 1'b0;
			end
		4'b0001://EQ
			begin
				COND_en = R16[31];
			end
		4'b0010://NE
			begin
				COND_en = ~R16[31];
			end
		4'b0011://CS
			begin
				COND_en = R16[30];
			end
		4'b0100://CC
			begin
				COND_en = ~R16[30];
			end
		4'b0101://MI
			begin
				COND_en =  R16[28];
			end	
		4'b0110://PL
			begin
				COND_en =  ~R16[28];
			end	
		4'b0111://VS
			begin
				COND_en =  R16[29];
			end	
		4'b1000://VC
			begin
				COND_en =  ~R16[29];
			end	
		4'b1001://HI
			begin
				COND_en = ( R16[30] && (~R16[31]));
			end	
		4'b1010://LS
			begin
				COND_en = ( (R16[31]) || (~R16[30]));
			end	
		4'b1011://GE
			begin
				COND_en = ( R16[29] == R16[28]);
			end	
		4'b1100://LT
			begin
				COND_en = ( R16[29] != R16[28]);
			end	
		4'b1101://GT
			begin
				COND_en = ( ~R16[31]  && ( R16[29] == R16[28]) );
			end	
		4'b1110://LE
			begin
				COND_en = ( R16[31]  || ( R16[29] != R16[28]) ) ;
			end	
		4'b1111://AL
			begin
				COND_en = 1'b1;
			end	
	 endcase
			
end


MUX_32_to_1_32bit ALU_Ra1_REG32(
.sel_i_32(ALU_Ra1),
.out(Reg32_Ra1),
.i0(R00),.i1(R01),.i2(R02),.i3(R03),
.i4(R04),.i5(R05),.i6(R06),.i7(R07),
.i8(R08),.i9(R09),.i10(R10),.i11(R11),
.i12(R12),.i13(R13),.i14(R14),.i15(R15),
.i16(R16),.i17(R17),.i18(R18),.i19(R19),
.i20(R20),.i21(R21),.i22(R22),.i23(R23),
.i24(R24),.i25(R25),.i26(R26),.i27(R27),
.i28(R28),.i29(R29),.i30(R30),.i31(R31)
    );
	 
MUX_32_to_1_32bit ALU_Rb1_REG32(
.sel_i_32(ALU_Rb1),
.out(Reg32_Rb1),
.i0(R00),.i1(R01),.i2(R02),.i3(R03),
.i4(R04),.i5(R05),.i6(R06),.i7(R07),
.i8(R08),.i9(R09),.i10(R10),.i11(R11),
.i12(R12),.i13(R13),.i14(R14),.i15(R15),
.i16(R16),.i17(R17),.i18(R18),.i19(R19),
.i20(R20),.i21(R21),.i22(R22),.i23(R23),
.i24(R24),.i25(R25),.i26(R26),.i27(R27),
.i28(R28),.i29(R29),.i30(R30),.i31(R31)
    );
	 
MUX_32_to_1_32bit ALU_Ra2_REG32(
.sel_i_32(ALU_Ra2),
.out(Reg32_Ra2),
.i0(R00),.i1(R01),.i2(R02),.i3(R03),
.i4(R04),.i5(R05),.i6(R06),.i7(R07),
.i8(R08),.i9(R09),.i10(R10),.i11(R11),
.i12(R12),.i13(R13),.i14(R14),.i15(R15),
.i16(R16),.i17(R17),.i18(R18),.i19(R19),
.i20(R20),.i21(R21),.i22(R22),.i23(R23),
.i24(R24),.i25(R25),.i26(R26),.i27(R27),
.i28(R28),.i29(R29),.i30(R30),.i31(R31)
    );
	 
MUX_32_to_1_32bit ALU_Rb2_REG32(
.sel_i_32(ALU_Rb2),
.out(Reg32_Rb2),
.i0(R00),.i1(R01),.i2(R02),.i3(R03),
.i4(R04),.i5(R05),.i6(R06),.i7(R07),
.i8(R08),.i9(R09),.i10(R10),.i11(R11),
.i12(R12),.i13(R13),.i14(R14),.i15(R15),
.i16(R16),.i17(R17),.i18(R18),.i19(R19),
.i20(R20),.i21(R21),.i22(R22),.i23(R23),
.i24(R24),.i25(R25),.i26(R26),.i27(R27),
.i28(R28),.i29(R29),.i30(R30),.i31(R31)
    );	 
	 
MUX_2_to_1_32bit ALU_Ra1_Mux(
.sel_i_2(ALU_input_sel_Ra1),
.out(MUX_to_ALU_Ra1),
.i0(32'b0),
.i1(Reg32_Ra1)
    );

MUX_4_to_1_32bit ALU_Rb1_Mux(
.sel_i_4(ALU_input_sel_Rb1),
.out(MUX_to_ALU_Rb1),
.i0(32'b0),
.i1(Reg32_Rb1),
.i2(ALU_Imm1),
.i3(32'b0)
    );
	 
MUX_2_to_1_32bit ALU_Ra2_Mux(
.sel_i_2(ALU_input_sel_Ra2),
.out(MUX_to_ALU_Ra2),
.i0(32'b0),
.i1(Reg32_Ra2)
    );

MUX_4_to_1_32bit ALU_Rb2_Mux(
.sel_i_4(ALU_input_sel_Rb2),
.out(MUX_to_ALU_Rb2),
.i0(32'b0),
.i1(Reg32_Rb2),
.i2(ALU_Imm2),
.i3(32'b0)
	 );


CPU_ALU ALU1(
////////INPUT///////////
.ALU_op(ALU1_op),//[4:0]  5-bit :{C , operand}
.ALU_Ra(MUX_to_ALU_Ra1),//[31:0]	
.ALU_Rb(MUX_to_ALU_Rb1),//[31:0]	
.FLAG_i(R16[31:28]),//[3:0]	
////////OUTPUT///////////
.FLAG_o(FLAG_Rd),//[3:0]	
.ALU_Rd(ALU1_Rd)//[31:0]	
    );


CPU_ALU ALU2(
////////INPUT///////////
.ALU_op(ALU2_op),//[4:0]  5-bit :{C , operand}
.ALU_Ra(MUX_to_ALU_Ra2),//[31:0]	
.ALU_Rb(MUX_to_ALU_Rb2),//[31:0]	
.FLAG_i(R16[31:28]),//[3:0]	
////////OUTPUT///////////
.FLAG_o(),//[3:0]	no Write back
.ALU_Rd(ALU2_Rd)//[31:0]	
    );

MUX_4_to_1_32bit DMEM_Addr_Mux(
.sel_i_4(DMEM_Control_sel),
.out(DMEM_Addr_o),
.i0(DMEM_Addr),
.i1(MUX_to_ALU_Ra1),
.i2(ALU1_Rd),
.i3(DMEM_Addr)
	 );
	 
	 
MUX_2_to_1_32bit DMEM_Data_Mux(
.sel_i_2(DMEM_Data_sel),
.out(DMEM_Data_o),
.i0(ALU2_Rd),
.i1(Rd_DMEM_r)
    );
	 
MUX_16_to_1_32bit DMEM_Data_R(
.sel_i_16(Rd_DMEM),
.out(Rd_DMEM_r),
.i0(R00),.i1(R01),.i2(R02),.i3(R03),
.i4(R04),.i5(R05),.i6(R06),.i7(R07),
.i8(R08),.i9(R09),.i10(R10),.i11(R11),
.i12(R12),.i13(R13),.i14(R14),.i15(R15)
	 );
	 
MUX_16_to_1_32bit Jump_R_sel(
.sel_i_16(JUMP_R_sel),
.out(JUMP_R_o),
.i0(R00),.i1(R01),.i2(R02),.i3(R03),
.i4(R04),.i5(R05),.i6(R06),.i7(R07),
.i8(R08),.i9(R09),.i10(R10),.i11(R11),
.i12(R12),.i13(R13),.i14(R14),.i15(R15)
	 ); 

/////////////////////
//Eacch of the register are independent
/////////////////////	 
wire no_hit;
wire DMEM_hit_w;
wire DMEM_no_hit_w;
reg  DMEM_WE_TMP;

assign no_hit = IMEM_no_hit | DMEM_no_hit;
assign DMEM_hit_w = ((DMEM_Addr_o >= DMEM_Base_Addr) && (DMEM_Addr_o <= DMEM_High_Addr));
assign DMEM_no_hit_w = !((DMEM_Addr >= DMEM_Base_Addr) && (DMEM_Addr <= DMEM_High_Addr));
always @(posedge clk or negedge rst )
if(!rst)
begin

FLUSH <= 3'b000;
R00 <= 32'b0;//R0~R15 for compute
R01 <= 32'b0;
R02 <= 32'b0;
R03 <= 32'b0;
R04 <= 32'b0;
R05 <= 32'b0;
R06 <= 32'b0;
R07 <= 32'b0;
R08 <= 32'b0;
R09 <= 32'b0;
R10 <= 32'b0;
R11 <= 32'b0;
R12 <= 32'b0;
R13 <= 32'b0;
R14 <= 32'b0;
R15 <= 32'b0;

R16 <= 32'b0;//FALG 
R18 <= 32'b0;//PC_LINK

R23 <= 32'b0;//R23 ~ R31 can make for INT ,floating compute
R24 <= 32'b0;
R25 <= 32'b0;
R26 <= 32'b0;
R27 <= 32'b0;
R28 <= 32'b0;
R29 <= 32'b0;
R30 <= 32'b0;
R31 <= 32'b0;
DMEM_WE <= 1'b0;
DMEM_Addr <= 32'b0;
DMEM_Data <= 32'b0;
DMEM_no_hit <= 1'b1;
DMEM_WE_TMP <= 1'b0;
R17 <= 32'b0;//PC
R19 <= 32'b0;//output device value
R20 <= 32'b0;//output data value

end
else 
begin

	if(no_hit)
	begin	
		DMEM_no_hit <= DMEM_no_hit_w;
		DMEM_WE <= DMEM_no_hit_w? 1'b0: DMEM_WE_TMP;
	end	
	else 
	begin
		if(COND_en && (FLUSH[2:0] == 3'b000) )//This is a method of FLUSH data
		begin
		    if(DMEM_hit_w)
			begin
			case(JUMP_sel)
		//		3'b000:begin R17 <= R17 + 1; end
				3'b001:begin R17 <= R17 - 1; R18 <= R18; FLUSH <= FLUSH >> 1; end
				3'b010:begin R17 <= PC_ID + ALU_Imm1 - 1; R18 <= PC_ID; FLUSH <= 3'b010; end
				3'b011:begin R17 <= PC_ID - ALU_Imm1 - 1; R18 <= PC_ID; FLUSH <= 3'b010; end 
				3'b100:begin R17 <= JUMP_R_o; R18 <= PC_ID; FLUSH <= 3'b010; end
				default : begin R17 <= R17 + 1; FLUSH <= FLUSH >> 1; R18 <= R18; end
			endcase				
			end	
			else 
			begin
			R17 <= R17;

			end
		R00 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b00000))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b00000)? ALU2_Rd : R00);//(LOAD_EN? DMEM_DATA_WB_w : R00));
		R01 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b00001))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b00001)? ALU2_Rd : R01);
		R02 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b00010))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b00010)? ALU2_Rd : R02);
		R03 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b00011))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b00011)? ALU2_Rd : R03);
		R04 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b00100))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b00100)? ALU2_Rd : R04);
		R05 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b00101))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b00101)? ALU2_Rd : R05);
		R06 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b00110))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b00110)? ALU2_Rd : R06);
		R07 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b00111))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b00111)? ALU2_Rd : R07);
		R08 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b01000))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b01000)? ALU2_Rd : R08);
		R09 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b01001))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b01001)? ALU2_Rd : R09);
		R10 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b01010))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b01010)? ALU2_Rd : R10);
		R11 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b01011))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b01011)? ALU2_Rd : R11);
		R12 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b01100))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b01100)? ALU2_Rd : R12);
		R13 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b01101))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b01101)? ALU2_Rd : R13);
		R14 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b01110))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b01110)? ALU2_Rd : R14);
		R15 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b01111))?  (LOAD_EN? DMEM_DATA_WB_w : ALU1_Rd ) : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b01111)? ALU2_Rd : R15);
		
	//	R16 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b10000))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b10000)? ALU2_Rd : R16); // flag
		R16 <= ALU_FLAG_WB_en ? {FLAG_Rd , R16[27:0] }: R16;
	
	//	R17 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b10001))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b10001)? ALU2_Rd : R17); // PC
	
	
	//	R18 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b10010))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b10010)? ALU2_Rd : R18); // PC_LINK
		R19 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b10011))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b10011)? ALU2_Rd : R19);
		R20 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b10100))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b10100)? ALU2_Rd : R20);
	//	R21 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b10101))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b10101)? ALU2_Rd : R21); // Input device value 
	//	R22 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b10110))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b10110)? ALU2_Rd : R22); // Input data value 
		R23 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b10111))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b10111)? ALU2_Rd : R23);
		R24 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b11000))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b11000)? ALU2_Rd : R24);
		R25 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b11001))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b11001)? ALU2_Rd : R25);
		R26 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b11010))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b11010)? ALU2_Rd : R26);
		R27 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b11011))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b11011)? ALU2_Rd : R27);
		R28 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b11100))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b11100)? ALU2_Rd : R28);
		R29 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b11101))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b11101)? ALU2_Rd : R29);
		R30 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b11110))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b11110)? ALU2_Rd : R30);
		R31 <= (ALU_Rd1_WB_en && (ALU_Rd1_WB_sel == 5'b11111))?  ALU1_Rd : ((ALU_Rd2_WB_en && ALU_Rd2_WB_sel == 5'b11111)? ALU2_Rd : R31);	
		DMEM_Addr <= DMEM_Addr_o;
		DMEM_no_hit <= !DMEM_hit_w;
		DMEM_WE <= DMEM_hit_w? DMEM_ID_WE : 1'b0;/////
		DMEM_WE_TMP <= DMEM_hit_w? 1'b0 : DMEM_ID_WE;
		DMEM_Data <= DMEM_Data_o;
		
		end
		else
		begin
			R17 <= R17 + 1; 
			FLUSH <= FLUSH >> 1; 
			R18 <= R18;
		end
		
	end
		
end

endmodule
