`include "caches/l2cache.sv"
`include "caches/instructionCache.sv"



module mmu #(
	VIRTUAL_ADDRESS_SIZE=64,
	PHYSICAL_ADDRESS_SIZE=56,
	NFU=2,

	localparam INSTRSIZE = NFU * 32
) (
/* verilator lint_off UNUSEDSIGNAL */
	input logic [VIRTUAL_ADDRESS_SIZE-1:0] instructionAddress,
/* verilator lint_on UNUSEDSIGNAL */
	output logic [INSTRSIZE-1:0] instruction,

	input logic doInstructionFetch,
	output logic doneInstructionFetch,

	output logic doBusWrite,
	input wire [63:0] dataIn,
	output wire [63:0] dataOut,
	output logic [PHYSICAL_ADDRESS_SIZE-1:0] addrBus,

	input logic clk
);

/* verilator lint_off UNUSEDSIGNAL */
	logic doFetch;
/* verilator lint_on UNUSEDSIGNAL */
	logic doWrite;
	always_comb begin
		if (doWrite) begin
			doBusWrite = 1;
		end else begin
			doBusWrite = 0;
		end
	end

	instructionCache #(
		.NFU(NFU)
	) icache (
		.address(translatedInstructionAddress),
		.data(instruction),
		.doneFetch(doneInstructionFetch),
		.doFetch(finishedInstructionTranslation),
		.l2Data(l2Data),
		.doneL2Fetch(l2DoneFetch),
		.l2Address(l2Address),
		.doL2Fetch(l2DoFetch),

		.clk(clk)
	);

	logic l2DoneFetch;
	logic l2DoFetch;
	logic [INSTRSIZE-1:0] l2Data;
	logic [PHYSICAL_ADDRESS_SIZE-1:0] l2Address;

	l2cache #(
		.NFU(NFU)
	) l2cache (
		.address(l2Address),
		.doFetch(l2DoFetch),
		.doneFetch(l2DoneFetch),
		.data(l2Data),

		.doMainFetch(doFetch),
		.doMainWrite(doWrite),
		.mainAddress(addrBus),
		.mainData(dataIn),
		.mainDataWrite(dataOut),

		.clk(clk)
	);


	logic [PHYSICAL_ADDRESS_SIZE-1:0] translatedInstructionAddress;
	logic finishedInstructionTranslation;

	always_ff @( posedge clk ) begin
		if (doInstructionFetch) begin
			// TODO - Actual translation here
			translatedInstructionAddress <= instructionAddress[55:0];
			finishedInstructionTranslation <= 1;
		end 
		if (finishedInstructionTranslation) begin
			finishedInstructionTranslation <= 0;
		end
	end
	
endmodule
