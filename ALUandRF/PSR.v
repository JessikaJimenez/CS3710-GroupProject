// REGISTER FILE MODULE
/*************************************************************/

module PSR #(parameter WIDTH = 16) (
       input                clk, reset,
       input  [WIDTH-1:0]   flags, 
       output [WIDTH-1:0]   readFlags
);

       reg  [WIDTH-1:0] RAM; //Register file is 16 bits wide and 1 register deep
	
       initial begin
          RAM <= 16'd0;
       end

      // dual-ported register file
      //   read two ports combinationally
      //   write third port on rising edge of clock
      always @(negedge reset, posedge clk) begin
         if(~reset) begin
            RAM <= 16'd0; 
         end
			else RAM[WIDTH-1:0] <= flags; //Fill the register
      end
      
       assign readFlags = RAM[WIDTH-1:0]; // assign the output
	
endmodule
