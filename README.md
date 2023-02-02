# edge_sensitive_sr
A glitch-free, latch free and oscillation-free edge sensitive set/reset
cell with an asychronous reset.

# How to use
Simply add the file to you project and instantiate the component. Generics
allows you to change the behaviour of the component such as reset polarity,
edge sensitivity, etc... See "Generics" below for more details.

# Detailed description
This cell is a simple edge sensitive set/reset
cell with an asynchronous reset. The cell is implemented using two
flip-flops. The implementation uses an asymmetric encoding, with only
two stable states ("00" and "10"). The two others states degenrate to
the "00" state. The reason is that each flip-flop can only be connected
to one of the edge sensitive inputs. This means that the A cell can
only toggle on a SET(or CLEAR) edge, and the B cell can only toggle on a CLEAR(or SET)
edge. Thus we can not directly go from "10" to "00" (but we can go from
"00" to "10").

To solve this issue, we use the two intermediate states
to degenerate to the "00" state. To go from "10" to "00", the sequence is as follow:
"10" toggles to "11" via the B cell on a CLEAR(or SET) edge, then "11" forces an
asynchronous reset of the A cell, getting to the "01" state, then "01"
forces an asynchronous reset of the B cell, getting to the "00" state.
In the other direction, the A cell simply toggles to "10" on a SET(or CLEAR) edge.
The asymmerty causes a difference in the timing constraints between the 
two states. Going from "00" to "10" is faster than going from "10" to
"00".

In each stable state, the corresponding flip-flop is forced to its state
via either the asynchronous reset or the asynchronous set, meaning that
a SET(or RESET) edge when the state is "10" will not change the state, and a CLEAR(or SET)
edge when the state is "00" will not change the state either.
Toggling both cells at the same time will flip the state, and will probably
cause timing violations. The cell is glitch-free and oscillation-free,
timing violations will not put the cell in an unstable state but can lead
to unpredictable outputs.

# Generics
 - **RESET_POSITIVE** : If true RST is active high, else it is active low
 - **RESET_LOW** : If true asserting RST set Q to low, else it resets to high
 - **SET_POSITIVE** : If true SET is sensitive to rising edges, else to falling edges
 - **CLEAR_POSITIVE** : If true CLEAR is sensitive to rising edges, else to falling edges
 - **FAST_SET** : If true the fast transition is from low to high, else from high to low
 
 # License
 This file is licensed under the MIT license. See LICENSE file
