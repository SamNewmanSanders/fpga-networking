# 02 - Clock domains

This project is a practical exercise in building a design with two clocks. A
100 MHz domain counter and a 25 MHz domain counter each count 100 million clock
cycles before incrementing their own two-bit LED counter. As a result, `led1`
increments about once per second and `led2` about once every four seconds.
Both LED counters wrap from 3 back to 0. Each counter drives its own LEDs, so
this project does not transfer signals between clock domains.

## Clocking Wizard

The Vivado Clocking Wizard is IP that uses the FPGA's clock-management
hardware to generate a clock at a requested frequency. Create and configure it
in Vivado's IP Catalog with the board's 100 MHz input and a 25 MHz output, then
instantiate the generated IP in the RTL. Its `clk_out1` drives logic in the
25 MHz domain. Its `locked` output indicates that this clock is stable; keep
that domain's logic reset until it is locked.

## Using both clocks

Use separate clocked logic for the two counters: one `always_ff` block
triggered by `CLK100MHZ`, and one triggered by `clk_25mhz`. Each counter can
drive its own LEDs without depending on state from the other clock domain.

The 25 MHz clock is derived from the 100 MHz clock, so tell Vivado about the
input clock in the timing constraints and let it analyze the generated clock.

## LED experiment

On the Arty A7, `led1` displays the two-bit counter from the 100 MHz domain
and advances about once per second. `led2` displays the counter from the
25 MHz domain and advances about once every four seconds. Both count from 0
through 3, then wrap back to 0. Press BTN1 to reset both counters.

The XDC file assigns the clock, reset, and LED pins. It routes `eth_ref_clk`
to FPGA pin G18, which connects to the Ethernet PHY's X1 reference-clock input.
The Clocking Wizard's 25 MHz output is the reference clock required there.

Open `02-clock-domains.xpr` in Vivado, run **Synthesis** and
**Implementation**, then **Generate Bitstream**. Program the Arty A7 and
observe the LEDs: `led1` should advance faster than `led2`.

Transferring signals between clock domains—and choosing the right
synchronization method for them—is a useful next topic, but is outside the
scope of this project.

## Result

IT WORKED!!: both LED counters advanced at their expected rates.
With the board connected to a laptop, the Ethernet jack's orange link/activity
LED turned on and flashed; before providing the PHY with its 25 MHz reference
clock, only the green power LED was on.
