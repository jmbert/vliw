`include "caches/instructionCache.sv"

module immu #(
	INSTRUCTIONSIZE
) (
/* verilator lint_off UNUSEDSIGNAL */
	input logic [63:0] address,
/* verilator lint_on UNUSEDSIGNAL */
	output logic [INSTRUCTIONSIZE-1:0] instruction,
	input logic doFetch,
	output logic doneFetch,

	input logic clk
);
	
	reg [INSTRUCTIONSIZE-1:0] instructionBigEndian;

	assign instruction = {<<8{instructionBigEndian}};

	instructionCache iCache (
		.address({address[55:0]}),
		.data(instructionBigEndian),
		.clk(clk),
		.doFetch(doFetch),
		.doneFetch(doneFetch)
	);

endmodule
