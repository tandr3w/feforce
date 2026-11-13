// input is a 3d point, outputs projected 2d points that are on the framebuffer space
// https://www.cs.rochester.edu/courses/259/fall2025/decks/lect21-rasterization.pdf

// using fixed point stuff for division https://projectf.io/posts/division-in-verilog/
// module divisionUnit (
//     input clk, 
//     input [15:0] 
//     reg 
// );
// endmodule

module vertex_projector ( // i should output new coords x0,y0 ... to x2,y2 based off depth

// output 4 points, x,y,z,w
    input clk,
    input rst,
    input start,

    // input 3d points(transformed)
    input signed [15:0] x0, y0, z0,
    input signed [15:0] x1, y1, z1,
    input signed [15:0] x2, y2, z2,

    //output projected points
    output reg signed [15:0] x0_out, x1_out, x2_out,
    output reg signed [15:0] y0_out, y1_out, y2_out,

    // calculated depth?
    output reg signed [15:0] z0_out, z1_out, z2_out, // z


    output reg is_done
    // fixed point check later

   

    //output reg valid // marks if the triangle is loaded and ready to be used

);
    parameter [15:0] n = 10 * 256;
    parameter [15:0] r = 5 * 256;
    parameter [15:0] l = -5 * 256;
    parameter [15:0] t = 5 * 256; 
    parameter [15:0] b = -5 * 256;
    parameter [15:0] f = 4'd15 * 256; 

    parameter [15:0] a1 = (2 * n) / (r - l) * 256; // double check
    parameter [15:0] b2 = (2 * n) / (t - b) * 256; // double check
    parameter [15:0] c1 = -(r + l) / (r - l) * 256; // set these to be really nice numbers, otherwise manually simplify
    parameter [15:0] c2 = -(t + b) / (t - b) * 256;
    parameter [15:0] c3 = (f + n) / (f - n) * 256;
    parameter [15:0] c4 = 1 * 256; 
    parameter [15:0] d3 = (-2 * f * n) / (f - n); // fine maybe

    parameter IDLE = 3'b000;
    parameter LOAD_W0 = 3'b001;
    parameter LOAD_W1 = 3'b010;
    parameter LOAD_W2 = 3'b011;
    parameter COMPUTE = 3'b100;
    parameter DONE = 3'b101; 

    reg [3:0] state;
    reg [15:0] w0_out, w1_out, w2_out; // w
    reg [15:0] w0_out_recip, w1_out_recip, w2_out_recip; // w out
    
// camera space 
// perspective divide
// screen space
// remap to NDC(normailised device coords [-1,1] coord range)
// NDC space to raster space

// just use a matrix ig
    // how do i do synthsiable division
    // these are given in NDC space

    // w not actually outputted or smth, just directly calculate 

    // do not do this prob


    wire [15:0] w0_val, w1_val, w2_val;

    //reg [15:0] w0_addr, w1_addr, w2_addr;
    
    reg [15:0] w_addr; 
    //wire [15:0] w0_data, w1_data, w2_data;

    wire [15:0] w_data; 

    wire signed [15:0] x0_val, x1_val, x2_val;
    wire signed [15:0] y0_val, y1_val, y2_val;
    wire signed [15:0] z0_val, z1_val, z2_val;
    // bruh
    assign x0_val = x0 * a1 + z0 * c1; 
    assign y0_val = y0 * b2 * z0 * c2; 
    assign z0_val = z0 * c3 + d3; 
    assign w0_val = z0; 

    assign x1_val = x1 * a1 + z1 * c1; 
    assign y1_val = y1 * b2 * z1 * c2; 
    assign z1_val = z1 * c3 + d3; 
    assign w1_val = z1; 

    assign x2_val = x2 * a1 + z2 * c1; 
    assign y2_val = y2 * b2 * z2 * c2; 
    assign z2_val = z2 * c3 + d3; 
    assign w2_val = z2; 

    depth_rom depth_LUT(w_addr, clk, w_data); // takes 1 clock cycle
    // depth_rom depth_LUT(w1_addr, clk, w1_data); 
    // depth_rom depth_LUT(w2_addr, clk, w2_data); 

    always @ (*) begin 
        // fsm

        case (state) 
        LOAD_W0: begin 
            w_addr <= w0_val; 
        end
        LOAD_W1: begin
            w_addr <= w1_val; 
        end
        LOAD_W2: begin 
            w_addr <= w2_val; 
        end

        default: begin 
            w_addr <= 16'b0; 
        end
        endcase

    end

    // store intermediate products to ensure bit widths are correct
    wire signed [32:0] product_x0, product_x1, product_x2;
    wire signed [32:0] product_y0, product_y1, product_y2;
    wire signed [32:0] product_z0, product_z1, product_z2;

    assign product_x0 = (x0_val * $signed({1'b0, w0_out_recip}));
    assign product_x1 = (x1_val * $signed({1'b0, w1_out_recip}));
    assign product_x2 = (x2_val * $signed({1'b0, w2_out_recip}));
    assign product_y0 = (y0_val * $signed({1'b0, w0_out_recip}));
    assign product_y1 = (y1_val * $signed({1'b0, w1_out_recip}));
    assign product_y2 = (y2_val * $signed({1'b0, w2_out_recip}));
    assign product_z0 = (z0_val * $signed({1'b0, w0_out_recip}));
    assign product_z1 = (z1_val * $signed({1'b0, w1_out_recip}));
    assign product_z2 = (z2_val * $signed({1'b0, w2_out_recip}));

    always @ (posedge clk or posedge rst) begin
        if  (rst) begin
            is_done <= 0; 
            state <= IDLE; 
        end 
        else begin 
            case (state)
            IDLE: begin 
                is_done <= 0;
                if (start) begin 
                    state <= LOAD_W0;
                end
            end 

            LOAD_W0: begin
                w0_out_recip <= w_data;  
                state <= LOAD_W1;
            end

            LOAD_W1: begin 
                w1_out_recip <= w_data;
                state <= LOAD_W2; 
            end

            LOAD_W2: begin 
                w2_out_recip <= w_data;
                state <= COMPUTE; 

            end

            COMPUTE: begin
                x0_out <= product_x0 >> 13;
                x1_out <= product_x1 >> 13;
                x2_out <= product_x2 >> 13; 

                y0_out <= product_y0 >> 13;
                y1_out <= product_y1 >> 13;
                y2_out <= product_y2 >> 13; 

                z0_out <= product_z0 >> 13;
                z1_out <= product_z1 >> 13;
                z2_out <= product_z2 >> 13;
                state <= DONE; 

            end

            DONE: begin 
                is_done <= 1;
                state <= IDLE; // may be completely uneeded
            end   
            endcase
        end

    end

    


    // put in fsm


    // lookup table thing
    // divide by w to do division
    // need fsm 


    

endmodule
