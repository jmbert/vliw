

module l2cache #(
	NFU=2,
	NCACHE_ENTRIES=2048,
	ADDRESS_LENGTH=56,

	localparam CACHELINEINDEX = $clog2(NFU * 4),
	localparam CACHEINDEX = $clog2(NCACHE_ENTRIES),
	localparam TAGSIZE = ADDRESS_LENGTH - CACHEINDEX - CACHELINEINDEX,

	localparam CACHELINEWIDTH = NFU * 32,
	localparam CACHEENTRYWIDTH = CACHELINEWIDTH + 2 + TAGSIZE // Valid, dirty and tag bits
) (
/* verilator lint_off UNUSEDSIGNAL */
	input logic [ADDRESS_LENGTH-1:0] address,
/* verilator lint_on UNUSEDSIGNAL */
	input logic doFetch,
	output logic doneFetch,
	output logic [CACHELINEWIDTH-1:0] data,

	input logic clk,

	output logic doMainFetch,
	output logic doMainWrite,
	input logic [63:0] mainData,
	output logic [63:0] mainDataWrite,
	output logic [ADDRESS_LENGTH-1:0] mainAddress
);

	`define ADDRESS_CACHETAG address[CACHEINDEX+CACHELINEINDEX+:TAGSIZE]
	`define ADDRESS_CACHEINDEX address[CACHELINEINDEX+:CACHEINDEX]
	`define CACHEENTRY cache[`ADDRESS_CACHEINDEX]

	logic [CACHEENTRYWIDTH-1:0] cache [NCACHE_ENTRIES-1:0];

	logic waitingForMain;

	assign doMainWrite = 0;
	assign mainDataWrite = 0;

	always_ff @( posedge clk ) begin
		if (waitingForMain) begin
			cache[`ADDRESS_CACHEINDEX] <= {2'b10, `ADDRESS_CACHETAG, mainData};
			data <= mainData;
			doneFetch <= 1;
			doMainFetch <= 0;
			waitingForMain <= 0;
		end else if (doFetch) begin
			if (`CACHEENTRY[CACHEENTRYWIDTH-1] == 1 && `ADDRESS_CACHETAG == `CACHEENTRY[CACHEENTRYWIDTH-2-:TAGSIZE]) begin
				data <= `CACHEENTRY[CACHELINEWIDTH-1:0];
				doneFetch <= 1;
				waitingForMain <= 0;
			end else begin
				mainAddress <= address;
				doMainFetch <= 1;
				doneFetch <= 0;
				waitingForMain <= 1;
			end
		end else begin 
			doMainFetch <= 0;
			doneFetch <= 0;
		end
	end
endmodule

`undef ADDRESS_CACHETAG
`undef ADDRESS_CACHEINDEX
`undef CACHEENTRY
