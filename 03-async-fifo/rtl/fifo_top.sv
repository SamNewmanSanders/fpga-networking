module fifo_top (
    input  logic       CLK100MHZ,

    // Switches to input 4-bit binary
    input  logic [3:0] switches,
    input  logic       btn_reset,

    // Buttons to read/write
    input  logic       btn_write,
    input  logic       btn_read,

    // Output leds for binary and status
    output logic [3:0] leds,
    output logic [2:0] rgb_led_n
);

    // 25 MHz clock domain signals
    logic clk_25mhz;
    logic clk_locked;

    // Clock domain logic as in 02-clock-domains
    clk_wiz_0 clk_wiz_inst (
        .clk_in1  (CLK100MHZ),
        .reset    (btn_reset),
        .clk_out1 (clk_25mhz),
        .locked   (clk_locked)
    );


    // The reset idea is ASYNC ASSERT, SYNC DEASSERT. Discussed more in README
    logic [1:0] reset_sync_100;
    logic [1:0] reset_sync_25;
    // Synced reset signals to feed into FIFO
    logic       reset_100;
    logic       reset_25;

    // Assert reset immediately from the button or when the generated clock
    // loses lock. Each domain releases reset only after two of its own clocks.
    logic  reset_request;
    assign reset_request = btn_reset || !clk_locked;

    always_ff @(posedge CLK100MHZ or posedge reset_request) begin
        if (reset_request)
            reset_sync_100 <= 2'b11;
        else
            reset_sync_100 <= {reset_sync_100[0], 1'b0};
    end

    always_ff @(posedge clk_25mhz or posedge reset_request) begin
        if (reset_request)
            reset_sync_25 <= 2'b11;
        else
            reset_sync_25 <= {reset_sync_25[0], 1'b0};
    end

    assign reset_100 = reset_sync_100[1];
    assign reset_25  = reset_sync_25[1];


    logic       write_button_debounced;
    logic       read_button_debounced;

    // Write button operates in the 100MHz domain
    button_debouncer write_button_debouncer_inst (
        .clk              (CLK100MHZ),
        .rst              (reset_100),
        .button           (btn_write),
        .debounced_button (write_button_debounced)
    );

    // Read button operates in its own 25MHz domain
    button_debouncer read_button_debouncer_inst (
        .clk              (clk_25mhz),
        .rst              (reset_25),
        .button           (btn_read),
        .debounced_button (read_button_debounced)
    );

    logic write_button_prev;
    wire write_button_edge = write_button_debounced && !write_button_prev;

    always_ff @(posedge CLK100MHZ) begin
        if (reset_100) begin
            write_button_prev <= 1'b0;
        end else begin
            write_button_prev <= write_button_debounced;
        end
    end

    logic read_button_prev;
    wire  read_button_edge = read_button_debounced && !read_button_prev;

    always_ff @(posedge clk_25mhz) begin
        if (reset_25) begin
            read_button_prev <= 1'b0;
        end else begin
            read_button_prev <= read_button_debounced;
        end
    end

    logic [3:0] fifo_data_out;
    logic       fifo_full;
    logic       fifo_empty;
    logic       fifo_wr_en;
    logic       fifo_rd_en;

    // Condsider the backpressure signals:
    // Can't write when full, can't read when empty
    assign fifo_wr_en = write_button_edge && !fifo_full;
    assign fifo_rd_en = read_button_edge && !fifo_empty;

    async_fifo #(
        .DATA_WIDTH(4),
        .DEPTH(8)
    ) fifo_inst (
        .wr_clk  (CLK100MHZ),
        .rd_clk  (clk_25mhz),
        .wr_rst  (reset_100),
        .rd_rst  (reset_25),
        .data_in (switches),
        .wr_en   (fifo_wr_en),
        .full    (fifo_full),
        .data_out(fifo_data_out),
        .rd_en   (fifo_rd_en),
        .empty   (fifo_empty)
    );

    logic read_pending;

    always_ff @(posedge clk_25mhz) begin
        if (reset_25) begin
            read_pending <= 1'b0;
            leds         <= '0;
        end else begin
            read_pending <= fifo_rd_en;
            if (read_pending)
                leds <= fifo_data_out;
        end
    end

    // RGB status is an output-only indication, so combine the FIFO flags
    // directly rather than synchronizing them into either clock domain.
    // The vector is {red, green, blue}; the Arty A7 RGB LED is active-low,
    // so a bit at 0 turns that color on and 1 leaves it off.
    always_comb begin
        rgb_led_n = 3'b111; // All colors off by default.
        if (fifo_empty)
            rgb_led_n[2] = 1'b0; // Red on when empty.
        else if (fifo_full)
            rgb_led_n[1] = 1'b0; // Green on when full.
        else
            rgb_led_n[0] = 1'b0; // Blue on when neither empty nor full.
    end

endmodule
