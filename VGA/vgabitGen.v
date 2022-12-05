module vgabitGen #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16)
				  (input wire bright, clk, clear, counterEnable,
					input wire [DATA_WIDTH-1:0] read_b,
					input wire [9:0] hCount, vCount,
					output reg [ADDR_WIDTH-1:0] addr_b,
				   output reg [7:0] Red, Green, Blue);
					
//4 pixel colors can be stored in one word of memory because we have 6 pre-set colors so one color can be represented in 3 bits.

//Assume sprites begin at Address 14B0 (Each sprite takes up 16*4 = 64 lines of code or 40 in hex) total memory for sprites = 1920 words
					
	//Pre-defined colors that can be displayed.
	parameter Black = 3'b000;
	parameter Blu = 3'b001;
	parameter Yellow = 3'b010;
	parameter Redd = 3'b011;
	parameter Crimson = 3'b100;
	parameter White = 3'b111;
	
	//Addresses that need accessed directly.
	 parameter spriteStorageStartAddress = 16'h14B0;
	 parameter spriteIDStartAddress = 16'h1000;
	 parameter capXAddr = 16'h1C30;
	 parameter capYAddr = 16'h1C31;
	 parameter capDirAddr = 16'h1C32;
	 parameter ghostXAddr = 16'h1C33;
	 parameter ghostYAddr = 16'h1C34;
	 parameter ghostDirAddr = 16'h1C35;
