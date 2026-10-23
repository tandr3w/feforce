// VGA signal names: https://www-ug.eecg.toronto.edu/msl/manuals/tutorial_DE1-SoC-v5.4.pdf

module top(
    input clk,
    input rst,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output       VGA_HS,
    output       VGA_VS,
    output       VGA_CLK,
    output       VGA_BLANK_N,
    output       VGA_SYNC_N
);
    wire [9:0] sx, sy;
    wire pixel_clk;
    wire de;

    pixel_clock U1(
        .clk(clk),
        .rst(rst),
        .pixel_clk(pixel_clk)
    );

    assign VGA_CLK = pixel_clk;
    assign VGA_BLANK_N = de;

    display U2(
        .clk_pix(pixel_clk),
        .rst_pix(rst),
        .sx(sx),
        .sy(sy),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .de(de)
    );


    reg [7:0] paint_r, paint_g, paint_b;
    reg [7:0] display_r, display_g, display_b;
    reg square;

    always @(*) begin
        square = (sx > 220 && sx < 420) && (sy > 140 && sy < 340);
        paint_r = square ? 8'hFF : 8'h00;
        paint_g = square ? 8'h00 : 8'h00;
        paint_b = square ? 8'h00 : 8'h00;
        
        // display colour: paint colour but black in blanking interval
        display_r = (de) ? paint_r : 4'h00;
        display_g = (de) ? paint_g : 4'h00;
        display_b = (de) ? paint_b : 4'h00;
    end

    assign VGA_R = display_r;
    assign VGA_G = display_g;
    assign VGA_B = display_b;

endmodule