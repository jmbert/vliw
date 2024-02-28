`include "caches/instructionCache.sv"

module immu #(
	INSTRUCTIONSIZE
) (
	input logic [63:0] address,
	output logic [INSTRUCTIONSIZE-1:0] instruction,
	input logic doFetch,
	output logic doneFetch,

	input logic clk
);
	
	logic [INSTRUCTIONSIZE-1:0] instructionBigEndian;

	assign instruction = {<<8{instructionBigEndian}};

	instructionCache iCache (
		.address({address[55:0]}),
		.data(instructionBigEndian),
		.clk(clk),
		.doFetch(doFetch),
		.doneFetch(doneFetch)
	);

endmodule
