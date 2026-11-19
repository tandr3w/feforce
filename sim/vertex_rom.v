// Example memory for a cube for DESim testing
module vertex_rom (
    input [7:0] address,
    input clock,
    output reg [47:0] q
);
    reg [47:0] memory [0:4095];
    initial begin
        $readmemh("vertices.hex", memory);
    end
    always @(posedge clock) begin
        q <= memory[address];
    end

endmodule