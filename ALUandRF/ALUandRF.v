// TOP-LEVEL MODULE
/*************************************************************/
// This module acts as a part of the bigger CR-16 Processor System
// Assuming immediate is 16-bit, sign-extended or zero-extended
// This module will focus on arithmetic and writing to the register file
module ALUandRF #(parameter WIDTH = 16) (
	input clk, reset,
	input [WIDTH - 1 : 0] pc, immd,
	input [3 : 0] srcAddr, dstAddr,
	input pcInstruction, rTypeInstruction, shiftInstruction, regWrite, flagSet, copyInstruction,
	input [2:0] aluOp,
	output reg [WIDTH - 1 : 0] resultData,
	output wire [WIDTH - 1 : 0] outputFlags
);

	// Declare variables
	wire carry, low, flag, zero, negative;
	wire [WIDTH - 1 : 0] srcValue, dstValue, aluResult, shiftResult;

	// Registers for muxes
	reg [WIDTH - 1: 0] aluDstInput, aluSrcInput;
	reg [WIDTH - 1 : 0] inputFlags;

	// Instantiate modules
	RegFile rf (
	  .clk(clk), 
	  .reset(reset),
	  .regWrite(regWrite),
	  .sourceAddr(srcAddr), 
	  .destAddr(dstAddr), 
	  .wrData(resultData), 
	  .readData1(dstValue),
	  .readData2(srcValue)
	);

	PSR psr (
	  .clk(clk),
	  .reset(reset),
	  .flags(inputFlags),
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

	// Shifter module using RSrc/Immd as the amount
	Shifter sb (
	  .reset(reset), 
	  .shiftInput(aluDstInput), 
	  .shiftAmount(aluSrcInput[3 : 0]), 
	  .rightShift(aluSrcInput[4]), 
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

	// MUX for the output of this module
	// If this is a copy instruction (MOV, JAL, Jcond) then the src/immd will be output
	// If this is a shift instruction (LSH, ASHU) then the shifter will be output
	// For anything else, the ALU will be the output
	always @(*) begin
	  if (~reset) resultData <= aluResult;
	  else if (copyInstruction) resultData <= aluSrcInput;
	  else if (shiftInstruction) resultData <= shiftResult;
	  else resultData <= aluResult;
	end

	// Flip-Flop for setting flags
	always @(posedge clk) begin
		if (~reset) inputFlags <= 16'd0;
		else if (flagSet) inputFlags <= {11'd0, negative, zero, flag, low, carry};
	end

endmodule 
