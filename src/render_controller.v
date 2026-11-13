module render_controller (
    input wire clk,
    input wire rst,

    output [8:0] write_x,
    output [7:0] write_y,
    output [15:0] write_color,
    output write_enable
);
    parameter IDLE = 3'b000;
    parameter LOAD = 3'b001;
    parameter TRANSFORM = 3'b010;
    parameter RASTER = 3'b011;
    parameter DONE   = 3'b100;

    reg [1:0] state;

    reg [7:0] curr_triangle;

    wire signed [15:0] x0, y0, z0, x1, y1, z1, x2, y2, z2;
    wire [15:0] color0, color1, color2;
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
        .color0(color0), .color1(color1), .color2(color2),

        .valid(loader_valid)
    );

    wire signed [15:0] x0_out, x1_out, x2_out;
    wire signed [15:0] y0_out, y1_out, y2_out;
    wire signed [15:0] z0_out, z1_out, z2_out;
    wire projector_done;
    reg projector_start;

    vertex_projector projector(
        .clk(clk),
        .rst(rst),
        .start(projector_start),

        .x0(x0), .y0(y0), .z0(z0),
        .x1(x1), .y1(y1), .z1(z1),
        .x2(x2), .y2(y2), .z2(z2),

        .x0_out(x0_out), .x1_out(x1_out), .x2_out(x2_out),
        .y0_out(y0_out), .y1_out(y1_out), .y2_out(y2_out),

        .z0_out(z0_out), .z1_out(z1_out), .z2_out(z2_out),
        .is_done(projector_done)
    );

    wire signed [23:0] proj_product_x0, proj_product_x1, proj_product_x2;
    wire signed [22:0] proj_product_y0, proj_product_y1, proj_product_y2;

    wire [8:0] projected_x0, projected_x1, projected_x2;
    wire [7:0] projected_y0, projected_y1, projected_y2;

    assign proj_product_x0 = (160 * x0_out);
    assign proj_product_x1 = (120 * y0_out);
    assign proj_product_x2 = (160 * x1_out);
    assign proj_product_y0 = (120 * y1_out);
    assign proj_product_y1 = (160 * x2_out);
    assign proj_product_y2 = (120 * y2_out);

    // assign projected_x0 = proj_product_x0 >> 8 + 160;
    // assign projected_y0 = proj_product_x0 >> 8 + 120;
    // assign projected_x1 = proj_product_x0 >> 8 + 160;
    // assign projected_y1 = proj_product_x0 >> 8 + 120;
    // assign projected_x2 = proj_product_x0 >> 8 + 160;
    // assign projected_y2 = proj_product_x0 >> 8 + 120;

    // assign projected_x0 = (x0 >> 2) + 160;
    // assign projected_y0 = (y0 >> 2) + 120;
    // assign projected_x1 = (x1 >> 2) + 160;
    // assign projected_y1 = (y1 >> 2) + 120;
    // assign projected_x2 = (x2 >> 2) + 160;
    // assign projected_y2 = (y2 >> 2) + 120;

    rasterizer raster (
        .clk(clk),
        .rst(rst),
        .color0_in(color0),
        .color1_in(color1),
        .color2_in(color2),

        .x0_in(projected_x0),
        .y0_in(projected_y0),

        .x1_in(projected_x1),
        .y1_in(projected_y1),

        .x2_in(projected_x2),
        .y2_in(projected_y2),

        .start(raster_start),
        .done(raster_done),

        .write_x(write_x),
        .write_y(write_y),
        .write_color(write_color),
        .write_enable(write_enable)
    );



    always @(posedge clk or posedge rst) begin
        if (rst) begin
            curr_triangle <= 0;
            raster_start <= 0;
            loader_start <= 0;
            state <= IDLE;
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
                    if (loader_valid) begin
                        state <= TRANSFORM;
                        projector_start <= 1;
                    end
                end
                TRANSFORM: begin
                    projector_start <= 0;
                    if (projector_done) begin
                        state <= RASTER;
                        raster_start <= 1;
                    end
                end
                RASTER: begin
                    raster_start <= 0;
                    if (raster_done) begin
                        if (!is_final) begin
                            curr_triangle <= curr_triangle + 1; // start loading the next triangle
                            loader_start <= 1;
                            state <= LOAD; // Load next triangle
                        end else begin
                            state <= DONE; // Finish
                        end
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