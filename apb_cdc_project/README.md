# APB Master to APB Slave CDC FIFO Project

This project demonstrates an APB master communicating with an APB slave through a CDC bridge using two asynchronous FIFOs:

- Request FIFO: transfers APB request packets from the master clock domain to the slave clock domain.
- Response FIFO: returns APB responses back from the slave clock domain to the master clock domain.

## Files

- `apb_master.sv`: simple request generator with one APB write followed by one read.
- `apb_cdc_bridge.sv`: CDC bridge with request and response FIFOs.
- `apb_slave_mem.sv`: APB slave memory peripheral.
- `async_fifo_top.sv`: asynchronous FIFO wrapper with binary/gray pointer synchronization.
- `fifo_mem_2port.sv`: dual-clock memory array for asynchronous FIFO storage.
- `wptr_bin2gray.sv`: write pointer binary-to-gray converter.
- `wptr_gray2bin.sv`: write pointer gray-to-binary converter.
- `rptr_bin2gray.sv`: read pointer binary-to-gray converter.
- `rptr_gray2bin.sv`: read pointer gray-to-binary converter.
- `sync_wptr_to_rd.sv`: synchronizes write pointer into read clock domain.
- `sync_rptr_to_wr.sv`: synchronizes read pointer into write clock domain.
- `top.sv`: testbench and top-level integration.

## How to run

Use your preferred SystemVerilog simulator to run `top.sv` along with the other source files.
