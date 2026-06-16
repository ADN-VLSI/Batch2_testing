module wptr_gray2bin #(
    parameter int WIDTH = 5
) (
    input  logic [WIDTH-1:0] gray,
    output logic [WIDTH-1:0] bin
);

    integer i;

    always_comb begin
        bin[WIDTH-1] = gray[WIDTH-1];
        for (i = WIDTH-2; i >= 0; i = i - 1) begin
            bin[i] = bin[i+1] ^ gray[i];
        end
    end

endmodule
