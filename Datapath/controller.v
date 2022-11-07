// CONTROLLER MODULE
/*************************************************************/
// 
// FETCH - retrieveInstruction, pcContinue
// IF DOES NOT WORK, DO THIS
// FETCH1 - retrieveInstruction, LOAD
// FETCH2 - retrieveInstruction, pcContinue
//
// After the instruction is updated...
//
// DECODE - Look at OP CODE
// OP CODE
// 0000 - Look at EXTENDED OP CODE
// 0001 - ANDI -> WRITETOREG
// 0010 - ORI -> WRITETOREG
// 0011 - XORI -> WRITETOREG
// 0100 - Look at EXTENDED OP CODE
// 0101 - ADDI -> WRITEANDSETFLAGS
// 1000 - Look at SHIFTS
// 1001 - SUBI -> [Check OPCODE[1]] -> WRITEANDSETFLAGS
// 1011 - SUBI -> [Check OPCODE[1]] -> ONLYSETFLAGS (CMPI)
// 1100 - [Check Conditions] -> BRANCH -> WRITETOPC
// 1101 - MOVI -> WRITETOREG
// 1111 - LUI -> MEMLOAD -> WRITETOREG
// EXTENDED OP CODE
// 0000 - MOV -> [Check OPCODE[2]] -> MEMLOAD -> WRITETOREG (LOAD)
// 0001 - AND -> WRITETOREG
// 0010 - OR -> WRITETOREG
// 0011 - XOR -> WRITETOREG
// 0100 - MOV -> [Check OPCODE[2]] -> WRITETOMEM (STOR)
// 0101 - ADD -> WRITEANDSETFLAGS
// 1000 - JAL -> JUMP -> WRITETOPC
// 1001 - SUB -> [Check OPCODE[1]] -> WRITEANDSETFLAGS
// 1011 - SUB -> [Check OPCODE[1]] -> ONLYSETFLAGS (CMP)
// 1100 - [Check Conditions] -> JUMP -> WRITETOPC (JUMP)
// 1101 - MOV -> WRITETOREG
// SHIFTS
// 000s - SHFTI -> WRITETOREG (LSHI)
// 001s - SHFTI -> WRITETOREG (ASHUI)
// 0100 - SHFT -> WRITETOREG (LSH)
// 0110 - SHFT -> WRITETOREG (ASHU)
// SPECIAL
//
// [AT THE END OF EACH CHAIN, GO BACK TO FETCH (-> FETCH)]
// 
// SIMPLIFIED STATES
//
// ADD - rTypeInstruction, 000
// ADDI - 000
// |
// v
// WRITEANDSETFLAGS - regWrite, flagSet
//
// SUB - rTypeInstruction, 100
// SUBI - 100
// | OPCODE[1] == 0
// v
// WRITEANDSETFLAGS - regWrite, flagSet
// | OPCODE[1] == 1
// v
// ONLYSETFLAGS - flagSet (CMP and CMPI)
//
// AND - rTypeInstruction, 001
// ANDI - zeroExtend, 001
// OR - rTypeInstruction, 010
// ORI - zeroExtend, 010
// XOR - rTypeInstruction, 011
// XORI - zeroExtend, 011
// MOV - rTypeInstruction, COPY
// MOVI - zeroExtend, COPY
// SHFT - rTypeInstruction, SHIFT
// SHFTI - SHIFT
// |
// v
// WRITETOREG - regWrite
//
// LUI - luiInstruction, SHIFT
// |
// v
// MEMLOAD - LOAD
// |
// v
// WRITETOREG - regWrite
//
// (LOAD)
// MOV - rTypeInstruction, COPY
// | OPCODE[2] == 0
// v
// MEMLOAD - LOAD
// |
// v
// WRITETOREG - regWrite
// 
// (STOR)
// MOV - rTypeInstruction, COPY
// | OPCODE[2] == 1
// v
// WRITETOMEM - memWrite
//
// [These next two instructions must have passed condition checks before executing]
// BRANCH - pcInstruction, 000
// JUMP - pcInstruction, rTypeInstruction, COPY
// |
// v
// WRITETOPC - pcOverwrite
//
// (JAL)
// JAL - storeNextInstruction, regWrite
// |
// v
// JUMP - pcInstruction, rTypeInstruction, COPY
// |
// v
// WRITETOPC - pcOverwrite
// 
// [At the end of each instruction chain, go back to FETCH]
module controller(input clk, reset,
                  input [3:0] firstOp,
                  input [3:0] extendedOp,
                  input [4:0] flags,
                  output reg [1:0] aluOp,
                  output reg [1:0] outputSelect,
                  output reg regWrite, memWrite, luiInstruction, retrieveInstruction,
                             zeroExtend, pcContinue, pcOverwrite, flagSet, rTypeInstruction);
    
    // Parameters for states.
    parameter   FETCH           = 5'b00000;
    parameter   DECODE          = 5'b00001;
    parameter   SPECIALDECODE   = 5'b00010;
    parameter   CONDITIONCHECK  = 5'b00011;
    parameter   PASSCONDITION   = 5'b00100;
    parameter   ADD             = 5'b00101;
    parameter   ADDI            = 5'b00110;
    parameter   SUB             = 5'b00111;
    parameter   SUBI            = 5'b01000;
    parameter   AND             = 5'b01001;
    parameter   ANDI            = 5'b01010;
    parameter   OR              = 5'b01011;
    parameter   ORI             = 5'b01100;
    parameter   XOR             = 5'b01101;
    parameter   XORI            = 5'b01110;
    parameter   MOVI            = 5'b01111;
    parameter   SHFT            = 5'b10000;
    parameter   SHFTI           = 5'b10001;
    parameter   MOV             = 5'b10010;
    parameter   LUI             = 5'b10011;
    parameter   MEMLOAD         = 5'b10100;
    parameter   BRANCH          = 5'b10101;
    parameter   JAL             = 5'b10110;
    parameter   JUMP            = 5'b10111;
    parameter   WRITEANDSETFLAGS = 5'b11000;
    parameter   ONLYSETFLAGS    = 5'b11001;
    parameter   WRITETOREG      = 5'b11010;
    parameter   WRITETOMEM      = 5'b11011;
    parameter   WRITETOPC       = 5'b11100;

    // Parameters for condition codes
    parameter EQ    = 4'b0000;
    parameter NE    = 4'b0001;
    parameter CS    = 4'b0010;
    parameter CC    = 4'b0011;
    parameter HI    = 4'b0100;
    parameter LS    = 4'b0101;
    parameter GT    = 4'b0110;
    parameter LE    = 4'b0111;
    parameter FS    = 4'b1000;
    parameter FC    = 4'b1001;
    parameter LO    = 4'b1010;
    parameter HS    = 4'b1011;
    parameter LT    = 4'b1100;
    parameter GE    = 4'b1101;
    parameter UC    = 4'b1110;
    parameter NJ    = 4'b1111;

    reg [4:0] state, nextstate; 

    // Assign flag bits for checking
    wire negative, zero, flag, low, carry;
    assign negative = flags[4];
    assign zero = flags[3];
    assign flag = flags[2];
    assign low = flags[1];
    assign carry = flags[0];

    // state register
    always @(posedge clk)
      if(~reset) state <= FETCH;
      else state <= nextstate;

    // next state logic (combinational)
    always @(*)
      begin
         case(state)
            FETCH:  nextstate <= DECODE;
            DECODE:  case(firstOp)
                        0000: nextstate <= SPECIALDECODE; // R-Type Instructions
                        0001: nextstate <= ANDI;
                        0010: nextstate <= ORI;
                        0011: nextstate <= XORI;
                        0100: begin
                                if (extendedOp[2]) nextstate <= SHFT; // LSH, ASHU
                                else nextstate <= SHFTI; // LSHI, ASHUI 
                            end
                        0101: nextstate <= ADDI;
                        1000: nextstate <= SPECIALDECODE; // Special Instructions
                        1001: nextstate <= SUBI;
                        1011: nextstate <= SUBI;
                        1100: nextstate <= CONDITIONCHECK;
                        1101: nextstate <= MOVI;
                        1111: nextstate <= LUI;
                        default: nextstate <= FETCH; // should never happen
                     endcase
            SPECIALDECODE: case(extendedOp)
                            0000: nextstate <= MOV; // LOAD
                            0001: nextstate <= AND;
                            0010: nextstate <= OR;
                            0011: nextstate <= XOR;
                            0100: nextstate <= MOV; // STOR
                            0101: nextstate <= AND;
                            1000: nextstate <= JAL;
                            1001: nextstate <= SUB;
                            1011: nextstate <= SUB;
                            1100: nextstate <= CONDITIONCHECK;
                            1101: nextstate <= MOV;
                            default: nextstate <= FETCH; // should never happen
                        endcase
            CONDITIONCHECK: case(cond)
                                EQ: begin
                                        if (zero) // EQUAL (EQ)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                NE: begin
                                        if (!zero) // NOT EQUAL (NE)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                CS: begin
                                        if (carry) // CARRY SET (CS)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                CC: begin
                                        if (!carry) // CARRY CLEAR (CC)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                HI: begin
                                        if (low) // HIGHER THAN (HI)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                LS: begin
                                        if (!low) // LOWER THAN OR SAME AS (LS)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                GT: begin
                                        if (negative) // GREATER THAN (GT)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                LE: begin
                                        if (!negative) // LESS THAN OR EQUAL (LE)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                FS: begin
                                        if (flag) // FLAG SET (FS)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                FC: begin
                                        if (!flag) // FLAG CLEAR (FC)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                LO: begin
                                        if (!low && !zero) // LOWER THAN (LO)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                HS: begin
                                        if (low || zero) // HIGHER THAN OR SAME AS (HS)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                LT: begin
                                        if (!negative && !zero) // LESS THAN (LT)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                GE: begin
                                        if (negative || zero) // GREATER THAN OR EQUAL (GE)
                                            nextstate <= PASSCONDITION;
                                        else
                                            nextstate <= FETCH;
                                    end
                                UC: nextstate <= PASSCONDITION; // UNCONDITIONAL (UC)
                                NJ: nextstate <= FETCH; // NEVER JUMP ()
                                default: nextstate <= FETCH; // should never happen
                            endcase
            PASSCONDITION: begin
                            if (opCode[3]) nextstate <= BRANCH;
                            else nexstate <= JUMP;
                        end
            ADD: nextstate <= WRITEANDSETFLAGS;
            ADDI: nextstate <= WRITEANDSETFLAGS;
            SUB: begin
                    if (extendedOp[1]) nextstate <= ONLYSETFLAGS; // CMP
                    else nextstate <= WRITEANDSETFLAGS; // SUB
                end
            SUBI: begin
                    if (opCode[1]) nextstate <= ONLYSETFLAGS; // CMPI
                    else nextstate <= WRITEANDSETFLAGS; // SUBI
                end
            AND: nextstate <= WRITETOREG;
            ANDI: nextstate <= WRITETOREG;
            OR: nextstate <= WRITETOREG;
            ORI: nextstate <= WRITETOREG;
            XOR: nextstate <= WRITETOREG;
            XORI: nextstate <= WRITETOREG;
            MOVI: nextstate <= WRITETOREG;
            SHFT: nextstate <= WRITETOREG;
            SHFTI: nextstate <= WRITETOREG;
            MOV: begin
                    if (opCode == 4'b0000) nextstate <= WRITETOREG; // MOV
                    else begin
                        if (extendedOp[2]) nextstate <= WRITETOMEM; // STOR
                        else nextstate <= MEMLOAD; // LOAD
                    end
                end
            LUI: nextstate <= MEMLOAD;
            MEMLOAD: nextstate <= WRITETOREG;
            BRANCH: nextsate <= WRITETOPC;
            JAL: nextstate <= JUMP;
            JUMP: nextstate <= WRITETOPC;
            WRITEANDSETFLAGS: nextstate <= FETCH;
            ONLYSETFLAGS: nextstate <= FETCH;
            WRITETOREG: nextstate <= FETCH;
            WRITETOMEM: nextstate <= FETCH;
            WRITETOPC: nextstate <= FETCH;
            default: nextstate <= FETCH1; // should never happen
         endcase
      end

endmodule
