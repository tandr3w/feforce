# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work;

# compile the Verilog source code in the parent folder
vlog ../../src/vertextransformer.v
# vlog ../../sine_rom.v
# file copy ../../sine_rom.mif .
file copy -force ../../sim/sine_table.hex .
file copy -force ../../sine_rom.v .

# compile the Verilog code of the testbench
vlog *.v
# start the Simulator, including some libraries that may be needed
vsim work.testbench -voptargs=+acc -Lf 220model -Lf altera_mf_ver -Lf verilog
# show waveforms specified in wave.do
do wave.do
# advance the simulation the desired amount of time
run 900 ns
