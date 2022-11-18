// REGISTER FILE MODULE
/*************************************************************/

module RegFile #(parameter WIDTH = 16, REGBITS = 4) (
       input                clk,
       input                regWrite, 
       input  [REGBITS-1:0] sourceAddr, destAddr, 
       input  [WIDTH-1:0]   wrData, 
       output [WIDTH-1:0]   readData1, readData2
);

       reg  [WIDTH-1:0] RAM [(1<<REGBITS)-1:0];
	
       initial begin
          $display("Loading register file");
          // you'll need to change the path to this file! 
          $readmemb("C:/Users/sizzl/OneDrive/Documents/School Documents/CS 3710/Project/CS3710-GroupProject/Helper Files/TestReg.dat", RAM); 
          $display("done with RF load"); 
       end

      // dual-ported register file
      //   read two ports combinationally
      //   write third port on rising edge of clock
      always @(posedge clk)
       if (regWrite) RAM[destAddr] <= wrData; 
	
       // register 0 is hardwired to 0
       assign readData1 = destAddr ? RAM[destAddr] : 0;
       assign readData2 = sourceAddr ? RAM[sourceAddr] : 0;
	
endmodule
