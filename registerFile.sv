

module registerFile #(
	NFU = 2
)(
	input [4:0] writeAddress [NFU-1:0],
	input [63:0] inputData [NFU-1:0],

	input [4:0] address1 [NFU-1:0],
	input [4:0] address2 [NFU-1:0],
	input [4:0] address3 [NFU-1:0],
	output [63:0] outputData1 [NFU-1:0],
	output [63:0] outputData2 [NFU-1:0],
	output [63:0] outputData3 [NFU-1:0],

	input writeEnable [NFU-1:0],

	input enable [NFU-1:0]
);
	reg [63:0] bank[31:0];
	reg [63:0] outputData1Reg [NFU-1:0], outputData2Reg [NFU-1:0], outputData3Reg [NFU-1:0];

	/*
		Basic register file, with accesses copied for the number of functional units
		3-reads per FU, one write per fu
		Done in parallel
	*/

	generate
		genvar i;

		for (i = 0; i < NFU; i++) begin 
			assign outputData1[i] = outputData1Reg[i];
			assign outputData2[i] = outputData2Reg[i];
			assign outputData3[i] = outputData3Reg[i];
	
			always_latch begin
				if (enable[i]) begin
					if (writeEnable[i]) begin
						bank[writeAddress[i]] = inputData[i];
					end
					outputData1Reg[i] = bank[address1[i]];
					outputData2Reg[i] = bank[address2[i]];
					outputData3Reg[i] = bank[address3[i]];
				end
			end
		end
	endgenerate
	
endmodule
