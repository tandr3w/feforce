`timescale 1ns / 1ps

module testbench ( );

	reg clk = 0;
	reg rst = 0;
    reg start; 
    // 2 sets of coords
    reg signed [15:0] x_in, y_in, z_in; 

    //this is what we are concerned about
    wire signed [15:0] x_out, y_out, z_out;  


    // wire [7:0] VGA_R;
    // wire [7:0] VGA_G;
    // wire [7:0] VGA_B;
    // wire       VGA_HS;
    // wire       VGA_VS;
    // wire       VGA_CLK;
    // wire       VGA_BLANK_N;
    // wire       VGA_SYNC_N;

	initial begin
		#20;
		rst <= 1;

		#100;
		rst <= 0;

        // values copied from rom 
        x_in <= 16'hFEA2; 
        y_in <= 16'hFF2F;
        z_in <= 16'h0B50;
        start <= 0; 
        #9000000;
        x_in <= 16'hFFA2; 
        y_in <= 16'hFE98;
        z_in <= 16'h0CF1;
        start <= 1; 

        #17000000;
        $stop;
	end // initial
	
    always #10
        clk <= ~clk;

    top U1 (
        .clk(clk),
		.rst(rst),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_CLK(VGA_CLK),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N)
    );

endmodule
