# This is a tcl command script for the Vivado tool chain
read_vhdl -vhdl2008 { nexys4ddr/nexys4ddr.vhd src/cpu_65c02.vhd src/control/control.vhd src/control/microcode.vhd src/datapath/datapath.vhd src/datapath/alu.vhd src/datapath/ar.vhd src/datapath/hi.vhd src/datapath/lo.vhd src/datapath/pc.vhd src/datapath/sp.vhd src/datapath/sr.vhd src/datapath/xr.vhd src/datapath/yr.vhd src/datapath/zp.vhd src/datapath/mr.vhd  }
read_xdc nexys4ddr/nexys4ddr.xdc
synth_design -top nexys4ddr -part xc7a100tcsg324-1 -flatten_hierarchy none
opt_design
place_design
route_design
write_bitstream -force build/nexys4ddr.bit
write_checkpoint -force build/nexys4ddr.dcp
exit
