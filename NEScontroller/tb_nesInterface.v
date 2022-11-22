// TESTBENCH FOR nes Intercase
/*************************************************************/
`timescale 1ns/1ns

module tb_nesInterface #(parameter WIDTH = 16) ();
	
	reg clk;
	reg nesData;
    wire nesClock;
    wire nesLatch;
	 reg [7:0] nesTestData = 0;
	 reg signed [3:0] nesPos = 0;
	 reg [7:0] controllerData;

	// Instantiate modules
	nesInterface UUT (
 	   .clk(clk), //
       .nesData(nesData),
       .nesClock(nesClock),
       .nesLatch(nesLatch),
		 .controllerData(controllerData)
	);
	
	// Start clock and reset
	initial begin
	   clk <= 0;
		nesTestData <= 8'd1;
	end
		
	// Generate clock
	always #10 begin
	   clk = ~clk;
	end
	
	always @(posedge nesClock) begin
		nesData = nesTestData[nesPos];
		nesPos = nesPos + 4'd1;
	end
	
	always @(negedge nesLatch) begin
	   nesPos <= 4'd0;
		nesTestData <= nesTestData + 8'd1;
	end
	
endmodule 
