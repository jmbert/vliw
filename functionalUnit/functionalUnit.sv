`include "functionalUnit/listingDefs.sv"
`include "alu/alu.sv"

module functionalUnit #(
/* verilator lint_off UNUSEDPARAM */
	FUID
/* verilator lint_on UNUSEDPARAM */
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
/* verilator lint_off UNUSEDSIGNAL */
	input logic [63:0] bundleAddr,
/* verilator lint_on UNUSEDSIGNAL */
	input logic instructionReady
);

/* verilator lint_off UNUSEDSIGNAL */
	logic [63:0] workingBundleAddress;
/* verilator lint_on UNUSEDSIGNAL */

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
	`define RS1 workingInstruction[15:11]
	`define IMM12 workingInstruction[27:16]
	`define IMM20 workingInstruction[30:11]
	`define F26 workingInstruction[31:6]
	`define F4 workingInstruction[31:28]
	`define F1 workingInstruction[31]

	logic [3:0] stage;
	`define FETCH 0
	`define DECODE 1
	`define EXECUTE 2
	`define WRITEBACK 3

	always_ff @(posedge clk) begin
		if (instructionReady == 1 && stage == `FETCH) begin
			workingInstruction <= instruction;
			workingBundleAddress <= bundleAddr;
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

				case (`OPCODE)
					`OPI_ART: begin
						registerAddress1 <= `RS1;
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
					`OPI_ART: begin
						case (`F4)
							`ADDUI: begin
								aluInput1 <= registerOutputData1;
								aluInput2 <= {52'b0, `IMM12};
								aluOperation <= `ADD;
							end 
							`XORUI: begin
								aluInput1 <= registerOutputData1;
								aluInput2 <= {52'b0, `IMM12};
								aluOperation <= `XOR;
							end 
							`ANDUI: begin
								aluInput1 <= registerOutputData1;
								aluInput2 <= {52'b0, `IMM12};
								aluOperation <= `AND;
							end 
							`ORUI: begin
								aluInput1 <= registerOutputData1;
								aluInput2 <= {52'b0, `IMM12};
								aluOperation <= `OR;
							end 
							default: begin end
						endcase
					end
					default: begin end
				endcase
				stage <= `WRITEBACK;				
			end else if (stage == `WRITEBACK) begin
				case (`OPCODE)
					`OPI_ART: begin
						registerWriteAddress <= `RD;
						registerWriteEnable <= 1;
						registerEnable <= 1;
						registerInputData <= aluOutput;
					end 
					`LUI: begin
						registerWriteAddress <= `RD;
						if (`F1 == 0) begin
							registerInputData <= {32'b0, `IMM20, 12'b0};	
						end else begin
							registerInputData <= {{32{`IMM20[19]}}, `IMM20, 12'b0};	
						end
						registerWriteEnable <= 1;
						registerEnable <= 1;
					end
					default: begin end
				endcase
				stage <= `FETCH;
			end
		end
	end

endmodule
