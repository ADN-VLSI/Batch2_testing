module tb_apb_slave_mem();
    logic clk = 0;
    logic rst_n = 0;
    logic psel = 0;
    logic penable = 0;
    logic [7:0] paddr = 0;
    logic pwrite = 0;
    logic [31:0] pwdata = 0;
    logic [3:0] pstrb = 4'hF;
    logic pready;
    logic [31:0] prdata;
    logic pslverr;

    apb_slave_mem #(.ADDR_WIDTH(8), .DATA_WIDTH(32)) dut (
        .clk_i(clk), .rst_n(rst_n), .psel_i(psel), .penable_i(penable), .paddr_i(paddr),
        .pwrite_i(pwrite), .pwdata_i(pwdata), .pstrb_i(pstrb), .pready_o(pready),
        .prdata_o(prdata), .pslverr_o(pslverr)
    );

    initial begin
        rst_n = 0; #10; rst_n = 1;
        // write
        psel = 1; penable = 1; pwrite = 1; paddr = 8'h10; pwdata = 32'hCAFEBABE; #10;
        psel = 0; penable = 0; pwrite = 0; #10;
        // read
        psel = 1; penable = 1; pwrite = 0; paddr = 8'h10; #10;
        $display("Read data = 0x%08h", prdata);
        $finish;
    end

    initial forever #5 clk = ~clk;
endmodule
