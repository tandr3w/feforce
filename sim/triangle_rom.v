// Example memory for a cube for DESim testing

module triangle_rom (
    input [7:0] address,
    input clock,
    output reg [71:0] q
);

    always @(posedge clock) begin
        case (address)
            8'd0:  q <= {16'hF800, 16'h07E0, 16'h001F, 8'd0, 8'd1, 8'd2};
            8'd1:  q <= {16'hF800, 16'h001F, 16'hFFE0, 8'd0, 8'd2, 8'd3};
            8'd2:  q <= {16'h07FF, 16'hFFFF, 16'hF81F, 8'd4, 8'd6, 8'd5};
            8'd3:  q <= {16'h07FF, 16'hFD20, 16'hFFFF, 8'd4, 8'd7, 8'd6};
            8'd4:  q <= {16'hF800, 16'hFFE0, 16'hFD20, 8'd0, 8'd3, 8'd7};
            8'd5:  q <= {16'hF800, 16'hFD20, 16'h07FF, 8'd0, 8'd7, 8'd4};
            8'd6:  q <= {16'h07E0, 16'hF81F, 16'hFFFF, 8'd1, 8'd5, 8'd6};
            8'd7:  q <= {16'h07E0, 16'hFFFF, 16'h001F, 8'd1, 8'd6, 8'd2};
            8'd8:  q <= {16'hF800, 16'h07FF, 16'hF81F, 8'd0, 8'd4, 8'd5};
            8'd9:  q <= {16'hF800, 16'hF81F, 16'h07E0, 8'd0, 8'd5, 8'd1};
            8'd10: q <= {16'hFFE0, 16'h001F, 16'hFFFF, 8'd3, 8'd2, 8'd6};
            8'd11: q <= {16'hFFE0, 16'hFFFF, 16'hFD20, 8'd3, 8'd6, 8'd7};
            default: q <= 72'd0;
        endcase
    end

endmodule