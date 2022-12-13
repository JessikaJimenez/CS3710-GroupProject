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
					
// Pre-defined colors that can be displayed. These bit values are stored in memory.
	parameter Black = 3'b000;
	parameter Blu = 3'b001;
	parameter Yellow = 3'b010;
	parameter Redd = 3'b011;
	parameter Crimson = 3'b100;
	parameter White = 3'b111;
	
// Addresses that need accessed directly.
	 parameter frameFinishedFlagAddress = 16'h1DD5;
	 parameter spriteStorageStartAddress = 16'h14B0;
	 parameter spriteIDStartAddress = 16'h1000;
	 parameter capXAddr = 16'h1C30;
	 parameter capYAddr = 16'h1C31;
	 parameter capDirAddr = 16'h1C32;
	 parameter ghostXAddr = 16'h1C33;
	 parameter ghostYAddr = 16'h1C34;
	 parameter ghostDirAddr = 16'h1C35;
	 parameter mov_spritesBufStartAddr = 11'd1100;
	
// Set RGB bits to all 1's or all 0's
	parameter ON = 8'b11111111;	
	parameter OFF = 8'b00000000;
	
// States for background buffer loading
	parameter IDRead = 4'b0000;			//Set addr_b to currentIDAddr.
	parameter IDStore = 4'b0001;		//Store the ID at addr_b in a register.
	parameter pixelRead = 4'b0010;		//Set addr_b to currentPixelAddr which will return 4 pixel colors.
	parameter pixelStore = 4'b0011;		//Store the 4 color values in 4 different lines of the buffer.
	parameter endLine = 4'b0111;		//Reset horizontal count.
	parameter endFrame = 4'b1000;		//Increment frame counter and set frameFinishedFlag to 1 and reset horizontal counter. Move on to getting new moving sprite info.
	
	reg [4:0] animationCounter;			//Tells us when to Switch between certain sprites in the animation.
	
	reg [2:0] color;				 	//Gets set based on pixel we need drawn.
	reg [15:0] currentSpriteID; 		//Used to calculate currentPixelAddr and is an ID from 1-30 (The number of sprites we use).
	reg [3:0] state, nextstate; 		//State of loading background into buffer.
	reg [3:0] movingSpriteInfoToGet; 	//Keep track of what moving sprite info we need to lookup and put into the buffer/registers.
	
// Counters to set lookup addresses to the right address.
	reg [9:0] fast_hCount; 				//Counts by 4 (because 4 colors are at one address) and is tied to a faster clock than the vga clock so we can quickly load the buffer.
	wire [9:0] alt_vCount;				//Always one higher than vCount unless vCount is beyond the vertical range of the screen, then it is 0.

	assign alt_vCount = (vCount < 479) ? (vCount+1'b1):(9'd0); 	
	
	reg [7:0] ghostPix;		 			//Where we are on drawing ghost sprite.
	reg [7:0] capPix;					//Where we are on drawing Capman sprite.
	reg [10:0] mov_spritebufferCounter; //location offset for loading sprites into buffer.
	
// Positions of capman and the ghost so we can know where to draw them
	reg [9:0] capHPos;		//pull from memory address listed in parameters as capXAddr.
	reg [8:0] capVPos;		//pull from memory address listed in parameters as capYAddr.
	reg [9:0] ghostHPos;	//pull from memory address listed in parameters as ghostXAddr.
	reg [8:0] ghostVPos;	//pull from memory address listed in parameters as ghostYAddr.
	reg [15:0] capDir; 		//ID of capman sprite in specific direction. (To do animation we switch between this sprite and the sprite just after this one)
	reg [15:0] ghostDir; 	//ID of ghost sprite in specific direction. (To do animation we switch between this sprite and the sprite just after this one)

// Buffer for one line of the screen and moving sprites.
	reg [DATA_WIDTH-1:0] buffer[(1<<11)-1:0];
	
	initial begin 				//Initializations used for simulation.
		fast_hCount <= 10'd0;
		ghostPix <= 8'd0;
		capPix <= 8'd0;
		mov_spritebufferCounter <= 11'd0;
		animationCounter <= 0;
	end
	
// Booleans to determine what to draw.
	wire inCapVRange;
	wire inGhostVRange;
	wire drawCapman; 			//Tells us if we are in Capman's v-range and in his h-range.
	wire drawGhost;				//Tells us if we are in the Ghost's v-range and in his h-range.
	
