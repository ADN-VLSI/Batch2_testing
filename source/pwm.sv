module pwm # (
    parameter int NUM_PWM = 8
  ) (
    input  logic       clk_i,
    input  logic       areset_ni,

    input  logic [$clog2(NUM_PWM)-1:0] addr_i,
    input  logic [7:0]                 wr_data_i,
    input  logic                       wr_en_i,

    output logic [7:0] rd_data_o,

    output logic [NUM_PWM-1:0] pwm_o
  );
  logic [7:0] counter;
  logic [7:0] register [NUM_PWM];

  // 8 bit counter
  always_ff @(posedge clk_i or negedge areset_ni)
  begin
    if (!areset_ni)
      counter <= 8'd0;
    else
      counter <= counter + 1;
  end

  // register interface
  //  initialization

  always_ff @(posedge clk_i or negedge areset_ni)
  begin
    if (!areset_ni)
    begin
      foreach (register[a]) register[a] <= '0;
    end
    else if (wr_en_i)
    begin  //  Address wise access
      register[addr_i] <= wr_data_i;
    end
  end

  for (genvar i = 0; i < NUM_PWM; i++) begin : g_waves
    assign pwm_o[i] = (register[i] == 8'hFF) ? 1 : counter < register[i];
  end

  always_comb rd_data_o = register[addr_i];

  endmodule
