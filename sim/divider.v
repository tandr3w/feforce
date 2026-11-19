module divider (
    input clock,
    input signed [20:0] denom,
    input signed [25:0] numer,
    output reg [25:0] quotient,
    output reg [20:0] remain
);

    reg signed [25:0] q_pipeline [0:6];
    reg signed [20:0] r_pipeline [0:6];

    always @(posedge clock) begin
        if (denom != 0) begin
            q_pipeline[0] <= numer / denom;
            r_pipeline[0] <= numer % denom;
        end else begin
            q_pipeline[0] <= 0;
            r_pipeline[0] <= 0;
        end

        // shift the pipeline forward
        q_pipeline[1] <= q_pipeline[0];
        r_pipeline[1] <= r_pipeline[0];

        q_pipeline[2] <= q_pipeline[1];
        r_pipeline[2] <= r_pipeline[1];

        q_pipeline[3] <= q_pipeline[2];
        r_pipeline[3] <= r_pipeline[2];

        q_pipeline[4] <= q_pipeline[3];
        r_pipeline[4] <= r_pipeline[3];

        q_pipeline[5] <= q_pipeline[4];
        r_pipeline[5] <= r_pipeline[4];

        q_pipeline[6] <= q_pipeline[5];
        r_pipeline[6] <= r_pipeline[5];

        quotient <= q_pipeline[6];
        remain <= r_pipeline[6];
    end

endmodule