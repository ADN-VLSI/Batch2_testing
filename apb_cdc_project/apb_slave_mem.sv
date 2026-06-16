module apb_slave_mem #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
) (
    input  logic                         clk_i,
    input  logic                         rst_n,
    input  logic                         psel_i,
    input  logic                         penable_i,
    input  logic [ADDR_WIDTH-1:0]        paddr_i,
    input  logic                         pwrite_i,
    input  logic [DATA_WIDTH-1:0]        pwdata_i,
    input  logic [(DATA_WIDTH/8)-1:0]    pstrb_i,
    output logic                         pready_o,
    output logic [DATA_WIDTH-1:0]        prdata_o,
    output logic                         pslverr_o
);

    logic [DATA_WIDTH-1:0] memory [0:255];
    logic [DATA_WIDTH-1:0] data_out;
    integer byte_i;

    assign pready_o = psel_i & penable_i;
    assign prdata_o = data_out;
    assign pslverr_o = 1'b0;

    always_ff @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= '0;
        end else begin
            if (psel_i && penable_i && pwrite_i) begin
                for (byte_i = 0; byte_i < DATA_WIDTH/8; byte_i = byte_i + 1) begin
                    if (pstrb_i[byte_i]) begin
                        memory[paddr_i][byte_i*8 +: 8] <= pwdata_i[byte_i*8 +: 8];
                    end
                end
            end
            if (psel_i && penable_i && !pwrite_i) begin
                data_out <= memory[paddr_i];
            end
        end
    end

endmodule
