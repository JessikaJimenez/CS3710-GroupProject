module nesInterface
(
    input clk,
    input nesData,
    output nesClock,
    output nesLatch,
	 output reg [7:0] controllerData
);

reg [15:0] clkCount = 16'd0;
localparam perioudCount = 16'd30;
reg [15:0] pulseState;
reg clkDiv = 0;
reg [7:0] dataIn = 0;

initial begin
	pulseState <= 16'd0;
end

//Divide The Clock
always @(posedge clk) begin
    if (clkCount == perioudCount) begin
        clkDiv = ~clkDiv;
        clkCount <= 0;
    end
    else begin
      clkCount <= clkCount + 16'd1;
    end
end

//Count cycles for updating
always @(negedge clkDiv) begin
    if (pulseState == 0) begin
		  dataIn[pulseState] <= nesData;
        pulseState <= pulseState + 16'd1;
    end
    else if ((pulseState > 0) && (pulseState < 9)) begin
        dataIn[pulseState-1] <= nesData;
        pulseState <= pulseState + 16'd1;
    end
    else begin
		controllerData <= dataIn;
      pulseState <= 0;
    end
end

assign nesClock = clkDiv & ((pulseState > 0) && (pulseState < 9));
assign nesLatch = clkDiv & (pulseState == 0);


endmodule