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
    output done // signal to tell the render controller that we are done rasterizing this triangle
);

    parameter IDLE = 2'b00; // Ready to accept a new triangle
    parameter SETUP = 2'b01; // Setup bounding box and initial position
    parameter RASTER = 2'b10; // Rasterizing the triangle
    
    parameter DIVIDER_CYCLES = 8;

    parameter signed [15:0] LIGHT_X = 10084; // signed Q1.14
    parameter signed [15:0] LIGHT_Y = 0;
    parameter signed [15:0] LIGHT_Z = -4000;

    parameter [15:0] LIGHT_AMBIENT = 1000;

    
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

    // delay the output by 1 cycle
    reg [8:0] x_d1;
    reg [7:0] y_d1;
    reg [9:0] depth_d1;
    reg valid_d1;
    reg done_d0;
    reg done_d1;

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

    // divider to get reciprocal of area for barycentric coordinates
    // barycentric coordinates = area(BCP) / area(ABC) for a point P (areas should be unsigned)
    // https://codeplea.com/triangular-interpolation
    // https://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-rendering-a-triangle//barycentric-coordinates.html


    divider div (
        .clock(clk),
        .numer(26'd16777216), // 1.0 in signed fixed point 1.24 is 2^24
        .denom(t_area), // signed area
        .quotient(t_area_recip),
        .remain(remain)
    );

    // All edge functions need to be the same sign for the pixel to be inside the triangle
    assign inside = (edge0 >= 0) && (edge1 >= 0) && (edge2 >= 0)
                    || (edge0 <= 0) && (edge1 <= 0) && (edge2 <= 0);

    assign valid = (min_x <= max_x) && (min_y <= max_y) && (t_area > 0);

    // textures (should probably move this stuff to a new module)
    // affine textures: just interpolate uv coords
    // https://gabrielgambetta.com/computer-graphics-from-scratch/14-textures.html
    // https://m.youtube.com/watch?t=1747&v=nBzCS-Y0FcY&feature=youtu.be

    wire signed [29:0] u_sum, v_sum;
    wire signed [55:0] u_scaled, v_scaled;
    wire [5:0] u_coord, v_coord;

    assign u_sum = edge1 * $signed({1'b0, u0}) +
                edge2 * $signed({1'b0, u1}) +
                edge0 * $signed({1'b0, u2});

    assign v_sum = edge1 * $signed({1'b0, v0}) +
                edge2 * $signed({1'b0, v1}) +
                edge0 * $signed({1'b0, v2});

    assign u_scaled = u_sum * t_area_recip;
    assign v_scaled = v_sum * t_area_recip;

    assign u_coord = u_scaled >>> 24;
    assign v_coord = v_scaled >>> 24;

    wire [15:0] texture_color;

    texture_rom texture (
        .address({v_coord, u_coord}), // 64 * v_coord + u_coord
        .clock(clk),
        .q(texture_color)
    );

    // lighting
    // defines 1 directional light source
    // should add up to 16384 so brightness ranges from 0 to 1
    // brightness multiplier is just dot product of normal and light source

    wire signed [31:0] brightness_sum; // intermediate product
    wire signed [15:0] brightness_raw;
    wire signed [15:0] brightness_directional;

    wire [15:0] brightness;

    assign brightness_sum = (normal_x * LIGHT_X) + (normal_y * LIGHT_Y) + (normal_z * LIGHT_Z);

    assign brightness_raw = brightness_sum >> 14;

    // clamp the brightness between 0 and 1 to ensure colors stay in the valid range, and add ambient light
    assign brightness_directional = ((brightness_raw < 0) ? 0 : brightness_raw) + LIGHT_AMBIENT; // make sure above 0
    assign brightness = (brightness_directional > 16384) ? 16384 : brightness_directional; // clamp to 1.0

    wire [31:0] red_product, green_product, blue_product; // intermediate variables

    wire [4:0] red_out, blue_out;
    wire [5:0] green_out;

    assign red_product = texture_color[15:11] * brightness;
    assign green_product = texture_color[10:5] * brightness;
    assign blue_product = texture_color[4:0] * brightness;

    // correct for q1.14
    assign red_out = red_product >> 14;
    assign green_out = green_product >> 14;
    assign blue_out = blue_product >> 14;

    // depth interpolation using barycentric coordinates
    wire signed [39:0] depth_sum;
    wire signed [65:0] depth_scaled;
    wire [15:0] depth_out;

    assign depth_sum = edge1 * $signed({1'b0, depth0}) + 
                       edge2 * $signed({1'b0, depth1}) + 
                       edge0 * $signed({1'b0, depth2});

    assign depth_scaled = depth_sum * t_area_recip;

    assign depth_out = depth_scaled >> 24;

    wire [9:0] stored_depth;

    wire write_enable_d1;
    assign write_enable_d1 = valid_d1 && (depth_d1 > stored_depth);

    depthbuffer_ram depth_buffer(
        .clock(clk),
        .rdaddress(curr_y * 17'd320 + curr_x),
        .wraddress(clear ? clear_addr : y_d1 * 17'd320 + x_d1),
        .data(clear ? 10'b0 : depth_d1),
        .wren(clear | write_enable_d1),
        .q(stored_depth)
    );

    assign write_color = {red_out, green_out, blue_out};
    assign write_x = x_d1;
    assign write_y = y_d1;
    assign write_enable = write_enable_d1;
    assign done = done_d1;

    // pipeline logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x_d1 <= 0;
            y_d1 <= 0;
            depth_d1 <= 0;
            valid_d1 <= 0;
            done_d1 <= 0;
        end
        else begin
            // stored_depth and texture_color are delayed by 1 cycle, which we need to set the write_color and write_enable
            // so, we track the x, y, depth, and valid signals for the previous cycle and use those for the output instead
            // so it corresponds with the delayed write_color and write_enable.
            x_d1 <= curr_x;
            y_d1 <= curr_y;
            depth_d1 <= depth_out[9:0];
            valid_d1 <= (state == RASTER) && !done_d0 && inside;
            done_d1 <= done_d0;
        end
    end

    // fsm logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            divider_counter <= 0;
            done_d0 <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done_d0 <= 0;
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
                        done_d0 <= 1;
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
                        if (done_d0) begin
                            done_d0 <= 0;
                            state <= IDLE; // Done all pixels in bounding box, go back to idle
                        end
                        else begin 
                            done_d0 <= 1;
                        end
                    end
                end
            endcase
        end
    end

endmodule