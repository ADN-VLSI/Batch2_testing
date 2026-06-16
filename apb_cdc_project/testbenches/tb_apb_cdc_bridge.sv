module tb_apb_cdc_bridge();
    // instantiate simplified master and slave and the bridge
    logic m_clk = 0, s_clk = 0;
    logic m_rst_n = 0, s_rst_n = 0;

    // master side signals
    logic req_valid; logic [7:0] req_addr; logic req_write; logic [31:0] req_wdata; logic [3:0] req_strb; logic req_ready;
    logic resp_ready = 1; logic resp_valid; logic [31:0] resp_rdata; logic resp_slverr;

    // slave side signals
    logic s_psel; logic s_penable; logic [7:0] s_paddr; logic s_pwrite; logic [31:0] s_pwdata; logic [3:0] s_pstrb;
    logic s_pready; logic [31:0] s_prdata; logic s_pslverr;

    apb_cdc_bridge #(.ADDR_WIDTH(8), .DATA_WIDTH(32), .FIFO_ADDR_WIDTH(3)) bridge (
        .m_clk_i(m_clk), .m_rst_n(m_rst_n), .req_valid_i(req_valid), .req_addr_i(req_addr), .req_write_i(req_write),
        .req_wdata_i(req_wdata), .req_strb_i(req_strb), .req_ready_o(req_ready), .resp_ready_i(resp_ready),
        .resp_valid_o(resp_valid), .resp_rdata_o(resp_rdata), .resp_slverr_o(resp_slverr),
        .s_clk_i(s_clk), .s_rst_n(s_rst_n), .pready_i(s_pready), .prdata_i(s_prdata), .pslverr_i(s_pslverr),
        .s_psel_o(s_psel), .s_penable_o(s_penable), .s_paddr_o(s_paddr), .s_pwrite_o(s_pwrite), .s_pwdata_o(s_pwdata), .s_pstrb_o(s_pstrb)
    );

    apb_slave_mem #(.ADDR_WIDTH(8), .DATA_WIDTH(32)) slave (
        .clk_i(s_clk), .rst_n(s_rst_n), .psel_i(s_psel), .penable_i(s_penable), .paddr_i(s_paddr),
        .pwrite_i(s_pwrite), .pwdata_i(s_pwdata), .pstrb_i(s_pstrb), .pready_o(s_pready), .prdata_o(s_prdata), .pslverr_o(s_pslverr)
    );

    // simple master model drives requests into the bridge
    logic start = 0; logic done = 0;
    apb_master #(.ADDR_WIDTH(8), .DATA_WIDTH(32)) master (.clk_i(m_clk), .rst_n(m_rst_n), .start_i(start),
        .req_valid_o(req_valid), .req_addr_o(req_addr), .req_write_o(req_write), .req_wdata_o(req_wdata), .req_strb_o(req_strb),
        .req_ready_i(req_ready), .resp_ready_o(resp_ready), .resp_valid_i(resp_valid), .resp_rdata_i(resp_rdata), .resp_slverr_i(resp_slverr), .done_o(done)
    );

    initial begin
        m_clk = 0; s_clk = 0; m_rst_n = 0; s_rst_n = 0; #20; m_rst_n = 1; s_rst_n = 1; #20;
        start = 1; #10; start = 0;
    end
    initial forever #5 m_clk = ~m_clk;
    initial forever #7 s_clk = ~s_clk;

    initial begin
        #500; $display("tb_apb_cdc_bridge done"); $finish;
    end
endmodule
