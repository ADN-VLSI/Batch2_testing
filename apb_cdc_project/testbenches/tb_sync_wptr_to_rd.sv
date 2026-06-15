module tb_sync_wptr_to_rd();
    logic rd_clk = 0;
    logic rd_rst_n = 0;
    logic [4:0] wptr_gray = 0;
    logic [4:0] wptr_gray_sync;

    sync_wptr_to_rd #(.WIDTH(5)) dut (.rd_clk(rd_clk), .rd_rst_n(rd_rst_n), .wptr_gray(wptr_gray), .wptr_gray_sync(wptr_gray_sync));

    initial forever #7 rd_clk = ~rd_clk;

    initial begin
        rd_rst_n = 0; #10; rd_rst_n = 1;
        repeat (8) begin
            #10 wptr_gray = wptr_gray + 1;
            #1 $display("wptr_gray=%b sync=%b", wptr_gray, wptr_gray_sync);
        end
        $finish;
    end
   
endmodule
