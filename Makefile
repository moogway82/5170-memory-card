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

test: GHDL
	~/opt/oss-cad-suite/bin/ghdl -a at_memory_card_tb.vhd 
	~/opt/oss-cad-suite/bin/ghdl -e at_memory_card_tb
	~/opt/oss-cad-suite/bin/ghdl -r at_memory_card_tb --vcd=at_memory_card_tb.vcd --ieee-asserts=disable

clean:
	rm -f $(IMAGES) at_memory_card at_memory_card.edif at_memory_card.fit at_memory_card.io at_memory_card.jed at_memory_card.pin at_memory_card.tt3 work-obj*.cf at_memory_card_tb.o at_memory_card.o e~at_memory_card.o e~at_memory_card_tb.o at_memory_card_tb.vcd
