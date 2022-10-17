// TESTBENCH FOR ALU AND REGISTER FILE
/*************************************************************/
`timescale 1ns/1ns

module tb_ALUandRF #(parameter WIDTH = 16) ();

	reg clk, reset;
	reg [WIDTH - 1 : 0] pc, srcAddr, dstAddr, immd;
	reg pcInstruction, rTypeInstruction, shiftInstruction, regWrite;
	reg [2:0] aluOp;
	reg [3:0] shiftAmount;
	wire [WIDTH - 1 : 0] resultData;
	wire [WIDTH - 1 : 0] outputFlags;

	// Instantiate top level module
	ALUandRF #(WIDTH) alurf (
		.clk(clk),
		.reset(reset),
		.pc(pc), 
		.srcAddr(srcAddr), 
		.dstAddr(dstAddr), 
		.immd(immd),
		.pcInstruction(pcInstruction), 
		.rTypeInstruction(rTypeInstruction), 
		.shiftInstruction(shiftInstruction), 
		.regWrite(regWrite),
		.aluOp(aluOp),
		.shiftAmount(shiftAmount),
		.resultData(resultData),
		.outputFlags(outputFlags)
	);	
	
	// Instantiate inputs
	initial begin
		clk <= 0;
		reset <= 0;
		#10;
		clk <= 1;
		#10;
		reset <= 1;
		#10;
		clk <= 0;
		#10;
	end
		
	// Generate clock
	always #10 begin
		clk = ~clk;
	end
	
endmodule 
