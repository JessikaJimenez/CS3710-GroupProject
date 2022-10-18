// DATAPATH MODULE
/*************************************************************/
//
// ADD - rTypeInstruction, regWrite, flagSet, 000
// ADDI - regWrite, flagSet, 000
// 
// SUB - rTypeInstruction, regWrite, flagSet, 100
// SUBI - regWrite, flagSet, 100
//
// CMP - rTypeInstruction, flagSet, 100
// CMPI - flagSet, 100
//
// AND - rTypeInstruction, regWrite, 001
// ANDI - regWrite, zeroExtend, 001
//
// OR - rTypeInstruction, regWrite, 010
// ORI - regWrite, zeroExtend, 010
//
// XOR - rTypeInstruction, regWrite, 011
// XORI - regWrite, zeroExtend, 011
//
// MOV - rTypeInstruction, regWrite, copyInstruction
// MOVI - regWrite, zeroExtend, copyInstruction
//
// LSH - rTypeInstruction, regWrite, shiftInstruction
// LSHI - regWrite, shiftInstruction
//
// ASHU - rTypeInstruction, regWrite, shiftInstruction
// ASHUI - regWrite, shiftInstruction
//
// LUI - luiInstruction, copyInstruction
//
// LOAD - 
// STOR -
//
// NEED TO DETERMINE CONDITION CODES
// B - pcInstruction, 000
// J - pcInstruction, copyInstruction
//
// JAL - TO DO
//
module datapath #(parameter WIDTH = 16) ();
    // Inputs and outputs
    input clk, reset;
    input pcInstruction, rTypeInstruction, shiftInstruction, regWrite, flagSet, copyInstruction;
    input [2:0] aluOp;
    input [7:0] eightImmd;
    input pcWrite, zeroExtend, luiInstruction;
    output reg [WIDTH - 1 : 0] PC, nextPC;

    // Declare variables
    reg [WIDTH - 1 : 0] sixteenImmd, immdInput, luiOutput;

    // Instantiate modules
    ALUandRF alurf(
        .clk(clk), 
        .reset(reset),
	    .pc(PC), 
        .immd,
	input [3 : 0] srcAddr, dstAddr,
	    .pcInstruction(pcInstruction), 
        .rTypeInstruction(rTypeInstruction), 
        .shiftInstruction(shiftInstruction), 
        .regWrite(regWrite), 
        .flagSet(flagSet), 
        .copyInstruction(copyInstruction),
	    .aluOp(aluOp),
	output reg [WIDTH - 1 : 0] resultData,
	output wire [WIDTH - 1 : 0] outputFlags
    );

    Shifter LUIShift(
        .reset(reset), 
        .shiftInput(sixteenImmd), 
        .shiftAmount(4'd8), 
        .rightShift(1'b0), 
        .shiftResult(luiOutput)
    );

    // MUX for the next PC instruction
    always @(*) begin
        if (~reset) nextPC <= PC + 1;
        else if (pcInstruction) nextPC <= resultData;
        else nextPC <= PC + 1;
    end

    // Either zero-extend or sign-extend the immediate based on instruction
	always @(*) begin
		if (~reset) sixteenImmd <= 16'd0;
		if (zeroExtend) sixteenImmd <= {8'd0, eightImmd};
		else immd <= {{8{eightImmd[7]}}, eightImmd};
	end
    
    // Flip-flop for the PC
    always @(posedge clk) begin
        if (~reset) PC <= 16'd0;
        else if (pcWrite) PC <= nextPC;
    end

    // Flip-flop for immediate that gets inputted into the ALUandRF
    always @(posedge clk) begin
        if (~reset) immdInput <= sixteenImmd;
        else if (luiInstruction) immdInput <= luiOutput;
        else immdInput <= sixteenImmd;
    end
endmodule
