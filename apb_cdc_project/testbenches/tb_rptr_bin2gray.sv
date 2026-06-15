module tb_rptr_bin2gray();
    logic [4:0] bin = 0;
    logic [4:0] gray;

    rptr_bin2gray #(.WIDTH(5)) dut (.bin(bin), .gray(gray));

    initial begin
        repeat (8) begin
            #5 bin = bin + 1;
            #1 $display("rbin=%0d rgray=%b", bin, gray);
        end
        $finish;
    end
endmodule
