
module halfAdder (
	input logic a,
	input logic b,
	output logic q,
	output logic carry
);
	always_comb begin
		q = a ^ b;
		carry = a & b; 
	end
endmodule

module bitAdder (
	input logic a,
	input logic b,
	input logic carry,
	output logic q,
	output logic carryOut
);
	halfAdder hadder (
		.a(a),
		.b(b),
		.q(halfQ),
		.carry(halfCarry)
	);
	logic halfQ;
	logic halfCarry;
	always_comb begin
		q = halfQ ^ carry;
		carryOut = halfCarry | (carry & halfQ);
	end
endmodule

module adder #(
	OPERANDSIZE=64
) (
	input logic [OPERANDSIZE-1:0] a,
	input logic [OPERANDSIZE-1:0] b,
	output logic [OPERANDSIZE-1:0] q
);

	logic [OPERANDSIZE-1:0] carries;

	generate
		genvar bitI;
		for (bitI = 0; bitI < OPERANDSIZE ; bitI++ ) begin
			bitAdder bitAdderI (
				.a(a[bitI]),
				.b(b[bitI]),
				.q(q[bitI]),
				.carry((bitI == 0) ? 0 : carries[bitI-1]),
				.carryOut(carries[bitI])
			);
		end
	endgenerate
	
endmodule
