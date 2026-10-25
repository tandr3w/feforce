// VGA signal names: https://www-ug.eecg.toronto.edu/msl/manuals/tutorial_DE1-SoC-v5.4.pdf

module top(
    input clk,
    input rst,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output VGA_CLK,
    output VGA_BLANK_N,
    output VGA_SYNC_N
);
    wire [9:0] sx, sy;
    wire pixel_clk;
    wire de, hsync, vsync;

    pixel_clock U1(
        .clk(clk),
        .rst(rst),
        .pixel_clk(pixel_clk)
    );

    display U2(
        .clk_pix(pixel_clk),
        .rst_pix(rst),
        .sx(sx),
        .sy(sy),
        .hsync(hsync),
        .vsync(vsync),
        .de(de)
    );

    // Delay signals by 1 clock cycle since the RAM has 1 cycle read latency
    // so we have to delay all of the VGA cycles by 1 cycle as well
    reg hsync_d, vsync_d, de_d;
    always @(posedge pixel_clk or posedge rst) begin
        if (rst) begin
            hsync_d <= 1;
            vsync_d <= 1;
            de_d    <= 0;
        end else begin
            hsync_d <= hsync;
            vsync_d <= vsync;
            de_d    <= de;
        end
    end

    // ------ Code to draw to the framebuffer -------
    wire [8:0] raster_x;
    wire [7:0] raster_y;
    wire [15:0] raster_color;
    wire raster_write;
    wire raster_busy;

    // Pulse raster_start for 1 cycle after reset
    reg raster_start;

    always @(posedge pixel_clk or posedge rst) begin
        if (rst) begin
            raster_start <= 0;
        end else if (!raster_start) begin
            raster_start <= 1;
        end else begin
            raster_start <= 0;
        end
    end

    rasterizer raster (
        .clk(clk),
        .rst(rst),
        .color_in(16'h001F),

        .x0_in(9'd50),
        .y0_in(8'd40),

        .x1_in(9'd250),
        .y1_in(8'd70),

        .x2_in(9'd120),
        .y2_in(8'd200),

        .start(raster_start),

        .write_x(raster_x),
        .write_y(raster_y),
        .write_color(raster_color),
        .write_enable(raster_write),

        .busy(raster_busy)
    );

    wire [15:0] fb_color;
    framebuffer fb (
        .clk_write(clk),
        .clk_read(pixel_clk),

        // Parameters to write to framebuffer
        .write_x(raster_x),
        .write_y(raster_y),
        .write_color(raster_color),
        .write_enable(raster_write),

        // Parameters to read from framebuffer
        .read_x(sx),
        .read_y(sy),
        .read_color(fb_color)
    );
    // -------------

    assign VGA_CLK = pixel_clk;
    assign VGA_BLANK_N = de_d;
    assign VGA_SYNC_N = 1'b0;
    assign VGA_HS = hsync_d;
    assign VGA_VS = vsync_d;

    // Convert the 5 or 6 bit colors from the framebuffer to the 8 bit that the VGA wants.
    assign VGA_R = de_d ? {fb_color[15:11], fb_color[15:13]} : 8'h00;
    assign VGA_G = de_d ? {fb_color[10:5], fb_color[10:9]} : 8'h00;
    assign VGA_B = de_d ? {fb_color[4:0], fb_color[4:2]} : 8'h00;

endmodule