module vgabitGen #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16)
				  (input wire bright, clk, clear,
					input wire [DATA_WIDTH-1:0] read_b,
					input wire [9:0] hCount, vCount, fast_hCount,
					output reg [ADDR_WIDTH-1:0] addr_b,
				   output reg [7:0] Red, Green, Blue);
					
//4 pixel colors can be stored in one word of memory because we have 6 pre-set colors.

//Assume sprites begin at Address C000 (Each sprite takes up 16*4 = 64 lines of code or 40 in hex) total memory for sprites = 1920 words

//When storing sprite ID's in memory we need to start on address 0 Count by 32 (39 times) up to 1248
								//Once we get to 1248 go down to address 1 Count by 32 (39 times) up to 1249... and so on.
					
	//Pre-defined colors that can be displayed.
	parameter Black = 3'b000;
	parameter Blu = 3'b001;
	parameter Yellow = 3'b010;
	parameter Red = 3'b011;
	parameter Crimson = 3'b100;
	parameter White = 3'b111;
	
	parameter spriteStorageStartAddress = 16'hC4B0;
	parameter spriteIDStartAddress = 16'hC000;
	
	//Set RGB bits to all 1's or all 0's
	parameter ON = 8'b11111111;	
	parameter OFF = 8'b00000000;
	parameter IDRead = 2'b00;
	parameter pixelRead1 = 2'b01;
	parameter pixelRead2 = 2'b10;
	parameter pixelRead3 = 2'b10;
	parameter pixelRead4 = 2'b10;
	parameter Store = 3'b000;
	parameter Idle = 2'b11;
	
	reg [2:0] color;
	
	wire [ADDR_WIDTH-1:0] currentSpriteAddr;
	//reg [ADDR_WIDTH-1:0] nextSpriteAddr;
	wire [ADDR_WIDTH-1:0] currentPixelAddr;
	
	reg [1:0] currentPixel;
	reg [15:0] currentSpriteID
	reg [DATA_WIDTH-1:0] pixelColorsFromMem;
	reg [7:0] bufferAddress;
	//reg IDRead;
	reg state, nextstate;
	assign currentIDAddr <= spriteIDStartAddress + fast_hCount[9:4] + alt_vCount[8:4]*16'd40;
	assign currentPixelAddr <= {10'd0, alt_vCount[3:0], fast_hCount[3:2]}+currentSpriteID*16'd64 + spriteStorageStartAddress;
	
	//reg findSprite;
	//reg enableNewPixels;
	
	reg [9:0] fast_hCount [9:0];
	reg [8:0] alt_vCount [8:0];
	reg [9:0] pacHPos;
	reg [8:0] pacVPos;
	reg [9:0] ghostHPos;
	reg [8:0] ghostVPos;
	
	
	//Buffer for one line of the screen.
	reg [DATA_WIDTH-1:0] buffer[(1<<8)-1:0];
	
	    always @(posedge clk)
      if(~clear) state <= IDRead;
      else state <= nextstate;

	always@(*) begin
		case(state)
			IDRead: nextstate <= IDStore;
			IDStore: nextstate <= pixelRead1;
			pixelRead1: nextstate <= pixelRead2;
			pixelRead2: nextstate <= pixelRead3;
			pixelRead3: nextstate <= pixelRead4;
			pixelRead4: begin
				if(fast_hCount >= 636 && atl_vCount < 479) nextstate <= endLine;
				else if(fast_hCount >= 636 && atl_vCount == 479) nextstate <= endFrame;
				else nextstate <= IDRead;
			end
			endLine: begin
				if(fast_hCount == 800)
					nextstate <= IDRead;
				else 
					nextstate <= Idle;
			end
		endcase
	end
	
	always@(*) begin
		case(state)
			IDRead: begin
				buffer[fast_hCount[9:2]-1] <= read_b;
				addr_b <= currentIDAddr;
			end
			IDStore: currentSpriteID <= read_b;
			pixelRead1: begin
				addr_b <= currentPixelAddr;
				fast_hCount <= fast_hCount + 10'd4;
			end
			pixelRead2: begin
				buffer[fast_hCount[9:2]-1] <= read_b;
				addr_b <= currentPixelAddr;
				fast_hCount <= fast_hCount + 10'd4;
			end
			pixelRead3: begin
				buffer[fast_hCount[9:2]-1] <= read_b;
				addr_b <= currentPixelAddr;
				fast_hCount <= fast_hCount + 10'd4;
			end
			pixelRead4: begin
				buffer[fast_hCount[9:2]-1] <= read_b;
				addr_b <= currentPixelAddr;
				fast_hCount <= fast_hCount + 10'd4;
			end
			endLine: begin
				loading <= 0;
				fast_hCount <= 0;
				alt_vCount <= alt_vCount + 9'd1;
			end
			endFrame: begin
				loading <= 0;
				fast_hCount <= 0;
				alt_vCount <= 0;
			end
			
	end
	
	
	
	//Set the enable signals for the addr_b use.
	always@(*)begin
		if(
			
	end
	//Set current 
	always@(*)begin
		if(findSpriteEnable)begin
			addr_b = nextSpriteAddr;
		end	
		else
	end
	always@(*) begin
		if(bright) begin
			//Taking the most significant bits of counters as the sprite address.
			currentSpriteAddr <= {5'd0, fast_hCount[9:4], vCount[8:4]};
			
			if(hCount[9:4] == 6'd39 && vCount[8:4] == 5'd29)begin
				nextSpriteAddr <= 16'd0;
			end
			else if(hCount[9:4] == 6'd39)begin
				nextSpriteAddr <= {11'd0, vCount[8:4]+1}
			end
			else begin
				nextSpriteAddr <= {5'd0, hCount[9:4]+1, vCount[8:4]};
			end
			
			//CurrentPixelAddr = pixelWeAreOn/4 + ID*64 + SpriteStorageStartingAddress. (64 words of memory stores 1 sprite)
 			currentPixelAddr <= {10'd0, vCount[3:0], hCount[3:2]}+currentSpriteID*16'd64 + spriteStorageStartAddress;
			
			currentPixel <= hCount[1:0];
		end
	end
	
	always@(*) begin
		case(currentPixel)
			00: begin
				color = pixelColorsFromMem[13:11];
				if(hCount[3:0] == 4'd12) begin
					currentSpriteID = read_b;
					findSprite = 0;
				end
			end
			01: color = pixelColorsFromMem[10:8];
			10: color = pixelColorsFromMem[7:5];
			11: begin
				color = pixelColorsFromMem[4:2];
				pixelColorsFromMem = read_b;
				if(hCount[3:0] == 4'd15) begin
					findSprite = 1;
				end
			end
		endcase
	end
	
	//Set Color outputs.
	always@(*) begin
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
				Red: begin
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
endmodule 
