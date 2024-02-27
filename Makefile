
TOPMOD?=tb_vliw
TOPFILE?=testBench.sv
CXX=gcc

VERILATOR?=verilator
NPROC=$(shell nproc)
VFLAGS= -Wall -Wno-DECLFILENAME -Wno-UNDRIVEN -Wno-UNUSEDSIGNAL --compiler $(CXX) --trace --assert --top $(TOPMOD) -j $(NPROC)


binary:
	$(VERILATOR) --binary $(TOPFILE) $(VFLAGS)
cc:
	$(VERILATOR) --cc $(TOPFILE) $(VFLAGS)
