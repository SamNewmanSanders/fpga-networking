module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 2048
)(

    // Clock domain signals and reset
    input logic wr_clk,
    input logic rd_clk,
    input logic rst,

    // Write signals
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic                  wr_en,
    output logic                  full, // Equivalent to !ready_in

    // Read signals
    output logic [DATA_WIDTH-1:0] data_out,
    input  logic                  rd_en,
    output logic                  empty
);

    localparam ADDR_WIDTH = $clog2(DEPTH);
    localparam PTR_WIDTH =  ADDR_WIDTH + 1;

    // Main buffer memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Buffer pointers
    logic [PTR_WIDTH-1:0] wr_ptr;
    logic [PTR_WIDTH-1:0] rd_ptr;
    // Grey pointers
    logic [PTR_WIDTH-1:0] wr_ptr_grey;
    logic [PTR_WIDTH-1:0] rd_ptr_grey;


    // -----------------------------------------------------------------------------

    // Pointers - also calculate the grey pointers using the known next value to save a cycle of latency

    // Write pointer (overflows, so DEPTH must be a power of 2! - also includes bit at start)
    wire [PTR_WIDTH-1:0] next_wr_ptr;
    assign next_wr_ptr = wr_ptr + 1;

    always @(posedge wr_clk) begin
        if (rst) begin
            wr_ptr <= '0;
            wr_ptr_grey <= '0;
        end
        else begin
            if (!full && wr_en) begin
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_in;
                wr_ptr <= next_wr_ptr;
                wr_ptr_grey <= ((next_wr_ptr ^ (next_wr_ptr >> 1)));
            end
        end
    end

    // Read pointer
    wire [PTR_WIDTH-1:0] next_rd_ptr;
    assign next_rd_ptr = rd_ptr + 1;

    always @(posedge rd_clk) begin
        if (rst) begin
            rd_ptr <= '0;
            rd_ptr_grey <= '0;
        end
        else begin
            if (!empty && rd_en) begin
                rd_ptr <= next_rd_ptr;
                rd_ptr_grey <= ((next_rd_ptr ^ (next_rd_ptr >> 1)));
                data_out <= mem[rd_ptr[ADDR_WIDTH-1:0]];
            end
        end
    end

    // ------------------------------------------------------------------------------

    // Sync write pointer to read domain
    reg [PTR_WIDTH-1:0] wr_ff_1;
    reg [PTR_WIDTH-1:0] wr_ff_2;

    always @(posedge rd_clk) begin
        if (rst) begin
            wr_ff_1 <= '0;
            wr_ff_2 <= '0;
        end
        else begin
            // Double flip flop synchroniser
            wr_ff_1 <= wr_ptr_grey;
            wr_ff_2 <= wr_ff_1;
        end
    end

    // Sync read pointer to write domain
    reg [PTR_WIDTH-1:0] rd_ff_1;
    reg [PTR_WIDTH-1:0] rd_ff_2;

    always @(posedge wr_clk) begin
        if (rst) begin
            rd_ff_1 <= '0;
            rd_ff_2 <= '0;
        end
        else begin
            // Double flip flop synchroniser
            rd_ff_1 <= rd_ptr_grey;
            rd_ff_2 <= rd_ff_1;
        end
    end

    // -----------------------------------------------------

    // We need to compare the synced read pointer to the write pointer (both grey) and vice versa

    assign empty = (wr_ff_2 == rd_ptr_grey); // All bits match
    assign full = (wr_ptr_grey == {~rd_ff_2[PTR_WIDTH-1:PTR_WIDTH-2], rd_ff_2[PTR_WIDTH-3:0]});

endmodule