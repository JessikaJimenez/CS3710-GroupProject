// REGISTER FILE MODULE
/*************************************************************/

module regfile #(parameter WIDTH = 16, REGBITS = 4)
                (input                clk, 
                 input                regwrite, 
                 input  [REGBITS-1:0] ra1, ra2, wa, 
                 input  [WIDTH-1:0]   wd, 
                 output [WIDTH-1:0]   rd1, rd2);

   reg  [WIDTH-1:0] RAM [(1<<REGBITS)-1:0];
	
	initial begin
	$display("Loading register file");
	// you'll need to change the path to this file! 
	$readmemb("C:/Users/danie/Documents/Homework/22 Fall/ECE 3710/Quartus/MiniMips/reg.dat", RAM); 
	$display("done with RF load"); 
	end

   // dual-ported register file
   //   read two ports combinationally
   //   write third port on rising edge of clock
   always @(posedge clk)
      if (regwrite) RAM[wa] <= wd;
	
   // register 0 is hardwired to 0
   assign rd1 = ra1 ? RAM[ra1] : 0;
   assign rd2 = ra2 ? RAM[ra2] : 0;
endmodule
