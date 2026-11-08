// input is a 3d point, outputs projected 2d points that are on the framebuffer space
// https://www.cs.rochester.edu/courses/259/fall2025/decks/lect21-rasterization.pdf

// using fixed point stuff for division https://projectf.io/posts/division-in-verilog/
// module divisionUnit (
//     input clk, 
//     input [15:0] 
//     reg 
// );
// endmodule

module vertexProjector ( // i should output new coords x0,y0 ... to x2,y2 based off depth

// output 4 points, x,y,z,w
    input clk,
    input rst,
    input [15:0] color, 

    // input 3d points(transformed)
    input signed [15:0] x0, y0, z0,
    input signed [15:0] x1, y1, z1,
    input signed [15:0] x2, y2, z2,


    //output projected points
    output [15:0] x0_out, x1_out, x2_out,
    output [15:0] y0_out, y1_out, y2_out,
    // calculated depth?
    output [15:0] color_out,
    output [15:0] z0_out, z1_out, z2_out, // z
    output [15:0] w0_out, w1_out, w2_out, // w
    // fixed point check later

    parameter [15:0] n = 10 * 256,
    parameter [15:0] r = 5 * 256,
    parameter [15:0] l = -5 * 256,
    parameter [15:0] t = 5 * 256, 
    parameter [15:0] b = -5 * 256,
    parameter [15:0] f = 4'd15 * 256, 

    parameter [15:0] a1 = (2 * n) / (r - l), 
    parameter [15:0] b2 = (2 * n) / (t - b), 
    parameter [15:0] c1 = -(r + l) / (r - l) * 256, // set these to be really nice numbers, otherwise manually simplify
    parameter [15:0] c2 = -(t + b) / (t - b) * 256,
    parameter [15:0] c3 = (f + n) / (f - n) * 256,
    parameter [15:0] c4 = 1 * 256, 
    parameter [15:0] d3 = (-2 * f * n) / (f - n), // fine maybe

);
// camera space 
// perspective divide
// screen space
// remap to NDC(normailised device coords [-1,1] coord range)
// NDC space to raster space

// just use a matrix ig
    // how do i do synthsiable division
    // these are given in NDC space
    assign x0_out = x0 * a1; 
    assign y0_out = y0 * b2; 
    assign z0_out = z0 * (c1 + c2 + c3 + 1);
    assign w0_out = 1 * d3;  

    assign x1_out = x1 * a1; 
    assign y1_out = y1 * b2; 
    assign z1_out = z1 * (c1 + c2 + c3 + 1);
    assign w1_out = 1 * d3;  

    assign x2_out = x2 * a1; 
    assign y2_out = y2 * b2; 
    assign z2_out = z2 * (c1 + c2 + c3 + 1);
    assign w2_out = 1 * d3;  

    assign color_out = color; 


    // lookup table thing
    // divide by w to do division
    // need fsm 


    

endmodule; 
