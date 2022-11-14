// DATAPATH MODULE
/*************************************************************/
// 
// FETCH - retrieveInstruction, pcContinue
// IF DOES NOT WORK, DO THIS
// FETCH1 - retrieveInstruction, LOAD
// FETCH2 - retrieveInstruction, pcContinue
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
// LUIEX - luiInstruction, SHIFT
// LUIREAD - LOAD
// LUIWR - regWrite
//
// LADR - rTypeInstruction, COPY
// LREAD - LOAD
// LWR - regWrite
// 
// SADR - rTypeInstruction, COPY
// SWR - memWrite
//
// CONDITION CODES CHECKED OUTSIDE OF DATAPATH
//
// BEX - pcInstruction, 000
// BWR - pcOverwrite
//
// JEX - pcInstruction, rTypeInstruction, COPY
// JWR - pcOverwrite
//
// JAL
// SAVENEXTINSTRUCTION - storeNextInstruction, regWrite
// |
// v
// JEX - pcInstruction, rTypeInstruction, COPY
// JWR - pcOverwrite
// 
module datapath #(parameter WIDTH = 16) (
   // DATAPATH
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
   input memWrite, // Flag to write to memory
   input storeNextInstruction, // Flag to store next instruction in register
   input luiInstruction, // Flag to make output an 8-bit left shifted immediate
   input retrieveInstruction, // Flag to get new instruction from memory
	
   // MEMORY ACCESS FOR PORT B
   input [WIDTH - 1 : 0] writeDataB, // Data to write to Port B
   input [WIDTH - 1 : 0] addrDataB, // Address on Port B
   input [WIDTH - 1 : 0] ioInput, // Input data from I/O space
   input writeEnB, // Flag to write to port B
	
   // DATAPATH
   output reg [WIDTH - 1 : 0] instruction, // The current instruction retrieved from memory
   output wire [WIDTH - 1 : 0] outputFlags, // The current flags set

   // MEMORY ACCESS FOR PORT B
   output wire [WIDTH - 1 : 0] readDataB, // Data read from Port B

   // OUTPUT OF CPU FOR IO SPACE
   output wire [WIDTH - 1 : 0] ioOutput // Output of I/O Space
);

   // Define parameters
   parameter ALURESULT = 2'b00;
   parameter SHIFTRESULT = 2'b01;
   parameter COPYSRC = 2'b10;
   parameter LOADINSTRUCTION = 2'b11;

   // Declare variables
   wire [3:0] srcAddr, dstAddr; // Addresses of source and destination registers
   wire carry, low, flag, zero, negative; // Flags of ALU
   wire [WIDTH - 1 : 0] srcValue, dstValue; // Values read from register file
   wire [WIDTH - 1 : 0] aluResult, shiftResult; // Results of ALU and Shifters
   wire [WIDTH - 1 : 0] readOutput; // What is read from memory
   wire [WIDTH - 1 : 0] luiImmd; // 8-bit left shifted immediate
   reg [WIDTH - 1 : 0] dataWriteToReg; // What gets written into the register file
   reg [WIDTH - 1 : 0]  immd; // Immediate retrieved from instruction
   reg [WIDTH - 1: 0] aluDstInput, aluSrcInput; // Inputs into the ALU
   reg [WIDTH - 1 : 0] inputFlags; // The current flags of the system
   reg [WIDTH - 1 : 0] resultMUXData, outputReg; // The result of this datapath
   reg [WIDTH - 1 : 0] nextPC; // Register used to overwrite the PC
   reg [WIDTH - 1 : 0] shiftReg; // Necessary to use shifter or LUI shift
   reg [WIDTH - 1 : 0] readAddr; // Register used to read from memory
   reg [WIDTH - 1 : 0] PC; // Register used to find place in instruction set

   // Instantiate modules
   RegFile rf (
	  .clk(clk), 
	  .reset(reset),
	  .regWrite(regWrite),
	  .sourceAddr(srcAddr), 
	  .destAddr(dstAddr), 
	  .wrData(dataWriteToReg), 
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
	  .data_b(writeDataB),
	  .addr_b(addrDataB),
	  .write_b(writeEnB),
	  .ReadDataB(readDataB),
	  .InputData(ioInput),
	  .data_a(dstValue),
	  .addr_a(readAddr),
	  .write_a(memWrite),
	  .ReadDataA(readOutput),
	  .ioOutputData(ioOutput),
     .clk(clk),
     .reset(reset)
	);

    // Set address bits for registers
    assign dstAddr = instruction[11:8];
    assign srcAddr = instruction[3:0];
	
   // 8-Bit left shit for LUI instructions
   assign luiImmd = immd << 8;

    /* FLIP FLOPS */
    // Flip-flop for the PC
    always @(posedge clk) begin
        if (~reset) PC <= 16'd0;
        else PC <= nextPC;
    end

    // Flip-Flop for the output of the datapath that gets stored in registers or memory
    always @(posedge clk) begin
        if (~reset) outputReg <= 16'd0;
        else outputReg <= resultMUXData;
    end

    // Flip-Flop for flags
    always @(posedge clk) begin
	if (~reset) inputFlags <= 16'd0;
	else inputFlags <= {11'd0, negative, zero, flag, low, carry};
    end

   // Latch for instructions
   always @(posedge clk) begin
	if (~reset) instruction <= 16'd0;
	else if (retrieveInstruction) instruction <= readOutput;
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
        else if (pcOverwrite) nextPC <= outputReg;
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

   // MUX for shifting either being the result of the shifter or for LUI instructions
   always @(*) begin
	if (~reset) shiftReg <= shiftResult;
	else if (luiInstruction) shiftReg <= luiImmd;
	else shiftReg <= shiftResult;
   end

    // MUX for the output of the datapath
    // Will either output the alu, shifter, value for the source, or what is read from memory
    always @(*) begin
	  if (~reset) resultMUXData <= aluResult;
          case (outputSelect) 
              ALURESULT: resultMUXData <= aluResult;
              SHIFTRESULT: resultMUXData <= shiftReg;
              COPYSRC: resultMUXData <= aluSrcInput;
              LOADINSTRUCTION: resultMUXData <= readOutput;
          endcase
    end

   // MUX for what is being written into the register file
   // Will either be the output of the datapath or from memory
   always @(*) begin
	if (~reset) dataWriteToReg <= outputReg;
	else if (storeNextInstruction) dataWriteToReg <= PC + 1;
	else dataWriteToReg <= outputReg;
   end

   // MUX for determining if address is output or PC for memory
   always @(*) begin
	if (~reset) readAddr <= outputReg;
	else if (retrieveInstruction) readAddr <= PC;
	else readAddr <= outputReg;
   end
	
endmodule
