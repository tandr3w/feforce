// Example memory for a cube for DESim testing
module vertex_rom (
    input [7:0] address,
    input clock,
    output reg [47:0] q
);

    always @(posedge clock) begin
        case (address)
            8'd0: q <= 48'hFF00_FF00_FF00; // (-1, -1, -1)
            8'd1: q <= 48'h0100_FF00_FF00; // ( 1, -1, -1)
            8'd2: q <= 48'h0100_0100_FF00; // ( 1,  1, -1)
            8'd3: q <= 48'hFF00_0100_FF00; // (-1,  1, -1)
            8'd4: q <= 48'hFF00_FF00_0100; // (-1, -1,  1)
            8'd5: q <= 48'h0100_FF00_0100; // ( 1, -1,  1)
            8'd6: q <= 48'h0100_0100_0100; // ( 1,  1,  1)
            8'd7: q <= 48'hFF00_0100_0100; // (-1,  1,  1)
            default: q <= 48'd0;
        endcase
    end

endmodule