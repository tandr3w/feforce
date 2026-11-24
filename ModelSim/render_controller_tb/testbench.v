`timescale 1ns / 1ps

module testbench ( );

	reg clk = 0;

    wire [8:0] write_x;
    wire [7:0] write_y;
    wire [15:0] write_color;
    wire write_enable;
    reg rst;

	initial begin
		#20;
		rst <= 1;
		#40;
		rst <= 0;

        // Let the render controller process triangles
        #1000000;
        $stop;
	end // initial
	
    always #10
        clk <= ~clk;


    render_controller DUT (
        .clk(clk),
        .rst(rst),

        .write_x(write_x),
        .write_y(write_y),
        .write_color(write_color),
        .write_enable(write_enable),
        .rotate(1'b0),
        .translate(2'b00)
    );

endmodule