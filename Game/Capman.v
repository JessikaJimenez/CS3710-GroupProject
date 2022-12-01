
/* Top-level module for our game: Capman */
/*************************************************************/
module Capman (
	input        clk,		//Onboard 50MHz clock
	input        reset,		//Active-low reset
	//input  [9:0] sw,		//Switches
	output [7:0] LEDs,		//LEDs
	output [7:0] vga_red,		//VGA red
	output [7:0] vga_green, 	//VGA green
	output [7:0] vga_blue,		//VGA blue
	output hSync, 			//VGA hsync
	output vSync,			//VGA vsync
	output wire VGA_CLK, 		//VGA 25MHz clock
	output wire VGA_BLANK_N, 	//VGA blank
);
	
	//Variables for CPU
	wire [15:0] memData;
	wire [15:0] addr;
	wire [15:0] IOinput;
	wire [15:0] writeEnable;
	wire [15:0] memOutput;
	wire [15:0] IOoutput;
	//Variables for NES controller
	wire nesData;
    	wire nesClock;
    	wire nesLatch;
	//Variables for VGA controller
	wire [15:0] read_b;	
	wire [15:0] addr_b;
	wire splitClk, bright, sync_n;
			
	
	//Instantiate NES Controller
	nesInterface NES (
		.clk(clk),			//Input 50MHz clock
		.nesData(nesData),		//Input **
		.nesClock(nesClock),		//OUtput **
		.nesLatch(nesLatch),		//Output ** 
		.controllerData(LEDs),		//Outputs data from controller to LEDs
		.assemblyButton(assemblyData)	//Outputs 16-bits which will be input into the CPU
	);
	
	
	//Instantiate CPU 
	GeneralCPU CPU (
		.clk(clk),			//Input 50MHz clock
		.reset(reset),			//Input reset
		.memData(16'b0),		//Input 0, not being used
		.addr(addr_b),			//Input addr_b from VGA
		.IOinput(assemblyData),		//Input assemblyData from NES 
		.writeEnable(16'b0),		//Input 0, not being used	
		.memOutput(memOutput),		//Output memOutput which will go into VGA
		.IOoutput(IOoutput)		//Output 0, not being used
	);
	
	
	//Instantiate VGA Controller
	vgaDisplay VGA(
		.clk(clk),			//Input 50MHz clock
		.clear(reset),			//Input reset
		.read_b(memOutput),		//Input memOutput from CPU
		.addr_b(addr_b),		//Output addr_b to CPU
		.hSync(hSync),			//Output hSync
		.vSync(vSync),			//Output vSync
		.splitClk(VGA_CLK),		//Output VGA 25MHz clock
		.bright(bright),		//Output VGA bright
		.sync_n(VGA_SYNC_N),		//Output VGA sync n
		.Red(vga_red),			//Output VGA red
		.Green(vga_green),		//Output VGA green
		.Blue(vga_blue)			//Output VGA blue
	);
	
	
endmodule 
