
module instructionCache #(
	NFU=2,
	NCACHE_ENTRIES=256,
	localparam CACHEINDEX = $clog2(NCACHE_ENTRIES),
	PHYSICAL_ADDRESS_LENGTH=56,
	localparam CACHELINESIZE = NFU * 32,
	localparam CACHELINEINDEX = $clog2(NFU * 4),
	localparam TAGSIZE = PHYSICAL_ADDRESS_LENGTH - CACHEINDEX - CACHELINEINDEX,
	localparam CACHELINESIZE_PRESENT = CACHELINESIZE + 1 + TAGSIZE // Plus valid bit and tagsize
) (
/* verilator lint_off UNUSEDSIGNAL */
	input logic [PHYSICAL_ADDRESS_LENGTH-1:0] address,
/* verilator lint_on UNUSEDSIGNAL */
	output logic [CACHELINESIZE-1:0] data,
	input logic doFetch,
	output logic doneFetch,


	/* L2 Cache controller */
	output logic doL2Fetch,
	input logic doneL2Fetch,
	output logic [PHYSICAL_ADDRESS_LENGTH-1:0] l2Address,
	input logic [CACHELINESIZE-1:0] l2Data,

	input logic clk,
	input logic reset
);

	`define ADDRESS_CACHETAG address[CACHEINDEX+CACHELINEINDEX+:TAGSIZE]
	`define ADDRESS_CACHEINDEX address[CACHELINEINDEX+:CACHEINDEX]
	`define CACHEENTRY cache[`ADDRESS_CACHEINDEX]
	logic [CACHELINESIZE_PRESENT-1:0] cache [NCACHE_ENTRIES-1:0];
	logic waitingForL2;

	always_ff @(posedge clk) begin
		if (reset) begin
			waitingForL2 <= 0;
			data <= 0;
			doL2Fetch <= 0;
			l2Address <= 0;
			cache <= '{default:0};
		end else if (doneL2Fetch && waitingForL2) begin
			cache[`ADDRESS_CACHEINDEX] <= {1'b1, `ADDRESS_CACHETAG, l2Data};
			data <= l2Data;
			doneFetch <= 1;
			doL2Fetch <= 0;
			waitingForL2 <= 0;
		end else if (doFetch) begin
			if (`CACHEENTRY[CACHELINESIZE_PRESENT-1] == 1 && `ADDRESS_CACHETAG == `CACHEENTRY[CACHELINESIZE_PRESENT-2-:TAGSIZE]) begin
				data <= `CACHEENTRY[CACHELINESIZE-1:0];
				doneFetch <= 1;
				waitingForL2 <= 0;
			end else begin
				l2Address <= address;
				doL2Fetch <= 1;
				doneFetch <= 0;
				waitingForL2 <= 1;
			end
		end else begin 
			doL2Fetch <= 0;
			doneFetch <= 0;
		end
	end
endmodule

`undef ADDRESS_CACHETAG
`undef ADDRESS_CACHEINDEX
`undef CACHEENTRY
