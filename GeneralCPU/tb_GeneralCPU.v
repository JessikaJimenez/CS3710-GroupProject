// TESTBENCH FOR General CPU
/*************************************************************/
`timescale 1ns/1ns

module tb_GeneralCPU #(parameter WIDTH = 16) ();
	
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
	   memData <= 16'd0;
	   addr <= 16'd0;
	   IOinput <= 16'd0;
	   writeEnable <= 16'd0;
		#100;
		reset <= 1;
		#10
		integer[15:0] i;
		for (i = 0; i < 128; i++) begin
			#10
			IOinput <= i;
		end
		
		for (i = -1; i >= -128; i--) begin
			#10
			IOinput <= i;
		end
	end
		
	// Generate clock
	always #10 begin
	   clk = ~clk;
	end
	
endmodule 
