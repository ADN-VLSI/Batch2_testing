module apb_mem_tb;

  localparam int ADDR_WIDTH = 8;
  localparam int DATA_WIDTH = 32;

  logic clk_i = 0;
  logic arst_ni;

  logic psel_i;
  logic penable_i;
  logic pwrite_i;
  logic [ADDR_WIDTH-1:0] paddr_i;
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
    .arst_ni(arst_ni),
    .clk_i(clk_i),
    .psel_i(psel_i),
    .penable_i(penable_i),
    .paddr_i(paddr_i),
    .pwrite_i(pwrite_i),
    .pwdata_i(pwdata_i),
    .pstrb_i(pstrb_i),
    .pready_o(pready_o),
    .prdata_o(prdata_o),
    .pslverr_o(pslverr_o)
  );

  // clock
  always #5 clk_i = ~clk_i;

  // reset
  initial begin
    arst_ni = 0;
    psel_i = 0;
    penable_i = 0;
    pwrite_i = 0;
    paddr_i = 0;
    pwdata_i = 0;
    pstrb_i = '1;


  // ---------------- WRITE TASK ----------------
  task apb_write(input [ADDR_WIDTH-1:0] addr,
                 input [DATA_WIDTH-1:0] data);

    @(posedge clk_i);

    // SETUP phase
    psel_i   = 1;
    penable_i = 0;
    pwrite_i = 1;
    paddr_i  = addr;
    pwdata_i = data;
    pstrb_i  = '1;

    @(posedge clk_i);

    // ACCESS phase
    penable_i = 1;

    wait(pready_o == 1);

    @(posedge clk_i);

    // finish transaction
    psel_i = 0;
    penable_i = 0;


  foreach (i) begin
  if (pstrb_i[i])
    mem_model[address][8*i +: 8] = pwdata_i[8*i +: 8];
end
  endtask