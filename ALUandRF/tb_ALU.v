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
		 
		 //Testing if subtraction borrow is detected and low bit is set and negative bit.
	    aluOp <= 3'b100;
	    regDst <= 16'b0000000000000011;
	    regSrc <= 16'b0000000000000101;
	    #10
	    if (carry == 1 && zero == 0 && low == 1 && flag == 0 && negative == 1) $display("all flags is correct");
	    else $display("1. something is wrong");
		 
		 //Test if overflow (flag) and carry flags are set  
	    aluOp <= 3'b000;
	    regDst <= 16'b0000000000000011;
	    regSrc <= 16'b0111111111111101;
	    #10
	    if (carry == 0 && flag == 1 && zero==0 && low==1) $display("carry/flag flags are correct");
	    else $display("2. something is wrong");
		 
		 //Tests that no carry is detected.
	    aluOp <= 3'b100;
	    regDst <= 16'b0000000000000011;
	    regSrc <= 16'b0000000000000001;
	    #10
	    if (carry == 0) $display("carry flag is correct");
	    else $display("3. something is wrong");

	    aluOp <= 3'b000;
	    regDst <= 16'b0000000000000011;
	    regSrc <= 16'b0000000000000001;
	    #10
	    if (carry == 0) $display("carry flag is correct");
	    else $display("4. something is wrong");
		 
		 //Tests that the negative flag is correctly set when both are negative.
		aluOp <= 3'b100;
	    regDst <= 16'b1111111111111111;
	    regSrc <= 16'b1111111111111110;
	    #10
	    if (negative==0 && carry==0 && zero==0 && low==0 && flag==0) $display("negative flag is correct");
	    else $display("5. something is wrong");

		aluOp <= 3'b100;
	    regDst <= 16'b1111111111111110;
	    regSrc <= 16'b1111111111111111;
	    #10
	    if (negative==1 && carry==1 && zero==0 && low==1 && flag==0) $display("negative flag is correct");
	    else $display("6. something is wrong");
		 
		 //Tests to see if zero flag is set to 1 when the result is zero
		aluOp <= 3'b100;
	    regDst <= 16'b1111111111111110;
	    regSrc <= 16'b1111111111111110;
	    #10
	    if (negative==0 && carry==0 && zero==1 && low==0 && flag==0) $display("zero flag is correct");
	    else $display("7. something is wrong");

		aluOp <= 3'b000;
	    regDst <= 16'b1111111111111110;
	    regSrc <= 16'b1111111111111111;
	    #10
	    if (negative==1 && carry==1 && zero==0 && low==1 && flag==0) $display("carry flag is correct for unsigned addition");
	    else $display("8. something is wrong");

		//Testing to see if 3 + -3 sets zero flag and other flags correctly.
		aluOp <= 3'b000;
	    regDst <= 16'b0000000000000011;
	    regSrc <= 16'b1111111111111101;
	    #10
	    if (negative==0 && carry==1 && zero==1 && low==1 && flag==0) $display("carry/flag/zero flags are correct");
	    else $display("9. something is wrong");
	end
	
endmodule 
