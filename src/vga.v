// Parameter values and timing information are taken from https://projectf.io/posts/fpga-graphics/

module pixel_clock(
    input wire clk,
    input wire rst,
    output reg pixel_clk = 0
);
    // Generate a 25MHz clock from the 50MHz input.
    // each frame needs to draw 800*525 pixels, so at 60fps, 25.2 MHz clock is needed
    // but 50MHz is good enough and avoids needing a PLL
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pixel_clk <= 0;
        end else begin
            // Toggle every posedge, so will cycle once per 2 clock cycles
            pixel_clk <= ~pixel_clk;
        end
    end
endmodule

module display(
    input  clk_pix,   // pixel clock
    input  rst_pix,   // reset in pixel clock domain
    output reg [9:0] sx,  // current horizontal screen position
    output reg [9:0] sy,  // current vertical screen position
    output hsync,     // horizontal sync
    output vsync,     // vertical sync
    output de         // data enable (is it safe to draw?)
);
    // put all the blanking after the active pixels for simplicity
    // so active region is (0, 0) to (639, 479)
    // blanking region is (640, 480) to (799, 524)

    // horizontal timings
    parameter HA_END = 639;           // end of active pixels
    parameter HS_STA = HA_END + 17;   // sync starts after front porch
    parameter HS_END = HS_STA + 96;   // sync ends
    parameter LINE   = 799;           // last pixel on line (after back porch)

    // vertical timings
    parameter VA_END = 479;           // end of active pixels
    parameter VS_STA = VA_END + 11;   // sync starts after front porch
    parameter VS_END = VS_STA + 2;    // sync ends
    parameter SCREEN = 524;           // last line on screen (after back porch)
    
    assign hsync = ~((sx >= HS_STA) && (sx < HS_END)); // active low, so check if not in hs region
    assign vsync = ~((sy >= VS_STA) && (sy < VS_END)); // active low, so check if not in vs region
    assign de = (sx <= HA_END) && (sy <= VA_END); // 1 if position is in active region

    always @(posedge clk_pix or posedge rst_pix) begin
        if (rst_pix) begin
            sx <= 0;
            sy <= 0;
        end else if (sx == LINE) begin // Are we on the last horizontal pixel?
            sx <= 0;
            if (sy == SCREEN) begin // Are we on the last vertical line?
                sy <= 0;
            end else begin
                sy <= sy + 1; // Go to next line
            end
        end else begin
            sx <= sx + 1;
        end
    end
endmodule