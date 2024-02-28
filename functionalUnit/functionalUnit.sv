`include "functionalUnit/listingDefs.sv"

module functionalUnit #(
	FUID
) (

	input logic clk,
	input logic rst,

	input logic do_stall,
	output logic stalling,
	output logic working,

	/*
		Register pins
	*/

	output logic [63:0] registerInputData,
	output logic [4:0] registerWriteAddress,

	input logic [63:0] registerOutputData1,
	output logic [4:0] registerAddress1,

	input logic [63:0] registerOutputData2,
	output logic [4:0] registerAddress2,

	input logic [63:0] registerOutputData3,
	output logic [4:0] registerAddress3,

	output logic registerWriteEnable,
	output logic registerEnable,

	/*
		Instruction pins
	*/
	input logic [31:0] instruction,
	input logic [63:0] bundleAddr,
	input logic instructionReady
);

	logic [31:0] workingInstruction;

	`define OPCODE workingInstruction[5:0]
	`define RD workingInstruction[10:6]
	`define IMM16 workingInstruction[26:11]
	`define F26 workingInstruction[31:6]
	`define F5 workingInstruction[31:27]
	`define FETCH 0
	`define DECODE 1
	`define EXECUTE 2

	logic [5:0] opcode;

	logic [15:0] imm16;
	logic [4:0] rd;
	logic [4:0] f5;

	logic [25:0] f26;

	always_ff @(posedge clk ) begin
		if (stage == `FETCH) begin
			working <= 0;
		end else begin
			working <= 1;
		end
	end
	always_ff @(posedge clk) begin
		if (instructionReady == 1) begin
			workingInstruction <= instruction;
			stage <= `DECODE;
		end
	end

	always_ff @( posedge clk ) begin 
		if (rst) begin
			workingInstruction <= 0;
			registerInputData <= 0;
			registerWriteEnable <= 0;
			registerWriteAddress <= 0;
			stage <= `FETCH;
		end
	end

	always_comb begin
		opcode = `OPCODE;
		imm16 = `IMM16;
		rd = `RD;
		f5 = `F5;
		f26 = `F26;
	end

	logic [3:0] stage;

	always_ff @( posedge clk ) begin
		stalling <= do_stall;
		if (!stalling && !rst) begin
			if (stage == `DECODE) begin
				$strobe("FU: %x: Instruction: %x at %x", FUID, instruction, bundleAddr);

				case (opcode)
					`OPI_16: begin
						case (f5)
							`LUUI: begin
								registerWriteAddress <= rd;
								registerInputData <= {32'b0, imm16, 16'b0};
								registerWriteEnable <= 1;
								registerEnable <= 1;
							end 
							`LSUI: begin
								registerWriteAddress <= rd;
								registerInputData <= {{32{imm16[15]}}, imm16, 16'b0};
								registerWriteEnable <= 1;
								registerEnable <= 1;
							end
							default: begin end
						endcase
					end
					`SINGLE: begin
						case (f26)
							`NOP: begin
							end
							default: begin end
						endcase
					end
					default: begin end
				endcase
				stage <= `EXECUTE;
			end else if (stage == `EXECUTE) begin
				stage <= `FETCH;				
			end
		end
	end

endmodule
