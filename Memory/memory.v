// Quartus Prime Verilog Template
// True Dual Port RAM with single clock

module memory
#(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16)
(
	input [(DATA_WIDTH-1):0] data_a, data_b,
	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
	input we_a, we_b, clk,
	output reg [(DATA_WIDTH-1):0] q_a, q_b
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
	integer i;
	initial
	begin
		$display("Loading Memory");
		// you'll need to change the path to this file! 
		$readmemb("C:/Users/danie/Documents/Homework/22 Fall/ECE 3710/Quartus/ALUandRegister/CS3710-GroupProject/Game/CapMan8k.dat", ram); 
		$display("done with memory load"); 
	end

	// Port A 
	always @ (negedge clk)
	begin
		if (we_a) 
		begin
			ram[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= ram[addr_a];
		end 
	end 

	// Port B 
	always @ (negedge clk)
	begin
		if (we_b) 
		begin
			ram[addr_b] <= data_b;
			q_b <= data_b;
		end
		else 
		begin
			q_b <= ram[addr_b];
		end 
	end

endmodule
