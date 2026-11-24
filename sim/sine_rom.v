// Module to simulate texture ROM for DESim since it can't use the IP
module sine_rom (
    input [11:0] address,
    input clock,
    output reg [15:0] q
);
    reg [15:0] memory [0:4095];
    initial begin
        $readmemh("sine_table.hex", memory);
    end

    always @(posedge clock) begin
        q <= memory[address];
    end

endmodule
