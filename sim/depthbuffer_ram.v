// Module to simulate ram for DESim since it can't use the IP

module depth_buffer_ram (
    input [16:0] address,
    input clock,
    input [15:0] data,
    input wren,
    output reg [15:0] q
);

    reg [15:0] mem [0:76799];

    always @(posedge clock) begin
        if (wren) begin
            mem[address] <= data;
        end else begin
            q <= mem[address];
        end

    end

endmodule