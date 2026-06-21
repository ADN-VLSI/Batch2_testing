module khalid_axi4lite_memory_subordinate #(
    parameter int ADDR_WIDTH = 3,
    parameter int DATA_WIDTH = 8
) (
    input  logic clk_i,
    input  logic arst_ni,

    //AW Channel
    input  logic [ADDR_WIDTH-1:0] aw_addr_i,
    input  logic aw_valid_i,
    output logic aw_ready_o,
    input  logic [2:0] aw_prot_i,

    //W Channel
    input  logic [DATA_WIDTH-1:0] w_data_i,
    input  logic w_valid_i,
    output logic w_ready_o,
    input  logic [DATA_WIDTH/8-1:0] w_strb_i,

    //B Channel
    output logic [1:0] b_resp_o,
    output logic b_valid_o,
    input  logic b_ready_i, 

    //AR Channel
    input  logic [ADDR_WIDTH-1:0] ar_addr_i,
    input  logic ar_valid_i,
    output logic ar_ready_o,
    input  logic [2:0] ar_prot_i,

    //R Channel
    output logic [DATA_WIDTH-1:0] r_data_o,
    output logic [1:0] r_resp_o,
    output logic r_valid_o,
    input  logic r_ready_i
);
    
    //Internal Memory Reg
    localparam int MEM_DEPTH = 1 << ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] internal_mem [0:MEM_DEPTH-1];
    logic [ADDR_WIDTH-1:0] write_addr_reg;
    logic                  write_addr_valid_reg;
    logic                  write_data_valid_reg;

    // Response
    localparam logic [1:0] RESP_OKAY   = 2'b00;
    localparam logic [1:0] RESP_SLVERR = 2'b10;

    // Write Logic
    assign aw_ready_o = !write_addr_valid_reg && !b_valid_o;
    assign w_ready_o  = !write_data_valid_reg && !b_valid_o;

    always_ff @(posedge clk_i or negedge arst_ni) begin
        if (!arst_ni) begin
            write_addr_reg       <= '0;
            write_addr_valid_reg <= 1'b0;
            write_data_valid_reg <= 1'b0;
        end else begin
            if (aw_valid_i && aw_ready_o) begin
                write_addr_reg       <= aw_addr_i;
                write_addr_valid_reg <= 1'b1;
            end else if (b_valid_o && b_ready_i) begin
                write_addr_valid_reg <= 1'b0;
            end

            if (w_valid_i && w_ready_o) begin
                write_data_valid_reg <= 1'b1;
            end else if (b_valid_o && b_ready_i) begin
                write_data_valid_reg <= 1'b0;
            end
        end
    end

    logic write_en;
    assign write_en = write_addr_valid_reg && write_data_valid_reg;

    always_ff @(posedge clk_i or negedge arst_ni) begin
        if (!arst_ni) begin
            b_valid_o <= 1'b0;
            b_resp_o  <= RESP_OKAY;
        end else begin
            if (write_en && !b_valid_o) begin
                b_valid_o <= 1'b1;
                b_resp_o  <= RESP_OKAY;
                internal_mem[write_addr_reg] <= w_data_i; 
            end else if (b_valid_o && b_ready_i) begin
                b_valid_o <= 1'b0;
            end
        end
    end

    // Read Logic

    assign ar_ready_o = !r_valid_o || r_ready_i;

    always_ff @(posedge clk_i or negedge arst_ni) begin
        if (!arst_ni) begin
            r_valid_o <= 1'b0;
            r_data_o  <= '0;
            r_resp_o  <= RESP_OKAY;
        end else begin
            if (ar_valid_i && ar_ready_o) begin
                r_valid_o <= 1'b1;
                r_resp_o  <= RESP_OKAY;
                r_data_o  <= internal_mem[ar_addr_i]; 
            end else if (r_valid_o && r_ready_i) begin
                r_valid_o <= 1'b0;
            end
        end
    end
    

endmodule