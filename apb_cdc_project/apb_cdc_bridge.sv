module apb_cdc_bridge #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32,
    parameter int FIFO_ADDR_WIDTH = 4
) (
    input  logic                         m_clk_i,
    input  logic                         m_rst_n,
    input  logic                         req_valid_i,
    input  logic [ADDR_WIDTH-1:0]        req_addr_i,
    input  logic                         req_write_i,
    input  logic [DATA_WIDTH-1:0]        req_wdata_i,
    input  logic [(DATA_WIDTH/8)-1:0]    req_strb_i,
    output logic                         req_ready_o,
    input  logic                         resp_ready_i,
    output logic                         resp_valid_o,
    output logic [DATA_WIDTH-1:0]        resp_rdata_o,
    output logic                         resp_slverr_o,

    input  logic                         s_clk_i,
    input  logic                         s_rst_n,
    input  logic                         pready_i,
    input  logic [DATA_WIDTH-1:0]        prdata_i,
    input  logic                         pslverr_i,
    output logic                         s_psel_o,
    output logic                         s_penable_o,
    output logic [ADDR_WIDTH-1:0]        s_paddr_o,
    output logic                         s_pwrite_o,
    output logic [DATA_WIDTH-1:0]        s_pwdata_o,
    output logic [(DATA_WIDTH/8)-1:0]    s_pstrb_o
);

    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    localparam int REQUEST_WIDTH = ADDR_WIDTH + 1 + DATA_WIDTH + STRB_WIDTH;
    localparam int RESPONSE_WIDTH = DATA_WIDTH + 1;

    logic [REQUEST_WIDTH-1:0] req_bus;
    logic [REQUEST_WIDTH-1:0] req_fifo_data;
    logic [RESPONSE_WIDTH-1:0] resp_fifo_read_data;
    logic [RESPONSE_WIDTH-1:0] resp_fifo_write_data;

    logic req_fifo_full;
    logic req_fifo_empty;
    logic resp_fifo_full;
    logic resp_fifo_empty;
    logic req_fifo_wr_en;
    logic req_fifo_rd_en;
    logic resp_fifo_wr_en;
    logic resp_fifo_rd_en;

    logic [REQUEST_WIDTH-1:0] current_request;
    logic [ADDR_WIDTH-1:0]   current_addr;
    logic                    current_write;
    logic [DATA_WIDTH-1:0]   current_wdata;
    logic [STRB_WIDTH-1:0]   current_strb;

    typedef enum logic [1:0] {
        S_IDLE,
        S_SETUP,
        S_ENABLE,
        S_WAIT
    } slave_state_e;
    slave_state_e s_state;

    assign req_bus = {req_addr_i, req_write_i, req_wdata_i, req_strb_i};
    assign req_ready_o = !req_fifo_full;
    assign resp_valid_o  = !resp_fifo_empty;
    assign resp_rdata_o  = resp_fifo_read_data[DATA_WIDTH-1:0];
    assign resp_slverr_o = resp_fifo_read_data[DATA_WIDTH];
    assign resp_fifo_rd_en = resp_valid_o && resp_ready_i;
    assign s_paddr_o  = current_addr;
    assign s_pwrite_o = current_write;
    assign s_pwdata_o = current_wdata;
    assign s_pstrb_o  = current_strb;
    assign req_fifo_wr_en = req_valid_i && req_ready_o;

    async_fifo_top #(
        .DATA_WIDTH(REQUEST_WIDTH),
        .ADDR_WIDTH(FIFO_ADDR_WIDTH)
    ) u_req_fifo (
        .wr_clk   (m_clk_i),
        .wr_rst_n (m_rst_n),
        .wr_en    (req_fifo_wr_en),
        .wr_data  (req_bus),
        .full     (req_fifo_full),
        .rd_clk   (s_clk_i),
        .rd_rst_n (s_rst_n),
        .rd_en    (req_fifo_rd_en),
        .rd_data  (req_fifo_data),
        .empty    (req_fifo_empty)
    );

    async_fifo_top #(
        .DATA_WIDTH(RESPONSE_WIDTH),
        .ADDR_WIDTH(FIFO_ADDR_WIDTH)
    ) u_resp_fifo (
        .wr_clk   (s_clk_i),
        .wr_rst_n (s_rst_n),
        .wr_en    (resp_fifo_wr_en),
        .wr_data  (resp_fifo_write_data),
        .full     (resp_fifo_full),
        .rd_clk   (m_clk_i),
        .rd_rst_n (m_rst_n),
        .rd_en    (resp_fifo_rd_en),
        .rd_data  (resp_fifo_read_data),
        .empty    (resp_fifo_empty)
    );

    always_ff @(posedge s_clk_i or negedge s_rst_n) begin
        if (!s_rst_n) begin
            s_state           <= S_IDLE;
            current_request   <= '0;
            current_addr      <= '0;
            current_write     <= 1'b0;
            current_wdata     <= '0;
            current_strb      <= '0;
            s_psel_o          <= 1'b0;
            s_penable_o       <= 1'b0;
            resp_fifo_wr_en   <= 1'b0;
            req_fifo_rd_en    <= 1'b0;
        end else begin
            resp_fifo_wr_en <= 1'b0;
            req_fifo_rd_en  <= 1'b0;
            case (s_state)
                S_IDLE: begin
                    s_psel_o    <= 1'b0;
                    s_penable_o <= 1'b0;
                    if (!req_fifo_empty && !resp_fifo_full) begin
                        req_fifo_rd_en <= 1'b1;
                        current_request <= req_fifo_data;
                        s_state <= S_SETUP;
                    end
                end
                S_SETUP: begin
                    current_addr  <= current_request[REQUEST_WIDTH-1:REQUEST_WIDTH-ADDR_WIDTH];
                    current_write <= current_request[REQUEST_WIDTH-ADDR_WIDTH-1];
                    current_wdata <= current_request[REQUEST_WIDTH-ADDR_WIDTH-2:STRB_WIDTH];
                    current_strb  <= current_request[STRB_WIDTH-1:0];
                    s_psel_o      <= 1'b1;
                    s_penable_o   <= 1'b0;
                    s_state       <= S_ENABLE;
                end
                S_ENABLE: begin
                    s_psel_o    <= 1'b1;
                    s_penable_o <= 1'b1;
                    s_state     <= S_WAIT;
                end
                S_WAIT: begin
                    if (pready_i) begin
                        resp_fifo_wr_en      <= 1'b1;
                        resp_fifo_write_data <= {pslverr_i, prdata_i};
                        s_psel_o             <= 1'b0;
                        s_penable_o          <= 1'b0;
                        s_state              <= S_IDLE;
                    end
                end
                default: s_state <= S_IDLE;
            endcase
        end
    end

endmodule
