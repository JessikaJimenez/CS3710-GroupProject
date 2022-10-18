// DATAPATH MODULE
/*************************************************************/
module datapath #(parameter WIDTH = 16) ();
    input clk, reset;
    input pcInstruction, rTypeInstruction, shiftInstruction, regWrite, flagSet, copyInstruction;
    input [2:0] aluOp;
    input pcWrite;
    output reg [WIDTH - 1 : 0] PC, nextPC;

    ALUandRF alurf(
        .clk(clk), 
        .reset(reset),
	input [WIDTH - 1 : 0] pc, immd,
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

    // Flip-flop for the PC
    always @(posedge clk) begin
        if (~reset) PC <= 16'd0;
        else if (pcWrite) PC <= nextPC;
    end

    // MUX for the next PC instruction
    always @(*) begin
        if (~reset) nextPC <= PC + 1;
        else if (pcInstruction) nextPC <= resultData;
        else nextPC <= PC + 1;
    end
endmodule
