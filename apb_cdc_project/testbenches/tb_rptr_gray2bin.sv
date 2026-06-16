module tb_rptr_gray2bin();
    logic [4:0] gray = 0;
    logic [4:0] bin;

    rptr_gray2bin #(.WIDTH(5)) dut (.gray(gray), .bin(bin));

    initial begin
        repeat (8) begin
            #5 gray = gray + 1;
            #1 $display("rgray=%b rbin=%0d", gray, bin);
        end
        $finish;
    end
endmodule
