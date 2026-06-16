module tb_sync_rptr_to_wr();
    logic wr_clk = 0;
    logic wr_rst_n = 0;
    logic [4:0] rptr_gray = 0;
    logic [4:0] rptr_gray_sync;

    sync_rptr_to_wr #(.WIDTH(5)) dut (.wr_clk(wr_clk), .wr_rst_n(wr_rst_n), .rptr_gray(rptr_gray), .rptr_gray_sync(rptr_gray_sync));

    initial forever #5 wr_clk = ~wr_clk;

    initial begin
        wr_rst_n = 0; #10; wr_rst_n = 1;
        repeat (8) begin
            #10 rptr_gray = rptr_gray + 1;
            #1 $display("rptr_gray=%d sync=%d", rptr_gray, rptr_gray_sync);
        end
        $finish;
    end
endmodule
