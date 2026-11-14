`timescale 1ns / 1ps

module testbench ( );

	reg clk = 0;

    wire pixel_clk;
    wire [9:0] sx, sy;
    wire de;
    wire hsync;
    wire vsync;

    reg rst;

	initial begin
		#20;
		rst <= 1;
		#40;
		rst <= 0;

        #17000000;
        $stop;
	end // initial
	
    always #10
        clk <= ~clk;


    pixel_clock U1 (
        .clk(clk),
        .rst(rst),
        .pixel_clk(pixel_clk)
    );

    display DUT (
        .clk_pix(pixel_clk),
        .rst_pix(rst),

        .sx(sx),
        .sy(sy),

        .hsync(hsync),
        .vsync(vsync),
        .de(de)
    );

endmodule