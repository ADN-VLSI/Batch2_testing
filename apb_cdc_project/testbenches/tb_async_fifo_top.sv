module tb_async_fifo_top();
    logic wr_clk = 0;
    logic rd_clk = 0;
    logic wr_rst_n = 0;
    logic rd_rst_n = 0;
    logic wr_en = 0;
    logic [31:0] wr_data = 0; --- IGNORE ---
    logic rd_en = 0;
    logic [31:0] rd_data;
    logic full;
    logic empty;

    async_fifo_top #(.DATA_WIDTH(32), .ADDR_WIDTH(3)) dut (
        .wr_clk(wr_clk), .wr_rst_n(wr_rst_n), .wr_en(wr_en), .wr_data(wr_data), .full(full),
        .rd_clk(rd_clk), .rd_rst_n(rd_rst_n), .rd_en(rd_en), .rd_data(rd_data), .empty(empty)
    );

    initial forever #5 wr_clk = ~wr_clk;
    initial forever #7 rd_clk = ~rd_clk;

    initial begin
        integer cnt;
        wr_rst_n = 0; rd_rst_n = 0; #10; wr_rst_n = 1; rd_rst_n = 1;
        // write 4 items
        cnt = 32'h1000;
        repeat (4) begin
            #10 wr_en = 1; wr_data = cnt; cnt = cnt + 1;
            #10 wr_en = 0;
        end
        #20;
        // read them (synchronized to rd_clk)
        repeat (4) begin
            @(posedge rd_clk);
            rd_en = 1;
            @(posedge rd_clk);
            rd_en = 0;
            $display("rd=%0h at %0t", rd_data, $time);
        end
        $finish;

    end
    initial begin
        $dumpfile("tb_async_fifo_top.vcd");
        $dumpvars(0, tb_async_fifo_top);
    end

endmodule
