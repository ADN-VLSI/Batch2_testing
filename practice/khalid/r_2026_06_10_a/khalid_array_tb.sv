module khalid_array_tb;

    logic [3:0][7:0] tb_packed_in;
    logic [3:0][7:0] tb_packed_out;


    logic [7:0] tb_unpacked_in [3:0];
    logic [7:0] tb_unpacked_out [3:0];


    khalid_array dut (
        .data_in   (tb_packed_in),
        .data_out  (tb_packed_out),
        .data_in2  (tb_unpacked_in),
        .data_out2 (tb_unpacked_out)
    );

    initial begin

        $display("\n==================================================");
        $display("   STARTING SYSTEMVERILOG ARRAY MATRIX CHECK      ");
        $display("==================================================");

        tb_packed_in = 32'hDE_AD_BE_EF;
        #10;
        $display("[PACKED]   Driven Input: 0x%h", tb_packed_in);
        $display("[PACKED]   Output Slice [3] (MSB): 0x%h (Expected: DE)", tb_packed_out[3]);
        $display("[PACKED]   Output Slice [0] (LSB): 0x%h (Expected: EF)", tb_packed_out[0]);

        tb_unpacked_in = '{8'h11, 8'h22, 8'h33, 8'h44};
        #10;
        $display("\n[UNPACKED] Driven Structure: '{11, 22, 33, 44}");
        $display("[UNPACKED] Output Element [3]:   0x%h (Expected: 11)", tb_unpacked_out[3]);
        $display("[UNPACKED] Output Element [0]:   0x%h (Expected: 44)", tb_unpacked_out[0]);
        
        $display("==================================================\n");
        $finish;
    end

endmodule