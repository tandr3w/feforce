# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work;

# compile the Verilog source code in the parent folder
vlog ../../src/*.v
# compile the Verilog code of the testbench
vlog *.v
# vlog ../../ip/divider.v
vlog ../../sim/*.v
# vlog ../../ip/texture_rom.v
# vlog ../../ip/depthbuffer_ram.v
# vlog ../../ip/depth_rom.v

# start the Simulator, including some libraries that may be needed
vsim work.testbench -voptargs=+acc -Lf 220model -Lf altera_mf_ver -Lf verilog
file copy -force ../../sim/triangles.hex .
file copy -force ../../sim/vertices.hex .
file copy -force ../../sim/texture.hex .


# show waveforms specified in wave.do
do wave.do
# advance the simulation the desired amount of time
run 100000 ns
