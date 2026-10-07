module button_debouncer #(
        parameter DEBOUNCE_CYCLES = 500_000 // 5ms at 100MHz
    )(

    input   logic clk,
    input   logic rst,

    input   logic button,
    output  logic debounced_button
);

// Two flop synchroniser for async button input
logic button_sync_1, button_sync_2;

// Don't have to consider small number edge cases as would be pointless
localparam counter_bits = $clog2(DEBOUNCE_CYCLES); 
// Counter for consecutive cycles
logic [counter_bits - 1: 0] counter;

// Keep track of previous value
logic prev_value;

// Synchroniser
always @(posedge clk) begin
    if (rst) begin
        button_sync_1 <= 1'b0;
        button_sync_2 <= 1'b0;
    end else begin
        button_sync_1 <= button;
        button_sync_2 <= button_sync_1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        debounced_button <= '0;
        counter <= '0;
        prev_value <= '0;
    end
    else begin

        // Reset if bounce detected
        if (button_sync_2 != prev_value) begin
            counter <= '0;
        end
        else begin
            if (counter == DEBOUNCE_CYCLES - 1) begin
                debounced_button <= button_sync_2;
            end
            else begin
                counter <= counter + 1;
            end
        end

        prev_value <= button_sync_2;
    end
end

endmodule