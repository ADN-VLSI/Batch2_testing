module khalid_apb_mem_tb;


  localparam int ADDR_WIDTH = 8;
  localparam int DATA_WIDTH = 32;
  localparam int STRB_WIDTH = DATA_WIDTH / 8;

  logic                  arst_n;
  logic                  clk = 0;
  logic                  psel;
  logic                  penable;
  logic [ADDR_WIDTH-1:0] paddr;
  logic                  pwrite;
  logic [DATA_WIDTH-1:0] pwdata;
  logic [STRB_WIDTH-1:0] pstrb;

  logic                  pready;
  logic [DATA_WIDTH-1:0] prdata;
  logic                  pslverr;
  bit                    edge_aligned;
  logic [DATA_WIDTH-1:0] read_back_data;
  
  int                    NUM_TESTS = 1000;
  int                    DEBUG     = 1;
  int                    pass_count;
  int                    fail_count;
  logic [ADDR_WIDTH-1:0] used_addresses [$];

  logic [DATA_WIDTH-1:0] mem_array     [2**ADDR_WIDTH];

  apb_mem #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) u_dut (
      .arst_ni   (arst_n),
      .clk_i     (clk),
      .psel_i    (psel),
      .penable_i (penable),
      .paddr_i   (paddr),
      .pwrite_i  (pwrite),
      .pwdata_i  (pwdata),
      .pstrb_i   (pstrb),
      .pready_o  (pready),
      .prdata_o  (prdata),
      .pslverr_o (pslverr)
  );


  always #5ns clk <= ~clk;

  always @(posedge clk) begin
    edge_aligned = '1;
    #1ps;
    edge_aligned = '0;
  end

// APB Write Task
  task automatic apb_write(
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] data,
    input logic [STRB_WIDTH-1:0] strb = '1
  );
    @(posedge clk);

    psel    <= 1'b1;
    penable <= 1'b0;
    paddr   <= addr;
    pwrite  <= 1'b1;
    pwdata  <= data;
    pstrb   <= strb;

    @(posedge clk);
    penable <= 1'b1;

    do begin
      @(posedge clk);
    end while (!pready);

    mem_array[addr] = data;

    psel    <= 1'b0;
    penable <= 1'b0;
    pwrite  <= 1'b0;
    pstrb   <= '0;
  endtask

//APB Read Task
task automatic apb_read(
    input  logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] data
  );
    @(posedge clk);
    psel    <= 1'b1;
    penable <= 1'b0;
    paddr   <= addr;
    pwrite  <= 1'b0;
    pstrb   <= '0;

    @(posedge clk);
    penable <= 1'b1;

    do begin
      if (pready) data = prdata;
      @(posedge clk);
    end while (!pready);


  
    if (data !== mem_array[addr]) begin
      $display("[%0t] ERROR: Read data mismatch at address %h. Expected: %h, Got: %h", 
               $realtime, addr, mem_array[addr], data);
      fail_count++;
    end else begin
      if (DEBUG) begin
        $display("[%0t] PASS: Read from address %h successful. Data: %h", 
                 $realtime, addr, data);
      end
      pass_count++;
    end

    psel    <= 1'b0;
    penable <= 1'b0;

  endtask

  initial begin
    
    $timeformat(-9, 0, "ns");
    $dumpfile("khalid_apb_mem_tb.vcd");
    $dumpvars(0, khalid_apb_mem_tb);

    psel    = 0;
    penable = 0;
    paddr   = 0;
    pwrite  = 0;
    pwdata  = 0;
    pstrb   = 0;
    
    arst_n   = 0;
    #5ns;
    arst_n   = 1;
    #10ns;

    $display("--- Starting APB Memory Tests ---");


    $display("\nLaunching %0d Random Writes...", NUM_TESTS);
    repeat (NUM_TESTS) begin
      logic [ADDR_WIDTH-1:0] rand_addr;
      rand_addr = $urandom_range(0, 63) * 4; 
      
      used_addresses.push_back(rand_addr);
      apb_write(.addr(rand_addr), .data($urandom));
    end

    #1us;
    $display("--- APB Memory Simulation Complete ---");
    $finish;
  end

endmodule