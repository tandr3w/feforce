module render_controller (
    input wire clk,
    input wire rst,

    output [8:0] write_x,
    output [7:0] write_y,
    output [15:0] write_color,
    output write_enable
);
    parameter NUM_TRIANGLES = 12;

    parameter IDLE = 2'b00;
    parameter LOAD = 2'b01;
    parameter RASTER = 2'b10;
    parameter DONE   = 2'b11;

    reg [1:0] state;

    reg [7:0] curr_triangle;

    wire signed [15:0] x0, y0, z0, x1, y1, z1, x2, y2, z2;
    wire [15:0] color;
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
        .color(color),

        .valid(loader_valid)
    );

    wire [8:0] projected_x0, projected_x1, projected_x2;
    wire [7:0] projected_y0, projected_y1, projected_y2;

    // placeholder for now: remove z coordinate and center on screen
    assign projected_x0 = (x0 >> 2) + 160;
    assign projected_y0 = (y0 >> 2) + 120;
    assign projected_x1 = (x1 >> 2) + 160;
    assign projected_y1 = (y1 >> 2) + 120;
    assign projected_x2 = (x2 >> 2) + 160;
    assign projected_y2 = (y2 >> 2) + 120;

    rasterizer raster (
        .clk(clk),
        .rst(rst),
        .color_in(color),

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