# Specify install location of the Xilinx Vivado tool
XILINX_DIR = /opt/Xilinx/Vivado/2019.2

# This defines all the source files (VHDL) used in the project
BOARD_DIR = nexys4ddr
SOURCES  = $(BOARD_DIR)/nexys4ddr.vhd
SOURCES += src/cpu_65c02.vhd
SOURCES += src/control/control.vhd
SOURCES += src/control/microcode.vhd
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

# Configure the FPGA on the Nexys4DDR board with the generated bit-file
fpga: build build/nexys4ddr.bit
	djtgcfg prog -d Nexys4DDR -i 0 --file $<

# Create build directory
build:
	mkdir -p build

# Generate the bit-file used to configure the FPGA
build/nexys4ddr.bit: build/nexys4ddr.tcl $(SOURCES) $(BOARD_DIR)/nexys4ddr.xdc
	bash -c "source $(XILINX_DIR)/settings64.sh ; vivado -mode tcl -source $<"

# Generate the build script used by Vivado
build/nexys4ddr.tcl: Makefile
	echo "# This is a tcl command script for the Vivado tool chain" > $@
	echo "read_vhdl -vhdl2008 { $(SOURCES)  }" >> $@
	echo "read_xdc $(BOARD_DIR)/nexys4ddr.xdc" >> $@
	echo "synth_design -top nexys4ddr -part xc7a100tcsg324-1 -flatten_hierarchy none" >> $@
	echo "opt_design" >> $@
	echo "place_design" >> $@
	echo "route_design" >> $@
	echo "write_bitstream -force build/nexys4ddr.bit" >> $@
	echo "write_checkpoint -force build/nexys4ddr.dcp" >> $@
	echo "exit" >> $@

# Remove all generated files
clean:
	rm -rf build
	rm -rf usage_statistics_webtalk.*
	rm -rf vivado*
	rm -rf .Xil

