// Example memory for a cube for DESim testing

module triangle_rom (
    input [11:0] address,
    input clock,
    output reg [119:0] q
);

    reg [119:0] memory [0:4095];
    initial begin
        $readmemh("triangles.hex", memory);
    end
    always @(posedge clock) begin
        q <= memory[address];
    end

endmodule