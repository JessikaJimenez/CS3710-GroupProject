module vgaTiming
(input wire clk, clear, Enable, output reg hSync, vSync, bright, output wire sync_n, output reg [9:0] hCount, vCount);
	assign sync_n = 0;
	always@(negedge clear, posedge clk) begin
		if(~clear) begin		//Set values to where the screen will clear to black and start at top left corner.
			hCount <= 655;
			vCount <= 489;
			bright <= 0;
			hSync <= 0;
			vSync <= 0;
		end
		else if(Enable) begin	
			if(hCount < 800) begin						//Until the beginning of the next line.
				hCount <= hCount + 10'd1;
				if((hCount > 655) && (hCount < 752)) hSync <= 0;	//tells the "electron beam" when to move back to the left.
				else hSync <= 1;
				if((vCount < 521) && (hCount == 799)) begin					//Until we are ready to start the next screen painting.
					vCount <= vCount + 10'd1;
					if((vCount > 489) && (vCount < 492)) vSync <= 0;	//Tells the "electron beam" when to go back to the top.
					else vSync <= 1;
				end
				else if(vCount == 521)begin
					vCount <= 0;
					fast_hCount <= 0;
				end
				else vCount <= vCount;
			end
			else hCount <= 0;
			
			if((hCount<640 && vCount<480)) bright <= 1;	//When the "electron beam" should be on.
			else bright <= 0;
		end
		else hCount <= hCount;
	end
endmodule 