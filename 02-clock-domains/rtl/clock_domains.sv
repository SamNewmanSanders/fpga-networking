module clock_domains (
    // Default 100MHz input clock
    input  logic CLK100MHZ,
    input  logic rst,

    // Two, 2 bit counters
    output logic [1:0] led1,
    output logic [1:0] led2,

    // Output the 25MHz clock to also check PHY connection
    output logic eth_ref_clk
);

    // Generated clock
    logic clk_25mhz;
    // High when the Clocking Wizard's generated clock is stable and usable.
    logic clk_locked;

    // Vivado Clocking Wizard IP converts the board's 100 MHz clock to 25 MHz.
    // Create/configure it in the IP Catalog; `clk_locked` indicates a stable output.
    clk_wiz_0 clk_wiz_inst (
        .clk_in1  (CLK100MHZ),
        .reset    (rst),
        .clk_out1 (clk_25mhz),
        .locked   (clk_locked)
    );

    // Use say 100 mill cycles for an increment in both clock domains
    localparam logic [26:0] CYCLES_PER_LED_INCREMENT = 27'd100_000_000;
    logic [26:0] counter_100mhz;
    logic [26:0] counter_25mhz;

    // 100 MHz board clock
    always_ff @(posedge CLK100MHZ) begin
        if (rst || !clk_locked) begin
            counter_100mhz <= '0;
            led1           <= '0;
        end else if (counter_100mhz == CYCLES_PER_LED_INCREMENT - 1'b1) begin
            counter_100mhz <= '0;
            led1           <= led1 + 1'b1;
        end else begin
            counter_100mhz <= counter_100mhz + 1'b1;
        end
    end

    // 25 MHz clock
    always_ff @(posedge clk_25mhz) begin
        if (rst || !clk_locked) begin
            counter_25mhz <= '0;
            led2          <= '0;
        end else if (counter_25mhz == CYCLES_PER_LED_INCREMENT - 1'b1) begin
            counter_25mhz <= '0;
            led2          <= led2 + 1'b1;
        end else begin
            counter_25mhz <= counter_25mhz + 1'b1;
        end
    end

    // Send the 25 MHz clock to the Ethernet PHY
    assign eth_ref_clk = clk_25mhz;

endmodule