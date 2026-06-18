module rr_arb_sabbir #(
    parameter int N = 4,
    parameter int PTR_W = $clog2(N)
)(
    input  logic         clk,
    input  logic         reset,
    input  logic [N-1:0] req,
    output logic [N-1:0] grant
);

    logic [PTR_W-1:0] ptr;

    logic [N-1:0] rotated_req;
    logic [N-1:0] rotated_grant;

    // Crossbar1:Rotate Requests
    always_comb begin
        integer i;
        for (i = 0; i < N; i++)
            rotated_req[i] = req[(i + ptr) % N];
    end

    // Fixed Priority Arbiter
    always_comb begin
        integer i;
        rotated_grant = '0;

        for (i = 0; i < N; i++) begin
            if (rotated_req[i]) begin
                rotated_grant[i] = 1'b1;
                break;
            end
        end
    end

    // Crossbar-2 : De-Rotate Grant
    always_comb begin
        integer i;
        grant = '0;
        for (i = 0; i < N; i++)
            grant[(i + ptr) % N] = rotated_grant[i];
    end

      always_ff @(posedge clk or posedge reset) begin
    integer i;
    if (reset)
        ptr <= 0;
    else if (grant != '0) begin
        for (int i = 0; i < N; i++) begin
            if (grant[i])
                ptr <= (i + 1) % N;
        end
    end
end

endmodule