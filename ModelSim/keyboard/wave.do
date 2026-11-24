onerror {resume}
quietly WaveActivateNextPane {} 0
add wave sim:/testbench/*
add wave sim:/testbench/U7.state
add wave sim:/testbench/U7.w_addr
add wave sim:/testbench/U7.w_data

add wave sim:/testbench/U7.product_x0
add wave sim:/testbench/U7.product_x1
add wave sim:/testbench/U7.product_x2

add wave sim:/testbench/U7.product_y0
add wave sim:/testbench/U7.product_y1
add wave sim:/testbench/U7.product_y2

add wave sim:/testbench/U7.product_z0
add wave sim:/testbench/U7.product_z1
add wave sim:/testbench/U7.product_z2

add wave sim:/testbench/U7.cosine_angle
add wave sim:/testbench/U7.sine_angle

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
WaveRestoreZoom {0 ps} {300 ns}
