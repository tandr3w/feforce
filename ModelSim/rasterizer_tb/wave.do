onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -radix decimal sim:/testbench/*

add wave -divider "CONTROL"
add wave sim:/testbench/DUT/start
add wave -radix unsigned sim:/testbench/DUT/state
add wave -radix unsigned sim:/testbench/DUT/divider_counter
add wave sim:/testbench/DUT/done_d0
add wave sim:/testbench/DUT/done_d1
add wave sim:/testbench/DUT/done

add wave -divider "TRIANGLE"
add wave -radix unsigned sim:/testbench/DUT/x0
add wave -radix unsigned sim:/testbench/DUT/y0
add wave -radix unsigned sim:/testbench/DUT/x1
add wave -radix unsigned sim:/testbench/DUT/y1
add wave -radix unsigned sim:/testbench/DUT/x2
add wave -radix unsigned sim:/testbench/DUT/y2
add wave -radix unsigned sim:/testbench/DUT/depth0
add wave -radix unsigned sim:/testbench/DUT/depth1
add wave -radix unsigned sim:/testbench/DUT/depth2

add wave -divider "BOUNDING BOX"
add wave -radix unsigned sim:/testbench/DUT/min_x
add wave -radix unsigned sim:/testbench/DUT/max_x
add wave -radix unsigned sim:/testbench/DUT/min_y
add wave -radix unsigned sim:/testbench/DUT/max_y
add wave sim:/testbench/DUT/valid

add wave -divider "CURRENT PIXEL"
add wave -radix unsigned sim:/testbench/DUT/curr_x
add wave -radix unsigned sim:/testbench/DUT/curr_y
add wave -radix decimal sim:/testbench/DUT/t_area
add wave -radix decimal sim:/testbench/DUT/edge0
add wave -radix decimal sim:/testbench/DUT/edge1
add wave -radix decimal sim:/testbench/DUT/edge2
add wave sim:/testbench/DUT/inside
add wave -radix decimal sim:/testbench/DUT/t_area_recip

add wave -divider "TEXTURE"
add wave -radix decimal sim:/testbench/DUT/u_sum
add wave -radix decimal sim:/testbench/DUT/v_sum
add wave -radix decimal sim:/testbench/DUT/u_scaled
add wave -radix decimal sim:/testbench/DUT/v_scaled
add wave -radix unsigned sim:/testbench/DUT/u_coord
add wave -radix unsigned sim:/testbench/DUT/v_coord
add wave -radix hexadecimal sim:/testbench/DUT/texture_color

add wave -divider "DEPTH"
add wave -radix decimal sim:/testbench/DUT/depth_sum
add wave -radix decimal sim:/testbench/DUT/depth_scaled
add wave -radix unsigned sim:/testbench/DUT/depth_out
add wave -radix unsigned sim:/testbench/DUT/stored_depth

add wave -divider "PIPELINE"
add wave -radix unsigned sim:/testbench/DUT/x_d1
add wave -radix unsigned sim:/testbench/DUT/y_d1
add wave -radix unsigned sim:/testbench/DUT/depth_d1
add wave sim:/testbench/DUT/valid_d1
add wave sim:/testbench/DUT/write_enable_d1

add wave -divider "LIGHTING"
add wave -radix decimal sim:/testbench/DUT/brightness_raw
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