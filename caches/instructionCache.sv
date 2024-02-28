
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

	input logic clk
);
	initial begin
		$readmemh("initCache.txt", cache);
	end

	logic [CACHELINESIZE_PRESENT-1:0] cache [NCACHE_ENTRIES-1:0];

	logic [CACHEINDEX-1:0] cacheIndex;
	logic [TAGSIZE-1:0] tag;
	
	logic [CACHELINESIZE_PRESENT-1:0] cacheLine;

	/*
		Address: TAG CACHEINDEX ZERO(n bits)
	*/
	logic checkMiss;

	always_comb begin
		cacheIndex = address[CACHELINEINDEX+CACHEINDEX-1:CACHELINEINDEX];
		tag = address[TAGSIZE+CACHEINDEX+CACHELINEINDEX-1:CACHEINDEX+CACHELINEINDEX];
	end

	always_ff @(posedge clk) begin
		doneFetch <= 0;
		if (checkMiss) begin
			// After this, it seems to be delayed by a cycle
			if (cacheLine[CACHELINESIZE_PRESENT-1] == 1 && tag == cacheLine[CACHELINESIZE_PRESENT-2-:TAGSIZE]) begin
				/*
					Valid cache entry, proceed
				*/
				data <= cacheLine[CACHELINESIZE-1:0];
			end else begin
				/*
					TODO - Handle cache miss
				*/
				data <= 0;
			end
			doneFetch <= 1;
			checkMiss <= 0;	
		end else if (doFetch) begin
			cacheLine <= cache[cacheIndex];
			checkMiss <= 1;
		end
	end
endmodule
