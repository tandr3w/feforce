// Module to simulate ram for DESim since it can't use the IP

module framebuffer_ram (
    input wire clock,
    input wire [15:0] data,
    input wire [16:0] wraddress,
    input wire wren,
    input wire [16:0] rdaddress,
    output reg [15:0] q
);

    reg [15:0] mem [0:76799];

    always @(posedge clock) begin
        if (wren)
            mem[wraddress] <= data;

        q <= mem[rdaddress];
    end

endmodule