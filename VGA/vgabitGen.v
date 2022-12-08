module vgabitGen #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16)
				  (input wire bright, clk, clear, counterEnable,
					input wire [DATA_WIDTH-1:0] read_b,
					input wire [9:0] hCount, vCount,
					output reg write_b,
					output wire [DATA_WIDTH-1:0] data_b,
					output reg [ADDR_WIDTH-1:0] addr_b,
				   output reg [7:0] Red, Green, Blue);
	assign data_b = 16'd1;
					
//4 pixel colors can be stored in one word of memory because we have 6 pre-set colors so one color can be represented in 3 bits.

//Assume sprites begin at Address C4B0 (Each sprite takes up 16*4 = 64 lines of code or 40 in hex) total memory for sprites = 1920 words
					
	//Pre-defined colors that can be displayed.
	parameter Black = 3'b000;
	parameter Blu = 3'b001;
	parameter Yellow = 3'b010;
	parameter Redd = 3'b011;
	parameter Crimson = 3'b100;
	parameter White = 3'b111;
	
	//Addresses that need accessed directly.
	 parameter frameFinishedFlagAddress = 16'h1DD5;
	 parameter spriteStorageStartAddress = 16'h14B0;
	 parameter spriteIDStartAddress = 16'h1000;
	 parameter capXAddr = 16'h1C30;
	 parameter capYAddr = 16'h1C31;
	 parameter capDirAddr = 16'h1C32;
	 parameter ghostXAddr = 16'h1C33;
	 parameter ghostYAddr = 16'h1C34;
	 parameter ghostDirAddr = 16'h1C35;
//	parameter spriteStorageStartAddress = 16'h000A;		//<<Testing code.
//	parameter spriteIDStartAddress = 16'h0000;			//<<Testing code.
//	parameter capXAddr = 16'h0004;							//<<Testing code.
//	parameter capYAddr = 16'h0005;							//<<Testing code.
//	parameter capDirAddr = 16'h0006;							//<<Testing code.
//	parameter ghostXAddr = 16'h0007;							//<<Testing code.
//	parameter ghostYAddr = 16'h0008;							//<<Testing code.
//	parameter ghostDirAddr = 16'h0009;              	//<<Testing code.
	parameter mov_spritesBufStartAddr = 10'd800;
	
	//Set RGB bits to all 1's or all 0's
	parameter ON = 8'b11111111;	
	parameter OFF = 8'b00000000;
	
	//States for background buffer loading
	parameter IDRead = 4'b0000;
	parameter IDStore = 4'b0001;
	parameter pixelRead = 4'b0010;
	parameter pixelStore = 4'b0011;
//	parameter pixelRead2 = 4'b0011;
//	parameter pixelRead3 = 4'b0100;
//	parameter pixelRead4 = 4'b0101;
//	parameter endSprite = 4'b0110;
	parameter endLine = 4'b0111;
	parameter endFrame = 4'b1000;
	
	reg [4:0] animationCounter;
	
	reg [2:0] color;				 		//Gets set based on pixel we need drawn.
	reg [15:0] currentSpriteID; 		//Used to calculate currentPixelAddr.
	reg [3:0] state, nextstate; 		//State of loading background into buffer.
	reg [3:0] movingSpriteInfoToGet; //Keep track of what moving sprite info we need to lookup.
	
	//Counters to set lookup addresses to the right address.
	reg [9:0] fast_hCount;
	wire [9:0] alt_vCount;
	assign alt_vCount [9:0] = (vCount < 479) ? (vCount+1'b1):(9'd0);
	
//	reg [9:0] backPix;	 //Keeps track of where we are on drawing the background.
	reg [7:0] ghostPix;	 //Where we are on drawing ghost sprite.
	reg [7:0] capPix;		 //Where we are on drawing Capman sprite.
	reg [7:0] mov_spritebufferCounter; //location offset for loading sprites into buffer.
	
	//Positions of capman and the ghost so we can know where to draw them
	reg [9:0] capHPos;
	reg [8:0] capVPos;
	reg [9:0] ghostHPos;
	reg [8:0] ghostVPos;
	reg [15:0] capDir; 		//ID of capman sprite in specific direction.
	reg [15:0] ghostDir; 	//ID of ghost sprite in specific direction.
