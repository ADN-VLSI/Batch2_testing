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

  initial begin

    $display("Simulation started for Khalid's testbench bin_to_gray...");
    
    repeat (10000) begin
      bin = $random;
      #10;

      if (gray === (bin ^ (bin >> 1))) $display("PASS: bin=%b, gray=%b", bin, gray);
      else $display("FAIL: bin=%b, gray=%b", bin, gray);
    end

    $display("Simulation finished successfully.");
    $finish;
  end

endmodule
