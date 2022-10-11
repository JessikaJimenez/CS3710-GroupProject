// TOP-LEVEL MODULE
/*************************************************************/
// This module acts as a part of the bigger CR-16 Processor System
// Assuming immediate is 16-bit, sign-extended or zero-extended

module ALUandRF #(parameter WIDTH = 16) (
	input clk, reset,
	input [WIDTH - 1 : 0] pc, srcAddr, dstAddr, immd,
	input pcInstruction, rTypeInstruction, shiftInstruction, regWrite,
	input [2:0] aluOp,
	input [3:0] shiftAmount,
	output reg [WIDTH - 1 : 0] resultData,
	output reg [WIDTH - 1 : 0] outputFlags
);

	// Declare variables
	wire carry, low, flag, zero, negative;
	wire [WIDTH - 1 : 0] srcValue, dstValue, aluResult, shiftResult;

	// Registers for muxes
	reg [WIDTH - 1: 0] aluDstInput, aluSrcInput;

	// Instantiate modules
	RegFile rf (
	  .clk(clk), 
	  .reset(reset),
	  .regWrite(regWrite),
	  .sourceAddr(srcAddr), 
	  .destAddr(dstAddr), 
	  .wrData(resultData), 
	  .readData1(srcValue),
	  .readData2(dstValue)
	);

	PSR psr (
	  .clk(clk),
	  .reset(reset),
	  .flags({11'd0, negative, zero, flag, low, carry}),
	  .readFlags(outputFlags)
	);

	ALU aluModule (
	  .regSrc(aluSrcInput),
	  .regDst(aluDstInput),
	  .aluOp(aluOp),
	  .aluResult(aluResult), 
	  .carry(carry), 
	  .low(low), 
	  .flag(flag), 
	  .zero(zero),
	  .negative(negative)
	);

	// For the shifter, we will determine which way to shift based on whether
	//  the shift amount is negative or positive.
	Shifter sb (
	  .reset(reset), 
	  .shiftInput(aluDstInput), 
	  .shiftAmount(shiftAmount), 
	  .rightShift(shiftAmount[3]), 
	  .shiftResult(shiftResult)
	);

	// MUX for instructions that modify program counter
	always @(*) begin
	  if (~reset) aluDstInput <= dstValue;
	  else if (pcInstruction) aluDstInput <= pc;
	  else aluDstInput <= dstValue; 
	end

	// MUX for R-Type instructions
	always @(*) begin
	  if (~reset) aluSrcInput <= srcValue;
	  else if (rTypeInstruction) aluSrcInput <= srcValue;
	  else aluSrcInput <= immd;
	end

	// MUX for shift instructions
	always @(*) begin
	  if (~reset) resultData <= aluResult;
	  else if (shiftInstruction) resultData <= shiftResult;
	  else resultData <= aluResult;
	end

endmodule 
