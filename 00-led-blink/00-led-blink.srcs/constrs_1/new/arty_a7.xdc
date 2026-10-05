# Arty A7 board pin and timing constraints.

# Connect the top-level clock input to the board's 100 MHz oscillator.
# E3 is the oscillator pin on the Arty A7.
set_property PACKAGE_PIN E3 [get_ports clk]

# The FPGA I/O bank connected to this signal uses 3.3 V signalling.
# LVCMOS33 tells Vivado which voltage levels and electrical thresholds to use.
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# Connect the top-level reset input to FPGA package pin C2.
set_property PACKAGE_PIN C2 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# Connect the top-level LED output to the board LED on package pin H5.
set_property PACKAGE_PIN H5 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]

# Tell Vivado that clk repeats every 10 ns (100 MHz). This lets timing
# analysis check whether the design's logic can meet the board clock speed;
# it does not generate or change the physical clock.
create_clock -period 10.000 [get_ports clk]