module tb_top();
    // top-level smoke test: instantiate top from project
    logic clk_master = 0; logic clk_slave = 0; logic rst_n = 0;

    initial begin
        clk_master = 0; clk_slave = 0; rst_n = 0; #10; rst_n = 1; #10;
    end
    initial forever #5 clk_master = ~clk_master;
    initial forever #7 clk_slave = ~clk_slave;

    // instantiate top
    top uut();

    initial begin
        #600; $display("tb_top finished"); $finish;
    end
endmodule
