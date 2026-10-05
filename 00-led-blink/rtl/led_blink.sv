module led_blink #(
    parameter COUNT = 100_000_000
)(
    input logic clk,
    input logic rst,

    output logic led
);

logic [26:0] counter; // Enough bits for 100 mill

always @(posedge clk) begin
    // Arty A7 reset is active LOW
    if (!rst) begin 
        led <= 0;
        counter <= '0;
    end
    else begin
        if (counter == COUNT - 1) begin
            counter <= '0;
            led <= !led;    // Toggle the LED after 100 million cycles
        end else begin
            counter <= counter + 1;
        end
    end

end





endmodule