SOURCES=at_memory_card_128k_only.vhd
IMAGES=at_memory_card_128k_only.svf

all: $(SOURCES) $(IMAGES)

at_memory_card_128k_only.svf: GHDL
	./run_yosys.sh
	./run_fitter.sh at_memory_card_128k_only -preassign keep -tdi_pullup on -tms_pullup on -output_fast off -xor_synthesis on -logic_doubling off
	./run_fuseconv.sh

GHDL:
	~/opt/oss-cad-suite/bin/ghdl -a at_memory_card_128k_only.vhd
	~/opt/oss-cad-suite/bin/ghdl -e at_memory_card_128k_only

test: GHDL
	~/opt/oss-cad-suite/bin/ghdl -a SRAM.vhd
	~/opt/oss-cad-suite/bin/ghdl -e SRAM
	~/opt/oss-cad-suite/bin/ghdl -a at_memory_card_tb.vhd 
	~/opt/oss-cad-suite/bin/ghdl -e at_memory_card_tb
	~/opt/oss-cad-suite/bin/ghdl -r at_memory_card_tb --wave=at_memory_card_tb.ghw --ieee-asserts=disable # --stop-time=2000ms

clean:
	rm -f $(IMAGES) at_memory_card_128k_only at_memory_card_128k_only.edif at_memory_card_128k_only.fit at_memory_card_128k_only.io at_memory_card_128k_only.jed at_memory_card_128k_only.pin at_memory_card_128k_only.tt3 work-obj*.cf at_memory_card_tb.o at_memory_card_128k_only.o e~at_memory_card_128k_only.o e~at_memory_card_tb.o at_memory_card_tb.vcd

view:
	surfer at_memory_card_tb.ghw -s bus_cycle.surf.ron > /dev/null &