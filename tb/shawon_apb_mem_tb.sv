module shawon_apb_mem_tb;

  parameter int ADDR_WIDTH = 8;
  parameter int DATA_WIDTH = 32;

  // Clock & Reset
  logic clk_i;
  logic arst_ni;

  initial clk_i = 0;
  always #5 clk_i = ~clk_i;

  // APB signals
  logic psel_i;
  logic penable_i;
  logic [ADDR_WIDTH-1:0] paddr_i;
  logic pwrite_i;
  logic [DATA_WIDTH-1:0] pwdata_i;
  logic [(DATA_WIDTH/8)-1:0] pstrb_i;

  logic pready_o;
  logic [DATA_WIDTH-1:0] prdata_o;
  logic pslverr_o;

  // DUT
  apb_mem #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .arst_ni  (arst_ni),
    .clk_i    (clk_i),

    .psel_i   (psel_i),
    .penable_i(penable_i),
    .paddr_i  (paddr_i),
    .pwrite_i (pwrite_i),
    .pwdata_i (pwdata_i),
    .pstrb_i  (pstrb_i),

    .pready_o (pready_o),
    .prdata_o (prdata_o),
    .pslverr_o(pslverr_o)
  );

  // Reference memory
  logic [DATA_WIDTH-1:0] ref_mem [0:255];

  // WRITE TASK
  task automatic apb_write(
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] data,
    input logic [(DATA_WIDTH/8)-1:0] strb
  );
    int idx;

    @(posedge clk_i);
    psel_i    = 1;
    penable_i = 0;
    pwrite_i  = 1;
    paddr_i   = addr;
    pwdata_i  = data;
    pstrb_i   = strb;

    @(posedge clk_i);
    penable_i = 1;

    wait (pready_o == 1);

    @(posedge clk_i);
    psel_i = 0;
    penable_i = 0;

    // update reference model
    idx = addr >> $clog2(DATA_WIDTH/8);

    for (int i = 0; i < DATA_WIDTH/8; i++) begin
      if (strb[i])
        ref_mem[idx][8*i +: 8] = data[8*i +: 8];
    end
  endtask

  // READ TASK
  task automatic apb_read(
    input  logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] data
  );

    @(posedge clk_i);
    psel_i    = 1;
    penable_i = 0;
    pwrite_i  = 0;
    paddr_i   = addr;

    @(posedge clk_i);
    penable_i = 1;

    wait (pready_o == 1);

    data = prdata_o;

    @(posedge clk_i);
    psel_i = 0;
    penable_i = 0;

  endtask

  // TEST
  initial begin
    logic [DATA_WIDTH-1:0] rdata;
    int idx;

    // IMPORTANT: proper initialization
    psel_i = 0;
    penable_i = 0;
    pwrite_i = 0;
    paddr_i = '0;
    pwdata_i = '0;
    pstrb_i = '0;

    arst_ni = 0;
    repeat (2) @(posedge clk_i);
    arst_ni = 1;

    $dumpfile("apb_mem.vcd");
    $dumpvars(0, shawon_apb_mem_tb);

    // TEST 1
    apb_write(8'h10, 32'hAABBCCDD, 4'b1111);
    apb_read (8'h10, rdata);

    idx = 8'h10 >> $clog2(DATA_WIDTH/8);

    if (rdata !== ref_mem[idx])
      $error("TEST1 FAIL exp=%h got=%h", ref_mem[idx], rdata);
    else
      $display("TEST1 PASS");

    // TEST 2
    apb_write(8'h10, 32'h11223344, 4'b0011);
    apb_read (8'h10, rdata);

    idx = 8'h10 >> $clog2(DATA_WIDTH/8);

    if (rdata !== ref_mem[idx])
      $error("TEST2 FAIL exp=%h got=%h", ref_mem[idx], rdata);
    else
      $display("TEST2 PASS");

    // TEST 3 
    apb_write(8'h20, 32'hDEADBEEF, 4'b1111);
    apb_read (8'h20, rdata);

    idx = 8'h20 >> $clog2(DATA_WIDTH/8);

    if (rdata !== ref_mem[idx])
      $error("TEST3 FAIL");
    else
      $display("TEST3 PASS");

    // TEST 4
    for (int t = 0; t < 10; t++) begin
      logic [7:0] addr;
      logic [31:0] data;
      logic [3:0] strb;

      addr = $urandom_range(0, 255);
      data = $urandom;
      strb = $urandom;

      apb_write(addr, data, strb);
      apb_read(addr, rdata);

      idx = addr >> $clog2(DATA_WIDTH/8);

      if (rdata !== ref_mem[idx])
        $error("RANDOM TEST FAIL at %h", addr);
    end

    $display("ALL TESTS COMPLETED");
    $finish;
  end

endmodule