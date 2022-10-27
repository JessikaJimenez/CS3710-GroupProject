`timescale 1ns/1ns

module tb_datapath #(parameter WIDTH = 16) ();

    reg clk, reset;
    reg pcInstruction, rTypeInstruction;
    reg [1:0] outputSelect;
    reg regWrite, flagSet;
    reg [2:0] aluOp;
    reg pcOverwrite, pcContinue, zeroExtend, memWrite;
    reg storeNextInstruction, luiInstruction, retrieveInstruction;
    wire [WIDTH - 1 : 0] instr; 
    wire [WIDTH - 1 : 0] PC;
    wire [WIDTH - 1 : 0] outputFlags;

    datapath #(WIDTH) datpath(
        clk,
        reset,
        pcInstruction,
        rTypeInstruction,
        outputSelect,
        regWrite,
        flagSet,
        aluOp,
        pcOverwrite,
        pcContinue,
        zeroExtend,
        memWrite,
        storeNextInstruction,
        luiInstruction,
        retrieveInstruction,
        instr,
        PC,
        outputFlags
    );
	 
    initial begin
		clk <= 0;
		reset <= 0;
        pcInstruction <= 0;
        rTypeInstruction <= 0;
        outputSelect <= 2'b00;
        regWrite <= 0;
        flagSet <= 0;
        aluOp <= 3'b000;
        pcOverwrite <= 0;
        pcContinue <= 0;
        zeroExtend <= 0;
        memWrite <= 0;
        storeNextInstruction <= 0;
        luiInstruction <= 0;
        retrieveInstruction <= 0;
        #1000
        reset <= 1;
        #10
        // Fetch first instruction
        retrieveInstruction <= 1;
        pcContinue <= 1;
        #10
        retrieveInstruction <= 0;
        pcContinue <= 0;
        if (instr == 16'hd108)
            $display("MOV instruction correctly read.");
        else
            $display("SOMETHING WENT WRONG");
    end
    // Generate clock
    always #10 begin
        clk = ~clk;
    end

endmodule 
