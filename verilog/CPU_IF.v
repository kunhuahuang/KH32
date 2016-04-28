`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 07/09/2014 
// Design Name:    KH32 & KH16
// Module Name:    CPU_IF 
// Project Name:   Throughput Processor 
// Description:    This part is the Instruction Fetch of the CPU core
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module CPU_IF(
input wire clk,
input wire rst,
input wire [31:0] PC,
input wire [31:0] IMEM_Base_Addr,
input wire [31:0] IMEM_High_Addr,
input wire [0:0] 	DMEM_no_hit,
output wire [31:0] IMEM_Addr, // 
input wire [31:0] IMEM_Dout,
output reg [0:0] IMEM_no_hit,
output reg [31:0] PC_IF,
output reg [31:0] IR,
input wire [0:0] LOAD_happened

    );
wire IMEM_no_hit_o;
assign 	IMEM_no_hit_o = !((PC >= IMEM_Base_Addr) && (PC <= IMEM_High_Addr));
assign no_hit = IMEM_no_hit | DMEM_no_hit; 
assign IMEM_Addr = PC;
reg [1:0] IF_FLUSH;

always @(posedge clk or negedge rst)
if(!rst)
begin
IMEM_no_hit <= 1'b1;
PC_IF <= 32'b0;
IR <= 32'b0;
IF_FLUSH <= 2'b01;
end
else
begin

	IMEM_no_hit <= IMEM_no_hit_o;
	if(no_hit & LOAD_happened)
	begin	
		IR <= IR;
		PC_IF <= PC_IF;
		IF_FLUSH <= 2'b10;
	end	
	else if((no_hit | LOAD_happened) & (IF_FLUSH!= 2'b10))
	begin	
		IR <= IR;
		PC_IF <= PC_IF;
		IF_FLUSH <= 2'b01;
	end		
	else 
	begin
		if(IMEM_no_hit_o | ( | IF_FLUSH))
		begin
			IR <= ( | IF_FLUSH)? 32'b0 : IR;
			PC_IF <= PC_IF;
			IF_FLUSH <=  IF_FLUSH >> 1;
		end
		else 
		begin
			IR <= IMEM_Dout;
			PC_IF <= PC;
		end
	end
end



endmodule
