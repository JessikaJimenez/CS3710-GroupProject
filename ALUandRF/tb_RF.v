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
	
	// Start clock and reset
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
	   ///TestWriting & Reading
		#20;
	   dstAddr <= 4'd1;      //Write to register 1
	   srcAddr <= 4'd1; 
	   writeDataRF <= 16'd5; //Write a 5
	   regWrite <= 1;        //Make sure we're writing
	   #20;
		if (dstValue == 16'd5) $display("Write & Read to register 1 was successful"); //Read to see if the value is correct
		else $display("Write to register 2 was unsuccessful, decimal value was: %d", dstValue);
	   //Repeat the same process as above with different values and registers. srcAddr is
	   //used as the check address from here on.
	   dstAddr <= 4'd2;			//Write to register 2
	   srcAddr <= 4'd2;
	   writeDataRF <= 16'd4;	//Write a 4
	   regWrite <= 1;
	   #20;
		if (dstValue == 16'd4) $display("Write & Read to register 2 was successful"); //Read to see if the value is correct
		else $display("Write to register 2 was unsuccessful, decimal value was: %d", dstValue);
		dstAddr <= 4'd3;		//Write to register 2
		srcAddr <= 4'd3;
	   writeDataRF <= 16'd2;	//Write a 4
	   regWrite <= 1;
		#20;
		if (dstValue == 16'd2) $display("Write & Read to register 3 was successful"); //Read to see if the value is correct
		else $display("Write to register 2 was unsuccessful, decimal value was: %d", dstValue);
	end
	
endmodule 
