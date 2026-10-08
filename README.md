# FPGA Networking

This repository is a place to learn FPGA concepts, put them into practice in
hardware projects, and explore networking systems.

## Projects

Each project folder contains its own README with more detail about its design
and Vivado workflow.

- [`00-led-blink`](00-led-blink/README.md) blinks an Arty A7 LED using a clock-driven counter.
- [`01-button-debouncer`](01-button-debouncer/README.md) synchronizes and debounces a physical pushbutton before using it to control logic.
- [`02-clock-domains`](02-clock-domains/README.md) demonstrates counters running from 100 MHz and 25 MHz clocks.
- [`03-async-fifo`](03-async-fifo/README.md) explores asynchronous FIFOs, read styles, and FPGA memory-resource inference.
- [`Async FIFO`](Async%20FIFO/README.md) simulates a FIFO with separate write and read clocks.
- [`Packet Parser`](Packet%20Parser/README.md) develops and tests an MII receiver that assembles incoming nibbles into bytes.

## Reusing RTL in Vivado

A project may use RTL files stored in another folder: add the existing file to
the Vivado project's **Design Sources** instead of duplicating it. When adding
the file, leave **Copy sources into project** unchecked so the project
references the shared source.
