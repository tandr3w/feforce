// VGA signal names: https://www-ug.eecg.toronto.edu/msl/manuals/tutorial_DE1-SoC-v5.4.pdf

module top(
    input CLOCK_50,
    // input rst,
    input [3:0] KEY,
    output [9:0] LEDR,
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

    wire rst;
    wire clk;
    assign clk = CLOCK_50;

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

    wire PS2_CLK_S, PS2_DAT_S;  // for internal stuff
    // was a bit confused so i just copied and pasted into here from render controller
    keyboard U3 (
        .clk(clk),
        .rst(rst),

        .PS2_CLK(PS2_CLK_S),
        .PS2_DAT(PS2_DAT_S), 
// ??
        .rotate(rotate_sig),
        .translate(translate_sig)  

    );

    assign rst = ~KEY[0];
    assign LEDR[0] = rst;
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

    wire [8:0] raster_x;
    wire [7:0] raster_y;
    wire [15:0] raster_color;
    wire raster_write;
    wire clear;
    wire [16:0] clear_addr;

    render_controller rc (
        .clk(clk),
        .rst(rst),

        .write_x(raster_x),
        .write_y(raster_y),
        .write_color(raster_color),
        .write_enable(raster_write),
        
        .clear(clear),
        .clear_addr(clear_addr)
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

        .clear(clear),
        .clear_addr(clear_addr),

        // Parameters to read from framebuffer
        .read_x(sx),
        .read_y(sy),
        .read_color(fb_color)
    );

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