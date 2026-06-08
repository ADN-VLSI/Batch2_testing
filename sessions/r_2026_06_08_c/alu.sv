// ALU module
// OPC - Defination
// 00  - ADD
// 01  - SUB
// 10  - AND
// 11  - OR

module alu #(
    parameter WIDTH = 32
) (
    input  logic [WIDTH-1:0] in_a,
    input  logic [WIDTH-1:0] in_b,
    input  logic [      1:0] opc,
    output logic [WIDTH-1:0] out_c
);

  always_comb begin
    case (opc)
      2'b00: out_c = in_a + in_b;  // ADD
      2'b01: out_c = in_a - in_b;  // SUB
      2'b10: out_c = in_a & in_b;  // AND
      2'b11: out_c = in_a | in_b;  // OR
    endcase
  end

endmodule
