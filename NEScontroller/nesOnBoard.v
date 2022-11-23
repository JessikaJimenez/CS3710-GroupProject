module nesOnBoard
(
    input clk,
    input nesData,
    output nesClock,
    output nesLatch,
	 output [7:0] leds,
	 output [6:0] hexOut
);

wire [15:0] assemblyData;
//wire [7:0] fakeData;
	// Instantiate modules
	nesInterface UUT (
		.clk(clk), //
       .nesData(nesData),
       .nesClock(nesClock),
       .nesLatch(nesLatch),
		 .controllerData(leds),
		 .assemblyButton(assemblyData)
	);
	
	hexTo7Seg readHex(
	.x(assemblyData),
	.z(hexOut)
   );


endmodule