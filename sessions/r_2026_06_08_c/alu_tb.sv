module alu_tb;

  parameter int WIDTH = 16;

  logic [WIDTH-1:0] in_a;
  logic [WIDTH-1:0] in_b;
  logic [      1:0] opc;
  logic [WIDTH-1:0] out_c;

  alu #(
      .WIDTH(WIDTH)
  ) alu_inst (
      .in_a (in_a),
      .in_b (in_b),
      .opc  (opc),
      .out_c(out_c)
  );

  initial begin
    // $dumpfile("alu_tb.vcd");
    // $dumpvars(0, alu_tb);

    repeat (10000) begin
      in_a = $random;
      in_b = $random;
      opc  = $random;
      #10;

      casex(opc)
        2'b00: if (((in_a + in_b) & 'hffff) === out_c) $display("ADD PASS: %h + %h = %h", in_a, in_b, out_c); else $display("ADD FAIL: %h + %h != %h", in_a, in_b, out_c);
        2'b01: if (((in_a - in_b) & 'hffff) === out_c) $display("SUB PASS: %h - %h = %h", in_a, in_b, out_c); else $display("SUB FAIL: %h - %h != %h", in_a, in_b, out_c);
        2'b10: if (((in_a & in_b) & 'hffff) === out_c) $display("AND PASS: %h & %h = %h", in_a, in_b, out_c); else $display("AND FAIL: %h & %h != %h", in_a, in_b, out_c);
        2'b11: if (((in_a | in_b) & 'hffff) === out_c) $display("OR PASS: %h | %h = %h", in_a, in_b, out_c); else $display("OR FAIL: %h | %h != %h", in_a, in_b, out_c);
        default: $display("Invalid OPC: %b", opc);
      endcase

    end

    in_a = 16'h0000;
    in_b = 16'h0000;
    opc  = 2'b00;

    $finish;
  end

endmodule
