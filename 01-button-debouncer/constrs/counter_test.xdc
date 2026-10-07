# Arty A7 100 MHz clock.
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 [get_ports clk]

# BTN0 counts; BTN1 resets the counter.
set_property PACKAGE_PIN D9 [get_ports button]
set_property IOSTANDARD LVCMOS33 [get_ports button]
set_property PACKAGE_PIN C9 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# Four user LEDs.
set_property PACKAGE_PIN H5 [get_ports {leds[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
set_property PACKAGE_PIN J5 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
set_property PACKAGE_PIN T9 [get_ports {leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]
set_property PACKAGE_PIN T10 [get_ports {leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]
