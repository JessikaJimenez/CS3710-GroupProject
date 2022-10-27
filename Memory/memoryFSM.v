// put the address on the LEDs, the read data on one pair of the 7-Segment
// displays, and the write-data on the other pair of 7-segment displays. Use one of
// the pushbuttons to advance the state machine so that we can see each state change.

module memoryFSM #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16)
(
    input clk, rst, btn,
    input [9:0] inAddress,
    output [9:0] outAddress,
    output [(DATA_WIDTH-1):0] writeData,
    output [(DATA_WIDTH-1):0] readData
);

localparam resetState = 2'd0;
localparam readState = 2'd1;
localparam modifyState = 2'd2;
localparam writeState = 2'd2;

reg[1:0] state_reg, state_next;

initial begin
    state_reg = resetState;
    state_next = readState;
end

always @() begin
    
end

always @(posedge reset, posedge btn)
	begin
		if(reset)
			begin
			state_reg <= resetState;
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
        readState:   state_next <= modifyState;
        modifyState: state_next <= writeState;
        writeState:  state_next <= readState;

		default: state_next = state_next;
			
		endcase
		
end

always @(*) begin
    case (state_reg)
        resetState:
            begin
            
            end
        readState:
            begin
              
            end
        modifyState:
            begin
              
            end
        writeState: 
            begin
              
            end
        default: 
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
