// Module to simulate ram for DESim since it can't use the IP

module depthbuffer_ram (
    input clock,

    input [15:0] data,
    input [16:0] wraddress,
    input wren,
    input [16:0] rdaddress,
    output reg [15:0] q
);

    reg [15:0] mem [0:76799];

    integer i;

    initial begin
        q = 16'd0;
        for (i = 0; i < 76800; i = i + 1) begin
            mem[i] = 16'd0;
        end
    end

    always @(posedge clock) begin
        if (wren) begin
            mem[wraddress] <= data;
        end
        q <= mem[rdaddress];
        
    end

endmodule