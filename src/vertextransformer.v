    // https://vlsiuniverse.com/verilog-code-for-sine-cos-and-tan-cordic/ start point jk use a lookup table
    // https://codesignal.com/learn/courses/3d-worlds-and-matrix-transformations/lessons/translation-and-rotation-matrices

    module vertex_transformer(

        input clk,
        input rst,
        input start,

        //input mode, // placeholder for keyboard
        input signed [15:0] translate, // either -1 or 1
        //input [13:0] rotate; // temp rotation along the x axis??? 

        input [11:0] rotate,
        input [11:0] light_rotate,


        input signed [15:0] x0, y0, z0, // fixed point 8.8
        input signed [15:0] x1, y1, z1,
        input signed [15:0] x2, y2, z2,

        input signed [15:0] nx, ny, nz, // normal vector

        output reg signed [15:0] x0_out, x1_out, x2_out, // fixed point 8.8, first bit is 8
        output reg signed [15:0] y0_out, y1_out, y2_out,
        output reg signed [15:0] z0_out, z1_out, z2_out,

        output reg signed [15:0] nx_out, ny_out, nz_out, 
        output reg signed [15:0] light_x_out, light_y_out, light_z_out,

        output reg is_done
    );


        reg [1:0] state;
        reg [2:0] angle_step;
        //parameter [15:0] rotation = 16'b0000001010000000; // rotation amt(smth) in 10.6 *fix change to binary angle map
        // parameter [11:0] rotation = 12'b000101110010;
        wire [11:0] rotation;
        assign rotation = rotate;

        // parameter signed [15:0] translation_x = 16'b0000000001000000; // translation amt(arbitary) fixed point 8.8
        wire signed [15:0] translation_x;
        assign translation_x = translate;
        parameter signed [15:0] translation_y = 16'b0000000000000000; // translation amt
        parameter signed [15:0] translation_z = 16'b0000000000000000; // translation amt
        parameter IDLE = 2'b00;
        parameter LOAD_ANGLES = 2'b01;
        parameter COMPUTE = 2'b10;
        parameter DONE = 2'b11;
        //reg [15:0] sine_addr; // define the width 9 bits for numbr 4 bits for decimal place 

        reg [11:0] sine_addr; //use binary angle map
        reg [11:0] cur_angle; 
        // or 10.6 for sine addr


        // not considering negative
        wire signed [15:0] sine_data; // fixed point 1.15 first bit is the sign rest of the numbers can be approximated by the remaining nums

        reg signed [15:0] sine_angle; // need to discuss on width stuff 1.15
        reg signed [15:0] cosine_angle;
        reg signed [15:0] light_sine_angle, light_cosine_angle;

        // intermediate sutff
        wire signed [31:0] cos_of_x0, cos_of_x1, cos_of_x2, cos_of_z0, cos_of_z1, cos_of_z2, cos_of_nx, cos_of_nz, cos_of_lx, cos_of_lz;
        wire signed [31:0] sin_of_x0, sin_of_x1, sin_of_x2, sin_of_z0, sin_of_z1, sin_of_z2, sin_of_nx, sin_of_nz, sin_of_lx, sin_of_lz;
        wire signed [15:0] translation_of_x0, translation_of_y0, translation_of_z0;
        wire signed [15:0] translation_of_x1, translation_of_y1, translation_of_z1;
        wire signed [15:0] translation_of_x2, translation_of_y2, translation_of_z2;
        wire signed [15:0] translation_of_nx, translation_of_ny, translation_of_nz;
        wire signed [15:0] sum_x0, sum_x1, sum_x2, sum_nx, sum_y0, sum_y1, sum_y2, sum_ny, sum_z0, sum_z1, sum_z2, sum_nz; 
        wire signed [15:0] sum_lx, sum_ly, sum_lz;

        // default light direction is directly towards the object from the front
        parameter signed [15:0] LIGHT_X = 0;
        parameter signed [15:0] LIGHT_Y = 0;
        parameter signed [15:0] LIGHT_Z = -16384;



    
        // change to -360 to 360 decimal in a 12 bit format
        sine_rom sine(sine_addr, clk, sine_data); // i feel like it makes the msot sense using an address sine addr since i dont intend for rotation to change

        // always @ (*) begin
        //     case (state) 

        //         IDLE: begin 
        //             // load sin
        //             sine_addr <= sine_addr + rotation; // rotation (10.6 + 10.6)

        //         end

        //         LOAD_SIN: begin 
        //             //load cos
        //             // https://electronicstechnician.tpub.com/14091/css/Binary-Angular-Measurement-316.htm
        //             sine_addr <= sine_addr + 12'd1024; // theres prob a better way to do this(we are using brads because i hate conversion)
        //             // consider wrap around once past 360(for both cases)

                    
        //         end
        //         // LOAD_COS: begin 
        //         //     // https://electronicstechnician.tpub.com/14091/css/Binary-Angular-Measurement-316.htm
        //         //     sine_addr <= sine_addr + 12'd1024; // theres prob a better way to do this(we are using brads because i hate conversion)
        //         //     // consider wrap around once past 360(for both cases)
        //         // end

        //         default sine_addr <= 12'b0; // should be 12 bit

        //     endcase  
        // end

        // set addresses for angle loading
        always @(*) begin
            case (state)
                IDLE: sine_addr = rotation;
                LOAD_ANGLES: begin
                    case (angle_step)
                        3'd0: sine_addr = rotation + 12'd1024;
                        3'd1: sine_addr = light_rotate;
                        3'd2: sine_addr = light_rotate + 12'd1024;
                        3'd3: sine_addr = rotation;
                        default: sine_addr = rotation;
                    endcase
                end
                default: sine_addr = rotation;
            endcase
        end

        always @ (posedge clk or posedge rst) begin
            if (rst) begin
                x0_out <= 0;
                x1_out <= 0; 
                x2_out <= 0; 
                y0_out <= 0; 
                y1_out <= 0; 
                y2_out <= 0;
                z0_out <= 0; 
                z1_out <= 0; 
                z2_out <= 0;
                nx_out <= 0; 
                ny_out <= 0; 
                nz_out <= 0; 
                light_x_out <= LIGHT_X;
                light_y_out <= LIGHT_Y;
                light_z_out <= LIGHT_Z;

                is_done <= 1'b0;
                state <= IDLE; 
                angle_step <= 0;




            end
            else begin 
                case (state) 
                IDLE: begin 
                    is_done  <= 1'b0;
                    // sine_addr <= 12'b0; 
                    // we want this to be ready by load_sin
                    // cur_angle <= 12'b0;
                    if (start) begin
                        angle_step <= 0;
                        state <= LOAD_ANGLES;
                    end

                end 

                LOAD_ANGLES: begin
                    case (angle_step)
                        3'd0: sine_angle <= sine_data;
                        3'd1: cosine_angle <= sine_data;
                        3'd2: light_sine_angle <= sine_data;
                        3'd3: light_cosine_angle <= sine_data;
                    endcase
                    if (angle_step == 3)
                        state <= COMPUTE;
                    else
                        angle_step <= angle_step + 1'b1;
                end

                COMPUTE: begin 
                    x0_out <= sum_x0;
                    y0_out <= sum_y0;
                    z0_out <= sum_z0; 
                    
                    x1_out <= sum_x1;
                    y1_out <= sum_y1;
                    z1_out <= sum_z1;

                    x2_out <= sum_x2;
                    y2_out <= sum_y2;
                    z2_out <= sum_z2;

                    nx_out <= sum_nx;
                    ny_out <= sum_ny; 
                    nz_out <= sum_nz;

                    light_x_out <= sum_lx;
                    light_y_out <= sum_ly;
                    light_z_out <= sum_lz;
                    state <= DONE;// iify
                    
                end

                DONE: begin 
                    //do adjustments to sine/cosine angle if needed

                    is_done <= 1'b1; 
                    state <= IDLE; 
                end
                endcase
            end
        end


        // now do smth with the rotation/transformation matrix

        // parameter a1 = cosine_angle; 
        // parameter a3 = sine_angle;
        // parameter b2 = 1;
        // parameter c1 = -sine_angle; // check 
        // parameter c3 = cosine_angle; 


        // always @ (*)


        // need to do bit corrections
        // if statement for rotation?
        // https://electronics.stackexchange.com/questions/270849/how-to-multiply-fixed-point-numbers-of-different-format

        //move assign to always block
        // https://chipverify.com/verilog/verilog-operators 


        // these are for multiplication with cosine/sines and are intermediate products to be used later
        // x0, y0, z0

        // intermdiate wires

        // holy shit

        
        // 32 bits
        assign cos_of_x0 = cosine_angle * x0 >>> 15; // fractional bits add up to 23, want 8
        assign sin_of_z0 = sine_angle * z0 >>> 15; // take the lower terms (where the decimal in the middle or smth)
        assign translation_of_x0 =  translation_x; //UPDATE this is alr fixed point dont shift


        assign sum_x0 = cos_of_x0 + sin_of_z0 + translation_of_x0; // since 8.8 no need to shift

        assign translation_of_y0 =  translation_y;
        assign sum_y0 = y0 + translation_of_y0; // alr in 8.8 

        assign cos_of_z0 = cosine_angle * z0 >>> 15;
        assign sin_of_x0 = sine_angle * x0 >>> 15; 
        assign translation_of_z0 =  translation_z;
        assign sum_z0 = (-sin_of_x0) + cos_of_z0 + translation_of_z0 + 16'b0000110000000000;  // add 12 fixed point


        // x1 ,y1 ,z1
        assign cos_of_x1 = cosine_angle * x1 >>> 15;
        assign sin_of_z1 = sine_angle * z1 >>> 15;
        assign translation_of_x1 =  translation_x;
        assign sum_x1 = cos_of_x1 + sin_of_z1 + translation_of_x1; // since 8.8 no need to shift

        assign translation_of_y1 =  translation_y;
        assign sum_y1 = y1 + translation_of_y1; // alr in 8.8 

        assign cos_of_z1 = cosine_angle * z1 >>> 15;
        assign sin_of_x1 = sine_angle * x1 >>> 15; 
        assign translation_of_z1 = translation_z;
        assign sum_z1 = (-sin_of_x1) + cos_of_z1 + translation_of_z1 + 16'b0000110000000000; 


        // x2, y2, z2
        assign cos_of_x2 = cosine_angle * x2 >>> 15;
        assign sin_of_z2 = sine_angle * z2 >>> 15;
        assign translation_of_x2 = translation_x;
        assign sum_x2 = cos_of_x2 + sin_of_z2 + translation_of_x2; // since 8.8 no need to shift

        assign translation_of_y2 = translation_y;
        assign sum_y2 = y2 + translation_of_y2; // alr in 8.8 

        assign cos_of_z2 = cosine_angle * z2 >>> 15;
        assign sin_of_x2 = sine_angle * x2 >>> 15; 
        assign translation_of_z2 = translation_z;
        assign sum_z2 = (-sin_of_x2) + cos_of_z2 + translation_of_z2 + 16'b0000110000000000; // 12 in 8.8


        // normal vector stuff
        // nx, ny, nz
        assign cos_of_nx = cosine_angle * nx >>> 15;
        assign sin_of_nz = sine_angle * nz >>> 15;
        // assign translation_of_nx = translate * translation_x;
        assign sum_nx = cos_of_nx + sin_of_nz; // since 8.8 no need to shift

        // assign translation_of_ny = translate * translation_y;
        assign sum_ny = ny; // alr in 8.8 

        assign cos_of_nz = cosine_angle * nz >>> 15;
        assign sin_of_nx = sine_angle * nx >>> 15; 
        // assign translation_of_nz = translate * translation_z;
        assign sum_nz = (-sin_of_nx) + cos_of_nz; 

        // rotate the light vector in the same way as the normal
        assign cos_of_lx = light_cosine_angle * LIGHT_X >>> 15;
        assign sin_of_lz = light_sine_angle * LIGHT_Z >>> 15;
        assign sum_lx = cos_of_lx + sin_of_lz;

        assign sum_ly = LIGHT_Y;

        assign cos_of_lz = light_cosine_angle * LIGHT_Z >>> 15;
        assign sin_of_lx = light_sine_angle * LIGHT_X >>> 15;
        assign sum_lz = (-sin_of_lx) + cos_of_lz;

        // assign x0_out = (cosine_angle * x0) + (sine_angle * z0) + (translation_x * translate); 
        // assign y0_out = y0 + (translation_y * translate); 
        // assign z0_out = (-sine_angle * x0) + (cosine_angle * z0) + (translation_z * translate);
        // // get the thingy


        // assign x1_out = (cosine_angle * x1) + (sine_angle * z1) + (translation_x * translate); 
        // assign y1_out = y1 + (translation_y * translate); 
        // assign z1_out = (-sine_angle * x1) + (cosine_angle * z1) + (translation_z * translate);
        // // double check this

        // assign x2_out = (cosine_angle * x2) + (sine_angle * z2) + (translation_x * translate); 
        // assign y2_out = y2 + (translation_y * translate); 
        // assign z2_out = (-sine_angle * x2) + (cosine_angle * z2) + (translation_z * translate);
        // // double check this


        // translation


        // normal matrix multiplication (input vector dotted with columns)
        // repeat for 3 vertices
        


    endmodule
