// put the address on the LEDs, the read data on one pair of the 7-Segment
// displays, and the write-data on the other pair of 7-segment displays. Use one of
// the pushbuttons to advance the state machine so that we can see each state change.

module memoryFSM #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16)
(
    input clk, rst, btn,
    input [(ADDR_WIDTH-1):0] inAddress,
    output [(ADDR_WIDTH-1):0] outAddress,
    output [(DATA_WIDTH-1):0] writeData,
    output [(DATA_WIDTH-1):0] readData
);

localparam resetState = 2'd0;
localparam readState = 2'd1;
localparam writeState = 2'd2;

wire [(DATA_WIDTH-1):0] read_a;
wire [(DATA_WIDTH-1):0] read_b;

wire [(DATA_WIDTH-1):0] data_a;
wire [(DATA_WIDTH-1):0] data_b;

wire [(ADDR_WIDTH-1):0] addr_a;
wire [(ADDR_WIDTH-1):0] addr_b;

wire write_a, write_b;


reg[1:0] state_reg, state_next;

initial begin
    state_reg = resetState;
    state_next = readState;
end

always @(posedge reset, posedge btn)
	begin
		if(reset)
			begin
			state_reg <= resetState;
			end
        else if (state_reg == writeState) begin
            write_a = 1'b0;
            #10
            state_reg <= state_next;
        end
		else
			begin
			state_reg <= state_next;
			end
		$display("%d", state_reg);
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

always @(*) begin
    case (state_reg)
        //Outputs
        outAddress <= inAddress;
        readData <= read_a;
        writeData <= 0;

        //Read and Write
        addr_a <= inAddress;
        addr_b <= 1'b0;
        
        //writing
        data_a <= 0;
        //write_a <= 1'b0;
        data_b <= 0;
        write_b <= 1'b0;
        
        resetState:
            begin
                writeData <= 0;
                readData  <= 0;
            end
        writeState:
            begin
              writeData <= (read_a + 16'd2);
              data_a <= writeData;
              //write_a <=1'b0;
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
		.read_a(read_a),
		.read_b(read_b)
	);
  
endmodule
