module mem_tb_sabbir;

  parameter ADDR_WIDTH = 2;
  parameter DATA_WIDTH = 4;
  localparam DEPTH = 1 << ADDR_WIDTH;

  logic clk;
  logic we;
  logic [ADDR_WIDTH-1:0] waddr;
  logic [DATA_WIDTH-1:0] wdata;
  logic [ADDR_WIDTH-1:0] raddr;
  logic [DATA_WIDTH-1:0] rdata;

  logic [DATA_WIDTH-1:0] expected_mem [0:DEPTH-1];

  mem #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) dut (
      .clk_i(clk),
      .we_i(we),
      .waddr_i(waddr),
      .wdata_i(wdata),
      .raddr_i(raddr),
      .rdata_o(rdata)
  );

  initial begin
      clk = 0;
      forever #5 clk = ~clk;
  end

  task automatic write_word(input logic [ADDR_WIDTH-1:0] addr,
                            input logic [DATA_WIDTH-1:0] data);
    begin
      @(posedge clk);
      we = 1;
      waddr = addr;
      wdata = data;
      expected_mem[addr] = data;
    end
  endtask

  task automatic read_and_check(input logic [ADDR_WIDTH-1:0] addr);
    begin
      @(posedge clk);
      we = 0;
      raddr = addr;
      #1;
      if (rdata !== expected_mem[addr]) begin
        $error("FAIL: addr=%0d expected=%b got=%b", addr, expected_mem[addr], rdata);
      end
    end
  endtask

  initial begin
      we = 0;
      waddr = '0;
      wdata = '0;
      raddr = '0;

      for (int unsigned i = 0; i < DEPTH; i++) begin
        expected_mem[i] = '0;
      end

      // Write values to every address.
      for (int unsigned addr = 0; addr < DEPTH; addr++) begin
        write_word(addr, {DATA_WIDTH{1'b0}} ^ (addr * 3));
      end

      // Read back every address and check.
      for (int unsigned addr = 0; addr < DEPTH; addr++) begin
        read_and_check(addr);
      end

      $display("PASS: mem passed all %0d addresses", DEPTH);
      $finish;
  end
  /*initial begin
      $dumpfile("mem_tb_sabbir.vcd");
      $dumpvars(0, mem_tb);
  end*/

endmodule
