module apb_mem_tb;

  localparam int ADDR_WIDTH = 8;
  localparam int DATA_WIDTH = 32;

  logic clk_i = 0;
  logic arst_ni = 1;

  // APB slave interface signals
  logic psel_i = 0;
  logic penable_i = 0;
  logic [ADDR_WIDTH-1:0] paddr_i = 0;
  logic pwrite_i = 0;
  logic [DATA_WIDTH-1:0] pwdata_i = 0;
  logic [(DATA_WIDTH/8)-1:0] pstrb_i = '0;

  logic pready_o;
  logic [DATA_WIDTH-1:0] prdata_o;
  logic pslverr_o;

  int NUM_TESTS = 2000;
  int DEBUG = 0;

  bit edge_aligned;

  localparam int BYTE_OFFSET = $clog2(DATA_WIDTH/8);
  localparam int WORDS = 2**(ADDR_WIDTH - BYTE_OFFSET);

  logic [DATA_WIDTH-1:0] model_mem [WORDS];
  int used_addresses [$];
  // Module-scope variables to avoid procedural-scope declaration issues in some simulators
  int i;
  int addr;
  int mode;
  logic [DATA_WIDTH-1:0] data;
  logic [DATA_WIDTH-1:0] read_data;
  logic [DATA_WIDTH-1:0] wdata;
  logic [DATA_WIDTH-1:0] rdata;
  int test_addr;

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

  int pass_count = 0;
  int fail_count = 0;

  always #5 clk_i = ~clk_i;

  always @(posedge clk_i) begin
    edge_aligned = 1'b1;
    #1ps;
    edge_aligned = 1'b0;
  end

  task automatic apb_write(input logic [ADDR_WIDTH-1:0] addr, input logic [DATA_WIDTH-1:0] data);
    int word_idx;
    wait (edge_aligned);
    // Setup phase
    psel_i   <= 1'b1;
    penable_i<= 1'b0;
    pwrite_i <= 1'b1;
    paddr_i  <= addr;
    pwdata_i <= data;
    pstrb_i  <= {(DATA_WIDTH/8){1'b1}};
    @(posedge clk_i);
    // Enable phase
    penable_i <= 1'b1;
    @(posedge clk_i);
    // Capture model memory (address is byte address; convert to word index)
    word_idx = addr >> BYTE_OFFSET;
    model_mem[word_idx] = data;
    // Tear down
    psel_i    <= 1'b0;
    penable_i <= 1'b0;
    pwrite_i  <= 1'b0;
    paddr_i   <= '0;
    pwdata_i  <= '0;
    pstrb_i   <= '0;
  endtask

  task automatic apb_read(input logic [ADDR_WIDTH-1:0] addr, output logic [DATA_WIDTH-1:0] data);
    int word_idx;
    wait (edge_aligned);
    psel_i    <= 1'b1;
    penable_i <= 1'b0;
    pwrite_i  <= 1'b0;
    paddr_i   <= addr;
    @(posedge clk_i);
    penable_i <= 1'b1;
    @(posedge clk_i);
    word_idx = addr >> BYTE_OFFSET;
    data = prdata_o;
    if (data !== model_mem[word_idx]) begin
      $display("[%0t] ERROR: Read mismatch at addr %0h. Expected %0h, Got %0h", $realtime, addr, model_mem[word_idx], data);
      fail_count++;
    end else begin
      pass_count++;
      if (DEBUG) $display("[%0t] Read OK addr %0h data %0h", $realtime, addr, data);
    end
    // Tear down
    psel_i    <= 1'b0;
    penable_i <= 1'b0;
    paddr_i   <= '0;
  endtask

  initial begin
    $timeformat(-9, 0, "ns");
    $dumpfile("apb_mem_tb.vcd");
    $dumpvars(0, apb_mem_tb);

    // Reset
    arst_ni = 1'b0;
    repeat (4) @(posedge clk_i);
    arst_ni = 1'b1;
    @(posedge clk_i);

    // Fill model memory with known pattern
    for (i = 0; i < WORDS; i++) model_mem[i] = '0;

    // Simple deterministic write/read tests
    test_addr = 8'h10;
    wdata = 32'hDEAD_BEEF;
    used_addresses.push_back(test_addr);
    apb_write(test_addr, wdata);
    rdata = '0;
    apb_read(test_addr, rdata);

    // Random writes
    for (i = 0; i < NUM_TESTS; i++) begin
      addr = $urandom_range(0, 2**ADDR_WIDTH - 1);
      data = $urandom;
      used_addresses.push_back(addr);
      apb_write(addr, data);
    end

    // Random reads
    for (i = 0; i < NUM_TESTS; i++) begin
      mode = $urandom_range(0,9);
      if (mode == 0 || used_addresses.size() == 0) addr = $urandom_range(0, 2**ADDR_WIDTH - 1);
      else addr = used_addresses[$urandom_range(0, used_addresses.size()-1)];
      apb_read(addr, read_data);
    end

    // Report results
    if (fail_count == 0) begin
      $display("\033[1;32mAll %0d reads passed!\033[0m", pass_count);
    end else begin
      $display("\033[1;31m%0d reads failed out of %0d\033[0m", fail_count, pass_count + fail_count);
    end

    #1us;
    $finish;
  end

endmodule
