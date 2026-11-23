`timescale 1ns / 1ps

module testbench ();

	reg clk = 0;
	reg rst = 0;
    reg start = 0; 
    // 2 sets of coords
    reg signed [15:0] x0_in, y0_in, z0_in; 
    reg signed [15:0] x1_in, y1_in, z1_in; 
    reg signed [15:0] x2_in, y2_in, z2_in; 

    
    wire signed [15:0] x0_out, y0_out, z0_out;  
    wire signed [15:0] x1_out, y1_out, z1_out;  
    wire signed [15:0] x2_out, y2_out, z2_out;  

    wire is_done; 


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

        #30;
        rst <= 0;

		#40;
		//rst <= 0;
        // values copied from rom 

        // load a triangle
        // d0
        x0_in <= 16'hFEA2; 
        y0_in <= 16'hFF2F;
        z0_in <= 16'h0B50;
        // d1
        x1_in <= 16'hFFA2; 
        y1_in <= 16'hFE98;
        z1_in <= 16'h0CF1;

        // d2 
        x2_in <= 16'hFFA2; 
        y2_in <= 16'h0079;
        z2_in <= 16'h0DA0;


        #70
        start <= 1; 
        #70
        start <= 0;

        #100; // wait for loading

        //d3
        x0_in <= 16'hFEA2; 
        y0_in <= 16'h0111;
        z0_in <= 16'h0C00;

        //d4 

        x1_in <= 16'h005E; 
        y1_in <= 16'hFF87;
        z1_in <= 16'h0A60;

        //d5

        x1_in <= 16'h015E; 
        y1_in <= 16'hFEEF;
        z1_in <= 16'h0C00;

        #130;
        start <= 1; 
        #130
        start <= 0; 

        // #140;
        // start <= 0; 
    
        
	end // initial
	
    always #10
        clk <= ~clk;

    vertex_projector U6(
        .clk(clk),
        .start(start),
        .rst(rst),

        .x0(x0_in),
        .y0(y0_in),
        .z0(z0_in),

        .x1(x1_in),
        .y1(y1_in),
        .z1(z1_in),

        .x2(x2_in),
        .y2(y2_in),
        .z2(z2_in),


        .x0_out(x0_out),
        .x1_out(x1_out),
        .x2_out(x2_out),

        .y0_out(y0_out),
        .y1_out(y1_out),
        .y2_out(y2_out),

        .z0_out(z0_out),
        .z1_out(z1_out),
        .z2_out(z2_out),
        .is_done(is_done)

    );

endmodule
