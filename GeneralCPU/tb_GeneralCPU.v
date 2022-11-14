// TESTBENCH FOR General CPU
/*************************************************************/
`timescale 1ns/1ns

module tb_GenearalCPU #(parameter WIDTH = 16) ();
	
	reg clk, reset;
	reg [WIDTH - 1 : 0] memData;
    reg [WIDTH - 1 : 0] addr;
    reg [WIDTH - 1 : 0] IOinput;
    reg writeEnable;
    wire [WIDTH - 1 : 0] memOutput;
    wire [WIDTH - 1 : 0] IOoutput;

	// Instantiate modules
	GeneralCPU UUT (
 	   .clk(clk), //
	   .reset(reset),//
	   .memData(memData),
	   .addr(addr), //
	   .IOinput(IOinput), //
	   .writeEnable(writeEnable), 
	   .memOutput(memOutput),//
	   .IOoutput(IOoutput) //
	);
	
	// Start clock and reset
	initial begin
	   clk <= 0;
	   reset <= 0;
		#20;
		reset <= 1;
	end
		
	// Generate clock
	always #10 begin
	   clk = ~clk;
	end
		
	initial begin
	   ////////Test for Register File
	   ///TestWriting & Reading
		#20000;
	end
	
endmodule 
