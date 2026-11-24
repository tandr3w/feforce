# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work;

# compile the Verilog source code in the parent folder
vlog ../../src/vertextransformer.v
vlog ../../ip/sine_rom.v
file copy -force C:/Users/henry/Documents/Github/feforce/ModelSim/vertex_transformer/sine_rom.mif .

# compile the Verilog code of the testbench
vlog *.v
# start the Simulator, including some libraries that may be needed
vsim work.testbench -voptargs=+acc -Lf 220model -Lf altera_mf_ver -Lf verilog
# show waveforms specified in wave.do
do wave.do
# advance the simulation the desired amount of time
run 900 ns
