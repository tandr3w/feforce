// inspired by https://projectf.io/posts/framebuffers/ and https://www-ug.eecg.toronto.edu/msl/manuals/tutorial_DE1-SoC-v5.4.pdf

module framebuffer (
    input clk_write,
    input clk_read,

    input [8:0] write_x,
    input [7:0] write_y,
    input [15:0] write_color,
    input write_enable,
    input clear,
    input [16:0] clear_addr,

    input [9:0] read_x,
    input [9:0] read_y,
    output [15:0] read_color
);
    parameter [15:0] BGCOLOR = 16'h0000; // black

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
        .data      (clear ? BGCOLOR : write_color),
        .wraddress (clear ? clear_addr : write_address),
        .wren      (clear | write_enable),
        .rdaddress (read_address),
        .q         (read_color)
    );

endmodule