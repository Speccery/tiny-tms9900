# tiny-tms9900

This is a simple TMS9900 CPU system for the ICE40UP5K FPGA.
The board I used for development is the UPduino V3 board.

Information about the board: https://github.com/tinyvision-ai-inc/UPduino-v3.0

The core runs at 12MHz, the ICE40UP5K is a quite slow FPGA. FPGA's internal high speed clock is used for clock generation. The core includes:
* my TMS9900 core in verilog (CPU)
* pnr's TMS9902 core (UART)
* 8K ROM, containing EVMBUG (modified to run UART at 9600 8N1)
* 32K RAM (top 32K of the address space)

The initial design uses about 57% of the logic resources of the FPGA.

The EVMBUG is nicely docymented by Stuart Conner at http://www.stuartconner.me.uk/tibug_evmbug/tibug_evmbug.htm#evmbug

The FTDI chip is used for serial communication after configuring the FPGA. Just use a terminal program to communicate with the system. 

Building the core
-----------------
This is simple: install the IceStorm toolchain and issue `make`.

Program the chip
----------------
iceprog top.bin

Reprogramming
-------------
Sometimes it is necessary to issue the programming command twice, or do `iceprog -e 128` to erase a portion of the flash to be able to communicate with the serial flash chip. When the core has already been programmed, it uses some of the pins used for programming the configuration flash chip.

