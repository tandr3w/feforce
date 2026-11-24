# FeForce

A basic rasterizer and 3D graphics engine written in Verilog for the **Terasic DE1-SoC FPGA**. 

## Features

* Triangle rasterization.
* Loading and rendering triangles and vertices from memory.
* Affine textures based on the texture loaded in memory.
* Directional (diffuse) lighting.
* Vertex projections and transformations.
* Depth buffering and back face culling.
* Output @ 60FPS on 640x480 VGA output (the internal logic is in 320x240, which is upscaled 2x).

## Usage

Open the project in Quartus using `feforce.qpf`. Python scripts are provided in `tools/` for loading .obj files and textures and converting them into `.mif` files that will be initialized in memory during compilation. The entry point is `top.v`.

## Controls

Press KEY[0] for reset. 

## Testing

There is a `sim/` and `tb/` file for use with DESim. The `sim/` file contains simplified implementations of the Quartus IP blocks to be used in simulation only. ModelSim testbenches can be found in `ModelSim/`. Simply run `do testbench.tcl` in the subfolder for the module you wish to test.