//	reg [9:0] bufferAddress;

	reg [DATA_WIDTH-1:0] buffer[(1<<10)-1:0];
	
	initial begin
		fast_hCount <= 10'd0;
		ghostPix <= 8'd0;
		capPix <= 8'd0;
		mov_spritebufferCounter <= 8'd0;
		animationCounter <= 0;
	end
	
	//Booleans to determine what to draw.
	wire inCapVRange;
	wire inGhostVRange;
	
	//Addresses to look up drawing color information.
	wire [ADDR_WIDTH-1:0] currentIDAddr;
	wire [ADDR_WIDTH-1:0] currentPixelAddr;
	wire [9:0] capPixBufAddr;
	wire [9:0] ghostPixBufAddr;
//	wire [8:0] backPixBufAddr;
	
	//Assign booleans so we know when to load moving sprites into line buffer.
	assign inCapVRange = (alt_vCount >= capVPos) && (alt_vCount < (capVPos + 16));
	assign inGhostVRange = (alt_vCount >= ghostVPos) && (alt_vCount < (ghostVPos + 16));
	
// Assign addresses based on where we are on loading the buffer.
	assign currentIDAddr [ADDR_WIDTH-1:0] = spriteIDStartAddress + fast_hCount[9:4] + alt_vCount[8:4]*16'd40;
