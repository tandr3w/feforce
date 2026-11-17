module divider (
    input clock,
    input [20:0] denom,
    input [25:0] numer,
    output reg [25:0] quotient,
    output reg [20:0] remain
);

    reg signed [25:0] quotient_pipe [0:6];
    reg signed [20:0] remain_pipe [0:6];

    integer i;

    wire signed [25:0] numer_s = numer;
    wire signed [20:0] denom_s = denom;

    always @(posedge clock) begin
        if (denom_s != 0) begin
            quotient_pipe[0] <= numer_s / denom_s;
            remain_pipe[0] <= numer_s % denom_s;
        end else begin
            quotient_pipe[0] <= 0;
            remain_pipe[0] <= 0;
        end

        for (i = 1; i < 7; i = i + 1) begin
            quotient_pipe[i] <= quotient_pipe[i-1];
            remain_pipe[i] <= remain_pipe[i-1];
        end

        quotient <= quotient_pipe[6];
        remain <= remain_pipe[6];
    end

endmodule