
/* Top-level module for our game: Capman */
/*************************************************************/
module Capman (
	input        clk,		//Onboard 50MHz clock
	input        reset,		//Active-low reset
	input	     nesData,		//NES data
	output 	     nesClock,		//NES clock
	output       nesLatch,		//NES lach
	output [7:0] LEDs,		//LEDs
	output [7:0] vga_red,		//VGA red
	output [7:0] vga_green, 	//VGA green
	output [7:0] vga_blue,		//VGA blue
	output hSync, 			//VGA hsync
	output vSync,			//VGA vsync
	output wire VGA_CLK, 		//VGA 25MHz clock
	output wire VGA_SYNC_N, 	//VGA sync
	output wire VGA_BLANK_N		//VGA blank
);
	
	//Variables for CPU
	wire [15:0] IOinput;
	wire [15:0] memOutput;
	wire [15:0] IOoutput;
	//Variables for VGA controller
	wire [15:0] read_b;	
	wire [15:0] addr_b;	
	wire [15:0] data_b;
	wire write_b;	
	
	//Instantiate NES Controller
	nesInterface NES (
		.clk(clk),			//Input 50MHz clock
		.nesData(nesData),		//Input nesData
		.nesClock(nesClock),		//Output nesClock
		.nesLatch(nesLatch),		//Output nesLatch
		.controllerData(LEDs),		//Outputs data from controller to LEDs
		.assemblyButton(IOinput)	//Outputs 16-bits which will be input into the CPU
	);
	
	
	//Instantiate CPU 
	GeneralCPU #(.ADDR_WIDTH(13)) CPU (
		.clk(clk),			//Input 50MHz clock
		.reset(reset),			//Input reset
		.memData(data_b),		//Input data_b from VGA
		.addr(addr_b),			//Input addr_b from VGA
		.IOinput(IOinput),		//Input IOinput from NES 
		.writeEnable(write_b),		//Input write_b from VGA	
		.memOutput(memOutput),		//Output memOutput which will go into VGA
		.IOoutput(IOoutput)		//Output 0, not being used
	);
	
	
	//Instantiate VGA Controller
	vgaDisplay VGA(
		.clk(clk),			//Input 50MHz clock
		.clear(reset),			//Input reset
		.read_b(memOutput),		//Input memOutput from CPU
		.addr_b(addr_b),		//Output addr_b to CPU
		.we_b(write_b),		//Output write_b to CPU
		.data_b(data_b),		//Output data_b to CPU
		.hSync(hSync),			//Output hSync
		.vSync(vSync),			//Output vSync
		.splitClk(VGA_CLK),		//Output VGA 25MHz clock
		.bright(VGA_BLANK_N),		//Output VGA blank
		.sync_n(VGA_SYNC_N),		//Output VGA sync n
		.Red(vga_red),			//Output VGA red
		.Green(vga_green),		//Output VGA green
		.Blue(vga_blue)			//Output VGA blue
	);
	
endmodule 
