`include "functionalUnit/listingDefs.sv"
`include "alu/alu.sv"

module functionalUnit #(
	FUID
) (

	input logic clk,
	input logic rst,

	output logic working,

	/*
		Register pins
	*/

	output logic [63:0] registerInputData,
	output logic [4:0] registerWriteAddress,

	output logic [4:0] registerAddress1,
	output logic [4:0] registerAddress2,
	output logic [4:0] registerAddress3,

	input logic [63:0] registerOutputData1,
/* verilator lint_off UNUSEDSIGNAL */
	input logic [63:0] registerOutputData2,
	input logic [63:0] registerOutputData3,
/* verilator lint_on UNUSEDSIGNAL */

	output logic registerWriteEnable,
	output logic registerEnable,

	/*
		Instruction pins
	*/
	input logic [31:0] instruction,
	input logic [63:0] bundleAddr,
	input logic instructionReady
);

	logic [63:0] aluInput1;
	logic [63:0] aluInput2;
	logic [63:0] aluOutput;

	logic [11:0] aluOperation;

	alu fuAlu (
		.a(aluInput1),
		.b(aluInput2),
		.q(aluOutput),
		.operationSelect(aluOperation)
	);

	logic [31:0] workingInstruction;

	`define OPCODE workingInstruction[5:0]
	`define RD workingInstruction[10:6]
	`define IMM16 workingInstruction[26:11]
	`define F26 workingInstruction[31:6]
	`define F5 workingInstruction[31:27]
	`define ARS1 workingInstruction[31:27]

	logic [3:0] stage;
	`define FETCH 0
	`define DECODE 1
	`define EXECUTE 2
	`define WRITEBACK 3

	always_ff @(posedge clk) begin
		if (instructionReady == 1 && stage == `FETCH) begin
			workingInstruction <= instruction;
			working <= 1;
			stage <= `DECODE;
		end else if (stage == `WRITEBACK) begin
			working <= 0;
		end
	end

	always_ff @( posedge clk ) begin 
		if (rst) begin
			workingInstruction <= 0;
			registerInputData <= 0;
			registerWriteEnable <= 0;
			registerWriteAddress <= 0;
			registerAddress1 <= 0;
			registerAddress2 <= 0;
			registerAddress3 <= 0;
			working <= 0;
			stage <= `FETCH;
		end
	end


	always_ff @( posedge clk ) begin
		if (!rst) begin
			if (stage == `DECODE) begin
				registerEnable <= 0;
				registerWriteEnable <= 0;
				$strobe("FU: %x: Instruction: %x at %x", FUID, instruction, bundleAddr);

				case (`OPCODE)
					`OPADDUI, `OPXORUI, `OPORUI, `OPANDUI: begin
						registerAddress1 <= `ARS1;
						registerEnable <= 1;
					end
					`SINGLE: begin
						case (`F26)
							`NOP: begin
							end
							default: begin end
						endcase
					end
					default: begin end
				endcase
				stage <= `EXECUTE;
			end else if (stage == `EXECUTE) begin
				case (`OPCODE)
					`OPADDUI: begin
						aluInput1 <= registerOutputData1;
						aluInput2 <= {48'b0, `IMM16};
						aluOperation <= `ADD;
					end 
					`OPXORUI: begin
						aluInput1 <= registerOutputData1;
						aluInput2 <= {48'b0, `IMM16};
						aluOperation <= `XOR;
					end 
					`OPANDUI: begin
						aluInput1 <= registerOutputData1;
						aluInput2 <= {48'b0, `IMM16};
						aluOperation <= `AND;
					end 
					`OPORUI: begin
						aluInput1 <= registerOutputData1;
						aluInput2 <= {48'b0, `IMM16};
						aluOperation <= `OR;
					end 
					default: begin end
				endcase
				stage <= `WRITEBACK;				
			end else if (stage == `WRITEBACK) begin
				case (`OPCODE)
					`OPADDUI, `OPXORUI, `OPORUI, `OPANDUI: begin
						registerWriteAddress <= `RD;
						registerWriteEnable <= 1;
						registerEnable <= 1;
						registerInputData <= aluOutput;
					end 
					`OPI_16: begin
						case (`F5)
							`LUUI: begin
								registerWriteAddress <= `RD;
								registerInputData <= {32'b0, `IMM16, 16'b0};
								registerWriteEnable <= 1;
								registerEnable <= 1;
							end 
							`LSUI: begin
								registerWriteAddress <= `RD;
								registerInputData <= {{32{`IMM16[15]}}, `IMM16, 16'b0};
								registerWriteEnable <= 1;
								registerEnable <= 1;
							end
							default: begin end
						endcase
					end
					default: begin end
				endcase
				stage <= `FETCH;
			end
		end
	end

endmodule
