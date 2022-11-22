module nesOnBoard
(
    input clk,
    input nesData,
    output nesClock,
    output nesLatch,
	 output [7:0] leds
);


	// Instantiate modules
	nesInterface UUT (
		.clk(clk), //
       .nesData(nesData),
       .nesClock(nesClock),
       .nesLatch(nesLatch),
		 .controllerData(leds)
	);


endmodule