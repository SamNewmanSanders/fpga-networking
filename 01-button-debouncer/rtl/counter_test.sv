module counter_test (
    input  logic       clk,
    input  logic       rst,
    input  logic       button,
    output logic [3:0] leds
);

    // Declare the debouncer output logic
    logic debounced_button;
    // Also need to store prev
    logic button_prev;

    button_debouncer button_debouncer_inst (
        .clk(clk),
        .rst(rst),
        .button(button),
        .debounced_button(debounced_button)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            button_prev   <= 1'b0;
            leds          <= 4'b0000;
        end else begin
            button_prev <= debounced_button;

            if (debounced_button && !button_prev)
                leds <= leds + 1'b1;
        end
    end

endmodule