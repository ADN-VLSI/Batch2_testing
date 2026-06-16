module apb_master #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
) (
    input  logic                         clk_i,
    input  logic                         rst_n,
    input  logic                         start_i,
    output logic                         req_valid_o,
    output logic [ADDR_WIDTH-1:0]        req_addr_o,
    output logic                         req_write_o,
    output logic [DATA_WIDTH-1:0]        req_wdata_o,
    output logic [(DATA_WIDTH/8)-1:0]    req_strb_o,
    input  logic                         req_ready_i,
    output logic                         resp_ready_o,
    input  logic                         resp_valid_i,
    input  logic [DATA_WIDTH-1:0]        resp_rdata_i,
    input  logic                         resp_slverr_i,
    output logic                         done_o
);

    typedef enum logic [2:0] {
        IDLE,
        WAIT_WRITE_ACK,
        WAIT_WRITE_RESP,
        SEND_READ,
        WAIT_READ_RESP,
        DONE_STATE
    } state_e;

    state_e state_r;
    logic request_active;

    assign req_valid_o   = request_active;
    assign req_addr_o    = 'h10;
    assign req_write_o   = (state_r == WAIT_WRITE_ACK);
    assign req_wdata_o   = 32'hDEADBEEF;
    assign req_strb_o    = {(DATA_WIDTH/8){1'b1}};
    assign resp_ready_o  = 1'b1;

    always_ff @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            state_r        <= IDLE;
            request_active <= 1'b0;
            done_o         <= 1'b0;
        end else begin
            case (state_r)
                IDLE: begin
                    done_o <= 1'b0;
                    request_active <= 1'b0;
                    if (start_i) begin
                        request_active <= 1'b1;
                        state_r        <= WAIT_WRITE_ACK;
                    end
                end

                WAIT_WRITE_ACK: begin
                    if (req_ready_i) begin
                        request_active <= 1'b0;
                        state_r        <= WAIT_WRITE_RESP;
                    end
                end

                WAIT_WRITE_RESP: begin
                    if (resp_valid_i) begin
                        state_r <= SEND_READ;
                    end
                end

                SEND_READ: begin
                    request_active <= 1'b1;
                    if (req_ready_i) begin
                        request_active <= 1'b0;
                        state_r        <= WAIT_READ_RESP;
                    end
                end

                WAIT_READ_RESP: begin
                    if (resp_valid_i) begin
                        done_o <= 1'b1;
                        state_r <= DONE_STATE;
                    end
                end

                DONE_STATE: begin
                    request_active <= 1'b0;
                end

                default: state_r <= IDLE;
            endcase
        end
    end

endmodule
