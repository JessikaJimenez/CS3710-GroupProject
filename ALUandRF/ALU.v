// ALU MODULE
/*************************************************************/
// A 16-bit two's complement ALU that will take two registers
// as arguments and output a 16-bit result.
//
// Supports Add, Subtract, And, Or, Xor operations
//
// The ALU also must generate condition flags:
/*
	C - Carry bit (1 if carry UNSIGNED)
	L - Low bit (1 if Rdest < Rsc UNSIGNED)
	F - Flag bit (1 if overflow SIGNED)
	Z - Zero bit (1 if Rdest = Rsc ALWAYS)
	N - Negative bit (1 if Rdest < Rsc SIGNED)
*/
module ALU #(parameter WIDTH = 16) (regSrc, regDst, aluOp, aluResult, carry, low, flag, zero, negative);
	input [WIDTH - 1:0] regSrc, regDst; // Register values to perform arithmetic on
	input[2:0] aluOp; // Operation code (MSB determines add/sub, [1:0] determines operation)
	output reg [WIDTH - 1:0] aluResult; // Result of ALU
	output carry, low, flag, zero, negative;

	wire [WIDTH - 1:0] regSrc2, sum;
	wire sameSign;

	// Sum will be the result of an add or subtract based on the operation code
	assign regSrc2 = aluOp[2] ? ~regSrc:regSrc; 
	assign sum = regDst + regSrc2 + aluOp[2];
	assign sameSign = regDst[WIDTH-1] == regSrc[WIDTH-1];

	// PSR Flags
	assign carry = aluOp[2] ? (regDst<regSrc):(sum<regDst);
	assign zero = aluResult == 0;
	assign low = regDst < regSrc; 
	assign flag = aluOp[2] ? (!sameSign&&(regSrc[WIDTH-1]==sum[WIDTH-1])):(sameSign&&(sum[WIDTH-1]!=regDst[WIDTH-1])); 
	assign negative = ((regDst < regSrc) && sameSign)||(regDst[WIDTH - 1] == 1'b1); 

	always@(*) begin
		case(aluOp[1:0])
			2'b00: aluResult <= sum; // Add/Sub
			2'b01: aluResult <= regDst & regSrc; // Logical And
			2'b10: aluResult <= regDst | regSrc; // Logical Or
			2'b11: aluResult <= regDst ^ regSrc; // Logical Xor
		endcase
	end

endmodule
