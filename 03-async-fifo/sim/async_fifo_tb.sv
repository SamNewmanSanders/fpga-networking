`timescale 1ns/1ps

module async_fifo_tb;

    localparam DATA_WIDTH = 4;
    localparam DEPTH      = 4;

    reg wr_clk;
    reg rd_clk;
    reg rst;

    reg [DATA_WIDTH-1:0] data_in;
    reg                  wr_en;
    wire                 full;

    wire [DATA_WIDTH-1:0] data_out;
    reg                   rd_en;
    wire                  empty;

    integer write_count;
    integer read_count;
    integer error_count;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .wr_rst(rst),
        .rd_rst(rst),

        .data_in(data_in),
        .wr_en(wr_en),
        .full(full),

        .data_out(data_out),
        .rd_en(rd_en),
        .empty(empty)
    );
  
    initial begin
      $dumpfile("waveform.vcd");
      $dumpvars(0, async_fifo_tb);
  	end

    // ------------------------------------------------------------
    // Clocks
    // ------------------------------------------------------------

    initial begin
        wr_clk = 0;
        forever #5 wr_clk = ~wr_clk;
    end

    initial begin
        rd_clk = 0;
        forever #7 rd_clk = ~rd_clk;
    end

    // ------------------------------------------------------------
    // Queue for verification
    // ------------------------------------------------------------

    reg [DATA_WIDTH-1:0] expected_queue[$];

    // ------------------------------------------------------------
    // Reset
    // ------------------------------------------------------------

    initial begin
        rst = 1;

        #50;

        rst = 0;
    end

    // ------------------------------------------------------------
    // Continually drive random write requests
    // ------------------------------------------------------------

    initial begin
        wr_en   = 0;
        data_in = 0;

        forever begin
            @(negedge wr_clk);

          if ($urandom_range(0,99) < 20) begin
                data_in = $urandom;
                wr_en   = 1;
            end
            else begin
                wr_en   = 0;
            end
        end
    end

    // ------------------------------------------------------------
    // Continually request reads from the FIFO
    // ------------------------------------------------------------

    initial begin
        rd_en = 0;

        forever begin
            @(negedge rd_clk);

          if ($urandom_range(0,99) < 50)
                rd_en = 1;
            else
                rd_en = 0;
        end
    end

    // ------------------------------------------------------------
    // Add accepted writes to verification queue
    // ------------------------------------------------------------

    always @(posedge wr_clk) begin

        if (rst) begin
            expected_queue = {};
        end

        else if (wr_en && !full) begin
            expected_queue.push_back(data_in);
            write_count = write_count + 1;
        end
    end

    // ------------------------------------------------------------
    // Check accepted reads
    // ------------------------------------------------------------

    always @(posedge rd_clk) begin

        if (!rst && rd_en && !empty) begin

            if (expected_queue.size() == 0) begin
                $display("ERROR @ %0t: DUT performed a read but reference queue is empty",
                         $time);

                error_count = error_count + 1;
            end

            else begin

                if (data_out !== expected_queue[0]) begin

                    $display("ERROR @ %0t: expected %0d, got %0d",
                             $time,
                             expected_queue[0],
                             data_out);

                    error_count = error_count + 1;
                end

                expected_queue.pop_front();
                read_count = read_count + 1;
            end
        end
    end

    // ------------------------------------------------------------
    // End simulation
    // ------------------------------------------------------------

    initial begin

        write_count = 0;
        read_count  = 0;
        error_count = 0;

        #10000;

        $display("");
        $display("========================================");
        $display("Simulation complete");
        $display("Accepted writes : %0d", write_count);
        $display("Accepted reads  : %0d", read_count);
        $display("Queue size      : %0d", expected_queue.size());
        $display("Errors          : %0d", error_count);
        $display("========================================");

        if (error_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

endmodule
