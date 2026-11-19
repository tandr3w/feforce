// Background math theory used is from https://jtsorlinis.github.io/rendering-tutorial/ 

module edge_function (
    input [8:0] ax, bx, px,
    input [7:0] ay, by, py,
    output signed [20:0] edge_func
);
    // Calculate edge function (signed area) of a triangle
    // Clockwise = positive, counterclockwise = negative
    // edge function = signed area = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
    wire signed [9:0] dx_ab, dy_ab, dx_ap, dy_ap;

    assign dx_ab = $signed({1'b0, bx}) - $signed({1'b0, ax});
    assign dy_ab = $signed({1'b0, by}) - $signed({1'b0, ay});
    assign dx_ap = $signed({1'b0, px}) - $signed({1'b0, ax});
    assign dy_ap = $signed({1'b0, py}) - $signed({1'b0, ay});

    wire signed [19:0] product1, product2;

    assign product1 = dx_ab * dy_ap;
    assign product2 = dy_ab * dx_ap;
    assign edge_func = product1 - product2;

endmodule

module rasterizer (
    input clk,
    input rst,
    input signed [15:0] normal_x_in, normal_y_in, normal_z_in,
    input [5:0] u0_in, u1_in, u2_in, v0_in, v1_in, v2_in,
    input [8:0] x0_in, x1_in, x2_in,
    input [7:0] y0_in, y1_in, y2_in,
    input [15:0] depth_recip0, depth_recip1, depth_recip2, // w out

    input start, // signal to tell the rasterizer to start rasterizing the current triangle

    input clear,
    input [16:0] clear_addr,

    output [8:0] write_x,
    output [7:0] write_y,
    output [15:0] write_color,
    output write_enable, // should we actually write to this pixel?
    output reg done // signal to tell the render controller that we are done rasterizing this triangle
);

    parameter IDLE = 2'b00; // Ready to accept a new triangle
    parameter SETUP = 2'b01; // Setup bounding box and initial position
    parameter RASTER = 2'b10; // Rasterizing the triangle
    
    parameter DIVIDER_CYCLES = 8;
    reg [2:0] divider_counter; // counts how many cycles the divider has been running for

    reg [1:0] state;
    
    reg [8:0] x0, x1, x2;
    reg [7:0] y0, y1, y2;
    reg [15:0] depth0, depth1, depth2;

    reg signed [15:0] normal_x, normal_y, normal_z;
    reg [5:0] u0, u1, u2, v0, v1, v2;

    // reg [15:0] color0, color1, color2;
    wire signed [25:0] t_area_recip; // signed fixed point 1.24
    wire [20:0] remain;

    wire [8:0] min_x_raw, max_x_raw;
    wire [7:0] min_y_raw, max_y_raw;
    wire [8:0] min_x, max_x;
    wire [7:0] min_y, max_y;
    wire valid; // Is this triangle actually valid and on the screen?)

    reg [8:0] curr_x;
    reg [7:0] curr_y;

    assign min_x_raw = (x0 < x1) ? ((x0 < x2) ? x0 : x2) : ((x1 < x2) ? x1 : x2);
    assign min_y_raw = (y0 < y1) ? ((y0 < y2) ? y0 : y2) : ((y1 < y2) ? y1 : y2);
    assign max_x_raw = (x0 > x1) ? ((x0 > x2) ? x0 : x2) : ((x1 > x2) ? x1 : x2);
    assign max_y_raw = (y0 > y1) ? ((y0 > y2) ? y0 : y2) : ((y1 > y2) ? y1 : y2); 

    // Clip inside the framebuffer / screen bounds
    assign min_x = (min_x_raw < 0) ? 0 : min_x_raw;
    assign min_y = (min_y_raw < 0) ? 0 : min_y_raw;
    assign max_x = (max_x_raw > 319) ? 319 : max_x_raw;
    assign max_y = (max_y_raw > 239) ? 239 : max_y_raw;
    
    // Calculate edge function for all 3 edges of the triangle
    // Let x0,y0 = a, x1,y1 = b, x2,y2 = c, current pixel = p

    wire signed [20:0] t_area, edge0, edge1, edge2;
    wire inside;

    // Gets area of triangle ABC
    edge_function area_func (
        .ax(x0), .ay(y0),
        .bx(x1), .by(y1),
        .px(x2), .py(y2),
        .edge_func(t_area)
    );

    // edge ab
    edge_function edge0_func (
        .ax(x0), .ay(y0),
        .bx(x1), .by(y1),
        .px(curr_x), .py(curr_y),
        .edge_func(edge0)
    );

    // edge bc
    edge_function edge1_func (
        .ax(x1), .ay(y1),
        .bx(x2), .by(y2),
        .px(curr_x), .py(curr_y),
        .edge_func(edge1)
    );

    // edge ca
    edge_function edge2_func (
        .ax(x2), .ay(y2),
        .bx(x0), .by(y0),
        .px(curr_x), .py(curr_y),
        .edge_func(edge2)
    );


    // All edge functions need to be the same sign for the pixel to be inside the triangle
    assign inside = (edge0 >= 0) && (edge1 >= 0) && (edge2 >= 0)
                    || (edge0 <= 0) && (edge1 <= 0) && (edge2 <= 0);

    assign write_x = curr_x;
    assign write_y = curr_y;

    assign valid = (min_x <= max_x) && (min_y <= max_y) && (t_area > 0);

    // color interpolation based on https://codeplea.com/triangular-interpolation
    // https://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-rendering-a-triangle//barycentric-coordinates.html
    // barycentric coordinates = area(BCP) / area(ABC) for a point P (areas are unsigned)

    divider div (
        .clock(clk),
        .numer(26'd16777216), // 1.0 in signed fixed point 1.24 is 2^24
        .denom(t_area), // signed area
        .quotient(t_area_recip),
        .remain(remain)
    );

    // wire [4:0] redout, blueout;
    // wire [5:0] greenout;

    // // use signed values because the sign of the edge function will cancel out the sign of the t_area_recip if it is negative
    // // so we don't have to add any extra logic
    // wire signed [28:0] red_sum, blue_sum;
    // wire signed [29:0] green_sum;
    // wire signed [54:0] red_scaled, blue_scaled;
    // wire signed [55:0] green_scaled;

    // assign red_sum = edge1 * $signed({1'b0, color0[15:11]}) + 
    //                  edge2 * $signed({1'b0, color1[15:11]}) + 
    //                  edge0 * $signed({1'b0, color2[15:11]});

    // assign green_sum = edge1 * $signed({1'b0, color0[10:5]}) +
    //                    edge2 * $signed({1'b0, color1[10:5]}) + 
    //                    edge0 * $signed({1'b0, color2[10:5]});

    // assign blue_sum = edge1 * $signed({1'b0, color0[4:0]}) +
    //                   edge2 * $signed({1'b0, color1[4:0]}) + 
    //                   edge0 * $signed({1'b0, color2[4:0]});

    // assign red_scaled = red_sum * t_area_recip;
    // assign green_scaled = green_sum * t_area_recip;
    // assign blue_scaled = blue_sum * t_area_recip;

    // assign redout = red_scaled >> 24;
    // assign greenout = green_scaled >> 24;
    // assign blueout = blue_scaled >> 24;
    
    // textures (should probably move this stuff to a new momdule)

    // lighting
    // defines 1 directional light source
    parameter signed [15:0] LIGHT_X = 0; // signed Q1.14
    parameter signed [15:0] LIGHT_Y = 0;
    parameter signed [15:0] LIGHT_Z = -16384;

    wire signed [31:0] brightness_sum; // intermediate product
    wire signed [15:0] brightness_raw;
    wire [15:0] brightness;

    assign brightness_sum = (normal_x * LIGHT_X) + (normal_y * LIGHT_Y) + (normal_z * LIGHT_Z);

    assign brightness_raw = brightness_sum >> 14;

    // clamp the brightness between 0 and 1 to ensure colors stay in the valid range
    assign brightness = (brightness_raw < 0) ? 0 : (brightness_raw > 16384) ? 16384 : brightness_raw;

    wire [31:0] red_product, green_product, blue_product; // intermediate variables

    wire [4:0] red_out, blue_out;
    wire [5:0] green_out;

    // change to match the actual colors later
    assign red_product = 5'h1F * brightness;
    assign green_product = 6'h00 * brightness;
    assign blue_product = 5'h00 * brightness;

    // correct for q1.14
    assign red_out = red_product >> 14;
    assign green_out = green_product >> 14;
    assign blue_out = blue_product >> 14;

    assign write_color = {red_out, green_out, blue_out};

    // depth interpolation using barycentric coordinates
    wire signed [39:0] depth_sum;
    wire signed [65:0] depth_scaled;
    wire [15:0] depth_out;

    assign depth_sum = edge1 * $signed({1'b0, depth0}) + 
                       edge2 * $signed({1'b0, depth1}) + 
                       edge0 * $signed({1'b0, depth2});

    assign depth_scaled = depth_sum * t_area_recip;

    assign depth_out = depth_scaled >> 24;

    wire [15:0] stored_depth;

    reg [8:0] curr_x_next;
    reg [7:0] curr_y_next;

    assign write_enable = (state == RASTER) && inside && (depth_out > stored_depth);

    always @(*) begin
        if (state == SETUP) begin
            curr_x_next = min_x;
            curr_y_next = min_y;
        end
        else if (curr_x < max_x) begin
            curr_x_next = curr_x + 1;
            curr_y_next = curr_y;
        end else if (curr_y < max_y) begin
            curr_x_next = min_x;
            curr_y_next = curr_y + 1;
        end else begin
            curr_x_next = 0;
            curr_y_next = 0;
        end
    end

    depthbuffer_ram depth_buffer(
        .clock(clk),
        .rdaddress(curr_y_next * 17'd320 + curr_x_next),
        .wraddress(clear ? clear_addr : curr_y * 17'd320 + curr_x),
        .data(clear ? 16'b0 : depth_out),
        .wren(clear | write_enable),
        .q(stored_depth)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            divider_counter <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        // Store triangle in a register so we don't need to worry about inputs changing
                        x0 <= x0_in;
                        x1 <= x1_in;
                        x2 <= x2_in;
                        y0 <= y0_in;
                        y1 <= y1_in;
                        y2 <= y2_in;

                        // color0 <= color0_in;
                        // color1 <= color1_in;
                        // color2 <= color2_in;

                        normal_x <= normal_x_in;
                        normal_y <= normal_y_in;
                        normal_z <= normal_z_in;

                        u0 <= u0_in;
                        u1 <= u1_in;
                        u2 <= u2_in;
                        v0 <= v0_in;
                        v1 <= v1_in;
                        v2 <= v2_in;

                        depth0 <= depth_recip0;
                        depth1 <= depth_recip1;
                        depth2 <= depth_recip2;

                        divider_counter <= 0;
                        state <= SETUP;
                    end
                end

                SETUP: begin
                    if (!valid) begin
                        // Skip this triangle
                        done <= 1;
                        state <= IDLE;
                    end else begin
                        divider_counter <= divider_counter + 1;
                        if (divider_counter == DIVIDER_CYCLES - 1) begin
                            curr_x <= min_x;
                            curr_y <= min_y;
                            state <= RASTER;
                        end
                    end
                end

                RASTER: begin
                    // Loop through all pixels in bounding box
                    if (curr_x < max_x) begin
                        curr_x <= curr_x + 1;
                    end else if (curr_y < max_y) begin
                        curr_x <= min_x;
                        curr_y <= curr_y + 1;
                    end else begin
                        state <= IDLE; // Done all pixels in bounding box, go back to idle
                        done <= 1;
                    end
                end
            endcase
        end
    end

endmodule