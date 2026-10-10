# 03 - Asynchronous FIFO

This project is for learning about and testing an asynchronous FIFO: a buffer
that lets one part of a design write data using one clock while another part
reads it using a different clock. FIFOs like this are useful for safely passing
data between clock domains, for example between logic running at different
interface or system clock rates.

The hardware demonstration uses buttons to control FIFO writes and reads,
switches to select the 4-bit input value, and LEDs to display the output and
FIFO status. The button debouncers are reused from the `01-button-debouncer`
project. The switches connect directly to the FIFO input without synchronizer
registers because the intended operation is to set the switch value and let it
settle before pressing the write button; the input is only sampled for a FIFO
write on that button press.

## Asynchronous and synchronous memory reads

In `rtl/async_fifo_OLD.sv`, `data_out` is assigned directly from the memory
using the current read pointer. The output therefore changes as the pointer
changes, without waiting for a read-clock edge. This is a show-ahead style of
read: when the FIFO is not empty, the next word is already visible. That style
can make it harder for Vivado to infer block RAM (BRAM).

In `rtl/async_fifo.sv`, the read is instead performed inside the `rd_clk`
process when `rd_en` is asserted and the FIFO is not empty. The memory output
updates on that clock edge, which is a synchronous read style and may allow
BRAM inference. The trade-off is that `data_out` is not a continuously
available valid word; `empty` indicates whether a read can be accepted, not
whether the registered output currently contains valid data. A consumer or
future interface logic must account for the read timing.

## Reset across clock domains

The hardware top, `rtl/fifo_top.sv`, uses **asynchronous assertion and
synchronous deassertion** for reset. The reset button and the Clocking Wizard's
`locked` output are not guaranteed to change at a particular instant relative
to either design clock. A reset signal that changes close to a clock edge can
violate a flip-flop's setup or hold time and make its output temporarily
metastable.

The top combines the external reset button and loss of Clocking Wizard lock
into `reset_request`:

```systemverilog
assign reset_request = btn_reset || !clk_locked;
```

There is one two-stage reset synchronizer per clock domain. For example, the
100 MHz chain is:

```systemverilog
always_ff @(posedge CLK100MHZ or posedge reset_request) begin
    if (reset_request)
        reset_sync_100 <= 2'b11;
    else
        reset_sync_100 <= {reset_sync_100[0], 1'b0};
end

assign reset_100 = reset_sync_100[1];
```

The asynchronous `reset_request` immediately sets both synchronizer bits,
asserting reset without waiting for a clock edge. When the request is removed,
zeros shift through the chain only on rising edges of that chain's clock:

| Event | Synchronizer value | Domain reset |
|---|---:|---:|
| Reset asserted | `11` | asserted |
| First local clock edge after release | `10` | still asserted |
| Second local clock edge after release | `00` | deasserted |

The 25 MHz chain behaves the same way, but advances only on 25 MHz edges. The
chains must be separate: a release aligned to the 100 MHz clock is not
necessarily aligned to the 25 MHz clock. The two stages give the first
flip-flop time to settle before its value reaches the rest of the domain,
greatly reducing (but not mathematically eliminating) the chance of
metastability propagating.

The FIFO therefore has separate `wr_rst` and `rd_rst` inputs. Its write-side
state and read-pointer synchronizer use `wr_rst`, while its read-side state and
write-pointer synchronizer use `rd_rst`. These resets are consumed with
synchronous `if (wr_rst)` / `if (rd_rst)` checks on their respective clock
edges. Only the small reset synchronizer registers respond asynchronously to
`reset_request`; the rest of the logic sees reset assertion immediately on its
next clock edge, and reset release only after two local clock edges.

This pattern is useful when a reset source is asynchronous to a design clock:
asserting reset promptly puts the design into a known state, while releasing
reset in a clock-aligned way avoids letting downstream logic resume at an
arbitrary point in its clock cycle. In this design it also handles the
generated 25 MHz clock becoming unavailable: loss of `locked` asserts the
request, and reset release waits for that clock to be available and to advance
its own synchronizer.

## Verification

The FIFO was simulated and also tested on the Arty A7 board using the switches
and pushbuttons. Both checks behaved as expected: written values were read back
and shown on the four mono LEDs, the RGB status indicator showed the FIFO state,
and full and empty conditions correctly prevented writes and reads,
respectively.

## FPGA resource utilisation

Vivado synthesis results for the Xilinx Artix-7 XC7A100T (Arty A7-100T). Each
version stores 8-bit words. These are synthesis results, not necessarily
post-implementation results.

| Resource | Async read, depth 32 (`async_fifo_OLD.sv`) | Sync read, depth 32 (`async_fifo.sv`) | Sync read, depth 2048 |
|---|---:|---:|---:|
| LUTs | 31 | 32 (8 LUT6, 6 LUT5, 6 LUT4, 6 LUT3, 4 LUT2, 4 LUT1) | 37 (8 LUT6, 1 LUT3, 4 LUT1, 24 LUT2) |
| Flip-flops | 46 | 54 FDRE | 107 FDRE |
| FIFO memory primitives | 12 distributed RAM (RAM32M + RAMS32) | 12 distributed RAM (10 RAMD32 + 2 RAMS32) | 1 block RAM (RAMB18E1) |
| Carry-chain primitives | — | — | 14 CARRY4 |
| I/O buffers | 23 (13 IBUF, 10 OBUF) | 23 (13 IBUF, 10 OBUF) | 23 (13 IBUF, 10 OBUF) |
| Global clock buffers | 2 BUFGCTRL | 2 BUFG | 2 BUFG |

The depth-32 results show that changing to a synchronous read does not, by
itself, make Vivado infer block RAM: both small FIFOs were mapped to
distributed RAM. The depth-2048 FIFO stores 2048 x 8 = 16,384 bits. Its
synchronous read allows a block RAM implementation, and at this larger size
Vivado mapped the memory to one RAMB18E1 block. The larger memory is also an
important difference, so these results do not show that read style alone
caused the change; memory size and Vivado's mapping choices matter too.

LUT totals and distributed-RAM primitive counts are different views of
resources: distributed RAM is implemented using LUT resources, so do not add
those counts together as if they were independent LUT usage. RAMB18E1 is a
dedicated block-memory primitive. I/O and clock-buffer counts are included
where reported to make the three synthesis runs easier to compare.
