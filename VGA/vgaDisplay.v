module vgaDisplay(input wire clk, clear, input wire [2:0] rgbSwitches,  TBinputs,
						output wire hSync, vSync, splitClk, bright, sync_n, output wire [5:0] signals,
						output wire [7:0] Red, Green, Blue);
				  
	wire [9:0] hCount;
	wire [9:0] vCount;
	
	
	//Splits the 50MHz clock into a 25MHz clock.
	splitClock split(.clk(clk), .clkSplit(splitClk));
	
	
	//Based on the splitClk signal uses the bit counters to set vga signals.
	vgaTiming Syncer(.clk(clk), .clear(clear), .Enable(splitClk), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hCount), .vCount(vCount), .sync_n(sync_n));
	
	bitGen2 Gen2(.bright(bright), .rgbSwitches(rgbSwitches), .hCount(hCount), .vCount(vCount), .signals(signals), .Red(Red), .Green(Green), .Blue(Blue));
endmodule 