// PSR MODULE
/*************************************************************/

module PSR #(parameter WIDTH = 16) (
       input                clk, reset,
       input  [WIDTH-1:0]   flags, 
       input flagSet,
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
			else if (flagSet) RAM[WIDTH-1:0] <= flags; //Fill the register with input flags
      end
      
       assign readFlags = RAM[WIDTH-1:0]; // assign the output
	
endmodule
