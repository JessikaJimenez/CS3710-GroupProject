// SHIFTER MODULE
/*************************************************************/
// This module will shift an input a desired amount of bits
module Shifter #(parameter INPUTWIDTH = 16, parameter OUTPUTWIDTH = 16) 
    (reset, shiftInput, shiftAmount, rightShift, shiftResult);
    input reset;
    input [INPUTWIDTH - 1 : 0] shiftInput;
    input unsigned [3 : 0] shiftAmount;
    input rightShift; // Flag for determining left or right shift
    output reg [OUTPUTWIDTH - 1 : 0] shiftResult;

    always @(*) begin
        if (!reset) shiftResult <= shiftInput;
        else if (rightShift) shiftResult <= (shiftInput >> shiftAmount);
        else shiftResult <= (shiftInput << shiftAmount);
    end
endmodule
