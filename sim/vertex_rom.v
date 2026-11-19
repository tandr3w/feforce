// Example memory for a cube for DESim testing
module vertex_rom (
    input [7:0] address,
    input clock,
    output reg [47:0] q
);

    always @(posedge clock) begin
        case (address)
            8'd0: q <= 48'h0000_FF00_FF00;
            8'd1: q <= 48'h0032_FF00_FF05;
            8'd2: q <= 48'h0062_FF00_FF13;
            8'd3: q <= 48'h008E_FF00_FF2B;
            8'd4: q <= 48'h00B5_FF00_FF4B;
            8'd5: q <= 48'h00D5_FF00_FF72;
            8'd6: q <= 48'h00ED_FF00_FF9E;
            8'd7: q <= 48'h00FB_FF00_FFCE;
            8'd8: q <= 48'h0100_FF00_0000;
            8'd9: q <= 48'h00FB_FF00_0032;
            8'd10: q <= 48'h00ED_FF00_0062;
            8'd11: q <= 48'h00D5_FF00_008E;
            8'd12: q <= 48'h00B5_FF00_00B5;
            8'd13: q <= 48'h008E_FF00_00D5;
            8'd14: q <= 48'h0062_FF00_00ED;
            8'd15: q <= 48'h0032_FF00_00FB;
            8'd16: q <= 48'h0000_FF00_0100;
            8'd17: q <= 48'hFFCE_FF00_00FB;
            8'd18: q <= 48'hFF9E_FF00_00ED;
            8'd19: q <= 48'hFF72_FF00_00D5;
            8'd20: q <= 48'hFF4B_FF00_00B5;
            8'd21: q <= 48'hFF2B_FF00_008E;
            8'd22: q <= 48'hFF13_FF00_0062;
            8'd23: q <= 48'hFF05_FF00_0032;
            8'd24: q <= 48'hFF00_FF00_0000;
            8'd25: q <= 48'hFF05_FF00_FFCE;
            8'd26: q <= 48'hFF13_FF00_FF9E;
            8'd27: q <= 48'hFF2B_FF00_FF72;
            8'd28: q <= 48'hFF4B_FF00_FF4B;
            8'd29: q <= 48'hFF72_FF00_FF2B;
            8'd30: q <= 48'hFF9E_FF00_FF13;
            8'd31: q <= 48'hFFCE_FF00_FF05;
            8'd32: q <= 48'h0000_0100_0000;
            default: q <= 48'd0;
        endcase
    end

endmodule