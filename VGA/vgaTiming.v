module vgaTiming
(input wire clk, clear, Enable, output reg hSync, vSync, bright, output wire sync_n, output reg [9:0] hCount, vCount);
	assign sync_n = 0;
	parameter hSynLowBound = 10'd655;
	parameter hSynHighBound = 752;
	parameter vSynLowBound = 10'd489;
	parameter vSynHighBound = 492;
	parameter vCountEnd = 521;
	parameter hCountEnd = 799;
	parameter hScreenRes = 640;
	parameter vScreenRes = 480;
	
	always@(negedge clear, posedge clk) begin
		if(~clear) begin		//Set values to where beam will start at top left corner.
			hCount <= hSynLowBound;
			vCount <= vSynLowBound;
			bright <= 0;
			hSync <= 0; //Activate Sync signal
			vSync <= 0; //Activate Sync signal
		end
		else if(Enable) begin	
			if(hCount <= hCountEnd) begin						//Until the beginning of the next line.
				hCount <= hCount + 10'd1;
				if((hCount > hSynLowBound) && (hCount < hSynHighBound)) hSync <= 0;	//tells the "electron beam" when to move back to the left.
				else hSync <= 1;
				if((vCount < vCountEnd) && (hCount == hCountEnd)) begin					//Until we are ready to start the next screen painting.
					vCount <= vCount + 10'd1;
					if((vCount > vSynLowBound) && (vCount < vSynHighBound)) vSync <= 0;	//Tells the "electron beam" when to go back to the top.
					else vSync <= 1;
				end
				else if(vCount == vCountEnd)begin
					vCount <= 0;
				end
				else vCount <= vCount;
			end
			else hCount <= 0;
			
			if((hCount < hScreenRes && vCount < vScreenRes)) bright <= 1;	//When the "electron beam" should be on.
			else bright <= 0;
		end
		else hCount <= hCount;
	end
endmodule 