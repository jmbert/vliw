
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
	input [PHYSICAL_ADDRESS_LENGTH-1:0] address,
	output [CACHELINESIZE-1:0] data,
	input doFetch,

	input clk
);
	initial begin
		$readmemh("initCache.txt", cache);
	end

	reg [CACHELINESIZE_PRESENT-1:0] cache [NCACHE_ENTRIES-1:0];

	reg [CACHELINEINDEX-1:0] instrOffset; // Only used to detect misalignment
	reg [CACHEINDEX-1:0] cacheIndex;
	reg [TAGSIZE-1:0] tag;
	
	reg [CACHELINESIZE_PRESENT-1:0] cacheLine;

	reg [CACHELINESIZE-1:0] dataOut;
	assign data = dataOut;

	/*
		Address: TAG CACHEINDEX ZERO(n bits)
	*/
	reg checkMiss;
	reg missed;

	always_comb begin
		instrOffset = address[CACHELINEINDEX-1:0];
		cacheIndex = address[CACHELINEINDEX+CACHEINDEX-1:CACHELINEINDEX];
		tag = address[TAGSIZE+CACHEINDEX+CACHELINEINDEX-1:CACHEINDEX+CACHELINEINDEX];
	end

	always_ff @(doFetch) begin
		cacheLine <= cache[cacheIndex];
		checkMiss <= ~checkMiss;
	end

	always_ff @(checkMiss) begin
		// After this, it seems to be delayed by a cycle
		if (cacheLine[0] == 1 && tag == cacheLine[1+:TAGSIZE]) begin
			/*
				Valid cache entry, proceed
			*/
			dataOut <= cacheLine[CACHELINESIZE_PRESENT-1:1+TAGSIZE];
			missed <= 0;
			$display("%x => %x => %x", address, cacheIndex, cacheLine);
		end else begin
			/*
				TODO - Handle cache miss
			*/
			dataOut <= 0;
			missed <= 1;
			$display("Instruction Cache Miss:\n\tCache line index: %x\n\tCache line: %x\n\tTag: %x\n\tFull Address: %x", cacheIndex, cacheLine, tag, address);
		end
	end
endmodule
