// TESTBENCH FOR REGISTER FILE
/*************************************************************/
`timescale 1ns/1ns

module tb_AluRFonBoard #(parameter WIDTH = 16) ();
	
	reg clk, reset;
    reg [3:0] srcAddrSwitches = 4'b0001;
	reg [2:0] aluOp = 3'b000;

	// Instantiate modules
	AluRFonBoard UUT (
 	   .clk(clk), 
	   .reset(reset),
	   .srcAddrSwitches(srcAddrSwitches),
	   .aluOp(aluOp), 
	   .resultDataLeds(resultDataLeds) 
	);
	
	// Instantiate inputs
	initial begin
	   clk <= 0;
	   reset <= 1;
	end
		
	// Generate clock
	always #10 begin
	   clk = ~clk;
	end
		
	initial begin
	   ////////Test for Register File
	   ///TestWriting
	   #40;
       srcAddrSwitches <= 4'b0010;  

	end
	
endmodule 
