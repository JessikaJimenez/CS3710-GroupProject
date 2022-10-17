// TESTBENCH FOR ALU FILE
/*************************************************************/
`timescale 1ns/1ns

module tb_ALU #(parameter WIDTH = 16) ();
	
	reg [WIDTH - 1:0] regSrc, regDst; // Register values to perform arithmetic on
	reg[2:0] aluOp; // Operation code (MSB determines add/sub, [1:0] determines operation)
	wire [WIDTH - 1:0] aluResult; // Result of ALU
	wire carry, low, flag, zero, negative;

	// Instantiate modules
	ALU aluModule (
	  .regSrc(regSrc),
	  .regDst(regDst),
	  .aluOp(aluOp),
	  .aluResult(aluResult), 
	  .carry(carry), 
	  .low(low), 
	  .flag(flag), 
	  .zero(zero),
	  .negative(negative)
	);
	
	// Instantiate inputs
	initial begin
	   regSrc <= 16'd1;
	   #10
       regDst <= 16'd1;
	   #10
       aluOp <= 3'b000;
       #10
       if (aluResult == 16'd2) $display("Add is correct (%d + %d = %d).", regDst, regSrc, aluResult);
       aluOp <= 3'b100;
       #10
       if (aluResult == 16'd0) $display("Subtract is correct (%d - %d = %d).", regDst, regSrc, aluResult);
       regSrc <= 16'd15;
       #10
       aluOp <= 3'b001;
       #10
       if (aluResult == 16'd1) $display("And is correct (%d & %d = %d).", regDst, regSrc, aluResult);
       aluOp <= 3'b010;
       #10
       if (aluResult == 16'd15) $display("Or is correct (%d | %d = %d).", regDst, regSrc, aluResult);
       aluOp <= 3'b011;
       #10
       if (aluResult == 16'd14) $display("Xor is correct (%d ^ %d = %d).", regDst, regSrc, aluResult);
	   aluOp <= 3'b100;
	   regDst <= 16'b0000000000000011;
	   regSrc <= 16'b0000000000000101;
	   #10
	   if (carry = 1) $display("carry flag is correct");
	   else $display("something is wrong");
	   aluOp <= 3'b000;
	   regDst <= 16'b0000000000000011;
	   regSrc <= 16'b0111111111111101;
	   #10
	   if (carry = 0 && flag = 1) $display("carry/flag flags are correct");
	   else $display("something is wrong");
	end
	
endmodule 
