module khalid_interrupt_controller_tb;

    localparam int ADDR_WIDTH = 3;
    localparam int DATA_WIDTH = 8;

    logic clk_i;
    logic arst_ni;
    logic [ADDR_WIDTH-1:0] addr_i;
    logic [DATA_WIDTH-1:0] wdata_i;
    logic we_i;
    logic [DATA_WIDTH-1:0] rdata_o;
    logic [7:0] ci;
    logic [2:0] core0_id;
    logic core0_valid;
    logic [2:0] core1_id;
    logic core1_valid;

    khalid_interrupt_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut_int_cont (
        .clk_i(clk_i),
        .arst_ni(arst_ni),
        .addr_i(addr_i),
        .wdata_i(wdata_i),
        .we_i(we_i),
        .rdata_o(rdata_o),
        .ci(ci),
        .core0_id(core0_id),
        .core0_valid(core0_valid),
        .core1_id(core1_id),
        .core1_valid(core1_valid)
    );

    // Clock
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end

    initial begin

    $dumpfile("dump.vcd");
    $dumpvars(0, khalid_interrupt_controller_tb);


    //Initail

    arst_ni = 0;
    addr_i  = 0;
    wdata_i = 0;
    we_i    = 0;
    ci      = 0;

    #10;  
    arst_ni = 1;
    #10;

    //Write


    @(posedge clk_i);
        we_i    = 1;
        addr_i  = 3'h0;
        wdata_i = 8'b0000_1100;
        
    @(posedge clk_i);
        we_i    = 1;
        addr_i  = 3'h4;
        wdata_i = 8'b0101_0101;

    @(posedge clk_i);
        we_i = 0; 


    //Read


    $display("Simulation Beign!");    


    @(posedge clk_i);
        addr_i = 3'h0;
    @(posedge clk_i);
        $display("Time %0t: Read Core 0 Data = %b", $time, rdata_o);
        
        addr_i = 3'h4;
    @(posedge clk_i);
        $display("Time %0t: Read Core 1 Data = %b", $time, rdata_o);


    //Interrupts

    $display("\n Testing Interrupts Begins");


        // Test 1:
        #10;
        ci = 8'b0000_0100;
        #1;
        $display("Interrupt 2 Fired. Core 0: Valid=%b ID=%d | Core 1: Valid=%b ID=%d", 
                 core0_valid, core0_id, core1_valid, core1_id);

        // Test 2:
        #10;
        ci = 8'b0000_1000;
        #1;
        $display("Interrupt 3 Fired. Core 0: Valid=%b ID=%d | Core 1: Valid=%b ID=%d", 
                 core0_valid, core0_id, core1_valid, core1_id);

        // Test 3: 
        #10;
        ci = 8'b0100_0100;
        #1;
        $display("Interrupt 6 & 2 Fired. Core 0: Valid=%b ID=%d | Core 1: Valid=%b ID=%d", 
                 core0_valid, core0_id, core1_valid, core1_id);
        #20;
        $display("Simulation Finished!");
        $finish;

    end    


endmodule