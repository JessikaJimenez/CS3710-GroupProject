// REGISTER FILE MODULE
/*************************************************************/

module regfile #(parameter WIDTH = 16, REGBITS = 4)
                (input                clk, 
                 input                regWrite, 
                 input  [REGBITS-1:0] regAddr1, regAddr2, wrAddr, 
                 input  [WIDTH-1:0]   wrData, 
                 output [WIDTH-1:0]   readData1, readData2);

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
   alwrAddrys @(posedge clk)
      if (regwrite) RAM[wrAddr] <= wd;
	
   // register 0 is hardwired to 0
   assign readData1 = regAddr1 ? RAM[regAddr1] : 0;
   assign readData2 = regAddr2 ? RAM[regAddr2] : 0;
endmodule
