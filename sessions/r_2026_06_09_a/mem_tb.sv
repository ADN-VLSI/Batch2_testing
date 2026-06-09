module mem_tb;

    parameter int ADDR_WIDTH = 2;
    parameter int DATA_WIDTH = 4;

    logic                     clk_i;
    logic                     we_i;       

    logic [ADDR_WIDTH-1:0]    waddr_i;  
    logic [DATA_WIDTH-1:0]    wdata_i;    

    logic [ADDR_WIDTH-1:0]    raddr_i;    
    logic[DATA_WIDTH-1:0]    rdata_o;     

    mem #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .WIDTH(WIDTH)
    )  dut(
            .clk_i(clk_i),
            .we_i(we_i),
            .waddr_i(waddr_i),
            .wdata_i(wdata_i),
            .raddr_i(raddr_i),
            .rdata_o(rdata_o)
    );

    initial begin




