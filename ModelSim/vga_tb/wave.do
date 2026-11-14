onerror {resume}
quietly WaveActivateNextPane {} 0
add wave sim:/testbench/clk
add wave sim:/testbench/rst
add wave sim:/testbench/pixel_clk
add wave sim:/testbench/sx
add wave sim:/testbench/sy
add wave sim:/testbench/de
add wave sim:/testbench/hsync
add wave sim:/testbench/vsync
add wave sim:/testbench/DUT/*
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
WaveRestoreZoom {0 ps} {17000000 ns}