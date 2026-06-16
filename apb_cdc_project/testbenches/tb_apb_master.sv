module tb_apb_master();
    logic clk = 0;
    logic rst_n = 0;
    logic start = 0;

    logic req_valid;
    logic [7:0] req_addr;
    logic req_write;
    logic [31:0] req_wdata;
    logic [3:0] req_strb;
    logic req_ready;
    logic resp_ready;
    logic resp_valid;
    logic [31:0] resp_rdata;
    logic resp_slverr;
    logic done;

    apb_master #(.ADDR_WIDTH(8), .DATA_WIDTH(32)) dut (
        .clk_i(clk), .rst_n(rst_n), .start_i(start),
        .req_valid_o(req_valid), .req_addr_o(req_addr), .req_write_o(req_write),
        .req_wdata_o(req_wdata), .req_strb_o(req_strb), .req_ready_i(req_ready),
        .resp_ready_o(resp_ready), .resp_valid_i(resp_valid), .resp_rdata_i(resp_rdata),
        .resp_slverr_i(resp_slverr), .done_o(done)
    );

    initial begin
        rst_n = 0; #20; rst_n = 1; #20;
        start = 1; #10; start = 0;
    end

    initial forever #5 clk = ~clk;

    // Simple model of a responder (always ready, returns fixed data)
    assign req_ready = 1'b1;
    assign resp_valid = 1'b0; // driven external in integration tests

    initial begin
        #200;
        $display("tb_apb_master finished");
        $finish;
    end
endmodule
