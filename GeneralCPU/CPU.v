// Module to test FSM on the board
module CPU #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16) (
	input        clk,   //on-board 50MHz clock
	input        reset, //button KEY3
	input  [9:0] sw,    //switches SW9-SW0
	output [9:0] leds   //LEDs LEDR9-LEDR0
);

	reg [(ADDR_WIDTH-1):0] memData;
	wire [(ADDR_WIDTH-1):0] memOutput;
	reg [(ADDR_WIDTH-1):0] addr;
	wire writeEnable;

	
	// Instantiate modules
	GeneralCPU #(.ADDR_WIDTH(13)) cpu (
 	   .clk(clk), 
	   .reset(reset),
	   .memData(memData),
	   .addr(addr), 
	   .IOinput(sw), 
	   .writeEnable(writeEnable), 
	   .memOutput(memOutput),
	   .IOoutput(leds) 
	);
	

endmodule 
