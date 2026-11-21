`timescale 1ns / 1ps

module testbench ( );
    reg clk = 0;
    reg rst;
    reg start;
    reg [11:0] triangle_number;

    wire signed [15:0] x0, y0, z0;
    wire signed [15:0] x1, y1, z1;
    wire signed [15:0] x2, y2, z2;

    wire signed [15:0] normal_x, normal_y, normal_z;
    wire [5:0] u0, u1, u2; // 0 to 63
    wire [5:0] v0, v1, v2;

    wire is_final;
    wire valid;

	initial begin
		#20;
		rst <= 1;
		#40;
		rst <= 0;

        // load triangle 0
        #20;
        triangle_number <= 8'd0;
        start <= 1;
        #20;
        start <= 0;

        // wait for triangle 0 to finish loading
        #160;

        // load triangle 1
        triangle_number <= 8'd1;
        start <= 1;
        #20;
        start <= 0;

        // wait for triangle 1 to finish loading
        #160;

        $stop;
	end // initial
	
    always #10
        clk <= ~clk;


    triangle_loader DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .triangle_number(triangle_number),

        .x0(x0),
        .y0(y0),
        .z0(z0),

        .x1(x1),
        .y1(y1),
        .z1(z1),

        .x2(x2),
        .y2(y2),
        .z2(z2),

        .normal_x(normal_x),
        .normal_y(normal_y),
        .normal_z(normal_z),
        .u0(u0), .u1(u1), .u2(u2),
        .v0(v0), .v1(v1), .v2(v2),

        .is_final(is_final),
        .valid(valid)
    );

endmodule