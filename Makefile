# Specify install location of the Xilinx Vivado tool
XILINX_DIR = /opt/Xilinx/Vivado/2020.2

PLATFORM = nexys4ddr
PART = xc7a100tcsg324-1

# This defines all the source files (VHDL) used in the project
SOURCES  = $(PLATFORM)/$(PLATFORM).vhd
SOURCES += $(PLATFORM)/memory.vhd
SOURCES += src/cpu_65c02.vhd
SOURCES += src/control/control.vhd
SOURCES += src/control/microcode_65c02.vhd
SOURCES += src/control/microcode_6502.vhd
SOURCES += src/datapath/datapath.vhd
SOURCES += src/datapath/alu.vhd
SOURCES += src/datapath/ar.vhd
SOURCES += src/datapath/hi.vhd
SOURCES += src/datapath/lo.vhd
SOURCES += src/datapath/pc.vhd
SOURCES += src/datapath/sp.vhd
SOURCES += src/datapath/sr.vhd
SOURCES += src/datapath/xr.vhd
SOURCES += src/datapath/yr.vhd
SOURCES += src/datapath/zp.vhd
SOURCES += src/datapath/mr.vhd

VARIANT = 65C02

#ROM_FILE = test/6502_functional_test.s
ROM_FILE = test/65C02_extended_opcodes_test.s

STOP_TIME = 1ms

# Configure the FPGA on the board with the generated bit-file
fpga: build build/$(PLATFORM).bit
	djtgcfg prog -d $(PLATFORM) -i 0 --file $<

# Generate the bit-file used to configure the FPGA
build/$(PLATFORM).bit: build/$(PLATFORM).tcl $(SOURCES) $(PLATFORM)/$(PLATFORM).xdc build/rom.txt
	bash -c "source $(XILINX_DIR)/settings64.sh ; vivado -mode tcl -source $<"

# Create build directory
build:
	mkdir -p build

build/$(PLATFORM).tcl: Makefile
	echo "# This is a tcl command script for the Vivado tool chain" > $@
	echo "read_vhdl -vhdl2008 { $(SOURCES) }" >> $@
	echo "read_xdc $(PLATFORM)/$(PLATFORM).xdc" >> $@
	echo "synth_design -top $(PLATFORM) -part $(PART) -flatten_hierarchy none -generic G_VARIANT=$(VARIANT)" >> $@
	echo "opt_design" >> $@
	echo "place_design" >> $@
	echo "phys_opt_design" >> $@
	echo "route_design" >> $@
	echo "write_bitstream -force $(PLATFORM).bit" >> $@
	echo "write_checkpoint -force $(PLATFORM).dcp" >> $@
	echo "exit" >> $@

build/rom.txt: $(ROM_FILE)
	ca65 $^ -o build/rom.o -l build/rom.lst
	ld65 -vm -m build/rom.map -C test/ld.cfg build/rom.o
	./bin2hex.py build/rom.bin build/rom.txt

sim: build build/rom.txt $(SOURCES) $(PLATFORM)/$(PLATFORM)_tb.vhd
	ghdl -i --std=08 --workdir=build $(SOURCES) $(PLATFORM)/$(PLATFORM)_tb.vhd
	ghdl -m --std=08 --workdir=build $(PLATFORM)_tb
	ghdl -r $(PLATFORM)_tb  --max-stack-alloc=16384 --wave=build/$(PLATFORM).ghw --stop-time=$(STOP_TIME) -gG_VARIANT=$(VARIANT)
	gtkwave build/$(PLATFORM).ghw $(PLATFORM)/$(PLATFORM).gtkw

# Remove all generated files
clean:
	rm -rf build
	rm -rf usage_statistics_webtalk.*
	rm -rf vivado*
	rm -rf .Xil
	rm -rf a.out
	rm -rf e~$(PLATFORM)_tb.o
	rm -rf $(PLATFORM)_tb
	rm -rf $(PLATFORM).bit
	rm -rf $(PLATFORM).dcp


