`include "alu/add.sv"
`include "alu/binOps.sv"

`define ADD 0
`define XOR 1
`define AND 2
`define OR 3

module alu #(
	OPERANDSIZE=64
) (
	input logic [OPERANDSIZE-1:0] a,
	input logic [OPERANDSIZE-1:0] b,
	input logic [11:0] operationSelect,
	output logic [OPERANDSIZE-1:0] q
);

	adder #(.OPERANDSIZE(OPERANDSIZE)) adderModule (
		.a(a),
		.b(b),
		.q(adderQ)
	);
	xorMod #(.OPERANDSIZE(OPERANDSIZE)) xorModule (
		.a(a),
		.b(b),
		.q(xorQ)
	);
	andMod #(.OPERANDSIZE(OPERANDSIZE)) andModule (
		.a(a),
		.b(b),
		.q(andQ)
	);
	orMod #(.OPERANDSIZE(OPERANDSIZE)) orModule (
		.a(a),
		.b(b),
		.q(orQ)
	);
	logic [OPERANDSIZE-1:0] adderQ;
	logic [OPERANDSIZE-1:0] xorQ;
	logic [OPERANDSIZE-1:0] andQ;
	logic [OPERANDSIZE-1:0] orQ;

	always_comb begin
		case (operationSelect)
			`ADD: begin
				q = adderQ;
			end
			`XOR: begin
				q = xorQ;
			end
			`AND: begin
				q = andQ;
			end
			`OR: begin
				q = orQ;
			end
			default: begin
				q = 0;
			end
		endcase
	end
endmodule
