`ifndef __GUARD_APB_TYPEDEF_SVH__
`define __GUARD_APB_TYPEDEF_SVH__ 0

`define APB_REQ_T(__NM__, __AW__, __DW__)          \
  typedef struct packed {                          \
    logic                    psel;                 \
    logic                    penable;              \
    logic [  ``__AW__``-1:0] paddr;                \
    logic [             2:0] prot;                 \
    logic                    pwrite;               \
    logic [  ``__DW__``-1:0] pwdata;               \
    logic [``__DW__``/8-1:0] pstrb;                \
  } ``__NM__``_req_t;                              \


`define APB_RESP_T(__NM__, __DW__)                 \
  typedef struct packed {                          \
    logic                    pready;               \
    logic [  ``__DW__``-1:0] prdata;               \
    logic                    pslverr;              \
  } ``__NM__``_resp_t;                             \


`define APB_PORT_T(__NM__, __AW__, __DW__)         \
  `APB_REQ_T(``__NM__``, ``__AW__``, ``__DW__``)   \
  `APB_RESP_T(``__NM__``, ``__DW__``)              \


`endif
