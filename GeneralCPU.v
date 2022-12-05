// Top-level module for the "In General" CPU
/*************************************************************/
module GeneralCPU #(parameter WIDTH = 16, parameter ADDR_WIDTH = 7) (
    input clk,                  // 50MHz clock
    input reset,                // active-low reset
    input [WIDTH - 1 : 0] memData,
    input [ADDR_WIDTH - 1 : 0] addr,
    input [WIDTH - 1 : 0] IOinput,
    input writeEnable,
    output [WIDTH - 1 : 0] memOutput,
    output [WIDTH - 1 : 0] IOoutput
    );
        
    wire [15:0] instr;           // 16bit register for holding the instruction
    // Various control and status signals
    wire pcInstruction; // RDst or PC
    wire rTypeInstruction; // Rsrc or Immediate
    wire [1:0] outputSelect; // Determines output that gets written (ALU, SHIFT, COPY, STORE)
    wire regWrite; // Write output to Rdst
    wire flagSet; // Set flags
    wire [2:0] aluOp; // Which operation to execute on ALU
    wire pcOverwrite; // The next PC should be the output
    wire pcContinue; // The PC should increment
    wire zeroExtend; // Immediate is zero extended or sign extended
    wire memWrite; // Flag to write to memory
    wire storeNextInstruction; // Flag to store next instruction in register
    wire luiInstruction; // Flag to make output an 8-bit left shifted immediate
    wire loadPC, retrieveInstruction; // Flags to get new instruction from memory

    // Flags computed by ALU for condition codes
    wire [WIDTH - 1 : 0] outputFlags;
    wire [4:0] flags;
    assign flags = outputFlags[4:0];

   // Instantiate the controller and datapath modules
    controller  cntrl(
        .clk(clk),
        .reset(reset),
        .firstOp(instr[15:12]),
        .condition(instr[11:8]),
        .extendedOp(instr[7:4]),
        .flags(flags),
        .pcInstruction(pcInstruction),
        .rTypeInstruction(rTypeInstruction),
        .outputSelect(outputSelect),
        .regWrite(regWrite),
        .flagSet(flagSet),
        .aluOp(aluOp),
        .pcOverwrite(pcOverwrite),
        .pcContinue(pcContinue),
        .zeroExtend(zeroExtend),
        .memWrite(memWrite),
        .storeNextInstruction(storeNextInstruction),
        .luiInstruction(luiInstruction),
        .retrieveInstruction(retrieveInstruction),
        .loadPC(loadPC)
        );

   datapath  #(.ADDR_WIDTH(ADDR_WIDTH)) dp(
        .clk(clk),
        .reset(reset),
        .pcInstruction(pcInstruction),
        .rTypeInstruction(rTypeInstruction),
        .outputSelect(outputSelect),
        .regWrite(regWrite),
        .flagSet(flagSet),
        .aluOp(aluOp),
        .pcOverwrite(pcOverwrite),
        .pcContinue(pcContinue),
        .zeroExtend(zeroExtend),
        .memWrite(memWrite),
        .storeNextInstruction(storeNextInstruction),
        .luiInstruction(luiInstruction),
        .retrieveInstruction(retrieveInstruction),
        .loadPC(loadPC),
        .instruction(instr),
        .outputFlags(outputFlags),
        .writeDataB(memData),
        .addrDataB(addr),
        .ioInput(IOinput),
        .writeEnB(writeEnable),
        .readDataB(memOutput),
        .ioOutput(IOoutput)
    );
endmodule
