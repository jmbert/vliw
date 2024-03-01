
`default_nettype none
`include "vliw.sv"
`include "soc/ram.sv"

module tb_vliw;
logic clk;
logic rst_n;

vliw vliw
(
	.clk(clk),
	.rst(rst_n),

	.addressBus(addressBus),
	.dataIn(dataIn),
	.dataOut(dataOut),
	.enableWrite(enableWrite)
);

wire [55:0] addressBus;
wire [63:0] dataIn;
wire [63:0] dataOut;
wire enableWrite;

ram ram (
	.address(addressBus),
	.dataIn(dataOut),
	.dataOut(dataIn),
	.we(enableWrite),

	.clk(clk)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk<=~clk;

initial begin
	$dumpfile("tb_vliw.vcd");
	$dumpvars(0, tb_vliw);
end

localparam TEST_CYCLES = 100;

initial begin
	#1 rst_n=1'bx;clk=1'bx;
	#(CLK_PERIOD*3) rst_n=1;
	#(CLK_PERIOD*3) rst_n=0;clk=0;
	repeat(TEST_CYCLES) @(posedge clk);
	rst_n=1;
	@(posedge clk);
	repeat(2) @(posedge clk);
	$finish(2);
end

endmodule
