`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 07/09/2014 
// Design Name:    KH32 & KH16
// Module Name:    CPU_TOP
// Project Name:   Throughput Processor 
// Description:    This part is the CPU_TOP of the CPU core
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module CPU_TOP(
input wire [0:0] 		clk,
input wire [0:0] 	rst,
output wire [31:0] 	output_device_value, 		//output [31:0]//output device value
output wire [31:0] 	output_data_value, 			//output [31:0]//output data value 
input wire [31:0] 	input_device_value, 			//input [31:0]//input device value 
input wire [31:0] 	input_data_value, 			//input [31:0]//input data value
output wire [0:0] 	INEED_change_cache,		
output wire [31:0] 	INEED_Base_Addr,
output wire [31:0] 	INEED_High_Addr,
input wire [31:0] 	INEED_Addr,
input wire [31:0] 	INEED_Din,
output wire [31:0] 	INEED_Dout,
input wire [0:0] 		INEED_WE,
input wire [0:0]  	INEED_Done,
output wire [0:0] 	NEED_change_cache,	//Interrupt the Memory controller to change the cache value
output wire [0:0]  	NEED_WB_cache, 		//Write back the cache data
output wire [31:0] 	NEED_Base_Addr,
output wire [31:0] 	NEED_High_Addr,
input wire [31:0] 	NEED_Addr,
input wire [31:0] 	NEED_Din,
output wire [31:0] 	NEED_Dout,
input wire [0:0] 		NEED_WE,
input wire [0:0]  	NEED_Done
    );


//////CPU IF/////////
wire [31:0] PC;
wire [0:0] DMEM_no_hit;
wire [0:0] IMEM_no_hit;
wire [31:0] PC_IF;
wire [31:0] IR;
wire [0:0] ALU_input_sel_Ra1;
wire [1:0] ALU_input_sel_Rb1;
wire [0:0] ALU_input_sel_Ra2;
wire [1:0] ALU_input_sel_Rb2;
wire [31:0] PC_ID;
wire [3:0]	COND;
wire [4:0]	ALU1_op;
wire [4:0]	ALU_Ra1;
wire [4:0] 	ALU_Rb1;
wire [31:0]	ALU_Imm1;
wire [4:0]	ALU2_op;
wire [4:0]	ALU_Ra2;
wire [4:0]	ALU_Rb2;
wire [31:0] ALU_Imm2;
wire [4:0] ALU_Rd1_WB_sel;
wire [0:0] ALU_Rd1_WB_en;
wire [4:0] ALU_Rd2_WB_sel;
wire [0:0] ALU_Rd2_WB_en;
wire [0:0] ALU_FLAG_WB_en;
wire [1:0] DMEM_Control_sel;
wire [0:0] DMEM_ID_WE;
wire [0:0] DMEM_Data_sel;
wire [3:0] Rd_DMEM;
wire [2:0] JUMP_sel;
wire [3:0] JUMP_R_sel;
wire [0:0] LOAD_EN;
wire [0:0] DMEM_WE;
wire [31:0] DMEM_Addr;
wire [31:0] DMEM_Data;
wire [31:0] DMEM_DATA_WB_w;
wire [31:0] DMEM_Base_Addr;
wire [31:0] DMEM_High_Addr;
wire [31:0] IMEM_Base_Addr;
wire [31:0] IMEM_High_Addr;
wire [31:0] IMEM_Addr;
wire [31:0]	IMEM_Dout;
wire [0:0] LOAD_happened;

CPU_IMEM IMEM_stage(
    .clk(clk), 										//input wire [0:0]		*
	.rst(rst),
    .IMEM_Base_Addr(IMEM_Base_Addr),			//output [31:0]			*
    .IMEM_High_Addr(IMEM_High_Addr), 			//output [31:0]			*
    .IMEM_Addr(IMEM_Addr), 						//input wire [31:0]		*
    .IMEM_Dout(IMEM_Dout), 						//output wire [31:0]		*
    .IMEM_no_hit(IMEM_no_hit), 					//input wire [0:0]		*
    .INEED_change_cache(INEED_change_cache), //output [0:0]
    .INEED_Base_Addr(INEED_Base_Addr), 		//output [31:0]
    .INEED_High_Addr(INEED_High_Addr), 		//output [31:0] 
    .INEED_Addr(INEED_Addr), 						//input wire [31:0] 
    .INEED_Din(INEED_Din), 						//input wire [31:0] 
    .INEED_Dout(INEED_Dout), 						//output wire [31:0]
    .INEED_WE(INEED_WE), 							//input wire [0:0]
    .INEED_Done(INEED_Done)						//input wire [0:0]
    );




CPU_IF IF_stage (
    .clk(clk), 										//input wire [0:0] 		*
	.rst(rst),
    .PC(PC), 											//input wire [31:0] 		*
    .IMEM_Base_Addr(IMEM_Base_Addr), 			//input wire [31:0]		*
    .IMEM_High_Addr(IMEM_High_Addr), 			//input wire [31:0]		*
    .DMEM_no_hit(DMEM_no_hit), 					//input wire [0:0] 		*
    .IMEM_Addr(IMEM_Addr), 						//output wire [31:0]		*
    .IMEM_Dout(IMEM_Dout), 						//input wire [31:0]		*
    .IMEM_no_hit(IMEM_no_hit), 					//output reg [0:0]		*
    .PC_IF(PC_IF), 									//output reg [31:0]		*
    .IR(IR),												//output reg [31:0]		*
	.LOAD_happened(LOAD_happened)
    );
	 
//////CPU ID/////////	 
CPU_ID ID_stage (
    .clk(clk), 										//input wire [0:0] 		*
	.rst(rst),
    .PC_IF(PC_IF), 									//input wire [31:0] 		*
    .IR(IR), 											//input wire [31:0]		*
    .ALU_input_sel_Ra1(ALU_input_sel_Ra1), 	//output reg [0:0]		*
    .ALU_input_sel_Rb1(ALU_input_sel_Rb1), 	//output reg [1:0]		*
    .ALU_input_sel_Ra2(ALU_input_sel_Ra2), 	//output reg [0:0]		*
    .ALU_input_sel_Rb2(ALU_input_sel_Rb2), 	//output reg [1:0] 		*
    .PC_ID(PC_ID), 									//output reg [31:0]		*
    .COND(COND), 										//output reg [3:0] 		*
    .ALU1_op(ALU1_op), 								//output reg [4:0]		*
    .ALU_Ra1(ALU_Ra1), 								//output reg [4:0]		*
    .ALU_Rb1(ALU_Rb1), 								//output reg [4:0]		*
    .ALU_Imm1(ALU_Imm1), 							//output reg [31:0]		*
    .ALU2_op(ALU2_op), 								//output reg [4:0]		*
    .ALU_Ra2(ALU_Ra2), 								//output reg [4:0]		*
    .ALU_Rb2(ALU_Rb2), 								//output reg [4:0]		*
    .ALU_Imm2(ALU_Imm2), 							//output reg [31:0]		*
    .ALU_Rd1_WB_sel(ALU_Rd1_WB_sel), 			//output reg [4:0]		*
    .ALU_Rd1_WB_en(ALU_Rd1_WB_en), 				//output reg [0:0]		*
    .ALU_Rd2_WB_sel(ALU_Rd2_WB_sel), 			//output reg [4:0]		*
    .ALU_Rd2_WB_en(ALU_Rd2_WB_en), 				//output reg [0:0]		*
    .ALU_FLAG_WB_en(ALU_FLAG_WB_en), 			//output reg [0:0]		*
    .DMEM_Control_sel(DMEM_Control_sel), 		//output reg [1:0]		*
    .DMEM_ID_WE(DMEM_ID_WE), 						//output reg [0:0]		*
    .DMEM_Data_sel(DMEM_Data_sel), 				//output reg [0:0]		*
    .Rd_DMEM(Rd_DMEM), 								//output reg [3:0]		*
    .JUMP_sel(JUMP_sel), 							//output reg [2:0]		*
    .JUMP_R_sel(JUMP_R_sel), 						//output reg [3:0] 		*
    .LOAD_EN(LOAD_EN),								//output reg [0:0]		*
	.LOAD_happened(LOAD_happened),
	.DMEM_no_hit(DMEM_no_hit)
    );



//////CPU EX/////////
CPU_EX EX_stage (
    .clk(clk), 										//input wire [0:0] 		*
	.rst(rst),
    .ALU_input_sel_Ra1(ALU_input_sel_Ra1), 	//input wire [0:0]		*
    .ALU_input_sel_Rb1(ALU_input_sel_Rb1), 	//input wire [1:0]		*
    .ALU_input_sel_Ra2(ALU_input_sel_Ra2), 	//input wire [0:0]		*
    .ALU_input_sel_Rb2(ALU_input_sel_Rb2), 	//input wire [1:0]		*
    .PC_ID(PC_ID), 									//input wire [31:0]		*
    .COND(COND), 										//input wire [3:0]		*
    .ALU1_op(ALU1_op), 								//input wire [4:0]		*
    .ALU_Ra1(ALU_Ra1), 								//input wire [4:0]		*
    .ALU_Rb1(ALU_Rb1), 								//input wire [4:0]		*
    .ALU_Imm1(ALU_Imm1), 							//input wire [31:0]		*
    .ALU2_op(ALU2_op), 								//input wire [4:0]		*
    .ALU_Ra2(ALU_Ra2), 								//input wire [4:0]		*
    .ALU_Rb2(ALU_Rb2), 								//input wire [4:0]		*
    .ALU_Imm2(ALU_Imm2), 							//input wire [31:0]		*
    .ALU_Rd1_WB_sel(ALU_Rd1_WB_sel), 			//input wire [4:0]		*
    .ALU_Rd1_WB_en(ALU_Rd1_WB_en), 				//input wire [0:0]		*
    .ALU_Rd2_WB_sel(ALU_Rd2_WB_sel), 			//input wire [4:0]		*
    .ALU_Rd2_WB_en(ALU_Rd2_WB_en), 				//input wire [0:0]		*
    .ALU_FLAG_WB_en(ALU_FLAG_WB_en), 			//input wire [0:0]		*
    .DMEM_Control_sel(DMEM_Control_sel), 		//input wire [1:0]		*
    .DMEM_ID_WE(DMEM_ID_WE), 						//input wire [0:0]		*
    .DMEM_Data_sel(DMEM_Data_sel), 				//input wire [0:0]		*
    .Rd_DMEM(Rd_DMEM), 								//input wire [3:0]		*
    .JUMP_sel(JUMP_sel), 							//input wire [2:0]		*
    .JUMP_R_sel(JUMP_R_sel), 						//input wire [3:0] 		*
    .DMEM_DATA_WB_w(DMEM_DATA_WB_w), 			//input wire [31:0]		*
    .DMEM_Base_Addr(DMEM_Base_Addr), 			//input wire [31:0]		*
    .DMEM_High_Addr(DMEM_High_Addr), 			//input wire [31:0]		*
    .LOAD_EN(LOAD_EN), 								//input wire [0:0]		*
    .DMEM_WE(DMEM_WE), 								//output reg [0:0]		*
    .DMEM_Addr(DMEM_Addr), 						//output reg [31:0]		*
    .DMEM_Data(DMEM_Data), 						//output reg [31:0] 		*
    .DMEM_no_hit(DMEM_no_hit), 					//output reg [0:0] 		*
    .IMEM_no_hit(IMEM_no_hit), 					//input wire [0:0]		*
    .R17(PC), 											//output [31:0]//PC   	* 
    .R19(output_device_value), 					//output [31:0]//output device value
    .R20(output_data_value), 						//output [31:0]//output data value 
    .R21(input_device_value), 					//input [31:0]//input device value 
    .R22(input_data_value) 						//input [31:0]//input data value
    );


//////CPU MEM////////
CPU_MEM MEM_stage (
    .clk(clk), 										//input wire [0:0] 	*
	.rst(rst),
    .DMEM_WE(DMEM_WE), 								//input wire [0:0]	*
    .DMEM_Addr(DMEM_Addr), 						//input wire [31:0]	*
    .DMEM_Data(DMEM_Data), 						//input wire [31:0]	*
    .DMEM_no_hit(DMEM_no_hit), 					//input wire [0:0]	*
    .DMEM_DATA_WB_w(DMEM_DATA_WB_w), 			//output wire [31:0]	*
    .DMEM_Base_Addr(DMEM_Base_Addr), 			//output reg [31:0]	*
    .DMEM_High_Addr(DMEM_High_Addr), 			//output reg [31:0] 	*
    .NEED_change_cache(NEED_change_cache), 	//output reg [0:0]
    .NEED_WB_cache(NEED_WB_cache), 				//output reg [0:0]
    .NEED_Base_Addr(NEED_Base_Addr), 			//output reg [31:0]
    .NEED_High_Addr(NEED_High_Addr), 			//output reg [31:0]
    .NEED_Addr(NEED_Addr), 						//input wire [31:0]
    .NEED_Din(NEED_Din), 							//input wire [31:0]
    .NEED_Dout(NEED_Dout), 						//output wire [31:0]
    .NEED_WE(NEED_WE), 								//input wire [0:0] 
    .NEED_Done(NEED_Done)							//input wire [0:0]
    );



//////CPU MCACHE////////


//////CPU ICACHE////////

endmodule
