`timescale 1ns / 1ps
`default_nettype none

// This testbench is designed to hide the details of using the VPI code
// Modified version of DESim demos, "display"

module tb();

    reg CLOCK_50 = 0;               // DE-series 50 MHz clock
    reg [9:0] SW = 0;               // DE-series SW switches
    reg [3:0] KEY = 0;              // DE-series pushbutton keys
    wire [(8*6) -1:0] HEX;          // HEX displays (six ports)
    wire [9:0] LEDR;                // DE-series LEDs

    reg key_action = 0;
    reg [7:0] scan_code = 0;
    wire [2:0] ps2_lock_control;

    wire [9:0] VGA_X;               // "VGA" column
    wire [8:0] VGA_Y;               // "VGA" row
    wire [23:0] VGA_COLOR;          // "VGA pixel" colour
    wire plot;                       // "Pixel" is drawn when this is pulsed
    wire [31:0] GPIO;               // DE-series GPIO port

    // Real DE1-SoC VGA signals
    wire [7:0] VGA_R;
    wire [7:0] VGA_G;
    wire [7:0] VGA_B;
    wire VGA_HS;
    wire VGA_VS;
    wire VGA_CLK;
    wire VGA_BLANK_N;
    wire VGA_SYNC_N;

    initial $sim_fpga(CLOCK_50, SW, KEY, LEDR, HEX, key_action, scan_code, 
                      ps2_lock_control, VGA_X, VGA_Y, VGA_COLOR, plot, GPIO);

    wire [6:0] HEX0;                // DE-series HEX0 port
    wire [6:0] HEX1;                // DE-series HEX1 port
    wire [6:0] HEX2;                // ...
    wire [6:0] HEX3;
    wire [6:0] HEX4;
    wire [6:0] HEX5;

    // create the 50 MHz clock signal
    always #10
        CLOCK_50 <= ~CLOCK_50;

    reg rst = 0;
    initial begin
        #20;
        rst = 1;

        #100;
        rst = 0;
    end

    // connect the single HEX port on "sim_fpga" to the six DE-series HEX ports
    assign HEX[47:40] = {1'b0, HEX0};
    assign HEX[39:32] = {1'b0, HEX1};
    assign HEX[31:24] = {1'b0, HEX2};
    assign HEX[23:16] = {1'b0, HEX3};
    assign HEX[15: 8] = {1'b0, HEX4};
    assign HEX[ 7: 0] = {1'b0, HEX5};

    // convert real VGA signals to the DESim VGA interface
    reg [9:0] VGA_X_d;
    reg [8:0] VGA_Y_d;

    // delay by 1 cycle
    always @(posedge VGA_CLK) begin
        VGA_X_d <= DUT.sx;
        VGA_Y_d <= DUT.sy[8:0];
    end
    
    parameter downscale_factor = 2;
    parameter slice_size = downscale_factor == 0 ? 1 : downscale_factor - 1;

    assign VGA_X = VGA_X_d >> downscale_factor;
    assign VGA_Y = VGA_Y_d >> downscale_factor;

    assign VGA_COLOR = {VGA_R, VGA_G, VGA_B};

    // only draw one pixel from each block (top left corner)
    assign plot = downscale_factor == 0 ? VGA_BLANK_N : VGA_BLANK_N &&
        (VGA_X_d[slice_size:0] == {slice_size{1'b0}}) &&
        (VGA_Y_d[slice_size:0] == {slice_size{1'b0}});
    
    top DUT (
        .CLOCK_50(CLOCK_50),
        // .rst(rst),
        .KEY(KEY),
        .LEDR(LEDR),
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