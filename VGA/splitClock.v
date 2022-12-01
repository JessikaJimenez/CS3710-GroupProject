module splitClock(input wire clk, output reg clkSplit);
	always@(posedge clk) begin
		clkSplit <= !clkSplit;
	end
endmodule 