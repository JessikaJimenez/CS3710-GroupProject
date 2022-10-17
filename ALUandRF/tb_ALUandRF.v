// TESTBENCH FOR ALU AND REGISTER FILE
/*************************************************************/
`timescale 1ns/1ns

module tb_ALUandRF #(parameter WIDTH = 16) ();

	reg clk, reset;
	reg [WIDTH - 1 : 0] pc, immd;
	reg regWrite;
	wire [3:0] srcAddr, dstAddr;
	wire pcInstruction, rTypeInstruction, shiftInstruction, flagSet, copyInstruction;
	wire [2:0] aluOp;
	wire [WIDTH - 1 : 0] resultData;
	wire [WIDTH - 1 : 0] outputFlags;

	// Instantiate top level module
	ALUandRF #(WIDTH) alurf (
		.clk(clk),
		.reset(reset),
		.pc(pc), 
		.srcAddr(srcAddr), 
		.dstAddr(dstAddr), 
		.immd(immd),
		.pcInstruction(pcInstruction), 
		.rTypeInstruction(rTypeInstruction), 
		.shiftInstruction(shiftInstruction), 
		.flagSet(flagSet),
		.copyInstruction(copyInstruction),
		.regWrite(regWrite),
		.aluOp(aluOp),
		.resultData(resultData),
		.outputFlags(outputFlags)
	);	

	// Use register to input instructions
	reg[WIDTH - 1 : 0] instruction;
	wire[3:0] opCode;
	wire carry, low, flag, zero, negative;

	assign dstAddr = instruction[11:8];
	assign srcAddr = instruction[3:0];
	assign rTypeInstruction = (instruction[15:12] == 4'b0000 || 
		(shiftInstruction && (instruction[7:4] == 4'b0100 || instruction[7:4] == 4'b0110)));
	assign pcInstruction = 1'b0;
	assign shiftInstruction = (instruction[15:12] == 4'b1000);
	assign opCode = rTypeInstruction ? instruction[7:4]:instruction[15:12];
	assign aluOp = (opCode[3:2] == 2'b00) ? {1'b0, opCode[1:0]}:{opCode[3], 2'b00};
	assign flagSet = (aluOp[1:0] == 2'b00);
	assign copyInstruction = (opCode == 4'b1101);
	assign carry = outputFlags[0];
	assign low = outputFlags[1];
	assign flag = outputFlags[2];
	assign zero = outputFlags[3];
	assign negative = outputFlags[4];
	
	// Instantiate inputs
	initial begin
		clk <= 0;
		reset <= 0;
		regWrite <= 0;
		#10
		reset <= 1;
		#10
		instruction <= 16'b0101000100000001; // I-Type Add ($1 += 1)
		#50
		regWrite <= 1;
		#20
		regWrite <= 0;
		if (resultData == 16'd1) $display("$1 now equals 1 ($1 += 1).");
		if (!carry && low && !flag && !zero && negative) $display("Flags set correctly (Low, Negative).");
		instruction <= 16'b0010001000001111; // I-Type Or ($2 | 15)
		#50
		regWrite <= 1;
		#20
		regWrite <= 0;
		if (resultData == 16'd15) $display("$2 now equals 15 ($2 | 15).");
		if (!carry && low && !flag && !zero && negative) $display("Flags set correctly (unchanged).");
		instruction <= 16'b0000001001010001; // R-Type Add ($2 += $1)
		#50
		regWrite <= 1;
		#20
		regWrite <= 0;
		if (resultData == 16'd16) $display("$2 now equals 16 ($2 += $1).");
		if (!carry && !low && !flag && !zero && !negative) $display("Flags set correctly (Nothing).");
		instruction <= 16'b0000000110010001; // R-Type Sub ($1 -= $1)
		#50
		regWrite <= 1;
		#20
		regWrite <= 0;
		if (resultData == 16'd0) $display("$1 now equals 0 ($1 -= $1).");
		if (!carry && !low && !flag && zero && !negative) $display("Flags set correctly (Zero).");
		instruction <= 16'b1000001000010001; // I-Type LSH ($2 >> 1)
		#50
		regWrite <= 1;
		#20
		regWrite <= 0;
		if (resultData == 16'd8) $display("$2 now equals 8 ($2 >> 1).");
		instruction <= 16'b0011000100000001; // I-Type Xor ($1 ^ 1)
		#50
		regWrite <= 1;
		#10
		regWrite <= 0;
		if (resultData == 16'd1) $display("$1 now equals 1 ($1 ^ 1).");
		instruction <= 16'b0000001111010001; // R-Type Mov ($3 = $1)
		#50
		regWrite <= 1;
		#20
		regWrite <= 0;
		if (resultData == 16'd1) $display("$3 now equals 1 ($3 = $1).");
		instruction <= 16'b1001001000000101; // I-Type Sub ($2 -= 5)
		#50
		regWrite <= 1;
		#20
		regWrite <= 0;
		if (resultData == 16'd3) $display("$2 now equals 3 ($2 -= 5).");
		instruction <= 16'b1101010000001111; // I-Type Mov ($4 = 15)
		#50
		regWrite <= 1;
		#20
		regWrite <= 0;
		if (resultData == 16'd15) $display("$4 now equals 15 ($4 = 15).");
		instruction <= 16'b0000010000010010; // R-Type And ($4 & $2)
		#50
		regWrite <= 1;
		#20
		regWrite <= 0;
		if (resultData == 16'd3) $display("$4 now equals 3 ($4 & $2).");
		instruction <= 16'b0001010000000110; // I-Type And ($4 & 6)
		#50
		regWrite <= 1;
		#20
		regWrite <= 0;
		if (resultData == 16'd2) $display("$4 now equals 2 ($4 & 6).");
		instruction <= 16'b0000010000100011; // R-Type Or ($4 | $3)
		#50
		regWrite <= 1;
		#20
		regWrite <= 0;
		if (resultData == 16'd3) $display("$4 now equals 3 ($4 | $3).");
		instruction <= 16'b0000010000110010; // R-Type Xor ($4 ^ $2)
		#50
		regWrite <= 1;
		#10
		regWrite <= 0;
		if (resultData == 16'd0) $display("$4 now equals 0 ($4 ^ $2).");
		instruction <= 16'b1000001001000001; // R-Type LSH ($2 << $1)
		#50
		regWrite <= 1;
		#10
		regWrite <= 0;
		if (resultData == 16'd6) $display("$2 now equals 6 ($2 << $1).");
		instruction <= 16'b1000001001100100; // R-Type ASHU ($2 << $4)
		#50
		regWrite <= 1;
		#10
		regWrite <= 0;
		if (resultData == 16'd6) $display("$2 now equals 6 ($2 >> $4).");
		instruction <= 16'b1000001000110010; // I-Type ASHU ($2 >> 2)
		#50
		regWrite <= 1;
		#10
		regWrite <= 0;
		if (resultData == 16'd1) $display("$2 now equals 1 ($2 >> 2).");
	end
		
	// Generate clock
	always #10 begin
		clk = ~clk;
	end

	// Either zero-extend or sign-extend
	always @(*) begin
		if (!reset) immd <= 16'd0;
		if (aluOp[1:0] != 2'b00) immd <= {8'd0, instruction[7:0]};
		else immd <= {{8{instruction[7]}}, instruction[7:0]};
	end
	
endmodule 
