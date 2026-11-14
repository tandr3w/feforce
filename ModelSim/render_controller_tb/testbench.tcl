# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work;

# compile the Verilog source code in the parent folder
vlog ../../src/*.v
vlog ../../vertex_rom.v
vlog ../../triangle_rom.v
vlog ../../depth_rom.v
vlog ../../divider.v

file copy -force ../../triangles.mif .
file copy -force ../../vertices.mif .
file copy -force ../../depth_recip.mif .

# compile the Verilog code of the testbench
vlog *.v
# start the Simulator, including some libraries that may be needed
vsim work.testbench -voptargs=+acc -Lf 220model -Lf altera_mf_ver -Lf lpm -Lf verilog
# show waveforms specified in wave.do
do wave.do
# advance the simulation the desired amount of time
run 1000000 ns