//	assign currentIDAddr = spriteIDStartAddress + fast_hCount[5:4];                                  //<<Testing code.
	assign currentPixelAddr [ADDR_WIDTH-1:0] = {10'd0, alt_vCount[3:0], fast_hCount[3:2]}+(currentSpriteID-16'd1)*16'd64 + spriteStorageStartAddress;
	assign capPixBufAddr [9:0] = {3'd0, capPix[7:2]} + mov_spritesBufStartAddr;
	assign ghostPixBufAddr [9:0] = {3'd0, ghostPix[7:2]} + 9'd64 + mov_spritesBufStartAddr;
	
	wire [ADDR_WIDTH-1:0] movingSpriteAddr;
	assign movingSpriteAddr = (((mov_spritebufferCounter<64) ? capDir:ghostDir)-1'b1)*16'd64+spriteStorageStartAddress;
	
	//Tells if we are loading the background into buffer.
	reg loading; 	
	wire loadingTime;
	assign loadingTime = hCount >= 600 && vCount < 480;
	
	//Buffer for one line of the screen and moving sprites.
	
	always @(negedge clear, posedge clk) begin
		if(~clear) state <= IDRead;
		else state <= nextstate;
	 end

	always@(*) begin //Switch between states.
		if(loading) begin
			case(state)
				IDRead: nextstate <= IDStore;
				IDStore: nextstate <= pixelRead;
				pixelRead: nextstate <= pixelStore;
				pixelStore: begin
					if(fast_hCount == 636 && alt_vCount < 479) nextstate <= endLine; 			//If we are at end of line.
					else if(fast_hCount == 636 && alt_vCount >= 479) nextstate <= endFrame;	//If we are at end of frame.
					else if(fast_hCount[3:0] == 12) nextstate <= IDRead;
					else nextstate <= pixelRead;
				end
				endLine: nextstate <= IDRead;
				endFrame: nextstate <= IDRead;
				default: nextstate <= IDRead;
			endcase
		end
		else nextstate <= IDRead;
	end
	
	always@(negedge clear, posedge clk) begin //Load pixel info based on state and loading bool value.
		if(~clear) addr_b <= spriteIDStartAddress; //Set addr_b to first ID address.
		else if(loading) begin
			case(state)
				IDRead: begin
					addr_b <= currentIDAddr;			//Get the sprite ID from Memory
					write_b <= 0;
				end
				IDStore: currentSpriteID <= read_b;		//Store the ID of the sprite to the side
				pixelRead: begin
					addr_b <= currentPixelAddr;			//Get the first 4 pixels using sprite ID to get pixel location
//					fast_hCount <= fast_hCount + 10'd4; //Move to the next 4 pixels
				end
				pixelStore: begin
					buffer[fast_hCount] <= (currentSpriteID == 0) ? (16'd0):(read_b[13:11]);
					buffer[fast_hCount + 1] <= (currentSpriteID == 0) ? (16'd0):(read_b[10:8]);
					buffer[fast_hCount + 2] <= (currentSpriteID == 0) ? (16'd0):(read_b[7:5]);
					buffer[fast_hCount + 3] <= (currentSpriteID == 0) ? (16'd0):(read_b[4:2]);
					fast_hCount <= fast_hCount + 10'd4;	  										//Move to next 4.
				end
//				pixelRead3: begin
//					if(currentSpriteID == 16'd0) buffer[fast_hCount[9:2]-1] <= 16'd0; //"
//					else buffer[fast_hCount[9:2]-1] <= read_b; 								//" Could have taken these states out but didn't want to deal
//					addr_b <= currentPixelAddr;			  										//" with the state switching logic.
//					fast_hCount <= fast_hCount + 10'd4;	  										//"
//				end
//				pixelRead4: begin
//					if(currentSpriteID == 16'd0) buffer[fast_hCount[9:2]-1] <= 16'd0; //"
//					else buffer[fast_hCount[9:2]-1] <= read_b; 								//"
//					addr_b <= currentPixelAddr;			  		 								//"
//					fast_hCount <= fast_hCount + 10'd4;	  		 								//"
//				end
//				endSprite: begin
//					if(currentSpriteID == 16'd0) buffer[fast_hCount[9:2]-1] <= 16'd0; //If in blank square store blank pixels in buffer.
//					else buffer[fast_hCount[9:2]-1] <= read_b; //Load last 4 pixels of sprite to buffer.
//				end
				endLine: begin 
					fast_hCount <= 0;							//Reset the buffer's hCount
					if(inCapVRange) begin //Overwrite background bits if we need to draw Capman.
						buffer[capHPos] <= buffer[capPixBufAddr][13:11];
						buffer[capHPos + 10'd1] <= buffer[capPixBufAddr][10:8];
						buffer[capHPos + 10'd2] <= buffer[capPixBufAddr][7:5];
						buffer[capHPos + 10'd3] <= buffer[capPixBufAddr][4:2];
						buffer[capHPos + 10'd4] <= buffer[capPixBufAddr + 10'd1][13:11];
						buffer[capHPos + 10'd5] <= buffer[capPixBufAddr + 10'd1][10:8];
						buffer[capHPos + 10'd6] <= buffer[capPixBufAddr + 10'd1][7:5];
						buffer[capHPos + 10'd7] <= buffer[capPixBufAddr + 10'd1][4:2];
						buffer[capHPos + 10'd8] <= buffer[capPixBufAddr + 10'd2][13:11];
						buffer[capHPos + 10'd9] <= buffer[capPixBufAddr + 10'd2][10:8];
						buffer[capHPos + 10'd10] <= buffer[capPixBufAddr + 10'd2][7:5];
						buffer[capHPos + 10'd11] <= buffer[capPixBufAddr + 10'd2][4:2];
						buffer[capHPos + 10'd12] <= buffer[capPixBufAddr + 10'd3][13:11];
						buffer[capHPos + 10'd13] <= buffer[capPixBufAddr + 10'd3][10:8];
						buffer[capHPos + 10'd14] <= buffer[capPixBufAddr + 10'd3][7:5];
						buffer[capHPos + 10'd15] <= buffer[capPixBufAddr + 10'd3][4:2];
						capPix <= capPix + 8'd16;
					end
					else capPix <= 0;
					
					if(inGhostVRange) begin //Overwrite background bits if we need to draw Ghost.
						buffer[ghostHPos] <= buffer[ghostPixBufAddr][13:11];
						buffer[ghostHPos + 10'd1] <= buffer[ghostPixBufAddr][10:8];
						buffer[ghostHPos + 10'd2] <= buffer[ghostPixBufAddr][7:5];
						buffer[ghostHPos + 10'd3] <= buffer[ghostPixBufAddr][4:2];
						buffer[ghostHPos + 10'd4] <= buffer[ghostPixBufAddr + 10'd1][13:11];
						buffer[ghostHPos + 10'd5] <= buffer[ghostPixBufAddr + 10'd1][10:8];
						buffer[ghostHPos + 10'd6] <= buffer[ghostPixBufAddr + 10'd1][7:5];
						buffer[ghostHPos + 10'd7] <= buffer[ghostPixBufAddr + 10'd1][4:2];
						buffer[ghostHPos + 10'd8] <= buffer[ghostPixBufAddr + 10'd2][13:11];
						buffer[ghostHPos + 10'd9] <= buffer[ghostPixBufAddr + 10'd2][10:8];
						buffer[ghostHPos + 10'd10] <= buffer[ghostPixBufAddr + 10'd2][7:5];
						buffer[ghostHPos + 10'd11] <= buffer[ghostPixBufAddr + 10'd2][4:2];
						buffer[ghostHPos + 10'd12] <= buffer[ghostPixBufAddr + 10'd3][13:11];
						buffer[ghostHPos + 10'd13] <= buffer[ghostPixBufAddr + 10'd3][10:8];
						buffer[ghostHPos + 10'd14] <= buffer[ghostPixBufAddr + 10'd3][7:5];
						buffer[ghostHPos + 10'd15] <= buffer[ghostPixBufAddr + 10'd3][4:2];
						ghostPix <= ghostPix + 8'd16;
					end
					else ghostPix <= 0;
				end
				endFrame: begin
					fast_hCount <= 0;							//Reset buffer's hCount
					movingSpriteInfoToGet <= 4'b0000;   //Start getting moving sprite info imediately after frame loading is complete
					addr_b <= frameFinishedFlagAddress;
					write_b <= 1;								//enable writing to memory to store end of frame flag.
				end
				default: addr_b <= currentIDAddr;
			endcase
		end
		else if (movingSpriteInfoToGet < 4'b1010) begin 
			case(movingSpriteInfoToGet)
				4'b0000: begin //Get cap x-pos from memory.
					addr_b <= capXAddr;
					movingSpriteInfoToGet <= 4'b0001;
				end
				4'b0001: begin //Store cap x-pos. Get cap y-pos from memory.
					capHPos <= read_b[9:0];
					addr_b <= capYAddr;
					movingSpriteInfoToGet <= 4'b0010;
				end
				4'b0010: begin //Store cap y-pos. Get cap direction from memory (direction is just a sprite ID).
					capVPos <= read_b[8:0];
					addr_b <= capDirAddr;
					movingSpriteInfoToGet <= 4'b0011;
				end
				4'b0011: begin //Store cap direction. Get ghost x-pos from memory.
					capDir <= animationCounter[4] ? read_b:(read_b + 1'd1);
					addr_b <= ghostXAddr;
					movingSpriteInfoToGet <= 4'b0100;
				end
				4'b0100: begin //Store ghost x-pos. Get ghost y-pos from memory.
					ghostHPos <= read_b[9:0];
					addr_b <= ghostYAddr;
					movingSpriteInfoToGet <= 4'b0101;
				end
				4'b0101: begin //Store ghost y-pos. Get ghost direction from memory (direction is just a sprite ID).
					ghostVPos <= read_b[8:0];
					addr_b <= ghostDirAddr;
					movingSpriteInfoToGet <= 4'b0110;
				end
				4'b0110: begin //Store ghost direction.
					ghostDir <= animationCounter[4] ? read_b:(read_b + 1'd1);
					movingSpriteInfoToGet <= 4'b0111;
				end
				4'b0111: begin //Start of loop to store moving sprite pixels into the buffer.
					if(mov_spritebufferCounter < 64)
						addr_b <= movingSpriteAddr + mov_spritebufferCounter; //Get Capman pixels from memory.
					else 
						addr_b <= movingSpriteAddr + mov_spritebufferCounter - 16'd64; //Get Ghost pixels from memory.
					movingSpriteInfoToGet <= 4'b1000;
				end
				4'b1000: begin
					buffer[mov_spritebufferCounter + mov_spritesBufStartAddr] <= read_b; //Store moving sprite pixels.
					movingSpriteInfoToGet <= 4'b1001;
				end
				4'b1001: begin
					if(mov_spritebufferCounter < 128) begin
						mov_spritebufferCounter <= mov_spritebufferCounter + 1'd1; //Move on to next pixel buffer storage location.
						movingSpriteInfoToGet <= 4'b0111; 		//Go back to start of loop if we are not finished loading both moving sprites.
					end
					else begin
						mov_spritebufferCounter <= 0; 	 //Reset counter for next time we store moving sprites to buffer.
						movingSpriteInfoToGet <= 4'b1010; //Get out of loop.
					end
				end
				default: addr_b <= currentIDAddr;
			endcase
		end
		else addr_b <= addr_b;
	end
	
	always@(*)begin //Set the enable signal for the addr_b use.
		if(loadingTime) loading <= 1;
		else loading <= 0;
	end
	
//	always@(negedge clear, posedge clk)begin //Update counters that go along with vgaDisplay.
//		if(~clear) begin
//			bufferAddress <= 0;
//		end
//		else if(counterEnable) begin
//			
//			if(hCount > 640) bufferAddress <= 0;
//			else if(hCount[1:0] == 2'b11) bufferAddress <= bufferAddress + 1'b1;
//			else bufferAddress <= bufferAddress;
//				
//		end
//		else begin
//			bufferAddress <= bufferAddress;
//		end
//	end
	
	always@(negedge clk) begin //Choose color.
		if(counterEnable) begin //Syncs this always block with the VGA Clock.
		color <= buffer[hCount][2:0];
//			if(drawGhost) begin 
//				case(ghostPix[1:0]) //Set color based on current ghost pixel.
//					2'b00: begin
//						color <= buffer[ghostPixBufAddr][13:11];
//						ghostPix <= ghostPix + 1'b1;
//					end
//					2'b01: begin
//						color <= buffer[ghostPixBufAddr][10:8];
//						ghostPix <= ghostPix + 1'b1;
//					end
//					2'b10: begin
//						color <= buffer[ghostPixBufAddr][7:5];
//						ghostPix <= ghostPix + 1'b1;
//					end
//					2'b11: begin 
//						color <= buffer[ghostPixBufAddr][4:2];
//						if(ghostPix == 255) ghostPix <= 0;
//						else ghostPix <= ghostPix + 1'b1;
//					end
//				endcase
//			end
//			else if (drawCapman) begin 
//			if (drawCapman) begin
//				case(capPix[1:0]) //Set color based on current Capman pixel.
//					2'b00: begin
//						color <= buffer[capPixBufAddr][13:11];
//						capPix <= capPix + 1'b1;
//					end
//					2'b01: begin
//						color <= buffer[capPixBufAddr][10:8];
//						capPix <= capPix + 1'b1;
//					end
//					2'b10: begin
//						color <= buffer[capPixBufAddr][7:5];
//						capPix <= capPix + 1'b1;
//					end
//					2'b11: begin
//						color <= buffer[capPixBufAddr][4:2];
//						if(capPix == 255) capPix <= 0;
//						else capPix <= capPix + 1'b1;
//					end
//				endcase
//			end
//			else if(drawGhost) begin 
//				case(ghostPix[1:0]) //Set color based on current ghost pixel.
//					2'b00: begin
//						color <= ghostColor[13:11];
//						ghostPix <= ghostPix + 1'b1;
//					end
//					2'b01: begin
//						color <= ghostColor[10:8];
//						ghostPix <= ghostPix + 1'b1;
//					end
//					2'b10: begin
//						color <= ghostColor[7:5];
//						ghostPix <= ghostPix + 1'b1;
//					end
//					2'b11: begin 
//						color <= ghostColor[4:2];
//						if(ghostPix == 255) ghostPix <= 0;
//						else ghostPix <= ghostPix + 1'b1;
//					end
//				endcase
//			end
//			else if(bright) begin 
//			case(hCount[1:0]) 
//				2'b00: color <= backColor[13:11];
//				2'b01: color <= backColor[10:8];
//				2'b10: color <= backColor[7:5];
//				2'b11: color <= backColor[4:2];
//			endcase
//		end
//			else color<= Black;
			
//			if(bright) begin //Want to update the background pixel counter every time any of the counters goes up but only if bright is high.
//				if(backPix == 639) backPix <= 0; //If at end of line reset the counter.
//				else backPix <= hCount;
//			end
//			else backPix <= backPix;
			
		end
		else begin
			ghostPix <= ghostPix;
			capPix <= capPix;
		end
	end
	
	always@(*) begin //Set RGB outputs based on color chosen above.
		if(bright) begin
			case(color)
				Black: begin
					Red = OFF; Green = OFF; Blue = OFF;
				end
				Blu: begin
					Red = 8'd99; Green = 8'd155; Blue = 8'd255; 
				end
				Yellow: begin
					Red = 8'd251; Green = 8'd242; Blue = 8'd54; 
				end
				Redd: begin
					Red = 8'd255; Green = 8'd50; Blue = 8'd50; 
				end
				Crimson: begin
					Red = 8'd172; Green = 8'd50; Blue = 8'd50; 
				end
				White: begin
					Red = ON; Green = ON; Blue = ON;
				end
				default: begin
					Red = OFF; Green = OFF; Blue = OFF;
				end
			endcase	
		end
		else begin
			Red = OFF; Green = OFF; Blue = OFF;
		end
	end
endmodule 