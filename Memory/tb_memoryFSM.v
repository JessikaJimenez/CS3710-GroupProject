// TESTBENCH FOR memoryMap FILE
/*************************************************************/
`timescale 1ns / 1ps

module tb_memoryFSM #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16) 
();
  reg clk, rst, btn;
  reg [(ADDR_WIDTH-1):0] inAddress;
  reg [(ADDR_WIDTH-1):0] outAddress;
  reg [(DATA_WIDTH-1):0] writeData;
  reg [(ADDR_WIDTH-1):0] readData;

  // Instantiate memoryMap module
  memoryFSM mFSM (
    .clk(clk),
    .rst(rst),
    .btn(btn),
    .inAddress(inAddress),
    .outAddress(outAddress),
    .writeData(writeData),
    .readData(readData),
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
    inAddress <= 16'd2;
    $display("Value at address %d is: %d", inAddress, readData);
  end

endmodule 
