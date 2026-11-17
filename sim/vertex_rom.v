// Example memory for a cube for DESim testing
module vertex_rom (
    input [7:0] address,
    input clock,
    output reg [47:0] q
);

    always @(posedge clock) begin
        case (address)
            // 8'd0: q <= 48'hFF00_FF00_FF00; // (-1, -1, -1)
            // 8'd1: q <= 48'h0100_FF00_FF00; // ( 1, -1, -1)
            // 8'd2: q <= 48'h0100_0100_FF00; // ( 1,  1, -1)
            // 8'd3: q <= 48'hFF00_0100_FF00; // (-1,  1, -1)
            // 8'd4: q <= 48'hFF00_FF00_0100; // (-1, -1,  1)
            // 8'd5: q <= 48'h0100_FF00_0100; // ( 1, -1,  1)
            // 8'd6: q <= 48'h0100_0100_0100; // ( 1,  1,  1)
            // 8'd7: q <= 48'hFF00_0100_0100; // (-1,  1,  1)
            8'd0: q <= 48'hFEA2_FF2F_0B50;
            8'd1: q <= 48'hFFA2_FE98_0CF1;
            8'd2: q <= 48'hFFA2_0079_0DA0;
            8'd3: q <= 48'hFEA2_0111_0C00;
            8'd4: q <= 48'h005E_FF87_0A60;
            8'd5: q <= 48'h015E_FEEF_0C00;
            8'd6: q <= 48'h015E_00D1_0CB0;
            8'd7: q <= 48'h005E_0168_0B0F;
            default: q <= 48'd0;
        endcase
    end

endmodule