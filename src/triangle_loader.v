module triangle_loader (
    input clk,
    input rst,
    input start,
    input [7:0] triangle_number,

    output reg signed [15:0] x0, y0, z0,
    output reg signed [15:0] x1, y1, z1,
    output reg signed [15:0] x2, y2, z2,
    output reg [15:0] color,

    output reg valid // marks if the triangle is loaded and ready to be used
);
    wire [39:0] triangle_data;

    reg [7:0] vertex_address;
    wire [47:0] vertex_data;

    // ROM takes 1 cycle to read, so we need to wait 1 cycle after setting the address before saving the data
    parameter IDLE = 3'b000;
    parameter LOAD_TRI = 3'b001;
    parameter LOAD_V0 = 3'b010;
    parameter LOAD_V1 = 3'b011;
    parameter LOAD_V2 = 3'b100;
    
    reg [2:0] state;

    // 40 bits: 16 bits for color, 8 bits each for address of vertices a, b, c
    triangle_rom triangle_mem (
        .address(triangle_number),
        .clock(clk),
        .q(triangle_data)
    );

    // vertex_data is 48 bits; x, y, z are each 16 bits and are signed (two's complement)
    // stored coordinate = 256 * actual coordinate. 
    // This is done to allow for decimal values (which we'll get after applying transformations), so we basically have 8 bits of decimal precision
    vertex_rom vertex_mem (
        .address(vertex_address),
        .clock(clk),
        .q(vertex_data)
    );


    always @(*) begin
        case (state)
            // When vertex_address is set, the vertex_data will update in the next cycle
            LOAD_TRI: vertex_address = triangle_data[23:16]; // start a request for vertex 0 data
            LOAD_V0:  vertex_address = triangle_data[15:8];  // start a request for vertex 1 data
            LOAD_V1:  vertex_address = triangle_data[7:0];   // start a request for vertex 2 data
            default:  vertex_address = 8'd0;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            valid <= 0;
        end else begin
            case (state)
                IDLE: begin
                    // Wait for start
                    valid <= 0;
                    if (start) begin
                        state <= LOAD_TRI;
                    end
                end
                LOAD_TRI: begin
                    color <= triangle_data[39:24];
                    state <= LOAD_V0;
                end
                LOAD_V0: begin
                    // save vertex 0 data
                    x0 <= vertex_data[47:32];
                    y0 <= vertex_data[31:16];
                    z0 <= vertex_data[15:0];
                    state <= LOAD_V1;
                end
                LOAD_V1: begin
                    // save vertex 1 data
                    x1 <= vertex_data[47:32];
                    y1 <= vertex_data[31:16];
                    z1 <= vertex_data[15:0];
                    state <= LOAD_V2;
                end
                LOAD_V2: begin
                    // save vertex 2 data
                    x2 <= vertex_data[47:32];
                    y2 <= vertex_data[31:16];
                    z2 <= vertex_data[15:0];
                    state <= IDLE;
                    valid <= 1;
                end
            endcase
        end
    end

endmodule