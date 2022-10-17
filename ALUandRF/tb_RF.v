// TESTBENCH FOR REGISTER FILE
/*************************************************************/
`timescale 1ns/1ns

module tb_RF #(parameter WIDTH = 16) ();
	
	reg clk, reset;
	reg [3:0] srcAddr, dstAddr;
	reg [WIDTH - 1: 0] writeDataRF;
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
	   .wrData(writeDataRF), 
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
	   reset <= 1;
	end
		
	// Generate clock
	always #10 begin
	   clk = ~clk;
	end
		
	initial begin
	   ////////Test for Register File
	   ///TestWriting
		#20;
	   dstAddr <= 4'd1;
		srcAddr <= 4'd1;
	   writeDataRF <= 16'd5;
	   regWrite <= 1;
	   #20;
		if (dstValue == 16'd1) $display("Write to register 1 was successful");
	   dstAddr <= 4'd2;
	   writeDataRF <= 16'd4;
	   regWrite <= 1;
	   #20;
		if (dstValue == 16'd1) $display("Write to register 1 was successful");
		dstAddr <= 4'd3;
	   writeDataRF <= 16'd2;
	   regWrite <= 1;
		#20;
	end
	
endmodule 
