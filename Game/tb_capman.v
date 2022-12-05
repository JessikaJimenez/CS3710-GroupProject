// TESTBENCH FOR Capman
/*************************************************************/
`timescale 1ns/1ns

module tb_capman #(parameter WIDTH = 16) ();
	
	reg clk, reset;
	reg nesData;
	wire nesClock;		//NES clock
	wire nesLatch;		//NES lach
	wire [7:0] LEDs;		//LEDs
	wire [7:0] vga_red;		//VGA red
	wire [7:0] vga_green; 	//VGA green
	wire [7:0] vga_blue;		//VGA blue
	wire hSync; 			//VGA hsync
	wire vSync;			//VGA vsync
	wire VGA_CLK; 		//VGA 25MHz clock
	wire VGA_SYNC_N; 	//VGA sync
	wire VGA_BLANK_N;		//VGA blank

	// Instantiate modules
	Capman game(
        .clk(clk),
        .reset(reset),
        .nesData(nesData),
        .nesClock(nesClock),
        .nesLatch(nesLatch),
        .LEDs(LEDs),
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue),
        .hSync(hSync),
        .vSync(vSync),
        .VGA_CLK(VGA_CLK),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_BLANK_N(VGA_BLANK_N)
    );
	
	// Start clock and reset
	initial begin
	   clk <= 0;
	   reset <= 0;
	   nesData <= 0;
		#100;
		reset <= 1;
		#10;
	end
		
	// Generate clock
	always #10 begin
	   clk = ~clk;
	end
	
endmodule 
