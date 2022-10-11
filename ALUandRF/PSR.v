// REGISTER FILE MODULE
/*************************************************************/

module PSR #(parameter WIDTH = 16) (
       input                clk,
       input  [WIDTH-1:0]   flags, 
       output [WIDTH-1:0]   readFlags
);

       reg  [WIDTH-1:0] RAM; //Register file is 16 bits wide and 1 register deep
	
       initial begin
          $display("Loading register file");
          // you'll need to change the path to this file! 
          $readmemb("C:/Users/danie/Documents/Homework/22 Fall/ECE 3710/Quartus/MiniMips/reg.dat", RAM); 
          $display("done with RF load"); 
       end

   // dual-ported register file
   //   read two ports combinationally
   //   write third port on rising edge of clock
   always @(negedge reset, posedge clk) begin
      if(~reset) begin
        $display("Loading register file");
	      // you'll need to change the path to this file! 
	      $readmemb("C:/Users/danie/Documents/Homework/22 Fall/ECE 3710/Quartus/MiniMips/reg.dat", RAM); 
	      $display("done with RF load"); 
      end

      RAM[conditionAddr] <= flags; //Fill the register
   end
      
       assign readFlags = RAM[regAddr1]; // assign the output
endmodule
