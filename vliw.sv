`include "registerFile.sv"
`include "functionalUnit.sv"
`include "mmu.sv"

module vliw #(
	NFU = 2,
	localparam INSTRUCTIONSIZEBYTES = NFU * 4,
	localparam INSTRUCTIONSIZE = INSTRUCTIONSIZEBYTES * 8
) (
	input clk,
	input rst
);
	wire [4:0] registerWriteAddress[NFU-1:0];
	wire [63:0] registerInputData [NFU-1:0];
	wire [4:0] registerAddress1[NFU-1:0];
	wire [4:0] registerAddress2[NFU-1:0];
	wire [4:0] registerAddress3[NFU-1:0];
	wire [63:0] registerOutputData1[NFU-1:0];
	wire [63:0] registerOutputData2[NFU-1:0];
	wire [63:0] registerOutputData3[NFU-1:0];
	wire registerWriteEnable [NFU-1:0];
	wire registerEnable [NFU-1:0];

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
		.enable(registerEnable)
	);
	/*
		TODO - Move this into branch module
	*/
	reg [63:0] pc;
	reg doInstructionFetch;
	always_ff @(posedge clk) begin
		if (!rst) begin
			pc <= pc + INSTRUCTIONSIZEBYTES;
			doInstructionFetch <= ~doInstructionFetch;
		end else begin 
			pc <= 0;
			doInstructionFetch <= 0;
		end
	end
	reg [INSTRUCTIONSIZE-1:0] instruction;

	immu #(
		.INSTRUCTIONSIZE(INSTRUCTIONSIZE)
	) immu1  (
		.address(pc),
		.instruction(instruction),
		.clk(clk),
		.doFetch(doInstructionFetch)
	);


	reg [NFU-1:0] fuStalls;

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

				.do_stall(rst),
				
				.stalling(fuStalls[fuNumber])
			);
		end
	endgenerate
endmodule
