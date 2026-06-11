interface apb_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
) (
    // Global signals
    input logic arst_ni,  // Asynchronous reset, active low
    input logic clk_i  // Clock input
);

  logic                        psel;  // Peripheral select
  logic                        penable;  // Peripheral enable
  logic [      ADDR_WIDTH-1:0] paddr;  // Peripheral address
  logic                        pwrite;  // Peripheral write enable
  logic [      DATA_WIDTH-1:0] pwdata;  // Peripheral write data
  logic [(DATA_WIDTH / 8)-1:0] pstrb;  // Peripheral byte strobe
  logic                        pready;  // Peripheral ready
  logic [      DATA_WIDTH-1:0] prdata;  // Peripheral read data
  logic                        pslverr;  // Peripheral slave error

  bit                          edge_aligned;

  always @(posedge clk_i) begin
    edge_aligned = '1;
    #1ps;
    edge_aligned = '0;
  end

  task automatic master_reset();
    psel    <= '0;
    penable <= '0;
    paddr   <= '0;
    pwrite  <= '0;
    pwdata  <= '0;
    pstrb   <= '0;
  endtask

  // APB Write Task
  task automatic master_write(input logic [ADDR_WIDTH-1:0] addr, input logic [DATA_WIDTH-1:0] data,
                              input logic [DATA_WIDTH/8-1:0] strb = '1, output logic slverr);

    wait (edge_aligned);
    psel    <= 1'b1;
    penable <= 1'b0;
    paddr   <= addr;
    pwrite  <= 1'b1;
    pwdata  <= data;
    pstrb   <= strb;

    @(posedge clk_i);
    penable <= 1'b1;

    do begin
      @(posedge clk_i);
    end while (!pready);

    slverr = pslverr;

    psel <= 1'b0;

  endtask

  //APB Read Task
  task automatic master_read(input logic [ADDR_WIDTH-1:0] addr, output logic [DATA_WIDTH-1:0] data,
                             output logic slverr);

    wait (edge_aligned);
    psel    <= 1'b1;
    penable <= 1'b0;
    paddr   <= addr;
    pwrite  <= 1'b0;

    @(posedge clk_i);
    penable <= 1'b1;

    do begin
      @(posedge clk_i);
    end while (!pready);

    data   = prdata;
    slverr = pslverr;

    psel <= 1'b0;

  endtask

  task automatic monitor_tx(output logic [ADDR_WIDTH-1:0] addr, output logic write,
                            output logic [DATA_WIDTH-1:0] wdata,
                            output logic [DATA_WIDTH/8-1:0] strb,
                            output logic [DATA_WIDTH-1:0] rdata, output logic slverr);
    bit setup_done;
    setup_done = 0;
    while (1) begin
      @(posedge clk_i);
      if (psel && !penable) begin
        setup_done = 1;  // Address phase
      end else if (setup_done == 1) begin
        if (psel && penable && pready) begin
          addr   = paddr;
          write  = pwrite;
          wdata  = pwdata;
          strb   = pstrb;
          rdata  = prdata;
          slverr = pslverr;
          break;
        end
      end
    end
  endtask

endinterface
