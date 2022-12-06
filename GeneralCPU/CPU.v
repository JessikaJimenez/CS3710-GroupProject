// Module to test FSM on the board
// (Uses BoardProgram.dat)
// Takes user input (pushing switches) and outputs user input plus 2 (in binary)
// IO input is switches, IO output is LEDs
module CPU #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16) (
	input        clk,   //on-board 50MHz clock
	input        reset, //button KEY3
	input  [9:0] sw,    //switches SW9-SW0
	output [9:0] leds   //LEDs LEDR9-LEDR0
);

	wire [(ADDR_WIDTH-1):0] memOutput;

	// Instantiate modules
	GeneralCPU #(.ADDR_WIDTH(13)) cpu (
 	   .clk(clk), 
	   .reset(reset),
	   .memData(12'b0),
	   .addr(12'b0), 
	   .IOinput(sw), 
	   .writeEnable(1'b0), 
	   .memOutput(memOutput),
	   .IOoutput(leds) 
	);
	

endmodule 
