module bin_to_gray_tb;

  parameter WIDTH = 8;

  logic [WIDTH-1:0] bin;
  logic [WIDTH-1:0] gray;

  bin_to_gray #(
      .WIDTH(WIDTH)
  ) dut (
      .bin (bin),
      .gray(gray)
  );

  // YOU CODE HERE

endmodule
