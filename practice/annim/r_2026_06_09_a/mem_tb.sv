//testbench for memory module

module mem_tb #(
    parameter int ADDR_WIDTH = 2,
    parameter int DATA_WIDTH = 4
)(

    logic                     clk_i,
    logic                     we_i,       // 1: write, 0: read

    logic [ADDR_WIDTH-1:0]    waddr_i,    // write address
    logic [DATA_WIDTH-1:0]    wdata_i,    // write data

    logic [ADDR_WIDTH-1:0]    raddr_i,    // read address
    logic[DATA_WIDTH-1:0]    rdata_o     // read data

    mem # (
        .ADDR_WIDTH(ADDR_WIDTH)
        .DATA_WIDTH (DATA_WIDTH)  
    )
    dut (
        .clk_i(clk_i),
        .we_i(we_i),
        .waddr_i(waddr_i),
        .wdata_i(wdata_i),
        .raddr_i(raddr_i),
        .rdata_o(rdata_o)
    );

    initial begin
        
    end
