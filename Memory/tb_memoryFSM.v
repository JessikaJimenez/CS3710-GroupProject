// TESTBENCH FOR memoryMap FILE
/*************************************************************/
`timescale 1ns/1ns

module tb_memoryFSM #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16) ();
  reg clk, rst, btn;
  reg [(ADDR_WIDTH-1):0] inAddress;
  wire [(ADDR_WIDTH-1):0] outAddress;
  wire [(DATA_WIDTH-1):0] writeData;
  wire [(ADDR_WIDTH-1):0] readData;

  // Instantiate memoryMap module
  memoryFSM mFSM (
    .clk(clk),
    .rst(rst),
    .btn(btn),
    .inAddress(inAddress),
    .outAddress(outAddress),
    .hexWriteData(writeData),
    .hexReadData(readData)
  );

	// Start clock and reset
	initial begin
	   clk <= 0;
	   rst <= 1;
	end
		
	// Generate clock
	always #10 begin
	   clk = ~clk;
	end
    
  initial begin
    #20
    inAddress <= 16'd2;
	 #15
    $display("Value at address %d is: %d", inAddress, readData);
	 //Read State
	 btn <= 1'b0;
	 #10
	 btn <= 1'b1;
	 #10
	 //Write State
	 btn <= 1'b0;
	 #10
	 btn <= 1'b1;
	 #10;
	 //Complete Write and Enter Read State
	 btn <= 1'b0;
	 #10
	 btn <= 1'b1;
	 #30;
	 $display("New Value at address %d is: %d", inAddress, readData);
	 
	 //Change Address and Repeat
	 #10
    inAddress <= 16'd3;
	 #15
    $display("Value at address %d is: %d", inAddress, readData);
	 //Write State
	 btn <= 1'b0;
	 #10
	 btn <= 1'b1;
	 #10;
	 //Complete Write and Enter Read State
	 btn <= 1'b0;
	 #10
	 btn <= 1'b1;
	 #30;
	 $display("New Value at address %d is: %d", inAddress, readData);
  end

endmodule 
