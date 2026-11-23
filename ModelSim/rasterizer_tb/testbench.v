`timescale 1ns / 1ps

module testbench ( );

	reg clk = 0;

    wire [8:0] write_x;
    wire [7:0] write_y;
    wire [15:0] write_color;
    wire write_enable;
    wire done;
    reg rst;
    reg start;

	initial begin
		start <= 0;
		#20;
		rst <= 1;
		#40;
		rst <= 0;
        #20;
        start <= 1;
        #20;
        start <= 0;
        #17000000;
        $stop;
	end // initial
	
    always #10
        clk <= ~clk;


    rasterizer DUT (
        .clk(clk),
        .rst(rst),

        .normal_x_in(16'd16384),
        .normal_y_in(16'd0),
        .normal_z_in(16'd0),

        .u0_in(6'd0),
        .v0_in(6'd0),
        .u1_in(6'd63),
        .v1_in(6'd63),
        .u2_in(6'd0),
        .v2_in(6'd63),

        .x0_in(9'h16),
        .y0_in(8'h16),

        .x1_in(9'h20),
        .y1_in(8'h20),

        .x2_in(9'h16),
        .y2_in(8'h20),

        .depth_recip0(16'd700),
        .depth_recip1(16'd700),
        .depth_recip2(16'd700),

        .start(start),

        .clear(1'b0),
        .clear_addr(17'd0),

        .write_x(write_x),
        .write_y(write_y),
        .write_color(write_color),
        .write_enable(write_enable),
        .done(done)
    );

endmodule