//	parameter spriteStorageStartAddress = 16'h000A;
//	parameter spriteIDStartAddress = 16'h0000;
//	parameter capXAddr = 16'h0004;
//	parameter capYAddr = 16'h0005;
//	parameter capDirAddr = 16'h0006;
//	parameter ghostXAddr = 16'h0007;
//	parameter ghostYAddr = 16'h0008;
//	parameter ghostDirAddr = 16'h0009;
	parameter mov_spritesBufStartAddr = 9'd200;
	
	//Set RGB bits to all 1's or all 0's
	parameter ON = 8'b11111111;	
	parameter OFF = 8'b00000000;
	
	//States for buffer loading
	parameter IDRead = 4'b0000;
	parameter IDStore = 4'b0001;
	parameter pixelRead1 = 4'b0010;
	parameter pixelRead2 = 4'b0011;
	parameter pixelRead3 = 4'b0100;
	parameter pixelRead4 = 4'b0101;
	parameter endSprite = 4'b0110;
	parameter endLine = 4'b0111;
	parameter endFrame = 4'b1000;
	
	//Booleans to determine what to draw.
	wire drawCapman;
	wire drawGhost;
	wire inCapVRange;
	wire inGhostVRange;
	//Addresses to look up drawing color information.
	wire [1:0] currentPixel;
	wire [ADDR_WIDTH-1:0] currentIDAddr;
	wire [ADDR_WIDTH-1:0] currentPixelAddr;
	wire [8:0] capPixBufAddr;
	wire [8:0] ghostPixBufAddr;
		reg [2:0] color;				 //Gets set based on pixel we need drawn.
	reg [15:0] currentSpriteID; //used to calculate currentPixelAddr.
	reg [8:0] bufferAddress;	 //Keeps track of where we are on drawing the background.
	reg [3:0] state, nextstate; //State of loading background into buffer.
	reg [3:0] movingSpriteInfoToGet; //Keep track of what moving sprite info we need to lookup.
	
	//Counters to set lookup addresses to the right address.
	reg [9:0] fast_hCount;
	wire [9:0] alt_vCount;
	assign alt_vCount = (vCount < 480) ? (vCount+1'b1):(9'd0);
	//reg [8:0] alt_vCount; <<changed to wire.
	reg [3:0] cap_hCount;
	reg [3:0] cap_vCount;
	reg [3:0] ghost_hCount;
	reg [3:0] ghost_vCount;
	reg [7:0] mov_spritebufferCounter; //Where we are on loading a sprite into the buffer.
	//Positions of capman and the ghost so we can know where to draw them
	reg [9:0] capHPos;
	reg [8:0] capVPos;
	reg [9:0] ghostHPos;
	reg [8:0] ghostVPos;
	reg [15:0] capDir; 		//ID of capman sprite in specific direction.
	reg [15:0] ghostDir; 	//ID of ghost sprite in specific direction.
	
	//Assign booleans based on location of capman and the ghost compared to vga beam location.
	assign drawCapman = (hCount >= capHPos) && (hCount < (capHPos + 16)) && inCapVRange;
	assign drawGhost = (hCount >= ghostHPos) && (hCount < (ghostHPos + 16)) && inGhostVRange;
	assign inCapVRange = (vCount >= capVPos) && (vCount < (capVPos + 16));
	assign inGhostVRange = (vCount >= ghostVPos) && (vCount < (ghostVPos + 16));
	//Assign addresses based on where we are on loading the buffer.
	assign currentPixel = hCount[1:0]; //Tells pixel vga beam is on.<<Testing currentIDAddr
	assign currentIDAddr = spriteIDStartAddress + fast_hCount[9:4] + alt_vCount[8:4]*16'd40;
	//assign currentIDAddr = spriteIDStartAddress + fast_hCount[5:4];
	assign currentPixelAddr = {10'd0, alt_vCount[3:0], fast_hCount[3:2]}+(currentSpriteID-16'd1)*16'd64 + spriteStorageStartAddress;
	assign capPixBufAddr = {3'd0, cap_vCount[3:0], cap_hCount[3:2]} + mov_spritesBufStartAddr;
	assign ghostPixBufAddr = {3'd0, ghost_vCount[3:0], ghost_hCount[3:2]} + 9'd64 + mov_spritesBufStartAddr;
	
//	reg [ADDR_WIDTH-1:0] movingSpriteAddr;//Register with address to a moving sprite.<<<Changed to a wire.
	wire [ADDR_WIDTH-1:0] movingSpriteAddr;
	assign movingSpriteAddr = (((mov_spritebufferCounter<64) ? capDir:ghostDir)-1'b1)*16'd64+spriteStorageStartAddress;
	
	//Tells if we are loading the background into buffer.
	reg loading; 				
	
	//Buffer for one line of the screen and moving sprites.
	reg [DATA_WIDTH-1:0] buffer[(1<<9)-1:0];
	
	always @(negedge clear, posedge clk) begin
		if(~clear) state <= IDRead;
		else state <= nextstate;
	 end

	always@(*) begin //Switch between states.
	//if(loading) begin
		case(state)
			IDRead: nextstate <= IDStore;
			IDStore: nextstate <= pixelRead1;
			pixelRead1: nextstate <= pixelRead2;
			pixelRead2: nextstate <= pixelRead3;
			pixelRead3: nextstate <= pixelRead4;
			pixelRead4: nextstate <= endSprite;
			endSprite: begin
//				if(fast_hCount >= 636 && alt_vCount < 479) nextstate <= endLine;
//				else if(fast_hCount >= 636 && alt_vCount >= 479) nextstate <= endFrame;
				if(fast_hCount > 636 && alt_vCount < 479) nextstate <= endLine;
				else if(fast_hCount > 636 && alt_vCount >= 479) nextstate <= endFrame;
				else nextstate <= IDRead;
			end
			endLine: nextstate <= IDRead;
			endFrame: nextstate <= IDRead;
			default: nextstate <= IDRead;
		endcase
	//end
	//else nextstate <= nextstate;
	end
	
	always@(negedge clear, posedge clk) begin //Load pixel info based on state and loading bool value.
		if(~clear) addr_b <= spriteIDStartAddress;
		else if(loading) begin
			case(state)
				IDRead: addr_b <= currentIDAddr;			//Get the sprite ID from Memory
				IDStore: currentSpriteID <= read_b;		//Store the ID of the sprite to the side
				pixelRead1: begin
					addr_b <= currentPixelAddr;			//Get the first 4 pixels using sprite ID to get pixel location
					fast_hCount <= fast_hCount + 10'd4; //Move to the next 4 pixels
				end
				pixelRead2: begin
					if(currentSpriteID == 16'd0) buffer[fast_hCount[9:2]-1] <= 16'd0; //If in blank square store blank pixels in buffer.
					else buffer[fast_hCount[9:2]-1] <= read_b; 								//Load first 4 pixels to the buffer.
					addr_b <= currentPixelAddr; 			  										//Get the next 4 pixels.
					fast_hCount <= fast_hCount + 10'd4;	  										//Move to next 4.
				end
				pixelRead3: begin
					if(currentSpriteID == 16'd0) buffer[fast_hCount[9:2]-1] <= 16'd0; //"
					else buffer[fast_hCount[9:2]-1] <= read_b; 								//"
					addr_b <= currentPixelAddr;			  										//"
					fast_hCount <= fast_hCount + 10'd4;	  										//"
				end
				pixelRead4: begin
					if(currentSpriteID == 16'd0) buffer[fast_hCount[9:2]-1] <= 16'd0; //"
					else buffer[fast_hCount[9:2]-1] <= read_b; 								//"
					addr_b <= currentPixelAddr;			  		 								//"
					fast_hCount <= fast_hCount + 10'd4;	  		 								//"
				end
				endSprite: begin
					if(currentSpriteID == 16'd0) buffer[fast_hCount[9:2]-1] <= 16'd0; //If in blank square store blank pixels in buffer.
					else buffer[fast_hCount[9:2]-1] <= read_b; //Load last 4 pixels of sprite to buffer.
					//fast_hCount <= fast_hCount + 10'd4;	//<<TestCode
				end
				endLine: fast_hCount <= 0;							//Reset the buffer's hCount
				endFrame: begin
					fast_hCount <= 0;							//Reset buffer's hCount
					movingSpriteInfoToGet <= 4'b0000;
				end
				default: addr_b <= currentIDAddr;
			endcase
		end
		else if (movingSpriteInfoToGet < 4'b1010) begin 
			case(movingSpriteInfoToGet)
				4'b0000: begin
					addr_b <= capXAddr;
					movingSpriteInfoToGet <= 4'b0001;
				end
				4'b0001: begin
					capHPos <= read_b[9:0];
					addr_b <= capYAddr;
					movingSpriteInfoToGet <= 4'b0010;
				end
				4'b0010: begin
					capVPos <= read_b[8:0];
					addr_b <= capDirAddr;
					movingSpriteInfoToGet <= 4'b0011;
				end
				4'b0011: begin
					capDir <= read_b;
					addr_b <= ghostXAddr;
					movingSpriteInfoToGet <= 4'b0100;
				end
				4'b0100: begin
					ghostHPos <= read_b[9:0];
					addr_b <= ghostYAddr;
					movingSpriteInfoToGet <= 4'b0101;
				end
				4'b0101: begin
					ghostVPos <= read_b[8:0];
					addr_b <= ghostDirAddr;
					movingSpriteInfoToGet <= 4'b0110;
				end
				4'b0110: begin
					ghostDir <= read_b;
					movingSpriteInfoToGet <= 4'b0111;
				end
				4'b0111: begin
					if(mov_spritebufferCounter < 64)
						addr_b <= movingSpriteAddr + mov_spritebufferCounter;
					else 
						addr_b <= movingSpriteAddr + mov_spritebufferCounter - 16'd64;
					movingSpriteInfoToGet <= 4'b1000;
				end
				4'b1000: begin
					buffer[mov_spritebufferCounter + 200] <= read_b;
					movingSpriteInfoToGet <= 4'b1001;
				end
				4'b1001: begin
					if(mov_spritebufferCounter < 128) begin
						mov_spritebufferCounter <= mov_spritebufferCounter + 1'd1;
						movingSpriteInfoToGet <= 4'b0111;
					end
					else begin
						mov_spritebufferCounter <= 0;
						movingSpriteInfoToGet <= 4'b1010;
					end
				end
				default: addr_b <= currentIDAddr;
			endcase
		end
		else addr_b <= addr_b;
	end
// always@(*)	
	always@(*)begin //Set the enable signal for the addr_b use.
		if(hCount > 639 && vCount < 479 || vCount > 500) loading <= 1;
//		if(hCount > 640 && vCount < 480 || vCount > 500) loading <= 1;
		else loading <= 0;
	end
	always@(negedge clear, posedge clk)begin //Update counters that go along with vgaDisplay.
		if(~clear) begin
			cap_hCount <= 0;
			cap_vCount <= 0;
			ghost_hCount <= 0;
			ghost_vCount <= 0;
			bufferAddress <= 0;
		end
		else if(counterEnable) begin
			//Determine if we need to update horizontal counts and update them.
			if(drawGhost) ghost_hCount <= ghost_hCount + 1'b1;
			else if(drawCapman) cap_hCount <= cap_hCount + 1'b1;
			else begin
				ghost_hCount <= 0;
				cap_hCount <= 0;
			end
			
			//Determine if we need to update verticle counts and update them.
			if(inGhostVRange && vCount != ghostVPos) ghost_vCount <= ghost_vCount + 1'b1;
			else ghost_vCount <= 0;
			if(inCapVRange && vCount != capVPos) cap_vCount <= cap_vCount + 1'b1;
			else cap_vCount <= 0;
			
			if(hCount > 640) bufferAddress <= 0;
			else if(currentPixel == 2'b11) bufferAddress <= bufferAddress + 1'b1;
			else bufferAddress <= bufferAddress;
				
		end
		else begin
			ghost_hCount <= ghost_hCount;
			cap_hCount <= cap_hCount;
			cap_vCount <= cap_vCount;
			ghost_vCount <= ghost_vCount;
			bufferAddress <= bufferAddress;
		end
	end
// always@(*)
	always@(negedge clk) begin //Choose color.
		if(drawGhost) begin 
			case(ghost_hCount[1:0]) 
				2'b00: color <= buffer[ghostPixBufAddr][13:11];
				2'b01: color <= buffer[ghostPixBufAddr][10:8];
				2'b10: color <= buffer[ghostPixBufAddr][7:5];
				2'b11: color <= buffer[ghostPixBufAddr][4:2];
			endcase
		end
		else if (drawCapman) begin 
			case(cap_hCount[1:0]) 
				2'b00: color <= buffer[capPixBufAddr][13:11];
				2'b01: color <= buffer[capPixBufAddr][10:8];
				2'b10: color <= buffer[capPixBufAddr][7:5];
				2'b11: color <= buffer[capPixBufAddr][4:2];
			endcase
		end
		else if(bright) begin 
			case(currentPixel) 
				2'b00: color <= buffer[bufferAddress][13:11];
				2'b01: color <= buffer[bufferAddress][10:8];
				2'b10: color <= buffer[bufferAddress][7:5];
				2'b11: color <= buffer[bufferAddress][4:2];
			endcase
		end
		else color<= Black;
	end
	
	
	always@(*) begin //Set RGB outputs based on color.
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