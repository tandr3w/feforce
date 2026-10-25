// inspired by https://projectf.io/posts/framebuffers/ and https://www-ug.eecg.toronto.edu/msl/manuals/tutorial_DE1-SoC-v5.4.pdf

module framebuffer (
    input wire clk_write,
    input wire clk_read,

    input wire [8:0] write_x,
    input wire [7:0] write_y,
    input wire [15:0] write_color,
    input wire write_enable,

    input wire [9:0] read_x,
    input wire [9:0] read_y,
    output wire [15:0] read_color
);

    wire [16:0] write_address;

    assign write_address = write_y * 17'd320 + write_x;

    wire [8:0] fb_x;
    wire [8:0] fb_y;

    // downsample the read coordinates from 640x480 to 320x240
    assign fb_x = read_x >> 1;
    assign fb_y = read_y >> 1;

    wire [16:0] read_address;

    // If out of bounds, read from address 0 (black pixel)
    assign read_address = (read_x < 640 && read_y < 480) ? fb_y * 17'd320 + fb_x : 17'd0;

    framebuffer_ram memory (
        .rdclock   (clk_read),
        .wrclock   (clk_write),
        .data      (write_color),
        .wraddress (write_address),
        .wren      (write_enable),
        .rdaddress (read_address),
        .q         (read_color)
    );

endmodule