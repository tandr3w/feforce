transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/src {C:/Users/every/Documents/Programming/feforce/src/vga.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/src {C:/Users/every/Documents/Programming/feforce/src/top.v}

vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/ModelSim {C:/Users/every/Documents/Programming/feforce/ModelSim/testbench.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
