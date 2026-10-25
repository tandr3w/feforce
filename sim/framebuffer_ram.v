// Module to simulate ram for DESim since it can't use the IP

module framebuffer_ram (
    input wire rdclock,
    input wire wrclock,

    input wire [15:0] data,
    input wire [16:0] wraddress,
    input wire wren,
    input wire [16:0] rdaddress,
    output reg [15:0] q
);

    reg [15:0] mem [0:76799];

    always @(posedge wrclock) begin
        if (wren)
            mem[wraddress] <= data;
    end

    always @(posedge rdclock) begin
        q <= mem[rdaddress];
    end

endmodule