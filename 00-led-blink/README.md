# 00 - LED blink

This project uses SystemVerilog to blink an Arty A7 LED. A counter advances
with the board's 100 MHz clock and toggles the LED every 100 million cycles
(about once per second). The reset input is active low.

## Constraints

The `.xdc` file maps `clk`, `rst`, and `led` to physical Arty A7 pins, sets
their I/O standard to 3.3 V LVCMOS, and tells Vivado the clock period is
10 ns. Vivado can help create constraints through its board and I/O planning
tools; check generated pin assignments and timing against the board and design.

## Vivado workflow

Open `00-led-blink.xpr` in Vivado, run **Synthesis**, then **Implementation**,
and **Generate Bitstream**. Connect the Arty A7, open **Hardware Manager**,
program the FPGA with the bitstream, and observe the LED.
