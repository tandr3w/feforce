`timescale 1ns / 1ps

module testbench ();


    reg clk = 0;
	reg rst = 0;
    reg start = 0; 

    reg signed [1:0] translate;
    reg rotate;
    // 2 sets of coords
    reg signed [15:0] x0_in, y0_in, z0_in; 
    reg signed [15:0] x1_in, y1_in, z1_in; 
    reg signed [15:0] x2_in, y2_in, z2_in; 
    reg signed [15:0] nx_in, ny_in, nz_in; 

    wire signed [15:0] x0_out, y0_out, z0_out;  
    wire signed [15:0] x1_out, y1_out, z1_out;  
    wire signed [15:0] x2_out, y2_out, z2_out;  
    wire signed [15:0] nx_out, ny_out, nz_out; 

    wire is_done; 


    initial begin 
        #20;
        rst <= 1;
        rotate <= 0;
        translate <= 2'b0;

        #30;
        rst <= 0;
        rotate <= 1; 

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

        // load normal vector(for purposes of the test make it just a vertex d2)

        nx_in <= 16'hFFA2; 
        ny_in <= 16'h0079;
        nz_in <= 16'h0DA0;

        

        #50; 
        start <= 1'b1;
        #50; 
        start <= 1'b0;

        #90;
        rotate <= 0; 

        #100; 
        // do another test(translation)
        translate <= 2'b01;



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

        //normal again

        nx_in <= 16'h015E; 
        ny_in <= 16'hFEEF;
        nz_in <= 16'h0C00;

        #130;
        start <= 1; 
        #130
        start <= 0; 

        #200;
        translate <= 2'b00;


    end


    always #10
        clk <= ~clk;

    vertex_transformer U7 (
        .clk(clk),
        .start(start),
        .rst(rst),
        .rotate(rotate),
        .translate(translate),

        .x0(x0_in),
        .y0(y0_in),
        .z0(z0_in),

        .x1(x1_in),
        .y1(y1_in),
        .z1(z1_in),

        .x2(x2_in),
        .y2(y2_in),
        .z2(z2_in),

        .nx(nx_in),
        .ny(ny_in),
        .nz(nz_in),

        .x0_out(x0_out),
        .x1_out(x1_out),
        .x2_out(x2_out),

        .y0_out(y0_out),
        .y1_out(y1_out),
        .y2_out(y2_out),

        .z0_out(z0_out),
        .z1_out(z1_out),
        .z2_out(z2_out),

        .nx_out(nx_out),
        .ny_out(ny_out),
        .nz_out(nz_out),

        .is_done(is_done)
    );
endmodule