module memoryMap #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16) (
	input [(DATA_WIDTH-1):0] data_a, data_b, //Data Written to Memory
	input [(ADDR_WIDTH-1):0] addr_a, addr_b, //Address of Data
	input write_a, write_b, clk,
   	input [(DATA_WIDTH-1):0] InputData,                   //Switches In this case
	output wire [(DATA_WIDTH-1):0] OutputDataA, OutputDataB
);

	//Read values of Data
	wire [(DATA_WIDTH-1):0] read_a;
	wire [(DATA_WIDTH-1):0] read_b;
	
	wire mmIOReadA;
	assign mmIOReadA = addr_a[(ADDR_WIDTH-1)] == 1'b1 & !write_a; //If in IO space and not writing
	mux2 OutputA(read_a, InputData, mmIOWriteA, OutputDataA); //Set output data to either ExMem data or Data from IO (Switches)

	wire mmIOWriteA;
	assign mmIOWriteA = addr_a[(ADDR_WIDTH-1)] == 1'b1 & write_a;		//Given in Lab
	flopen flopA(clk, mmIOWriteA, data_a, OutputDataA);			//use the flop to set the LEDs


	wire mmIOReadB;
	assign mmIOReadB = addr_b[(ADDR_WIDTH-1)] == 1'b1 & !write_b; //If in IO space and not writing
	mux2 OutputB(read_b, InputData, mmIOReadB, OutputDataB); //Set output data to either ExMem data or Data from IO (Switches)

	wire mmIOWriteB;
	assign mmIOWriteB = addr_a[(ADDR_WIDTH-1)] == 1'b1 & write_b;		//Given in Lab
	flopen flopB(clk, mmIOWriteB, data_b, OutputDataB);			//use the flop to set the LEDs

	memory exMem(
		.data_a(data_a),
		.data_b(data_b),
		.addr_a(addr_a),
		.addr_b(addr_b),
		.write_a(write_a),
		.write_b(write_b),
		.clk(clk),
		.read_a(read_a),
		.read_b(read_b)
	);

endmodule


module mux2 #(parameter DATA_WIDTH = 16)
(
	input  [DATA_WIDTH-1:0] d0, d1, 
	input              s, 
	output [DATA_WIDTH-1:0] y
);

	assign y = s ? d1 : d0; 
	
endmodule

module flopen #(parameter DATA_WIDTH = 16)
               (input                  clk, en,
                input      [DATA_WIDTH-1:0] d, 
                output reg [DATA_WIDTH-1:0] q);
					 
					 
   always @(posedge clk)
      if (en) q <= d;
	
endmodule 
