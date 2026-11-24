module render_controller (
    input wire clk,
    input wire rst,

    output [8:0] write_x,
    output [7:0] write_y,
    output [15:0] write_color,
    output write_enable,

    output clear,
    output reg [16:0] clear_addr
);
    parameter IDLE = 3'b000;
    parameter LOAD = 3'b001;
    parameter TRANSFORM = 3'b010;
    parameter PROJECT = 3'b111; // out of order cuz why not
    parameter RASTER = 3'b011;
    parameter CLEAR = 3'b100; 
    parameter DONE = 3'b101;

    reg [2:0] state;

    reg [11:0] curr_triangle;

    wire signed [15:0] x0, y0, z0, x1, y1, z1, x2, y2, z2;
    wire [5:0] u0, u1, u2, v0, v1, v2;
    wire [15:0] normal_x, normal_y, normal_z;
    wire loader_valid, raster_done;
    reg loader_start, raster_start;
    wire is_final; // are we at the last triangle?

    triangle_loader loader (
        .clk(clk),
        .rst(rst),
        .start(loader_start),
        .triangle_number(curr_triangle),
        .is_final(is_final),

        .x0(x0), .y0(y0), .z0(z0),
        .x1(x1), .y1(y1), .z1(z1),
        .x2(x2), .y2(y2), .z2(z2),

        .normal_x(normal_x), .normal_y(normal_y), .normal_z(normal_z),
        .u0(u0), .u1(u1), .u2(u2),
        .v0(v0), .v1(v1), .v2(v2),

        .valid(loader_valid)
    );

    wire signed [15:0] x0_out, x1_out, x2_out;
    wire signed [15:0] y0_out, y1_out, y2_out;
    wire [15:0] w_recip_0, w_recip_1, w_recip_2; // stores depth of the vertex
    wire projector_done;
    reg projector_start;

    reg transformer_start; 
    wire transformer_done; 

    wire rotate_sig; 
    wire signed [1:0] translate_sig;


    wire signed [15:0] x0_transformed, x1_transformed, x2_transformed; 
    wire signed [15:0] y0_transformed, y1_transformed, y2_transformed;
    wire signed [15:0] z0_transformed, z1_transformed, z2_transformed;
    wire signed [15:0] nx_transformed, ny_transformed, nz_transformed;


    // keyboard wires



    // the transformed stuff goes in the projector now

    vertex_projector projector(
        .clk(clk),
        .rst(rst),
        .start(projector_start),

        // now we accept the transformed stuff

        // .x0(x0), .y0(y0), .z0(z0),
        // .x1(x1), .y1(y1), .z1(z1),
        // .x2(x2), .y2(y2), .z2(z2),


        .x0(x0_transformed), .y0(y0_transformed), .z0(z0_transformed),
        .x1(x1_transformed), .y1(y1_transformed), .z1(z1_transformed),
        .x2(x2_transformed), .y2(y2_transformed), .z2(z2_transformed),

        .x0_out(x0_out), .x1_out(x1_out), .x2_out(x2_out),
        .y0_out(y0_out), .y1_out(y1_out), .y2_out(y2_out),

        .w0_out_recip(w_recip_0), .w1_out_recip(w_recip_1), .w2_out_recip(w_recip_2),
        .is_done(projector_done)
    );


    vertex_transformer transformer(
        .clk(clk),
        .rst(rst),
        .start(transformer_start),

        .translate(translate_sig),
        .rotate(rotate_sig),

        .x0(x0), .y0(y0), .z0(z0),
        .x1(x1), .y1(y1), .z1(z1),
        .x2(x2), .y2(y2), .z2(z2),

        .nx(normal_x), .ny(normal_y), .nz(normal_z), 

        .x0_out(x0_transformed), .x1_out(x1_transformed), .x2_out(x2_transformed),
        .y0_out(y0_transformed), .y1_out(y1_transformed), .y2_out(y2_transformed),
        .z0_out(z0_transformed), .z1_out(z1_transformed), .z2_out(z2_transformed),

        .nx_out(nx_transformed), .ny_out(ny_transformed), .nz_out(nz_transformed),

        .is_done(transformer_done)

    );  



    wire PS2_CLK_S, PS2_DAT_S;  // for internal stuff



    keyboard da_big_fugging_gg_ez_keybord (
        .clk(clk),
        .reset(rst),

        .PS2_CLK(PS2_CLK_S),
        .PS2_DAT(PS2_DAT_S), 

        .rotate(rotate_sig),
        .translate(translate_sig)  
    );  


    // sync S3 (PS2_CLK, Resetn, clk, PS2_CLK_S);
    // sync S4 (PS2_DAT, Resetn, clk, PS2_DAT_S);

    wire signed [23:0] proj_product_x0, proj_product_x1, proj_product_x2;
    wire signed [22:0] proj_product_y0, proj_product_y1, proj_product_y2;

    wire [8:0] projected_x0, projected_x1, projected_x2;
    wire [7:0] projected_y0, projected_y1, projected_y2;

    assign proj_product_x0 = (160 * x0_out);
    assign proj_product_x1 = (160 * x1_out);
    assign proj_product_x2 = (160 * x2_out);
    assign proj_product_y0 = (120 * y0_out);
    assign proj_product_y1 = (120 * y1_out);
    assign proj_product_y2 = (120 * y2_out);

    // note that y is inverted because the VGA coordinate system has y increasing downwards
    assign projected_x0 = (proj_product_x0 >> 8) + 160;
    assign projected_x1 = (proj_product_x1 >> 8) + 160;
    assign projected_x2 = (proj_product_x2 >> 8) + 160;
    assign projected_y0 = 120 - (proj_product_y0 >> 8);
    assign projected_y1 = 120 - (proj_product_y1 >> 8);
    assign projected_y2 = 120 - (proj_product_y2 >> 8);

    assign clear = (state == CLEAR);

    rasterizer raster (
        .clk(clk),
        .rst(rst),

        // .normal_x_in(normal_x), .normal_y_in(normal_y), .normal_z_in(normal_z),
        .normal_x_in(nx_transformed), .normal_y_in(ny_transformed), .normal_z_in(nz_transformed),
        .u0_in(u0), .u1_in(u1), .u2_in(u2),
        .v0_in(v0), .v1_in(v1), .v2_in(v2),

        .x0_in(projected_x0),
        .y0_in(projected_y0),

        .x1_in(projected_x1),
        .y1_in(projected_y1),

        .x2_in(projected_x2),
        .y2_in(projected_y2),

        .depth_recip0(w_recip_0),
        .depth_recip1(w_recip_1),
        .depth_recip2(w_recip_2),

        .start(raster_start),
        .done(raster_done),

        .write_x(write_x),
        .write_y(write_y),
        .write_color(write_color),
        .write_enable(write_enable),

        .clear(clear),
        .clear_addr(clear_addr)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            curr_triangle <= 0;
            raster_start <= 0;
            loader_start <= 0;
            projector_start <= 0;
            clear_addr <= 0;
            state <= CLEAR;
        end else begin
            case (state)
                IDLE: begin
                    curr_triangle <= 0;
                    loader_start <= 1;
                    raster_start <= 0;
                    state <= LOAD;
                end
                LOAD: begin
                    loader_start <= 0;
                    if (is_final) begin
                        state <= DONE;
                    end 
                    else if (loader_valid) begin

                        // if (translate_sig != 2'b00) begin 
                        //     state <= TRANSFORM;
                        //     transformer_start <= 1; 

                        // end
                        // else begin 
                        //     state <= PROJECT;
                        //     projector_start <= 1; 
                        // end 

                        state <= TRANSFORM;
                        transformer_start <= 1; 
                        
                    end
                end
                TRANSFORM: begin 
                    transformer_start <= 0;
                    if (transformer_done) begin 
                        state <= CLEAR; // used to be project
                        projector_start <= 1; 
                    end
                end
                CLEAR: begin // clear screen after transform
                    if (clear_addr < 17'd76799) begin
                        clear_addr <= clear_addr + 1;
                    end 
                    if (transformer_done) begin // clear the screen(reset) then project new
                        clear_addr <= 0; 
                        state <= PROJECT;  
                    end
                    else begin
                        clear_addr <= 0;
                        state <= IDLE;
                    end
                end
                PROJECT: begin 
                    projector_start <= 0;
                    if (projector_done) begin
                        state <= RASTER;
                        raster_start <= 1;
                    end
                end
                RASTER: begin
                    raster_start <= 0;
                    if (raster_done) begin
                        curr_triangle <= curr_triangle + 1; // start loading the next triangle
                        loader_start <= 1;
                        state <= LOAD; // Load next triangle
                    end
                end
                DONE: begin
                    loader_start <= 0;
                    raster_start <= 0;
                end
            endcase
        end
    end

endmodule
