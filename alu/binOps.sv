
module xorMod #(
	OPERANDSIZE=64
) (
	input logic [OPERANDSIZE-1:0] a,
	input logic [OPERANDSIZE-1:0] b,
	output logic [OPERANDSIZE-1:0] q
);

	generate
		genvar bitI;
		for (bitI = 0; bitI < OPERANDSIZE ; bitI++ ) begin
			always_comb begin
				q[bitI] = a[bitI] ^ b[bitI];
			end
		end
	endgenerate
	
endmodule

module andMod #(
	OPERANDSIZE=64
) (
	input logic [OPERANDSIZE-1:0] a,
	input logic [OPERANDSIZE-1:0] b,
	output logic [OPERANDSIZE-1:0] q
);

	generate
		genvar bitI;
		for (bitI = 0; bitI < OPERANDSIZE ; bitI++ ) begin
			always_comb begin
				q[bitI] = a[bitI] & b[bitI];
			end
		end
	endgenerate
	
endmodule

module orMod #(
	OPERANDSIZE=64
) (
	input logic [OPERANDSIZE-1:0] a,
	input logic [OPERANDSIZE-1:0] b,
	output logic [OPERANDSIZE-1:0] q
);

	generate
		genvar bitI;
		for (bitI = 0; bitI < OPERANDSIZE ; bitI++ ) begin
			always_comb begin
				q[bitI] = a[bitI] | b[bitI];
			end
		end
	endgenerate
	
endmodule
