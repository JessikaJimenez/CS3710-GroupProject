// Quartus Prime Verilog Template
// True Dual Port RAM with single clock

module memory
#(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=10)
(
	input [(DATA_WIDTH-1):0] data_a, data_b,
	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
	input write_a, write_b, clk,
	output reg [(DATA_WIDTH-1):0] read_a, read_b
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
	integer i;
	initial
	begin
		for(i=0;i<1024;i=i+1)
			ram[i] = i[15:0]; 
	end

	// Port A 
	always @ (posedge clk)
	begin
		if (write_a) 
		begin
			ram[addr_a] <= data_a;
			read_a <= data_a;
		end
		else 
		begin
			read_a <= ram[addr_a];
		end 
	end 

	// Port B 
	always @ (posedge clk)
	begin
		if (write_b) 
		begin
			ram[addr_b] <= data_b;
			read_b <= data_b;
		end
		else 
		begin
			read_b <= ram[addr_b];
		end 
	end

endmodule
