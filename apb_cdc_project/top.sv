module top;
    localparam int ADDR_WIDTH = 8;
    localparam int DATA_WIDTH = 32;
    localparam int STRB_WIDTH  = DATA_WIDTH / 8;

    logic master_clk;
    logic slave_clk;
    logic rst_n;
    logic start;
    logic done;

    logic req_valid;
    logic [ADDR_WIDTH-1:0] req_addr;
    logic req_write;
    logic [DATA_WIDTH-1:0] req_wdata;
    logic [STRB_WIDTH-1:0] req_strb;
    logic req_ready;

    logic resp_ready;
    logic resp_valid;
    logic [DATA_WIDTH-1:0] resp_rdata;
    logic resp_slverr;

    logic s_psel;
    logic s_penable;
    logic [ADDR_WIDTH-1:0] s_paddr;
    logic s_pwrite;
    logic [DATA_WIDTH-1:0] s_pwdata;
    logic [STRB_WIDTH-1:0] s_pstrb;
    logic s_pready;
    logic [DATA_WIDTH-1:0] s_prdata;
    logic s_pslverr;

    apb_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) master_i (
        .clk_i         (master_clk),
        .rst_n         (rst_n),
        .start_i       (start),
        .req_valid_o   (req_valid),
        .req_addr_o    (req_addr),
        .req_write_o   (req_write),
        .req_wdata_o   (req_wdata),
        .req_strb_o    (req_strb),
        .req_ready_i   (req_ready),
        .resp_ready_o  (resp_ready),
        .resp_valid_i  (resp_valid),
        .resp_rdata_i  (resp_rdata),
        .resp_slverr_i (resp_slverr),
        .done_o        (done)
    );

    apb_cdc_bridge #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_ADDR_WIDTH(4)
    ) bridge_i (
        .m_clk_i       (master_clk),
        .m_rst_n       (rst_n),
        .req_valid_i   (req_valid),
        .req_addr_i    (req_addr),
        .req_write_i   (req_write),
        .req_wdata_i   (req_wdata),
        .req_strb_i    (req_strb),
        .req_ready_o   (req_ready),
        .resp_ready_i  (resp_ready),
        .resp_valid_o  (resp_valid),
        .resp_rdata_o  (resp_rdata),
        .resp_slverr_o (resp_slverr),
        .s_clk_i       (slave_clk),
        .s_rst_n       (rst_n),
        .pready_i      (s_pready),
        .prdata_i      (s_prdata),
        .pslverr_i     (s_pslverr),
        .s_psel_o      (s_psel),
        .s_penable_o   (s_penable),
        .s_paddr_o     (s_paddr),
        .s_pwrite_o    (s_pwrite),
        .s_pwdata_o    (s_pwdata),
        .s_pstrb_o     (s_pstrb)
    );

    apb_slave_mem #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave_i (
        .clk_i      (slave_clk),
        .rst_n      (rst_n),
        .psel_i     (s_psel),
        .penable_i  (s_penable),
        .paddr_i    (s_paddr),
        .pwrite_i   (s_pwrite),
        .pwdata_i   (s_pwdata),
        .pstrb_i    (s_pstrb),
        .pready_o   (s_pready),
        .prdata_o   (s_prdata),
        .pslverr_o  (s_pslverr)
    );

    // `resp_ready` is driven by the `apb_master` instance (resp_ready_o).
    // Remove the static drive to avoid multiple-driver conflicts.

    initial begin
        master_clk = 1'b0;
        slave_clk  = 1'b0;
        rst_n      = 1'b0;
        start      = 1'b0;
        #20;
        rst_n = 1'b1;
        #20;
        start = 1'b1;
        #10;
        start = 1'b0;
    end

    initial forever #5 master_clk = ~master_clk;
    initial forever #7 slave_clk  = ~slave_clk;

    always @(posedge master_clk) begin
        $display("%0t req_ready=%b resp_valid=%b resp_data=0x%08h done=%b", $time, req_ready, resp_valid, resp_rdata, done);
    end

    always @(posedge done) begin
        $display("Simulation finished.");
        $finish;
    end

endmodule
