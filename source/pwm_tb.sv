module pwm_tb;

localparam int NUM_PWM = 8;

logic clk_i = 0;
logic areset_ni = 0;

logic [$clog2(NUM_PWM)-1:0] addr_i;
logic [7:0] wr_data_i;
logic wr_en_i;

logic [7:0] rd_data_o;
logic [NUM_PWM-1:0] pwm_o;

// DUT
pwm #(.NUM_PWM(NUM_PWM)) modulator (
    .clk_i(clk_i),
    .areset_ni(areset_ni),
    .addr_i(addr_i),
    .wr_data_i(wr_data_i),
    .wr_en_i(wr_en_i),
    .rd_data_o(rd_data_o),
    .pwm_o(pwm_o)
);


always #10 clk_i = ~clk_i;

task automatic write_in_reg(
    input logic [$clog2(NUM_PWM)-1:0] addr,
    input logic [7:0] data
);
begin

    @(posedge clk_i);

    addr_i <= addr;
    wr_data_i <= data;
    wr_en_i   <= 1'b1;

    @(posedge clk_i);
    wr_en_i   <= 1'b0;
end
endtask

initial begin
    $dumpfile("pulse_width_modulator.vcd");
    $dumpvars(0, pwm_tb);

    addr_i = 0;
    wr_data_i = 0;
    wr_en_i   = 0;

    // reset
    areset_ni = 0;
    repeat (5) @(posedge clk_i);
    areset_ni = 1;

    // writes
    write_in_reg(3'h0, 8'h57);
    write_in_reg(3'h2, 8'hAB);
    write_in_reg(3'h5, 8'hFF);

    #10ms;

    $finish;
end

endmodule

