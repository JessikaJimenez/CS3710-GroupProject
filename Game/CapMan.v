
/* Top-level module for our game: CapMan */
/*************************************************************/
module CapMan (
	input        clk,         //Onboard 50MHz clock
	input        reset,       //Reset switch
	input  [9:0] sw,          //Switches
	output [9:0] LED,         //LEDs
	// add other inputs/outputs here
	
	// stuff for VGA
	output       VGA_CLK,     //VGA clock
	output       VGA_HS,      //VGA horizontal sync 
	output       VGA_VS,      //VGA vertical sync
	output       VGA_BLANK_N, //VGA BLANK
	output       VGA_SYNC_N,  //VGA N SYNC
	output [7:0] VGA_R,       //VGA Red[7:0]
	output [7:0] VGA_G,       //VGA Green[7:0]
	output [7:0] VGA_B        //VGA Blue[7:0]
);
	
	//**TODO - do game stuff
	
	// Read in game logic assembly file
	initial begin
		$display("Loading CapMan game from memory");
		// **TODO - fix file path 
		$readmemb("C:/Users/sizzl/OneDrive/Documents/School Documents/CS 3710/Project/CS3710-GroupProject/Helper Files/TestMem.dat", ram); 
		$display("Done with memory load"); 
	end	

	//Instantiate VGA Controller
	VGAController VGA(
	        .clk(clk),
		.reset(reset),
		.VGA_CLK(VGA_CLK),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N)),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B)
		//**TODO - actually make VGA controller
	);
	
	//Instantiate NES Controller
	nesOnBoard NES (
		.clk(clk),
		.nesData(nesData),
		.nesClock(nesClock),
		.nesLatch(nesLatch),
		.leds(leds),
		.hexOut(hexOut)
	);
		

endmodule 
