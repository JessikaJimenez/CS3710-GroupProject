
/* Top-level module for our game: Capman */
/*************************************************************/
module Capman (
	input        clk,     //Onboard 50MHz clock
	input        reset,   //Active-low reset
	//input  [9:0] sw,      //Switches
	output [7:0] LEDs,     //LEDs
	output [6:0] hexOut,  //HEX-to-7-seg
	output [7:0] Red,     //VGA red
	output [7:0] Green,   //VGA green
	output [7:0] Blue,    //VGA blue
	
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
	wire [6:0] hexOut;
	//Variables for VGA controller
	wire [15:0] read_b;	
	wire [15:0] addr_b;
	wire hSync, vSync, splitClk, bright, sync_n;
			
	
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
		.memData(0),			//Input 0, not being used
		.addr(addr_b),			//Input addr_b from VGA
		.IOinput(assemblyData),		//Input assemblyData from NES 
		.writeEnable(0),		//Input 0, not being used	
		.memOutput(memOutput),		//Output memOutput which will go into VGA addr_b
		.IOoutput(0)			//Output 0, not being used
	);
	
	
	//Instantiate VGA Controller
	vgaDisplay VGA(
		.clk(clk),			//
		.clear(reset),			//
		.read_b(memOutput),		//Input memOutput from CPU
		.addr_b(addr_b),		//
		.hSync(hSync),			//
		.vSync(vSync),			//
		.splitClk(splitClk),		//
		.bright(bright),		//
		.sync_n(sync_n),		//
		.Red(Red),			//
		.Green(Green),			//
		.Blue(Blue)			//
	);
	

endmodule 
