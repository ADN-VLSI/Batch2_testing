module tb_rr_arb_sabbir;

    parameter int N = 4;

    logic         clk;
    logic         reset;
    logic [N-1:0] req;
    logic [N-1:0] grant;

    logic [$clog2(N)-1:0] exp_ptr;
    logic [N-1:0]         exp_grant;

    int error_count;

    rr_arb_sabbir #(.N(N)) dut (
        .clk   (clk),
        .reset (reset),
        .req   (req),
        .grant (grant)
    );

    // Clock generation
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Calculate expected grant from current expected pointer
    task automatic calc_expected_grant;
        int i;
        int idx;
        begin
            exp_grant = '0;

            for (i = 0; i < N; i++) begin
                idx = (exp_ptr + i) % N;

                if (req[idx]) begin
                    exp_grant[idx] = 1'b1;
                    break;
                end
            end
        end
    endtask

    // Check combinational grant before clock edge
    task automatic check_grant;
        begin
            calc_expected_grant();

            #1; // combinational settle time

            if (grant !== exp_grant) begin
                $error("FAIL @%0t : ptr=%0d req=%b expected=%b got=%b",
                       $time, exp_ptr, req, exp_grant, grant);
                error_count++;
            end
            else begin
                $display("PASS @%0t : ptr=%0d req=%b grant=%b",
                         $time, exp_ptr, req, grant);
            end
        end
    endtask

    // Update expected pointer after a successful clock edge
    task automatic update_expected_ptr;
        int i;
        begin
            for (i = 0; i < N; i++) begin
                if (exp_grant[i]) begin
                    exp_ptr = (i + 1) % N;
                end
            end
        end
    endtask
    task automatic run_cycle;
        begin
            check_grant();
            @(posedge clk);
            update_expected_ptr();
        end
    endtask

    initial begin
        $dumpfile("tb_rr_arb_sabbir.vcd");
        $dumpvars(0, tb_rr_arb_sabbir);
    end

    initial begin
        error_count = 0;

        reset   = 1'b1;
        req     = '0;
        exp_ptr = '0;

        repeat (2) @(posedge clk);

        reset = 1'b0;

        // Give time for combinational output after reset release
        #1;

        req = 4'b1111;
        repeat (8) begin
            run_cycle();
        end

        req = 4'b1010;
        repeat (8) begin
            run_cycle();
        end

        req = 4'b0100;
        repeat (4) begin
            run_cycle();
        end

        req = 4'b0000;
        repeat (4) begin
            run_cycle();
        end

        repeat (20) begin
            req = $urandom_range(0, 15);
            run_cycle();
        end

        if (error_count == 0) begin
            $display("TEST PASSED");
        end
        else begin
            $display("TEST FAILED: %0d errors found", error_count);
        end

        $finish;
    end

endmodule