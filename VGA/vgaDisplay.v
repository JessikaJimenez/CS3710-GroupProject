module vgaDisplay #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16)
						(input wire clk, clear, 
						input wire [DATA_WIDTH-1:0] read_b,
						output wire [ADDR_WIDTH-1:0] addr_b,
						output wire hSync, vSync, splitClk, bright, sync_n, 
						output wire [7:0] Red, Green, Blue);
				  
	wire [9:0] hCount;
	wire [9:0] vCount;
	
	//Splits the 50MHz clock into a 25MHz clock.
	splitClock split(.clk(clk), .clkSplit(splitClk));
	
	//Based on the splitClk signal uses the bit counters to set vga signals.
	vgaTiming Syncer(.clk(clk), .clear(clear), .Enable(splitClk), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hCount), .vCount(vCount), .sync_n(sync_n));
	
	vgabitGen Gen(.bright(bright), .clk(clk), .clear(clear), .counterEnable(splitClk), .read_b(read_b), .hCount(hCount), .vCount(vCount), .addr_b(addr_b), .Red(Red), .Green(Green), .Blue(Blue));
endmodule 