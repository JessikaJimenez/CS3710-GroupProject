// ALU MODULE
/*************************************************************/
// A 16-bit two's complement ALU that will take two registers
// as arguments and output a 16-bit result.
//
//	Must support all required instructions:
/*
	ADD
	ADDI
	
	SUB
	SUBI
	
	CMP
	CMPI
	
	AND
	ANDI
	
	OR
	ORI
	
	XOR
	XORI
	
	MOV
	MOVI
	
	LSH
	LSHI
	
	LUI
	LOAD
	STOR
	
	Bcond
	Jcond
	JAL
*/
//
// The ALU also must generate condition flags:
/*
	C - Carry bit (1 if carry UNSIGNED)
	L - Low bit (1 if Rdest < Rsc UNSIGNED)
	F - Flag bit (1 if overflow SIGNED)
	Z - Zero bit (1 if Rdest = Rsc ALWAYS)
	N - Negative bit (1 if Rdest < Rsc SIGNED)
*/

module ALU();

endmodule
