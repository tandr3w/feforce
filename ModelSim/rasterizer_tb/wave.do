onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -divider "CONTROL"
add wave sim:/testbench/clk
add wave sim:/testbench/rst
add wave sim:/testbench/start
add wave -radix unsigned sim:/testbench/DUT/state
add wave sim:/testbench/DUT/done_d0
add wave sim:/testbench/DUT/done_d1
add wave sim:/testbench/DUT/done_d2

add wave -divider "COORDS"
add wave -radix unsigned sim:/testbench/DUT/x0
add wave -radix unsigned sim:/testbench/DUT/y0
add wave -radix unsigned sim:/testbench/DUT/x1
add wave -radix unsigned sim:/testbench/DUT/y1
add wave -radix unsigned sim:/testbench/DUT/x2
add wave -radix unsigned sim:/testbench/DUT/y2
add wave -radix unsigned sim:/testbench/DUT/depth0
add wave -radix unsigned sim:/testbench/DUT/depth1
add wave -radix unsigned sim:/testbench/DUT/depth2

add wave -divider "D0"
add wave -radix unsigned sim:/testbench/DUT/curr_x
add wave -radix unsigned sim:/testbench/DUT/curr_y
add wave sim:/testbench/DUT/inside
add wave -radix unsigned sim:/testbench/DUT/depth_out

add wave -divider "D1"
add wave -radix unsigned sim:/testbench/DUT/x_d1
add wave -radix unsigned sim:/testbench/DUT/y_d1
add wave -radix unsigned sim:/testbench/DUT/depth_d1
add wave -radix unsigned sim:/testbench/DUT/stored_depth
add wave sim:/testbench/DUT/write_enable_d1

add wave -divider "TEXTURE & LIGHTING"
add wave -radix unsigned sim:/testbench/DUT/u_coord
add wave -radix unsigned sim:/testbench/DUT/v_coord
add wave -radix hexadecimal sim:/testbench/DUT/texture_color
add wave -radix unsigned sim:/testbench/DUT/brightness
add wave -radix unsigned sim:/testbench/DUT/red_out
add wave -radix unsigned sim:/testbench/DUT/green_out
add wave -radix unsigned sim:/testbench/DUT/blue_out

add wave -divider "OUTPUT"
add wave -radix unsigned sim:/testbench/DUT/write_x
add wave -radix unsigned sim:/testbench/DUT/write_y
add wave -radix hexadecimal sim:/testbench/DUT/write_color
add wave sim:/testbench/DUT/write_enable

TreeUpdate [SetDefaultTree]
quietly wave cursor active 1
configure wave -namecolwidth 80
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {100000 ns}