// Addresses to look up drawing color information.
	wire [ADDR_WIDTH-1:0] currentIDAddr;		//Set addr_b to this to get the ID of the sprite we need to load into the buffer at the moment.
	wire [ADDR_WIDTH-1:0] currentPixelAddr;		//Set addr_b to this to get the current pixels we need to load into the buffer.
	wire [10:0] capPixBufAddr;					//Exact location of color we currently need to draw if we are drawing Capman.
	wire [10:0] ghostPixBufAddr;				//Exact location of color we currently need to draw if we are drawing ghost.

	
	wire [2:0] mov_SpriteColor;					//Pulls a capman color from buffer if drawCapman is true and a ghost color if it is false (using capPixBufAddr/ghostPixBufAddr)
	wire draw_movSprite;						//== 1 if either drawCapman or drawGhost are true.
	wire loadingTime;							//Loading time = 1 means we are loading background 0 means we see if we should load a moving sprite.
	wire [ADDR_WIDTH-1:0] movingSpriteAddr; 	//Address of moving sprite we need to load into buffer. (Based on capDir/ghostDir (IDs))
	
// Assign booleans so we know when to load moving sprites into line buffer.
	assign inCapVRange = (vCount >= capVPos) && (vCount < (capVPos + 16));
	assign inGhostVRange = (vCount >= ghostVPos) && (vCount < (ghostVPos + 16));
	assign drawCapman = (hCount >= capHPos) && (hCount < (capHPos + 16)) && inCapVRange;
	assign drawGhost = (hCount >= ghostHPos) && (hCount < (ghostHPos + 16)) && inGhostVRange;
	
