`include "caches/instructionCache.sv"

module immu #(
	INSTRUCTIONSIZE
) (
	input [63:0] address,
	output [INSTRUCTIONSIZE-1:0] instruction,
	input doFetch,

	input clk
);
	
	reg [INSTRUCTIONSIZE-1:0] instructionBigEndian;

	assign instruction = {<<8{instructionBigEndian}};

	instructionCache iCache (
		.address({address[55:0]}),
		.data(instructionBigEndian),
		.clk(clk),
		.doFetch(doFetch)
	);

endmodule
