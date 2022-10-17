module AluRFonBoard #(
    parameter WIDTH = 16
) (
    input clk, reset,
	input [3:0] srcAddrSwitches,
	input [2:0] aluOp,
	output [WIDTH - 1 : 0] resultDataLeds
);
reg [WIDTH - 1 : 0] pc = 16'd0;
reg [WIDTH - 1 : 0] immd = 16'd0;
reg [WIDTH - 1 : 0] dstAddr = 16'd1;

reg pcInstruction = 1'b0;
reg rTypeInstruction = 1'b1;
reg shiftInstruction = 1'b0;
reg regWrite = 1'b0;

wire [WIDTH - 1 : 0] outputFlags;


    ALUandRF #(WIDTH) alurf (
		.clk(clk),                  //INPUT
		.reset(reset),              //INPUT
		.pc(pc),                    //HARDCODE: 0
		.srcAddr(srcAddrSwitches),  //comes from switches on Board
		.dstAddr(dstAddr),          //HARDCODE: 0 (Doesn't need to write)
		.immd(immd),                //HARDCODE: 0 (not testing immediate)
		.pcInstruction(pcInstruction),       //HARDCODE: 0 (not testing pc)
		.rTypeInstruction(rTypeInstruction), //HARDCODE: 1 (Only testing r-type)
		.shiftInstruction(shiftInstruction), //HARCODE: 0 (Not testing shift)
		.regWrite(regWrite),        //HARDCODE: 0 (not writing back to regfile)
		.aluOp(aluOp),              //INPUT
		.resultData(resultDataLeds),     //OUPTUT (Sent to be curtailed first)
		.outputFlags(outputFlags)   //Assigned but not used
	);	
    
endmodule
