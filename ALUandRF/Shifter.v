// SHIFTER MODULE
/*************************************************************/
// This module will shift an input a desired amount of bits
module Shifter #(parameter INPUTWIDTH = 16, parameter OUTPUTWIDTH = 16, parameter SHIFTWIDTH = 4) 
    (reset, shiftInput, shiftAmount, rightShift, logicalShift, shiftResult);
    input reset;
    input [INPUTWIDTH - 1 : 0] shiftInput;
    input [SHIFTWIDTH - 1 : 0] shiftAmount;
    input rightShift; // Flag for determining left or right shift
    input logicalShift; // Flag for determining logical or arithmetic shift
    output reg [OUTPUTWIDTH - 1 : 0] shiftResult;

    // We will need to invert shift amount if it is negative
    wire absoluteShiftAmount;
    assign absoluteShiftAmount = -shiftAmount;

    always @(*) begin
        if (!reset) shiftResult <= shiftInput;
        else if (rightShift) begin
            shiftResult <= (shiftInput >> absoluteShiftAmount);
            if (logicalShift) shiftResult[OUTPUTWIDTH - 1] <= 1'b0; // Zero extend
            else shiftResult[OUTPUTWIDTH - 1] <= shiftResult[OUTPUTWIDTH - 2]; // Sign extend
        end
        else shiftResult <= (shiftInput << shiftAmount);
    end
endmodule
