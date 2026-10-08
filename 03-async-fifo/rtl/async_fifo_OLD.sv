module async_fifo #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH = 32
  )(

  input wire wr_clk,
  input wire rd_clk,
  input wire rst,

  // Write signals
  input wire [DATA_WIDTH-1:0] 	data_in,
  input wire 					wr_en,
  output wire 					full,	// Equivalent to !ready_in

  // Read signals
  output wire [DATA_WIDTH-1:0]	data_out,
  input wire 					rd_en,
  output wire 					empty
);

  localparam ADDR_WIDTH = $clog2(DEPTH);
  localparam PTR_WIDTH  = ADDR_WIDTH + 1;

  // Main buffer memory
  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Buffer pointers
  reg [PTR_WIDTH-1:0] wr_ptr;
  reg [PTR_WIDTH-1:0] rd_ptr;
  // Grey pointers
  reg [PTR_WIDTH-1:0] wr_ptr_grey;
  reg [PTR_WIDTH-1:0] rd_ptr_grey;


  // Data output (async) - make sure you only use the relevant lower bits
  assign data_out = mem[rd_ptr[ADDR_WIDTH-1:0]];

  // -----------------------------------------------------------------------------

  // Pointers - also calculate the grey pointers using the known next value to save a cycle of latency

  // Write pointer
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
        wr_ptr_grey <= ((next_wr_ptr  ^ (next_wr_ptr >> 1)));
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
        rd_ptr_grey <= ((next_rd_ptr  ^ (next_rd_ptr >> 1)));
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

/*
Lets think about the design. We want to write to the buffer when write enable, and when it is NOT full. (Basically a valid / ready handshake). Once we write, we increment the write pointer.

The full output wire can maybe be combinationally assigned. Full should be true if the read and write pointers are identical, including the top bit, where as read is true if only the top bit is different



TODO:
 - Update full
*/