// DATAPATH MODULE
/*************************************************************/
module datapath();
    input clk, reset;

    ALUandRF alurf(
        .clk(clk), 
        .reset(reset),
	input [WIDTH - 1 : 0] pc, immd,
	input [3 : 0] srcAddr, dstAddr,
	input pcInstruction, rTypeInstruction, shiftInstruction, regWrite, flagSet, copyInstruction,
	input [2:0] aluOp,
	output reg [WIDTH - 1 : 0] resultData,
	output wire [WIDTH - 1 : 0] outputFlags)