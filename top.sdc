create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]
create_generated_clock -name pixel_clk \
    -source [get_ports {clock_50}] \
    -divide_by 2 \
    [get_pins {pixel_clock:U1|pixel_clk}]