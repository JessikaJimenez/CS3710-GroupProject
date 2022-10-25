// DATAPATH MODULE
/*************************************************************/
// 
// ADDEX - rTypeInstruction, 000
// ADDWR - regWrite, flagSet
//
// ADDIEX - 000
// ADDIWR - regWrite, flagSet
// 
// SUBEX - rTypeInstruction, 100
// SUBWR - regWrite, flagSet
//
// SUBIEX - 100
// SUBIWR - regWrite, flagSet
//
// CMPEX - rTypeInstruction, 100
// CMPWR - flagSet
//
// CMPIEX - 100
// CMPIWR - flagSet
//
// ANDEX - rTypeInstruction, 001
// ANDWR - regWrite
//
// ANDIEX - zeroExtend, 001
// ANDIWR - regWrite
//
// OREX - rTypeInstruction, 010
// ORWR - regWrite
//
// ORIEX - zeroExtend, 010
// ORIWR - regWrite
//
// XOREX - rTypeInstruction, 011
// XORWR - regWrite
//
// XORIEX - zeroExtend, 011
// XORIWR - regWrite
//
// MOVEX - rTypeInstruction, COPY
// MOVWR - regWrite
//
// MOVIEX - zeroExtend, COPY
// MOVIWR - regWrite
//
// LSHEX - rTypeInstruction, SHIFT
// LSHWR - regWrite
//
// LSHIEX - SHIFT
// LSHIWR - regWrite
//
// ASHUEX - rTypeInstruction, SHIFT
// ASHUWR - regWrite
//
// ASHUIEX - SHIFT
// ASHUIWR - regWrite
//
// LUI -
// LOAD - 
// STOR -
//
// NEED TO DETERMINE CONDITION CODES
// BEX - pcInstruction, 000
// BWR - pcOverwrite
//
// JEX - pcInstruction, rTypeInstruction, COPY
// JWR - pcOverwrite
//
// JAL
// NEXTINSTREX - NEXTINSTRUCTION
// NEXTINSTRWR - regWrite
// JEX - pcInstruction, rTypeInstruction, COPY
// JWR - pcOverwrite
// 
//
module datapath #(parameter WIDTH = 16) (
    // Inputs and outputs
    input clk, reset, 
    input pcInstruction, // RDst or PC
	input rTypeInstruction, // Rsrc or Immediate
    input [1:0] outputSelect, // Determines output that gets written (ALU, SHIFT, COPY, STORE)
    input regWrite, // Write output to Rdst
	input flagSet, // Set flags
    input [2:0] aluOp, // Which operation to execute on ALU
    input pcOverwrite, // The next PC should be the output
	input pcContinue, // The PC should increment
	input zeroExtend, // Immediate is zero extended or sign extended
	input luiInstruction, // TO DO
    output reg [WIDTH - 1 : 0] instr, // The current instruction retrieved from memory
    output reg [WIDTH - 1 : 0] PC, // The program counter
    output wire [WIDTH - 1 : 0] outputFlags // The current flags set
);

    // Define parameters
    parameter ALURESULT = 2'b00;
    parameter SHIFTRESULT = 2'b01;
    parameter COPYSRC = 2'b10;
    parameter STORENEXTINSTRUCTION = 2'b11;

    // Declare variables
    wire [3:0] srcAddr, dstAddr; // Addresses of source and destination registers
    wire carry, low, flag, zero, negative; // Flags of ALU
    wire [WIDTH - 1 : 0] srcValue, dstValue; // Values read from register file
    wire [WIDTH - 1 : 0] aluResult, shiftResult, luiOutput; // Results of ALU and Shifters
    reg [WIDTH - 1 : 0]  immd; // Immediate retrieved from instruction
    reg [WIDTH - 1: 0] aluDstInput, aluSrcInput; // Inputs into the ALU
    reg [WIDTH - 1 : 0] inputFlags; // The current flags of the system
    reg [WIDTH - 1 : 0] resultMUXData, memData; // The result that gets written into a register
	reg [WIDTH - 1 : 0] nextPC; // Register used to overwrite the PC


    // Instantiate modules
    // ALUandRF alurf(
    //     .clk(clk), 
    //     .reset(reset),
	//     .pc(PC), 
    //     .immd(immdInput),
	//     .srcAddr(srcAddr), 
    //     .dstAddr(dstAddr),
	//     .pcInstruction(pcInstruction), 
    //     .rTypeInstruction(rTypeInstruction), 
    //     .shiftInstruction(shiftInstruction), 
    //     .regWrite(regWrite), 
    //     .flagSet(flagSet), 
    //     .copyInstruction(copyInstruction),
	//     .aluOp(aluOp),
	// output wire resultData(aluOutput),
	// output wire [WIDTH - 1 : 0] outputFlags
    // );

    // Instantiate modules
    RegFile rf (
	  .clk(clk), 
	  .reset(reset),
	  .regWrite(regWrite),
	  .sourceAddr(srcAddr), 
	  .destAddr(dstAddr), 
	  .wrData(memData), 
	  .readData1(dstValue),
	  .readData2(srcValue)
    );

    // Flag register file
    PSR psr (
	  .clk(clk),
	  .reset(reset),
	  .flags(inputFlags),
          .flagSet(flagSet),
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

    // Memory module
	memoryMap mp (

	);

    // Set address bits for registers
    assign dstAddr = instruction[11:8];
    assign srcAddr = instruction[3:0];

    /* FLIP FLOPS */
    // Flip-flop for the PC
    always @(posedge clk) begin
        if (~reset) PC <= 16'd0;
        else PC <= nextPC;
    end

    // Flip-Flop for the output that goes into the register file
    always @(posedge clk) begin
        if (~reset) memData <= 16'd0;
        else memData <= resultMUXData;
    end

    // Flip-Flop for flags
    always @(posedge clk) begin
	if (~reset) inputFlags <= 16'd0;
	else inputFlags <= {11'd0, negative, zero, flag, low, carry};
    end

    /* MUX */
    // MUX for instructions that modify PC or Rdest
    always @(*) begin
	  if (~reset) aluDstInput <= dstValue;
	  else if (pcInstruction) aluDstInput <= PC;
	  else aluDstInput <= dstValue; 
    end

    // MUX for the next PC instruction
    always @(*) begin
        if (~reset) nextPC <= PC;
        else if (pcContinue) nextPC <= PC + 1;
        else if (pcOverwrite) nextPC <= memData;
        else nextPC <= PC;
    end

    // MUX for R-Type instructions
    always @(*) begin
	  if (~reset) aluSrcInput <= srcValue;
	  else if (rTypeInstruction) aluSrcInput <= srcValue;
	  else aluSrcInput <= immd;
    end

    // Either zero-extend or sign-extend the immediate based on instruction type
    always @(*) begin
	  if (~reset) immd <= 16'd0;
	  else if (zeroExtend) immd <= {8'd0, instruction[7:0]};
	  else immd <= {{8{instruction[7]}}, instruction[7:0]};
    end

    // MUX for data that goes into the register file
    // Will either output the alu, shifter, value for the source, or PC + 1
    always @(*) begin
	  if (~reset) resultMUXData <= aluResult;
          case (outputSelect) 
              ALURESULT: resultMUXData <= aluResult;
              SHIFTRESULT: resultMUXData <= shiftResult;
              COPYSRC: resultMUXData <= aluSrcInput;
              STORENEXTINSTRUCTION: resultMUXData <= PC + 1;
          endcase
    end
	
endmodule
