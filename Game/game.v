
/* Top-level module for our game: Cap Man */
/*************************************************************/
module game (
	input clk,                //Onboard 50MHz clock
	input reset,              //Reset switch
	// add other inputs here
	
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
	NESController NES (
		//**TODO - actually make game controller 
	);
		

endmodule 
