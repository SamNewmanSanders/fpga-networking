# 03 - Asynchronous FIFO

This project is for learning about and testing an asynchronous FIFO: a buffer
that lets one part of a design write data using one clock while another part
reads it using a different clock. FIFOs like this are useful for safely passing
data between clock domains, for example between logic running at different
interface or system clock rates.

The eventual hardware test could use buttons to control writes and reads, or
another simple input/output demonstration. The exact test setup is still to be
decided; first, the goal is to get the FIFO working and verify its behavior.

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
