// Module to take a single (4-bit) hex value and 
// display it on a 7-segment display as a number
module hexTo7Seg(
		input [15:0]x,
		output reg [6:0]z
		);

  // always @* guarantees that the circuit that is 
  // synthesized is combinational 
  // (no clocks, registers, or latches)
  always @*
    // Note that the 7-segment displays on the DE1-SoC board are
    // "active low" - a 0 turns on the segment, and 1 turns it off
    case(x)
      16'd0 : z = ~7'b0111111; // 0
      16'd1 : z = ~7'b0000110; // 1
      16'd2 : z = ~7'b1011011; // 2
      16'd3 : z = ~7'b1001111; // 3
      16'd4 : z = ~7'b1100110; // 4
      16'd5 : z = ~7'b1101101; // 5
      16'd6 : z = ~7'b1111101; // 6
      16'd7 : z = ~7'b0000111; // 7
      16'd8 : z = ~7'b1111111; // 8
      16'd9 : z = ~7'b1100111; // 9 
      16'd10 : z = ~7'b1110111; // A
      16'd11 : z = ~7'b1111100; // b
      16'd12 : z = ~7'b1011000; // c
      16'd13 : z = ~7'b1011110; // d
      16'd14 : z = ~7'b1111001; // E
      16'd15 : z = ~7'b1110001; // F
      default : z = ~7'b1001001; // Always good to have a default! 
    endcase
endmodule 