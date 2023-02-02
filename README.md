# edge_sensitive_sr
A glitch-free, latch free and oscillation-free edge sensitive set/reset
cell with an asychronous reset

# How to use
Simply add the file to you project and instantiate the component. Rising
edges on SET will set the output to 1 and rising edges on CLEAR will set
the output to 0.

# Detailed description
This cell is a simple edge sensitive set/reset
cell with an asynchronous reset. The cell is implemented using two
flip-flops. The implementation uses an asymmetric encoding, with only
two stable states ("00" and "10"). The two others states degenrate to
the "00" state. The reason is that each flip-flop can only be connected
to one of the edge sensitive inputs. This means that the A cell can
only toggle on a SET edge, and the B cell can only toggle on a CLEAR
edge. Thus we can not directly go from "10" to "00" (but we can go from
"00" to "10").

To solve this issue, we use the two intermediate states
to degenerate to the "00" state. For a clear, the sequence is as follow:
"10" toggles to "11" via the B cell on a CLEAR edge, then "11" forces an
asynchronous reset of the A cell, getting to the "01" state, then "01"
forces an asynchronous reset of the B cell, getting to the "00" state.
In the other direction, the A cell simply toggles to "10" on a SET edge.
The asymmerty causes a difference in the timing constraints between the 
two states. Going from "00" to "10" is faster than going from "10" to
"00".

In each stable state, the corresponding flip-flop is forced to its state
via either the asynchronous reset or the asynchronous set, meaning that
a SET edge when the state is "10" will not change the state, and a CLEAR
edge when the state is "00" will not change the state either.
Toggling both cells at the same time will flip the state, and will probably
cause timing violations. The cell is glitch-free and oscillation-free,
timing violations will not put the cell in an unstable state but can lead
to unpredictable outputs.
