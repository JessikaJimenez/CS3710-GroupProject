// REGISTER FILE MODULE
/*************************************************************/

module RegFile #(parameter WIDTH = 16, REGBITS = 4) (
       input                clk, reset,
       input                regWrite, 
       input  [REGBITS-1:0] sourceAddr, destAddr, 
       input  [WIDTH-1:0]   wrData, 
       output [WIDTH-1:0]   readData1, readData2
);

       reg  [WIDTH-1:0] RAM [(1<<REGBITS)-1:0];
	
       initial begin
          $display("Loading register file");
          // you'll need to change the path to this file! 
          $readmemb("C:/Users/danie/Documents/Homework/22 Fall/ECE 3710/Quartus/ALUandRegister/CS3710-GroupProject/Helper Files/TestReg.dat", RAM); 
          $display("done with RF load"); 
       end

      // dual-ported register file
      //   read two ports combinationally
      //   write third port on rising edge of clock
      always @(posedge clk) begin
         if(~reset) begin
            $display("Loading register file");
	    // you'll need to change the path to this file! 
	    $readmemb("C:/Users/danie/Documents/Homework/22 Fall/ECE 3710/Quartus/ALUandRegister/CS3710-GroupProject/Helper Files/TestReg.dat", RAM); 
	    $display("done with RF load"); 
         end
         if (regWrite) RAM[destAddr] <= wrData;
      end     
	
       // register 0 is hardwired to 0
       assign readData1 = destAddr ? RAM[destAddr] : 0;
       assign readData2 = sourceAddr ? RAM[sourceAddr] : 0;
	
endmodule
