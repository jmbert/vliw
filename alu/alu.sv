`include "alu/add.sv"

`define ADD 0
`define SUB 1

module alu #(
	OPERANDSIZE=64
) (
	input logic [OPERANDSIZE-1:0] a,
	input logic [OPERANDSIZE-1:0] b,
	input logic [11:0] operationSelect,
	output logic [OPERANDSIZE-1:0] q,

	input logic clk
);

	adder #(.OPERANDSIZE(OPERANDSIZE)) adderModule (
		.a(a),
		.b(b),
		.q(adderQ)
	);
	logic [OPERANDSIZE-1:0] adderQ;

	always_comb begin
		case (operationSelect)
			`ADD: begin
				q = adderQ;
			end
			default: begin
				q = 0;
			end
		endcase
	end
endmodule
