//Memory Testbench

module mem_khalid_tb;

    parameter int ADDR_WIDTH = 2,
    parameter int DATA_WIDTH = 4;

    logic                   clk_i,
    logic                   we_i,       // 1: write, 0: read

    logic [ADDR_WIDTH-1:0]  waddr_i,    // write address
    logic [DATA_WIDTH-1:0]  wdata_i,    // write data

    logic [ADDR_WIDTH-1:0]  raddr_i,    // read address
    logic[DATA_WIDTH-1:0]   rdata_o     // read data

  mem #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) dut (
      .clk_i (clk_i),
      .we_i (we_i),
      .waddr_i (waddr_i),
      .wdata_i (wdata_i),
      .raddr_i (raddr_i),
      .rdata_o (rdata_o)
  );

    initial begin
    
        $dumpfile("mem_khalid_tb.vcd");
        $dumpvars(0, mem_khalid_tb);
    
        $display("Starting Simulation for Khalid's Memory testbench...");
    
        // Initialize signals
        clk_i = 0;
        we_i = 0;
        waddr_i = 0;
        wdata_i = 0;
        raddr_i = 0;
    
        // Write to memory
        repeat (4) begin
        @(posedge clk_i);
        we_i = 1; // Enable write
        waddr_i = $random % (2**ADDR_WIDTH); // Random write address
        wdata_i = $random % (2**DATA_WIDTH); // Random write data
        $display("Writing to address %b: data=%b", waddr_i, wdata_i);
        @(posedge clk_i);
        we_i = 0; // Disable write
        end
    
        // Read from memory
        repeat (4) begin
        @(posedge clk_i);
        raddr_i = $random % (2**ADDR_WIDTH); // Random read address
        @(posedge clk_i);
        $display("Reading from address %b: data=%b", raddr_i, rdata_o);
        end
    
        $display("Simulation Finished Successfully.");
        $finish;
    end


endmodule;
