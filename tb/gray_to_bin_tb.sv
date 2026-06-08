module gray_to_bin_tb;

  parameter WIDTH = 8;

  logic [WIDTH-1:0] gray;
  logic [WIDTH-1:0] bin;

  gray_to_bin #(
      .WIDTH(WIDTH)
  ) dut (
      .gray(gray),
      .bin (bin)
  );

  // YOU CODE HERE

endmodule
