module controller(input clk, reset,
                  input [3:0] opCode
                  output [1:0] aluOp);

endmodule

module aluControl(input [2:0] aluOp
                  input [3:0] extendedOp
                  output reg [2:0] aluControl);
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