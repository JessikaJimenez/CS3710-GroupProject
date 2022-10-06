// TOP-LEVEL MODULE
/*************************************************************/
// This module acts as a part of the bigger CR-16 Processor System
// Assuming immediate is 16-bit, sign-extended or zero-extended

module ALUandRF #(parameter WIDTH = 16) (clk, reset, pc, srcAddr, dstAddr, immd);
    input clk, reset;
    input [WIDTH - 1 : 0] pc, srcAddr, dstAddr, immd;
    input pcInstruction, rTypeInstruction, shiftInstruction, regWrite;
    input [2:0] aluOp;
    output reg [WIDTH - 1 : 0] resultData;

    // Declare variables
    wire carry, low, flag, zero, negative;
    wire [WIDTH - 1 : 0] srcValue, dstValue, aluResult;

    // Registers for muxes
    reg [WIDTH - 1: 0] aluDstInput, aluSrcInput;

    // Instantiate modules
    regfile rf(.clk(clk), 
        .regWrite(regWrite), 
        .flags({11'd0, negative, zero, flag, low, carry}),
        .regAddr1(srcAddr), 
        .regAddr2(dstAddr), 
        .wrData(resultData), 
        .readData1(srcValue),
        .readData2(dstValue));

    ALU aluModule(.regSrc(aluSrcInput),
        .regDst(aluDstInput),
        .aluOp(aluOp),
        .aluResult(aluResult), 
        .carry(carry), 
        .low(low), 
        .flag(flag), 
        .zero(zero),
        .negative(negative));

    // PLACE FOR SHIFTER

    // MUX for instructions that modify program counter
    always @(*) begin
        if (!reset) aluDstInput <= dstValue;
        else if (pcInstruction) aluDstInput <= pc;
        else aluDstInput <= dstValue; 
    end

    // MUX for R-Type instructions
    always @(*) begin
        if (!reset) aluSrcInput <= srcValue;
        else if (rTypeInstruction) aluSrcInput <= srcValue;
        else aluSrcInput <= immd;
    end

    // MUX for shift instructions
    always @(*) begin
        if (!reset) resultData <= aluResult;
        else if (shiftInstruction) resultData <= 
        else resultData <= aluResult;
    end

endmodule
