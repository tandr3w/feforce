`timescale 1ns / 1ps
// uhhh how do you testbench a keyboard
module testbench ();


    reg clk = 0;
	reg rst = 0;

    wire ps2_clk;
    wire ps2_dat;
    

    wire signed [1:0] translate;
    wire rotate;


    //erm 
    reg key_action = 0;
    reg [7:0] scan_code = 0;
    // 2 sets of coords

    // wire is_done; 


    initial begin 
        #20;
        rst <= 0; 
        key_action <= 1'b0; 
        scan_code <= 8'h00;

        #20 key_action <= 1'b1; scan_code = 8'h1C;      // PS/2 keyboard a key
        #20 key_action <= 1'b0;
		#80 key_action <= 1'b1; scan_code = 8'hF0;      // PS/2 keyboard release
        #20 key_action <= 1'b0;
		#80 key_action <= 1'b1; scan_code = 8'h1C;      // PS/2 keyboard a key
		#20 key_action <= 1'b0;


        
    end


    always #10
        clk <= ~clk;

    PS2_keyboard U7 (clk, rst, key_action, scan_code, ps2_clk, ps2_dat, rotate, translate);
endmodule