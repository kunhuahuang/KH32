`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 07/09/2014 
// Design Name:    KH32 & KH16
// Module Name:    CPU_MEM 
// Project Name:   Throughput Processor 
// Description:    This part is the Memory of the CPU core
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module CPU_MEM(
input wire [0:0] 	clk,
input wire rst,
////////INPUT from EX///////////
input wire [0:0] 	DMEM_WE,
input wire [31:0] DMEM_Addr,
input wire [31:0] DMEM_Data,
input wire [0:0] 	DMEM_no_hit,
////////OUTPUT for EX///////////
output wire [31:0] DMEM_DATA_WB_w,


////////OUTPUT DMEM done/////////////
output reg [31:0] DMEM_Base_Addr,
output reg [31:0] DMEM_High_Addr,


////////IO to MEM controller//////
output reg [0:0] 	NEED_change_cache,	//Interrupt the Memory controller to change the cache value
output reg [0:0]  NEED_WB_cache, 		//Write back the cache data
output reg [31:0] NEED_Base_Addr,
output reg [31:0] NEED_High_Addr,
input wire [31:0] NEED_Addr,
input wire [31:0] NEED_Din,
output wire [31:0] NEED_Dout,
input wire [0:0] 	NEED_WE,
input wire [0:0]  NEED_Done

    );	

//1K Word = 10bit address 
//32 bit data

MEM_1K_word D_Cache(
    .clka(~clk), 
    .we1(DMEM_WE), 
    .addr1(DMEM_Addr[9:0]), 
    .din1(DMEM_Data), 
    .dout1(DMEM_DATA_WB_w), 
	.clkb(clk), 
    .we2(NEED_WE), 
    .addr2(NEED_Addr[9:0]), 
    .din2(NEED_Din), 
    .dout2(NEED_Dout)
    );

always @(posedge clk or negedge rst)
if(!rst)
begin
DMEM_Base_Addr <= 32'hffffffff;
DMEM_High_Addr <= 32'hffffffff;
NEED_change_cache <= 1'b1;	//Interrupt the Memory controller to change the cache value
NEED_WB_cache <= 0; 		//Write back the cache data

end
else
begin
	if(DMEM_no_hit)
	begin
		if(NEED_Done)
		begin
			DMEM_Base_Addr <= NEED_Base_Addr;
			DMEM_High_Addr <= NEED_High_Addr;
			NEED_change_cache <= 1'b0;
			NEED_WB_cache 		<= 1'b0;
		end
		else 
		begin
		NEED_change_cache <= 1'b1;
		NEED_Base_Addr 	<=	{DMEM_Addr[31:10],10'b0};
		NEED_High_Addr 	<=	{DMEM_Addr[31:10],10'b1111111111};	
		
		end
	end
	else 
	begin
		NEED_change_cache <= 0;
		NEED_WB_cache <= DMEM_WE | NEED_WB_cache;
	end
end

endmodule
