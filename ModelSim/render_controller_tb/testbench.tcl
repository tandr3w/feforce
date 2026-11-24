# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work;

# compile the Verilog source code in the parent folder
vlog ../../sim/*.v
vlog ../../src/*.v

file copy -force ../../sim/triangles.hex .
file copy -force ../../sim/vertices.hex .
file copy -force ../../sim/texture.hex .

# compile the Verilog code of the testbench
vlog *.v

# start the Simulator, including some libraries that may be needed
vsim work.testbench -voptargs=+acc -Lf 220model -Lf altera_mf_ver -Lf lpm -Lf verilog
# show waveforms specified in wave.do
do wave.do
# advance the simulation the desired amount of time
run 5000000 ns