

module functionalUnit #(
	FUID
) (

	input clk,

	input do_stall,
	output stalling,

	/*
		Register pins
	*/

	output [63:0] registerInputData,
	output [4:0] registerWriteAddress,

	input [63:0] registerOutputData1,
	output [4:0] registerAddress1,

	input [63:0] registerOutputData2,
	output [4:0] registerAddress2,

	input [63:0] registerOutputData3,
	output [4:0] registerAddress3,

	output registerWriteEnable,
	output registerEnable,

	/*
		Instruction pins
	*/
	input [31:0] instruction,
	input [63:0] bundleAddr
);
	reg currentlyStalling;
	assign stalling = currentlyStalling;


	always_comb begin
		currentlyStalling = do_stall;
	end

	always @( posedge clk ) begin
		if (!currentlyStalling) begin
			$strobe("FU: %x: Instruction: %x at %x", FUID, instruction, bundleAddr);
		end
	end

endmodule