// Assign addresses based on where we are on loading the buffer.
	assign currentIDAddr = spriteIDStartAddress + fast_hCount[9:4] + alt_vCount[8:4]*16'd40;
	assign currentPixelAddr = {10'd0, alt_vCount[3:0], fast_hCount[3:2]}+(currentSpriteID-16'd1)*16'd64 + spriteStorageStartAddress;
	assign movingSpriteAddr [ADDR_WIDTH-1:0] = (((mov_spritebufferCounter<256) ? capDir:ghostDir)-1'b1)*16'd64+spriteStorageStartAddress;

// Assign based on where we are on drawing moving sprites.
	assign capPixBufAddr = {3'd0, capPix} + mov_spritesBufStartAddr;
	assign ghostPixBufAddr = {3'd0, ghostPix} + 11'd256 + mov_spritesBufStartAddr;
	
// Tells if we are loading the background into buffer.
	assign loadingTime = hCount >= 600 && vCount < 480;

// Tells if we should draw a moving sprite or the background and which moving sprite to draw.
	assign mov_SpriteColor = drawCapman ? (buffer[capPixBufAddr][2:0]):(buffer[ghostPixBufAddr][2:0]);
	assign draw_movSprite = drawCapman || drawGhost;
	
	always @(negedge clear, posedge clk) begin
		if(~clear) state <= IDRead;
		else state <= nextstate;
	 end

	always@(*) begin 			//Switch between states.
		if(loadingTime) begin
			case(state)
				IDRead: nextstate <= IDStore;
				IDStore: nextstate <= pixelRead;
				pixelRead: nextstate <= pixelStore;
				pixelStore: begin
					if(fast_hCount == 636 && alt_vCount < 479) nextstate <= endLine; 			//If we are at end of line.
					else if(fast_hCount == 636 && alt_vCount >= 479) nextstate <= endFrame;		//If we are at end of frame.
					else if(fast_hCount[3:0] == 12) nextstate <= IDRead;						//If we need a new move to next sprite.
					else nextstate <= pixelRead;												//If we need to get new pixels from the same sprite.
				end
				endLine: nextstate <= IDRead;
				endFrame: nextstate <= IDRead;
				default: nextstate <= IDRead;
			endcase
		end
		else nextstate <= IDRead;
	end
	
	always@(negedge clear, posedge clk) begin 		//Load pixel info based on state and loadingTime bool value.
		if(~clear) addr_b <= spriteIDStartAddress; 		//Set addr_b to first ID address.
		else if(loadingTime) begin
			case(state)
				IDRead: begin
					addr_b <= currentIDAddr;			//Get the sprite ID from Memory
					write_b <= 0;
				end
				IDStore: currentSpriteID <= read_b;		//Store the ID of the sprite to the side
				pixelRead: begin
					addr_b <= currentPixelAddr;			//Get 4 pixels from memory
				end
				pixelStore: begin
					buffer[fast_hCount] <= (currentSpriteID == 0) ? (16'd0):(read_b[13:11]);
					buffer[fast_hCount + 1] <= (currentSpriteID == 0) ? (16'd0):(read_b[10:8]);
					buffer[fast_hCount + 2] <= (currentSpriteID == 0) ? (16'd0):(read_b[7:5]);
					buffer[fast_hCount + 3] <= (currentSpriteID == 0) ? (16'd0):(read_b[4:2]);
					fast_hCount <= fast_hCount + 10'd4;	  										//Move to next pixel address (4 pixels).
				end
				endLine: fast_hCount <= 0;						//Reset the buffer's hCount
				endFrame: begin
					fast_hCount <= 0;							//Reset buffer's hCount
					movingSpriteInfoToGet <= 4'b0000;   		//Start getting moving sprite info imediately after frame loading is complete
					addr_b <= frameFinishedFlagAddress;
					write_b <= 1;								//enable writing to memory to store end of frame flag.
					animationCounter <= animationCounter + 5'd1;//increment animation counter.
				end
				default: addr_b <= currentIDAddr;
			endcase
		end
		else if (movingSpriteInfoToGet < 4'b1010) begin //If we need new moving sprite info.
			case(movingSpriteInfoToGet)
				4'b0000: begin 							//Get cap x-pos from memory.
					addr_b <= capXAddr;
					movingSpriteInfoToGet <= 4'b0001;
				end
				4'b0001: begin 							//Store cap x-pos. Get cap y-pos from memory.
					capHPos <= read_b[9:0];
					addr_b <= capYAddr;
					movingSpriteInfoToGet <= 4'b0010;
				end
				4'b0010: begin 							//Store cap y-pos. Get cap direction from memory (direction is just a sprite ID).
					capVPos <= read_b[8:0];
					addr_b <= capDirAddr;
					movingSpriteInfoToGet <= 4'b0011;
				end
				4'b0011: begin 							//Store cap direction (Sprite ID, based on animationCounter). Get ghost x-pos from memory.
					capDir <= (read_b == 22) ? read_b:(animationCounter[4] ? read_b:(read_b + 1'd1));
					addr_b <= ghostXAddr;
					movingSpriteInfoToGet <= 4'b0100;
				end
				4'b0100: begin 							//Store ghost x-pos. Get ghost y-pos from memory.
					ghostHPos <= read_b[9:0];
					addr_b <= ghostYAddr;
					movingSpriteInfoToGet <= 4'b0101;
				end
				4'b0101: begin 							//Store ghost y-pos. Get ghost direction from memory (direction is just a sprite ID).
					ghostVPos <= read_b[8:0];
					addr_b <= ghostDirAddr;
					movingSpriteInfoToGet <= 4'b0110;
				end
				4'b0110: begin 							//Store ghost direction (Sprite ID, based on animationCounter).
					ghostDir <= animationCounter[4] ? read_b:(read_b + 1'd1);
					movingSpriteInfoToGet <= 4'b0111;
				end
				4'b0111: begin 							//Start of loop to store moving sprite pixels into the buffer.
					if(mov_spritebufferCounter < 256)
						addr_b <= movingSpriteAddr + mov_spritebufferCounter[8:2]; 			//Get Capman pixels from memory.
					else 
						addr_b <= movingSpriteAddr + mov_spritebufferCounter[8:2] - 16'd64; //Get Ghost pixels from memory (-64 because mov_spritebufferCounter is too high).
					movingSpriteInfoToGet <= 4'b1000;
				end
				4'b1000: 								//Store each pixel in its own line of the buffer.
					buffer[mov_spritebufferCounter + mov_spritesBufStartAddr] <= read_b[13:11]; 		//Store moving sprite pixel.
					buffer[mov_spritebufferCounter + mov_spritesBufStartAddr + 11'd1] <= read_b[10:8]; 	//Store moving sprite pixel.
					buffer[mov_spritebufferCounter + mov_spritesBufStartAddr + 11'd2] <= read_b[7:5]; 	//Store moving sprite pixel.
					buffer[mov_spritebufferCounter + mov_spritesBufStartAddr + 11'd3] <= read_b[4:2]; 	//Store moving sprite pixel.
					movingSpriteInfoToGet <= 4'b1001;
				end
				4'b1001: begin
					if(mov_spritebufferCounter < 512) begin
						mov_spritebufferCounter <= mov_spritebufferCounter + 9'd4; 	//Move on to next pixel buffer storage location.
						movingSpriteInfoToGet <= 4'b0111; 							//Go back to start of loop if we are not finished loading both moving sprites.
					end
					else begin
						mov_spritebufferCounter <= 0; 	 							//Reset counter for next time we store moving sprites to buffer.
						movingSpriteInfoToGet <= 4'b1010; 							//Get out of loop.
					end
				end
				default: addr_b <= currentIDAddr;
			endcase
		end
		else addr_b <= addr_b;
	end
	
	always@(negedge clk) begin //Choose color.
		if(counterEnable) begin 												//Syncs this always block with the VGA Clock.
			color <= draw_movSprite ? mov_SpriteColor:buffer[hCount][2:0];		//Set the color to moving sprite color or background color.

		//Update moving sprite counters.
			if(drawGhost) ghostPix <= ghostPix + 1'd1;	 						
			else ghostPix <= ghostPix;
			if(drawCapman) capPix <= capPix + 1'd1;
			else capPix <= capPix;
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