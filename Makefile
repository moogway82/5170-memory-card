SOURCES=at_memory_card.vhd
IMAGES=at_memory_card.svf

all: $(SOURCES) $(IMAGES)

at_memory_card.svf: GHDL
	./run_yosys.sh
	./run_fitter.sh at_memory_card -preassign keep -tdi_pullup on -tms_pullup on -output_fast off -xor_synthesis on
	./run_fuseconv.sh

GHDL:
	~/opt/oss-cad-suite/bin/ghdl -a at_memory_card.vhd
	~/opt/oss-cad-suite/bin/ghdl -e at_memory_card
