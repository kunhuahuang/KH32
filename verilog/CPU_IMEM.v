`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 07/09/2014 
// Design Name:    KH32 & KH16
// Module Name:    CPU_IMEM 
// Project Name:   Throughput Processor 
// Description:    This part is the Instruction Memory of the CPU core
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module CPU_IMEM(
input wire [0:0] 		clk,
input wire rst,
////////INPUT from IF///////////
output reg [31:0] 	IMEM_Base_Addr,
output reg [31:0] 	IMEM_High_Addr,
input wire [31:0] 	IMEM_Addr,
output wire [31:0] 	IMEM_Dout,
input wire [0:0] 		IMEM_no_hit,

////////IO to MEM controller//////
output reg[0:0] 			INEED_change_cache,	//Interrupt the Memory controller to change the cache value
output reg [31:0] 			INEED_Base_Addr,
output reg [31:0] 			INEED_High_Addr,
input wire [31:0] 	INEED_Addr,
input wire [31:0] 	INEED_Din,
output wire [31:0] 	INEED_Dout,
input wire [0:0] 		INEED_WE,
input wire [0:0]  	INEED_Done

    );	

//reg [31:0] 	IMEM_Base_Addr = 32'hffffffff;
//reg [31:0] 	IMEM_High_Addr = 32'hffffffff;

//1K Word = 10bit address 
//32 bit data

MEM_1K_word I_Cache(
    .clka(clk), 
    .we1(1'b0), 
    .addr1(IMEM_Addr[9:0]), 
    .din1(32'b0), 
    .dout1(IMEM_Dout), 
	.clkb(clk), 
    .we2(INEED_WE), 
    .addr2(INEED_Addr[9:0]), 
    .din2(INEED_Din), 
    .dout2(INEED_Dout)
    );

always @(posedge clk or negedge rst)
if(!rst)
begin
IMEM_Base_Addr <= 32'hffffffff;
IMEM_High_Addr <= 32'hffffffff;
INEED_change_cache <= 1;	//Interrupt the Memory controller to change the cache value
end
else
begin
	if(IMEM_no_hit)
	begin
		if(INEED_Done)
		begin
			IMEM_Base_Addr <= INEED_Base_Addr;
			IMEM_High_Addr <= INEED_High_Addr;
			INEED_change_cache <= 1'b0;
		end
		else 
		begin
		INEED_change_cache <= 1'b1;
		INEED_Base_Addr 	<=	{IMEM_Addr[31:10],10'b0};
		INEED_High_Addr 	<=	{IMEM_Addr[31:10],10'b1111111111};	
		
		end
	end
	else 
	begin
		INEED_change_cache <= 0;
	end
end
endmodule
