# Arty A7 100 MHz board clock.
set_property PACKAGE_PIN E3 [get_ports CLK100MHZ]
set_property IOSTANDARD LVCMOS33 [get_ports CLK100MHZ]
create_clock -period 10.000 [get_ports CLK100MHZ]

# BTN0 resets, BTN1 writes, and BTN2 reads. Arty A7 pushbuttons are active high.
set_property PACKAGE_PIN D9 [get_ports btn_reset]
set_property IOSTANDARD LVCMOS33 [get_ports btn_reset]
set_property PACKAGE_PIN C9 [get_ports btn_write]
set_property IOSTANDARD LVCMOS33 [get_ports btn_write]
set_property PACKAGE_PIN B9 [get_ports btn_read]
set_property IOSTANDARD LVCMOS33 [get_ports btn_read]

# Four switches form the 4-bit FIFO input value.
set_property PACKAGE_PIN A8 [get_ports {switches[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[0]}]
set_property PACKAGE_PIN C11 [get_ports {switches[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[1]}]
set_property PACKAGE_PIN C10 [get_ports {switches[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[2]}]
set_property PACKAGE_PIN A10 [get_ports {switches[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[3]}]

# Four user LEDs display the last value read from the FIFO.
set_property PACKAGE_PIN H5 [get_ports {leds[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
set_property PACKAGE_PIN J5 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
set_property PACKAGE_PIN T9 [get_ports {leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]
set_property PACKAGE_PIN T10 [get_ports {leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]

# Arty A7 RGB LED 0 is common-anode, so its color outputs are active low.
set_property PACKAGE_PIN G6 [get_ports {rgb_led_n[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_led_n[2]}]
set_property PACKAGE_PIN F6 [get_ports {rgb_led_n[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_led_n[1]}]
set_property PACKAGE_PIN E1 [get_ports {rgb_led_n[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_led_n[0]}]
