module controller(input clk, reset,
                  input [3:0] opCode,
                  output reg [1:0] aluOp,
                  output reg [1:0] outputSelect,
                  output reg regWrite, memWrite, luiInstruction, retrieveInstruction,
                             zeroExtend, pcContinue, pcOverwrite, flagSet, rTypeInstruction));
        //Parameters for states.
    parameter   FETCH     =  5'b00000;
    parameter   DECODE    =  5'b00001;
    parameter   SPECIALEX =  5'b00010;
    parameter   RTYPEEX   =  5'b00011;
    parameter   SHIFTEX   =  5'b00100;
    parameter   SUBCMPIEX =  5'b00101;
    parameter   ORIEX     =  5'b00110;
    parameter   XORIEX    =  5'b00111;
    parameter   ADDIEX    =  5'b01000;
    parameter   ANDIEX    =  5'b01001;
    parameter   MOVIEX    =  5'b01010;
    parameter   LUIEX     =  5'b01011;
    parameter   LOADEX    =  5'b01100;
    parameter   STOREX    =  5'b01101;
    parameter   FLGSET    =  5'b01110;
    parameter   REGWR     =  5'b01111;
    parameter   REGWRFLAG =  5'b10000;
    parameter   MEMWR     =  5'b10001;

        //Parameters for instruction types (opCode).
    parameter   RTYPE     =  4'b0000;
    parameter   ADDI      =  4'b0101;
    parameter   SUBI      =  4'b1001;
    parameter   CMPI      =  4'b1011;
    parameter   ANDI      =  4'b0001;
    parameter   ORI       =  4'b0010;
    parameter   XORI      =  4'b0011;
    parameter   MOV       =  4'b1101;
    parameter   SHIFT     =  4'b1000;
    parameter   LUI       =  4'b1111;
    parameter   SPECIAL   =  4'b0100;
    parameter   BCOND     =  4'b1100;

    reg [4:0] state, nextstate; 

    // state register
    always @(posedge clk)
      if(~reset) state <= FETCH;
      else state <= nextstate;
      


endmodule

module aluControl(input [2:0] aluOp
                  input [3:0] extendedOp
                  output reg [2:0] aluControl;
    always @(*)
        case(aluOp)
            3'b000: aluControl <= 3'b000;  // add (for lb/sb/addi)
            3'b001: aluControl <= 3'b100;  // sub (for beq/subi/cmpi)
            3'b010: aluControl <= 3'b001;  // and (for andi)
            3'b011: aluControl <= 3'b010;  // or  (for ori)
            3'b100: aluControl <= 3'b011;  // xor (for xori)
            default: case(extendedOp)      // R-Type instructions
                     4'b0101: aluControl <= 3'b000; // add (for add)
                     4'b1001: aluControl <= 3'b100; // subtract (for sub)
                     4'b1011: aluControl <= 3'b100; // subtract (for cmp)
                     4'b0001: aluControl <= 3'b001; // logical and (for and)
                     4'b0010: aluControl <= 3'b010; // logical or (for or)set on less (for slt)
                     4'b0011: aluControl <= 3'b011; // logical xor (for xor)
                     4'b1101: aluControl <= 3'bxxx; //Mov - Need to decide how to pass straight to aluOutput!!!---
                     default: aluControl <= 3'b101; // should never happen
                     endcase
        endcase
endmodule