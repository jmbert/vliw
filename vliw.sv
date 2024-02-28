`include "registerFile.sv"
`include "functionalUnit/functionalUnit.sv"
`include "mmu.sv"

module vliw #(
	NFU = 2,
	localparam INSTRUCTIONSIZEBYTES = NFU * 4,
	localparam INSTRUCTIONSIZE = INSTRUCTIONSIZEBYTES * 8
) (
	input logic clk,
	input logic rst
);
	logic [4:0] registerWriteAddress[NFU-1:0];
	logic [63:0] registerInputData [NFU-1:0];
	logic [4:0] registerAddress1[NFU-1:0];
	logic [4:0] registerAddress2[NFU-1:0];
	logic [4:0] registerAddress3[NFU-1:0];
	logic [63:0] registerOutputData1[NFU-1:0];
	logic [63:0] registerOutputData2[NFU-1:0];
	logic [63:0] registerOutputData3[NFU-1:0];
	logic registerWriteEnable [NFU-1:0];
	logic registerEnable [NFU-1:0];

	registerFile #(.NFU(NFU)) registers (
		.writeAddress(registerWriteAddress),
		.inputData(registerInputData),

		.address1(registerAddress1),
		.address2(registerAddress2),
		.address3(registerAddress3),
		.outputData1(registerOutputData1),
		.outputData2(registerOutputData2),
		.outputData3(registerOutputData3),

		.writeEnable(registerWriteEnable),
		.enable(registerEnable),

		.rst(rst)
	);
	/*
		TODO - Move this into branch module
	*/
	logic [63:0] pc;
	logic doInstructionFetch;
	always_ff @(posedge clk) begin
		if (rst == 0 && fuStalls == 0 && fuWorking == 0) begin
			pc <= pc + INSTRUCTIONSIZEBYTES;
			doInstructionFetch <= 1;
		end else begin 
			pc <= 0;
			doInstructionFetch <= 0;
		end
	end
	logic [INSTRUCTIONSIZE-1:0] instruction;

	immu #(
		.INSTRUCTIONSIZE(INSTRUCTIONSIZE)
	) immu1  (
		.address(pc),
		.instruction(instruction),
		.clk(clk),
		.doFetch(doInstructionFetch),
		.doneFetch(doneFetch)
	);

	logic doneFetch;


	logic [NFU-1:0] fuStalls;
	logic [NFU-1:0] fuWorking;

	/*
		This generate loop handles all FU-specific actions
	*/
	generate
		genvar fuNumber;
		for (fuNumber = 0; fuNumber < NFU; fuNumber++) begin
			functionalUnit #(
				.FUID(fuNumber)
			) funcUnitN (
				.registerWriteAddress(registerWriteAddress[fuNumber]),
				.registerInputData(registerInputData[fuNumber]),

				.registerAddress1(registerAddress1[fuNumber]),
				.registerAddress2(registerAddress2[fuNumber]),
				.registerAddress3(registerAddress3[fuNumber]),
				.registerOutputData1(registerOutputData1[fuNumber]),
				.registerOutputData2(registerOutputData2[fuNumber]),
				.registerOutputData3(registerOutputData3[fuNumber]),

				.registerWriteEnable(registerWriteEnable[fuNumber]),
				.registerEnable(registerEnable[fuNumber]),

				.instruction(instruction[32*fuNumber+:32]),
				.bundleAddr(pc),

				.clk(clk),

				.do_stall(0),
				.rst(rst),
				.instructionReady(doneFetch),
				
				.stalling(fuStalls[fuNumber]),
				.working(fuWorking[fuNumber])
			);
		end
	endgenerate
endmodule
