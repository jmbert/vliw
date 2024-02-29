

module ram #(
	RAM_WIDTH=24,
	ADDR_SIZE=56,
	BUS_SIZE=64,

	localparam RAM_SIZE= 1 << RAM_WIDTH
) (
/* verilator lint_off UNUSEDSIGNAL */
	input logic [ADDR_SIZE-1:0] address,
/* verilator lint_on UNUSEDSIGNAL */
	input wire [BUS_SIZE-1:0] dataIn,
	output wire [BUS_SIZE-1:0] dataOut,

	input logic we,
	input logic clk
);
	initial begin
		$readmemh("memory.txt", memory);
	end
	logic [7:0] memory [RAM_SIZE-1:0];

	`define ADDRESS_TRUNC address[RAM_WIDTH-1:0]

	always_ff @(posedge clk) begin
		if (we) begin
			memory[`ADDRESS_TRUNC]   <= dataIn[63:56];
			memory[`ADDRESS_TRUNC+1] <= dataIn[55:48];
			memory[`ADDRESS_TRUNC+2] <= dataIn[47:40];
			memory[`ADDRESS_TRUNC+3] <= dataIn[39:32];
			memory[`ADDRESS_TRUNC+4] <= dataIn[31:24];
			memory[`ADDRESS_TRUNC+5] <= dataIn[23:16];
			memory[`ADDRESS_TRUNC+6] <= dataIn[15:8];
			memory[`ADDRESS_TRUNC+7] <= dataIn[7:0];
		end
		dataOut[63:56] <= memory[`ADDRESS_TRUNC];
		dataOut[55:48] <= memory[`ADDRESS_TRUNC+1];
		dataOut[47:40] <= memory[`ADDRESS_TRUNC+2];
		dataOut[39:32] <= memory[`ADDRESS_TRUNC+3];
		dataOut[31:24] <= memory[`ADDRESS_TRUNC+4];
		dataOut[23:16] <= memory[`ADDRESS_TRUNC+5];
		dataOut[15:8]  <= memory[`ADDRESS_TRUNC+6];
		dataOut[7:0]   <= memory[`ADDRESS_TRUNC+7];
	end


	`undef ADDRESS_TRUNC
endmodule
