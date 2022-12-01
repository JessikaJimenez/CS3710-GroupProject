
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
		.clk(clk),			//
		.reset(reset),			//
		.memData(memData),		//
		.addr(addr),			//
		.IOinput(assemblyData),		//
		.writeEnable(writeEnable),	//
		.memOutput(memOutput),		//
		.IOoutput(IOoutput)		//
	);
	
	
	//Instantiate VGA Controller
	vgaDisplay VGA(
		.clk(clk),			//
		.clear(reset),			//
		.read_b(read_b),		//
		.addr_b(addr_b),		//
		.hSync(hSync),			//
		.vSync(vSync),			//
		.splitClk(splitClk),		//
		.bright(bright),		//
		.sync_n(sync_n),
		.Red(Red),
		.Green(Green),
		.Blue(Blue)
	);
	

endmodule 
