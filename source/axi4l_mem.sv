// Module: axi4l_mem
//
// Description:
//   AXI4-Lite slave memory peripheral. Each AXI-Lite channel (AW, W, B, AR, R)
//   is decoupled from the internal logic via a small FIFO, providing registered
//   outputs on every port and isolating the master from back-pressure. An
//   axi4l_mem_ctrlr instance arbitrates read/write requests and drives a
//   dual_port_mem instance that holds the actual data.
//
// Parameters:
//   ADDR_WIDTH - Width of the AXI address bus (default: 32)
//   DATA_WIDTH - Width of the AXI data bus; must be a multiple of 8 (default: 32)

`include "package/defaults_pkg.sv"

module axi4l_mem #(
    parameter type axi4l_req_t  = defaults_pkg::axi4l_req_t,
    parameter type axi4l_resp_t = defaults_pkg::axi4l_resp_t,
    parameter int  ADDR_WIDTH   = 32,
    parameter int  DATA_WIDTH   = 64
) (

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // GLOBAL SIGNALS
    ////////////////////////////////////////////////////////////////////////////////////////////////

    input logic arst_ni,
    input logic clk_i,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXIL SIGNALS
    ////////////////////////////////////////////////////////////////////////////////////////////////

    input  axi4l_req_t  axi4l_req_i,
    output axi4l_resp_t axi4l_resp_o

);

  `include "axi/typedef.svh"

  `AXI_LITE_TYPEDEF_ALL(axil, logic[ADDR_WIDTH-1:0], logic[DATA_WIDTH-1:0], logic[DATA_WIDTH/8-1:0])

  localparam int AXSIZE = $clog2(DATA_WIDTH / 8);

  logic [7:0] mem[2][longint];

  axil_aw_chan_t aw_q[$];
  axil_w_chan_t w_q[$];
  axil_b_chan_t b_q[$];
  axil_ar_chan_t ar_q[$];
  axil_r_chan_t r_q[$];

  always @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      aw_q.delete();
      w_q.delete();
      b_q.delete();
      ar_q.delete();
      r_q.delete();
    end else begin
      if (axi4l_req_i.aw_valid) begin
        aw_q.push_back(axi4l_req_i.aw);
      end
      if (axi4l_req_i.w_valid) begin
        w_q.push_back(axi4l_req_i.w);
      end
      if (axi4l_req_i.b_ready) begin
        b_q.delete(0);
      end
      if (axi4l_req_i.ar_valid) begin
        ar_q.push_back(axi4l_req_i.ar);
      end
      if (axi4l_req_i.r_ready) begin
        r_q.delete(0);
      end
      if (aw_q.size() && w_q.size()) begin
        bit [  ADDR_WIDTH-1:0]      addr;
        bit [DATA_WIDTH/8-1:0][7:0] data;
        bit [DATA_WIDTH/8-1:0]      strb;
        addr = aw_q[0].addr;
        data = w_q[0].data;
        strb = w_q[0].strb;
        for (int i = 0; i < AXSIZE; i++) addr[i] = 0;
        foreach (strb[i]) if (strb[i]) mem[aw_q[0].prot[1]][addr+i] = data[i];
        aw_q.delete(0);
        w_q.delete(0);
        b_q.push_back('0);
      end
      if (ar_q.size()) begin
        bit [  ADDR_WIDTH-1:0]      addr;
        bit [DATA_WIDTH/8-1:0][7:0] data;
        addr = ar_q[0].addr;
        for (int i = 0; i < AXSIZE; i++) addr[i] = 0;
        for (int i = 0; i < DATA_WIDTH / 8; i++) data[i] = mem[ar_q[0].prot[1]][addr+i];
        r_q.push_back({data, 2'b00});
        ar_q.delete(0);
      end
    end
    axi4l_resp_o.aw_ready <= arst_ni;
    axi4l_resp_o.w_ready  <= arst_ni;
    axi4l_resp_o.b        <= b_q.size() ? b_q[0] : '0;
    axi4l_resp_o.b_valid  <= b_q.size() ? '1 : '0;
    axi4l_resp_o.ar_ready <= arst_ni;
    axi4l_resp_o.r        <= r_q.size() ? r_q[0] : '0;
    axi4l_resp_o.r_valid  <= r_q.size() ? '1 : '0;
  end

endmodule
