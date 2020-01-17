# 65c02
Implementation of the 65C02 CPU suitable for FPGA. It is provided with a MIT license.

## Features
The instruction set is the same as for the Rockwell 65C02. In particular, the
WDC-specific instructions (STP and WAI) are *not* supported. The precise
difference between this processor and the original 6502 processor is described
in detail [here](http://6502.org/tutorials/65c02opcodes.html). In particular,
there are no unused opcodes.

This implementation is not cycle exact, although most instructions do in fact
take the same number of cycles as the real chip. All instructions take between
two and eight clock cycles.

## Make targets
The Makefile provides two make targets:

### Building for the Nexys4DDR board

To test the implementation on the Nexys4DDR board, simply type

```
make
```
This will generate a bitfile and program this bitfile onto the Nexys4DDR board.
The test implementation runs a short assembly program that shows a binary
counter on the LED's.

### Testing in simulation
To test the implementation in simulation, type
```
make sim
```

## Implementation
It is written in VHDL-2008, and is tested on the Nexys4DDR board from Digilent,
which contains a Xilinx Artyx-7 FPGA.

The implementation is split up into a datapath block and a control block. The
control block uses microcoding to implement each instruction. The microcode is
implemented in a BRAM.

This design is inspired by Ben Eaters [video
series](https://www.youtube.com/playlist?list=PLowKtXNTBypGqImE405J2565dvjafglHU).

To save BRAM, the microcode can be implemented using combinatorial logic
instead, at a cost of approx. 200 LUTs.

## Utilization
The utilization is:

|  Item     | Number |
| --------  | ------ |
| LUTs      |  445   |
| Registers |  106   |
| BRAMs     |    3   | 

## Timing
The CPU easily runs at 25 MHz, i.e. a clock period of 40 ns.

Beware, the 65C02 CPU expects the output from the RAM to be ready on the next
clock cycle, which is essentially the same as requiring a combinatorial read
from memory. In applications, one option is to clock the Block RAM (outside the
CPU) using an inverted clock, so essentially the timing requirement is half a
clock period, i.e. 20 ns.

## Verification
The design has been tested using Klaus Dormanns very thorough test
[here](https://github.com/Klaus2m5/6502_65C02_functional_tests).

## TODO
Make the cycle timing of all instructions match the real chip, see e.g.  [this
link](http://6502.org/tutorials/65c02opcodes.html).


