module fifo #(
    parameter int ELEM_WIDTH = 8,
    parameter int FIFO_SIZE = 4,
    parameter bit PIPELINED = 1

) (
    input logic                     clk_i,
    input logic                     arst_ni,

    input logic [ELEM_WIDTH-1:0]    elem_in_i,
    input logic                     elem_in_valid_i,
    output logic                    elem_in_ready_o,

    output logic [ELEM_WIDTH-1:0]   elem_out_o,
    input logic                     elem_out_ready_i,
    output logic                    elem_out_valid_o,

    output logic                    elem_cnt_o

);


endmodule
