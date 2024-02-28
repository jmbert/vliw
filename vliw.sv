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
	logic waitingForRead;
	
	always_ff @(posedge clk) begin
		if (rst == 1) begin
			pc <= 0;
			doInstructionFetch <= 0; 
			waitingForRead <= 0;
		end else if (fuWorking == 0) begin
			doInstructionFetch <= 1;
			waitingForRead <= 1;
			pc <= pc + INSTRUCTIONSIZEBYTES;
		end
	end

	always_ff @(posedge clk) begin
		if (doneFetch == 1) begin
			waitingForRead <= 0;
			doInstructionFetch <= 0;
			instruction <= instructionVolatile;
			doInstruction <= 1;
			pcSaved <= pc;
		end else begin
			doInstruction <= 0;
		end
	end

	logic [INSTRUCTIONSIZE-1:0] instructionVolatile;
	logic [INSTRUCTIONSIZE-1:0] instruction;
	logic [INSTRUCTIONSIZE-1:0] pcSaved;
	logic doInstruction;

	immu #(
		.INSTRUCTIONSIZE(INSTRUCTIONSIZE)
	) immu1  (
		.address(pc),
		.instruction(instructionVolatile),
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
				.bundleAddr(pcSaved),

				.clk(clk),

				.do_stall(0),
				.rst(rst),
				.instructionReady(doInstruction),
				
				.stalling(fuStalls[fuNumber]),
				.working(fuWorking[fuNumber])
			);
		end
	endgenerate
endmodule
