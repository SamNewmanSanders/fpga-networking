# 01 - Button debouncer

A physical push button can rapidly switch between pressed and released states
when its contacts make or break connection. This contact bounce can look like
several presses to digital logic, causing a counter or other circuit to react
more than once to a single press.

The `button_debouncer` module first synchronizes the button input to the clock,
then waits for it to remain stable for a configurable number of clock cycles
before updating its output. The default interval is 500,000 cycles (about 5 ms
at 100 MHz). In `counter_test`, the debounced output is a level, so the design
stores its previous value and increments the LEDs only on a rising edge.

In the future, I may add an extra debouncer output that signals button edges
directly, rather than requiring each consuming module to detect edges from the
debounced level.
