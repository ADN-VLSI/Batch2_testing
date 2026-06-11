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

        // initial value set
        we_i    = 0;
        waddr_i = 0;
        wdata_i = 0;
        raddr_i = 0;

        // clock set with time period 20
        clk_i = 0;
        #20 clk_i = ~ clk_i;

        //write 1010 in memory addr 00
        we_i = 1;
        waddr_i = 2'b00;
        wdata_i = 4'b1010;

        //write 0101 in memory addr 10
        we_i = 1;
        waddr_i = 2'b10;
        wdata_i = 4'b0101;

        //read data from memory addr 00
        we_i = 0;
        raddr_i = 2'b00;
        display("In address = %b, data available = %b",raddr_i,rdata_o);

        //read data from memory addr 10
        we_i = 0;
        raddr_i = 2'b10;
        display("In address = %b, available data = %b",raddr_i, rdata_o);


      end
endmodule


