module tb_fifo_mem_2port();
    logic wr_clk = 0;
    logic rd_clk = 0;
    logic wr_en = 0;
    logic [3:0] wr_addr = 0;
    logic [31:0] wr_data = 0;
    logic [3:0] rd_addr = 0;
    logic [31:0] rd_data;

    fifo_mem_2port #(.ADDR_WIDTH(4), .DATA_WIDTH(32)) dut (
        .wr_clk(wr_clk), .wr_en(wr_en), .wr_addr(wr_addr), .wr_data(wr_data),
        .rd_clk(rd_clk), .rd_addr(rd_addr), .rd_data(rd_data)
    );

    initial begin
        forever #5 wr_clk = ~wr_clk;
    end
    initial begin
        forever #7 rd_clk = ~rd_clk;
    end

    initial begin
        #10;
        wr_en = 1; wr_addr = 4'h1; wr_data = 32'h1111; #10;
        wr_addr = 4'h2; wr_data = 32'h2222; #10;
        wr_en = 0; #20;
        rd_addr = 4'h1; #10; $display("rd1=0x%08h", rd_data);
        rd_addr = 4'h2; #10; $display("rd2=0x%08h", rd_data);
        $finish;
    end
endmodule
