// VGA signal names: https://www-ug.eecg.toronto.edu/msl/manuals/tutorial_DE1-SoC-v5.4.pdf

module decoder_7seg(x, h);
    input wire [3:0] x;
    output reg [6:0] h;

    always @(x) begin
        if (x == 4'b0000) h = 7'b0111111;
        else if (x == 4'b0001) h = 7'b0000110;
        else if (x == 4'b0010) h = 7'b1011011;
        else if (x == 4'b0011) h = 7'b1001111;
        else if (x == 4'b0100) h = 7'b1100110;
        else if (x == 4'b0101) h = 7'b1101101;
        else if (x == 4'b0110) h = 7'b1111101;
        else if (x == 4'b0111) h = 7'b0000111;
        else if (x == 4'b1000) h = 7'b1111111;
        else if (x == 4'b1001) h = 7'b1101111;
        else if (x == 4'b1010) h = 7'b1110111;
        else if (x == 4'b1011) h = 7'b1111100;
        else if (x == 4'b1100) h = 7'b0111001;
        else if (x == 4'b1101) h = 7'b1011110;
        else if (x == 4'b1110) h = 7'b1111001;
        else if (x == 4'b1111) h = 7'b1110001;
        else h = 7'b0000000;
    end

endmodule

module top(
    input CLOCK_50,
    // input rst,
    input [3:0] KEY,
    output [9:0] LEDR,
    output [6:0] HEX0,
    output [6:0] HEX2,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output VGA_CLK,
    output VGA_BLANK_N,
    output VGA_SYNC_N,
    inout wire  PS2_CLK_S, 
    inout wire PS2_DAT_S 
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

    // wire PS2_CLK_S, PS2_DAT_S;  // for internal stuff

    wire [11:0] rotate_sig;
    wire [11:0] light_rotate_sig;
    wire light_rotation_mode;
    wire signed [15:0] translate_sig;
    // was a bit confused so i just copied and pasted into here from render controller

    // synchronize the PS/2 signals with CLOCK_50
    // sync S3 (PS2_CLK, rst, clk, PS2_CLK_S);
    // sync S4 (PS2_DAT, rst, clk, PS2_DAT_S);
    wire [1:0] texture_index;
    wire [11:0] object_index;
    wire is_last_object;
    keyboard U3 (
        .clk(clk),
        .reset(rst),

        .PS2_CLK(PS2_CLK_S),
        .PS2_DAT(PS2_DAT_S), 
// ??
        .rotate(rotate_sig),
        .light_rotate(light_rotate_sig),
        .light_rotation_mode(light_rotation_mode),
        .translate(translate_sig),

        .texture_index(texture_index),
        .object_index(object_index),
        .is_last_object(is_last_object)

    );
    assign LEDR[1] = light_rotation_mode;

    // display some values on the 7seg
    wire [6:0] h0, h2;

    decoder_7seg hex0_decoder(.x({2'b00, texture_index}), .h(h0));
    decoder_7seg hex2_decoder(.x(object_index[3:0]), .h(h2));

    assign HEX0 = ~h0;
    assign HEX2 = ~h2;

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
        .rotate(rotate_sig),
        .light_rotate(light_rotate_sig),
        .translate(translate_sig),
        .texture_index(texture_index),
        .object_index(object_index),

        .write_x(raster_x),
        .write_y(raster_y),
        .write_color(raster_color),
        .write_enable(raster_write),
        
        .clear(clear),
        .clear_addr(clear_addr),
        .is_last_object(is_last_object)
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
