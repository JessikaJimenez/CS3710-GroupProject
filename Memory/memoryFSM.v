// put the address on the LEDs, the read data on one pair of the 7-Segment
// displays, and the write-data on the other pair of 7-segment displays. Use one of
// the pushbuttons to advance the state machine so that we can see each state change.
`timescale 1ns/1ns

module memoryFSM #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16)
(
    input clk, rst, btn,
    input [(ADDR_WIDTH-1):0] inAddress,
    output reg [(ADDR_WIDTH-1):0] outAddress,
    output wire [6:0] hexWriteData,
    output wire [6:0] hexReadData
);

localparam resetState = 2'd0;
localparam readState = 2'd1;
localparam writeState = 2'd2;

wire [(DATA_WIDTH-1):0] read_a;
wire [(DATA_WIDTH-1):0] read_b;

reg [(DATA_WIDTH-1):0] data_a;
reg [(DATA_WIDTH-1):0] data_b;

reg [(ADDR_WIDTH-1):0] addr_a;
reg [(ADDR_WIDTH-1):0] addr_b;

reg write_a, write_b;

reg [(DATA_WIDTH-1):0] writeData;
wire [(DATA_WIDTH-1):0] readData;


reg[1:0] state_reg, state_next;

initial begin
    state_reg = resetState;
    state_next = readState;
	 write_a = 1'b0;
end

always @(negedge rst, posedge btn)
	begin
		if(~rst)
			begin
			state_reg <= resetState;
			end
		else
			begin
			state_reg <= state_next;
			end
	end
  
  always @(*) begin
	//state_next = state_reg;
	case(state_reg)
		resetState:  state_next <= readState;
        readState:   state_next <= writeState;
        writeState: state_next <= readState;

		default: state_next = state_next;
			
		endcase
		
end

always @(posedge clk) begin
	outAddress = inAddress;
	data_a = writeData;
	addr_a = inAddress;
end

always @(state_reg,inAddress) begin
	  //Outputs
	  
	  //readData <= read_a;
	  //writeData <= 0;

	  //Read and Write
	  //addr_a = inAddress;
	  addr_b = 1'b0;
	  
	  //writing
	  //data_a <= 0;
	  //write_a <= 1'b0;
	  data_b = 0;
	  write_b = 1'b0;
    case (state_reg)        
        resetState:
            begin
					 write_a = 1'b0;
                writeData = 5;
					 //data_a = writeData;
                //readData  <= 0;
            end
        readState:
            begin
				  write_a = 1'b0;
              writeData = (readData + 16'd2);
              //data_a = writeData;
              //write_a <=1'b0;
            end
        writeState:
            begin
              writeData = writeData;
				  write_a = 1'b1;
              //data_a = writeData;
              //write_a <=1'b1;
            end
    endcase
end

  // Instantiate memory module
	memory exMem(
		.data_a(data_a),
		.data_b(data_b),
		.addr_a(addr_a),
		.addr_b(addr_b),
		.write_a(write_a),
		.write_b(write_b),
		.clk(clk),
		.read_a(readData),
		.read_b(read_b)
	);

//Instantiate Hex modules
	hexTo7Seg readHex(
		.x(readData),
		.z(hexReadData)

	);

	hexTo7Seg writeHex(
		.x(writeData),
		.z(hexWriteData)
	);
  
endmodule
