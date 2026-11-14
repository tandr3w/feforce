onerror {resume}
quietly WaveActivateNextPane {} 0
add wave sim:/testbench/*
add wave sim:/testbench/DUT/state
add wave sim:/testbench/DUT/curr_triangle
add wave sim:/testbench/DUT/loader_start
add wave sim:/testbench/DUT/loader_valid
add wave sim:/testbench/DUT/projector_start
add wave sim:/testbench/DUT/projector_done
add wave sim:/testbench/DUT/raster_start
add wave sim:/testbench/DUT/raster_done
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
WaveRestoreZoom {0 ps} {1000000 ns}