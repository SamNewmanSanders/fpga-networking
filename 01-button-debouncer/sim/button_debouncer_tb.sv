`timescale 1ns/1ps

module button_debouncer_tb ();

    logic clk;
    logic rst;
    logic button;
    logic debounced_button;

    button_debouncer #(
        .DEBOUNCE_CYCLES(100) // Override so the sim doesn't run forever
    ) dut (
        .clk(clk),
        .rst(rst),
        .button(button),
        .debounced_button(debounced_button)
    );

    // 100 MHz clock: 10 ns per cycle.
    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        button = 1'b0;

        repeat (2) @(negedge clk);
        rst = 1'b0;

        // A short pulse should not pass the 100-cycle debounce interval.
        button = 1'b1;
        repeat (20) @(negedge clk);
        button = 1'b0;
        repeat (20) @(negedge clk);
        assert (debounced_button == 1'b0)
            else $error("FAIL: short press bounce changed output to %b", debounced_button);

        // A stable press should be accepted.
        button = 1'b1;
        repeat (110) @(negedge clk);
        assert (debounced_button == 1'b1)
            else $error("FAIL: stable press not accepted; output is %b", debounced_button);

        // A short release bounce should not clear the debounced output.
        button = 1'b0;
        repeat (20) @(negedge clk);
        assert (debounced_button == 1'b1)
            else $error("FAIL: short release bounce changed output to %b", debounced_button);

        // A stable release should be accepted.
        repeat (110) @(negedge clk);
        assert (debounced_button == 1'b0)
            else $error("FAIL: stable release not accepted; output is %b", debounced_button);

        $display("PASS: button debouncer tests completed");
        $finish;
    end
endmodule