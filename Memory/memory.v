// Quartus Prime Verilog Template
// True Dual Port RAM with single clock

module memory #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16) (
	input [(DATA_WIDTH-1):0] data_a, data_b,
	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
	input write_a, write_b, clk,
	output reg [(DATA_WIDTH-1):0] read_a, read_b
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[(1<<7)-1:0]; //Depth of 16
	//reg [DATA_WIDTH-1:0] ram[(2**ADDR_WIDTH)-1:0]; //Depth of 16
	integer i;
	
	initial begin
//		for(i=0;i<1024;i=i+1)
//			ram[i] = i[15:0]; 
		$display("Loading Memory");
		// you'll need to change the path to this file! 
		$readmemb("C:/Users/sizzl/OneDrive/Documents/School Documents/CS 3710/Project/CS3710-GroupProject/Helper Files/TestMem.dat", ram); 
		$display("done with memory load"); 
	end

	// Memory block
	always @ (negedge clk) begin
		if (write_a) begin // PORT A
			ram[addr_a] <= data_a;
			read_a <= data_a;
		end
		else begin
			read_a <= ram[addr_a];
		end 
		
		if (write_b) begin // PORT B
			ram[addr_b] <= data_b;
			read_b <= data_b;
		end
		else begin
			read_b <= ram[addr_b];
		end 
	end 

endmodule 
