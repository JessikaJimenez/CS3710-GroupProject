// TESTBENCH FOR REGISTER FILE
/*************************************************************/
`timescale 1ns/1ns

module tb_RF #(parameter WIDTH = 16) ();
	
	reg clk, reset;
	reg [WIDTH - 1 : 0] srcAddr, dstAddr, writeDataRF;
	reg regWrite;
	reg flags;
	wire [WIDTH - 1 : 0] writeData;
	wire [WIDTH - 1 : 0] outputFlags;
	wire [WIDTH - 1 : 0] srcValue, dstValue;

	// Instantiate modules
	RegFile UUT (
 	   .clk(clk), 
	   .reset(reset),
	   .regWrite(regWrite),
	   .sourceAddr(srcAddr), 
	   .destAddr(dstAddr), 
	   .wrData(writeData), 
	   .readData1(srcValue),
	   .readData2(dstValue)
	);

        PSR psr (
	  .clk(clk),
          .reset(reset),
          .flags(flags),
         .readFlags(outputFlags)
	);
	
	// Instantiate inputs
	initial begin
	   clk <= 0;
	   reset <= 0;
	   #10;
	   clk <= 1;
	   #10;
	   reset <= 1;
	   #10;
	   clk <= 0;
	   #10;
	end
		
	// Generate clock
	always #10 begin
	   clk = ~clk;
	end
		
	initial begin
	   ////////Test for Register File
	   ///TestWriting
	   dstAddr <= 4'b0001;
	   writeDataRF <= 16'b0000000000000001;
	   regWrite <= 1;
	   #10;
	   dstAddr <= 4'b0010;
	   writeDataRF <= 16'b0000000000000010;
	   regWrite <= 1;
	   #10;
	end
	
endmodule 
