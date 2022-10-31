// TESTBENCH FOR memoryMap FILE
/*************************************************************/
`timescale 1ns / 1ps

module tb_memoryMap #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16) ();

  reg [(DATA_WIDTH-1):0] data_a, data_b;
  reg [(ADDR_WIDTH-1):0] addr_a, addr_b;
  reg write_a, write_b, clk;
  reg [(ADDR_WIDTH-1):0] InputData;
  wire [(DATA_WIDTH-1):0] ReadDataA, ioOutputData, ReadDataB;
  integer i;

  // Instantiate memoryMap module
  memoryMap mm (
    .data_a(data_a),
    .data_b(data_b),
    .addr_a(addr_a),
    .addr_b(addr_b),
    .write_a(write_a),
    .write_b(write_b),
    .clk(clk),
    .InputData(InputData),
    .ReadDataA(OutputReadDataA),
	 .ioOutputData(ioOutputData),
    .ReadDataB(ReadDataB),
  );

	// Start clock
	initial begin
	   clk <= 0;
	end
		
	// Generate clock
	always #10 begin
	   clk = ~clk;
	end
    
  initial begin
    data_a = 16'b0;
    data_b = 16'b0;
    addr_a = 16'b0;
    addr_b = 16'b0;
    write_a = 1'b0;
    write_b = 1'b0;
    InputData = 16'b0;

    #10;
	  write_a = 1'b1;
	  write_b = 1'b0;
    
    for(i = 0; i < 16; i = i+1) begin
      data_a = i;
      addr_a = i;
      #20;
	  end

  	  addr_a = 16'b0;
	  addr_b = 16'b0;
	  write_a = 1'b0;
  	  write_b = 1'b1;
  	#10;
    
    for(i = 16; i < 32; i = i+1) begin
      data_b = i;
      addr_b = i;
      #20;
	  end
    
   addr_a = 16'b0;
  	addr_b = 16'b0;
  	write_a = 1'b0;
  	write_b = 1'b0;
  	#10;
    
	 //READ FROM IO
	 $display("Reading from IO");
    for(i = 510; i < 515; i = i+1) begin
	   InputData = (i-509);
      addr_a = i;
      addr_b = i;
		#10;
		$display("Value of input Data is: %d Read From Output Read A is: %d   Read From OutPut Read B is: %d", InputData, OutputReadDataA, OutputReadDataB);
      
    end
	 
	 //WRITE TO IO
	 $display("Write to IO");
	 write_a = 1'b1;
	 for(i = 510; i < 515; i = i+1) begin
      addr_a = i;
		data_a = (i-509);
		#20;
		$display("Value of Write Data is: %d The output of OutputWriteDataA is: %d", data_a, OutputWriteDataA);
      
    end
   #100;
    
  end

endmodule 
