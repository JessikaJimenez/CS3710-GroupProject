module CPU (
	input wire clk,        //on-board 50MHz clock
	input wire reset,      //button KEY3
	input wire [9:0] sw,   //switches SW9-SW0
	output reg [9:0] leds  //LEDs LEDR9-LEDR0
);

	//**TODO -- something something compile BoardProgram.txt
	// and put that in a .dat file which gets loaded into memory


	// Sets output LEDs based on input switches
	always @(*) begin
		if (~reset) begin
			leds <= 10'b0;
		end
		else begin
			case (sw)
				10'b0000000001:	begin   // LED 0
						leds <= 10'b0000000001;
						end
				10'b0000000010:	begin   // LED 1
						leds <= 10'b0000000010;
						end
				10'b0000000100:	begin   // LED 2
						leds <= 10'b0000000100;
						end
				10'b0000001000:	begin   // LED 3
						leds <= 10'b0000001000;
						end
				10'b0000010000:	begin   // LED 4
						leds <= 10'b0000010000;
						end
				10'b0000100000:	begin   // LED 5
						leds <= 10'b0000100000;
						end
				10'b0001000000:	begin   // LED 6
						leds <= 10'b0001000000;
						end
				10'b0010000000:	begin   // LED 7
						leds <= 10'b0010000000;
						end	
				10'b0100000000:	begin   // LED 8
						leds <= 10'b0100000000;
						end
				10'b1000000000:	begin   // LED 9
						leds <= 10'b1000000000;
						end									
				 default: 	begin   // off
						leds <= 10'b0;
						end
			endcase 
		end
	end


endmodule 
