`timescale 1ns / 1ps

module testbench ( );

	reg clk = 0;
	reg [3:0] KEY = 0;
    wire [7:0] VGA_R;
    wire [7:0] VGA_G;
    wire [7:0] VGA_B;
    wire       VGA_HS;
    wire       VGA_VS;
    wire       VGA_CLK;
    wire       VGA_BLANK_N;
    wire       VGA_SYNC_N;

	initial begin
		#20;
		KEY[0] <= 0;
		#100;
		KEY[0] <= 1;
        #17000000;
        $stop;
	end // initial
	
    always #10
        clk <= ~clk;

    top U1 (
        .clk(clk),
		.KEY(KEY),
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
