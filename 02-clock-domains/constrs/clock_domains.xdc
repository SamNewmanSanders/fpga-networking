# Arty A7 100 MHz board clock.
set_property PACKAGE_PIN E3 [get_ports CLK100MHZ]
set_property IOSTANDARD LVCMOS33 [get_ports CLK100MHZ]
create_clock -period 10.000 [get_ports CLK100MHZ]

# BTN1 is active-high - used as reset.
set_property PACKAGE_PIN C9 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst] 

# led1[1:0] displays the 100 MHz domain counter.
set_property PACKAGE_PIN H5 [get_ports {led1[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led1[0]}]
set_property PACKAGE_PIN J5 [get_ports {led1[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led1[1]}]

# led2[1:0] displays the 25 MHz domain counter.
set_property PACKAGE_PIN T9 [get_ports {led2[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led2[0]}]
set_property PACKAGE_PIN T10 [get_ports {led2[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led2[1]}]

# Drive the Arty A7 Ethernet PHY's ETH_REF_CLK input (PHY pin X1).
set_property PACKAGE_PIN G18 [get_ports eth_ref_clk]
set_property IOSTANDARD LVCMOS33 [get_ports eth_ref_clk]
