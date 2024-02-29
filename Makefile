
TOPMOD?=tb_vliw
TOPFILE?=testBench.sv
CXX=gcc

VERILATOR?=verilator
NPROC=$(shell nproc)
VFLAGS= -Wall -Wno-fatal -Wno-DECLFILENAME --compiler $(CXX) --trace --assert --top $(TOPMOD) -j $(NPROC)


binary:
	$(VERILATOR) --binary $(TOPFILE) $(VFLAGS)
cc:
	$(VERILATOR) --cc $(TOPFILE) $(VFLAGS)
