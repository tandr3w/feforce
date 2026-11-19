transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/ip {C:/Users/every/Documents/Programming/feforce/ip/depth_rom.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/src {C:/Users/every/Documents/Programming/feforce/src/vertexprojector.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/src {C:/Users/every/Documents/Programming/feforce/src/vga.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/src {C:/Users/every/Documents/Programming/feforce/src/triangle_loader.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/src {C:/Users/every/Documents/Programming/feforce/src/top.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/src {C:/Users/every/Documents/Programming/feforce/src/render_controller.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/src {C:/Users/every/Documents/Programming/feforce/src/rasterizer.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/src {C:/Users/every/Documents/Programming/feforce/src/framebuffer.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/ip {C:/Users/every/Documents/Programming/feforce/ip/vertex_rom.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/ip {C:/Users/every/Documents/Programming/feforce/ip/triangle_rom.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/ip {C:/Users/every/Documents/Programming/feforce/ip/framebuffer_ram.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/ip {C:/Users/every/Documents/Programming/feforce/ip/divider.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/ip {C:/Users/every/Documents/Programming/feforce/ip/depthbuffer_ram.v}
vlog  -work work +incdir+C:/Users/every/Documents/Programming/feforce/ip {C:/Users/every/Documents/Programming/feforce/ip/texture_rom.v}

