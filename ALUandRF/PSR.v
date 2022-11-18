// PSR MODULE
/*************************************************************/

module PSR #(parameter WIDTH = 16) (
       input                clk, reset,
       input  [WIDTH-1:0]   flags, 
       input flagSetArithmetic, flagSetCompare,
       output [WIDTH-1:0]   readFlags
);

       reg  [WIDTH-1:0] RAM; //Register file is 16 bits wide and 1 register deep
	
       initial begin
          RAM <= 16'd0; //Clear the register
       end

      always @(negedge reset, posedge clk) begin
         if(~reset) begin
            RAM <= 16'd0; //Clear the register
         end
			else if (flagSetArithmetic) RAM[WIDTH-1:0] <= {readFlags[WIDTH-1:3], flags[2], readFlags[1], flags[0]}; // Overwrite C and F
         else if (flagSetCompare) RAM[WIDTH-1:0] <= {readFlags[WIDTH-1:5], flags[4:3], readFlags[2], flags[1], readFlags[0]}; // Overwrite N, L, Z
      end
      
       assign readFlags = RAM[WIDTH-1:0]; // assign the output
	
endmodule
