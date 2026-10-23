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

    // ------ Test code, will remove later -------
    wire [15:0] fb_colour;
    reg [8:0] fill_x;
    reg [7:0] fill_y;
    reg fill_done;

    // fill the screen with red pixels
    always @(posedge pixel_clk or posedge rst) begin
        if (rst) begin
            fill_x <= 0;
            fill_y <= 0;
            fill_done <= 0;
        end else if (!fill_done) begin
            if (fill_x == 319) begin
                fill_x <= 0;

                if (fill_y == 239)
                    fill_done <= 1;
                else
                    fill_y <= fill_y + 1;
            end else begin
                fill_x <= fill_x + 1;
            end
        end
    end

    framebuffer fb (
        .clk(pixel_clk),

        // Parameters to write to framebuffer
        .write_x(fill_x),
        .write_y(fill_y),
        .write_colour(16'hF800),
        .write_enable(!fill_done),

        // Parameters to read from framebuffer
        .read_x(sx),
        .read_y(sy),
        .read_colour(fb_colour)
    );
    // -------------

    assign VGA_CLK = pixel_clk;
    assign VGA_BLANK_N = de_d;
    assign VGA_SYNC_N = 1'b0;
    assign VGA_HS = hsync_d;
    assign VGA_VS = vsync_d;
    assign VGA_R = de_d ? {fb_colour[15:11], fb_colour[15:13]} : 8'h00;
    assign VGA_G = de_d ? {fb_colour[10:5], fb_colour[10:9]} : 8'h00;
    assign VGA_B = de_d ? {fb_colour[4:0], fb_colour[4:2]} : 8'h00;

endmodule