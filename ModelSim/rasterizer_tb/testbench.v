`timescale 1ns / 1ps

module testbench ( );

	reg clk = 0;

    wire [8:0] write_x;
    wire [7:0] write_y;
    wire [15:0] write_color;
    wire write_enable;
    wire done;
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


    rasterizer DUT (
        .clk(clk),
        .rst(rst),
        .color0_in(16'hF800),
        .color1_in(16'hF800),
        .color2_in(16'hF800),

        .x0_in(9'h16),
        .y0_in(8'h16),

        .x1_in(9'h16),
        .y1_in(8'h20),

        .x2_in(9'h20),
        .y2_in(8'h20),

        .start(1'b1), // signal to tell the rasterizer to start rasterizing the current triangle

        .write_x(write_x),
        .write_y(write_y),
        .write_color(write_color),
        .write_enable(write_enable), // should we actually write to this pixel?
        .done(done) // signal to tell the render controller that we are done rasterizing this triangle
    );

endmodule
