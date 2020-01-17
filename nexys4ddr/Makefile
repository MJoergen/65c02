# Specify install location of the Xilinx Vivado tool
XILINX_DIR = /opt/Xilinx/Vivado/2019.2

# This defines all the source files (VHDL) used in the project
SRC_DIR = ../src
SOURCES  = nexys4ddr.vhd
SOURCES += $(SRC_DIR)/cpu_65c02.vhd
SOURCES += $(SRC_DIR)/control/control.vhd
SOURCES += $(SRC_DIR)/control/microcode.vhd
SOURCES += $(SRC_DIR)/datapath/datapath.vhd
SOURCES += $(SRC_DIR)/datapath/alu.vhd
SOURCES += $(SRC_DIR)/datapath/ar.vhd
SOURCES += $(SRC_DIR)/datapath/hi.vhd
SOURCES += $(SRC_DIR)/datapath/lo.vhd
SOURCES += $(SRC_DIR)/datapath/pc.vhd
SOURCES += $(SRC_DIR)/datapath/sp.vhd
SOURCES += $(SRC_DIR)/datapath/sr.vhd
SOURCES += $(SRC_DIR)/datapath/xr.vhd
SOURCES += $(SRC_DIR)/datapath/yr.vhd
SOURCES += $(SRC_DIR)/datapath/zp.vhd
SOURCES += $(SRC_DIR)/datapath/mr.vhd

# Configure the FPGA on the Nexys4DDR board with the generated bit-file
fpga: nexys4ddr.bit
	djtgcfg prog -d Nexys4DDR -i 0 --file $<

# Generate the bit-file used to configure the FPGA
nexys4ddr.bit: nexys4ddr.tcl $(SOURCES) nexys4ddr.xdc
	bash -c "source $(XILINX_DIR)/settings64.sh ; vivado -mode tcl -source $<"

# Generate the build script used by Vivado
nexys4ddr.tcl: Makefile
	echo "# This is a tcl command script for the Vivado tool chain" > $@
	echo "read_vhdl -vhdl2008 { $(SOURCES)  }" >> $@
	echo "read_xdc nexys4ddr.xdc" >> $@
	echo "set_param synth.elaboration.rodinMoreOptions \"rt::set_parameter max_loop_limit 200000\"" >> $@
	echo "synth_design -top nexys4ddr -part xc7a100tcsg324-1 -flatten_hierarchy none" >> $@
	echo "opt_design -directive NoBramPowerOpt" >> $@
	echo "place_design" >> $@
	echo "route_design" >> $@
	echo "write_bitstream -force nexys4ddr.bit" >> $@
	echo "exit" >> $@

# Remove all generated files
clean:
	rm -rf usage_statistics_webtalk.*
	rm -rf vivado*
	rm -rf updatemem*
	rm -rf nexys4ddr-rom.bit
	rm -rf nexys4ddr.bit
	rm -rf nexys4ddr.dcp
	rm -rf post_synth.dcp
	rm -rf post_opt.dcp
	rm -rf nexys4ddr.tcl
	rm -rf .Xil
	rm -rf .cache
	rm -rf rom.mem
	rm -rf nexys4ddr.mmi
	rm -rf nexys4ddr.ltx

