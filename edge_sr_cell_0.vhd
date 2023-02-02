-------------------------------------------------------------------------------
-- File: edge_sr_cell_0.vhd
-- Description: A glitch-free edge sensitive set/reset cell
-- Author: Mathieu Bourquenoud
-- Date: 2023-02-02
-------------------------------------------------------------------------------
-- Detailed description: This cell is a simple edge sensitive set/reset
-- cell with an asynchronous reset. The cell is implemented using two
-- flip-flops. The implementation uses an asymmetric encoding, with only
-- two stable states ("00" and "10"). The two others states degenrate to
-- the "00" state. The reason is that each flip-flop can only be connected
-- to one of the edge sensitive inputs. This means that the A cell can
-- only toggle on a SET edge, and the B cell can only toggle on a CLEAR
-- edge. Thus we can not directly go from "10" to "00" (but we can go from
-- "00" to "10").
-- To solve this issue, we use the two intermediate states
-- to degenerate to the "00" state. For a clear, the sequence is as follow:
-- "10" toggles to "11" via the B cell on a CLEAR edge, then "11" forces an
-- asynchronous reset of the A cell, getting to the "01" state, then "01"
-- forces an asynchronous reset of the B cell, getting to the "00" state.
-- In the other direction, the A cell simply toggles to "10" on a SET edge.
-- The asymmerty causes a difference in the timing constraints between the 
-- two states. Going from "00" to "10" is faster than going from "10" to
-- "00".
-- In each stable edge, the corresponding flip-flop is forced to its state
-- via either the asynchronous reset or the asynchronous set, meaning that
-- a SET edge when the state is "10" will not change the state, and a CLEAR
-- edge when the state is "00" will not change the state either.
-- Toggling both cells at the same time will flip the state, and will probably
-- cause timing violations. The cell is glitch-free and oscillation-free,
-- timing violations will not put the cell in an unstable state but can lead
-- to unpredictable outputs.
--
--         ---------------------------------------------------------
--         ----------------------TRUTH TABLE------------------------
--         |  Qa  |  Qb  | NRST ||  Sa  |  Ra  |  Sb  |  Rb  | Out |
--         --------------------------------------------------------
--         |  0   |  0   |  1   ||  1   |  1   |  1   |  0   |  0  |
--         |  0   |  1   |  1   ||  1   |  0   |  1   |  0   |  0  |
--         |  1   |  0   |  1   ||  0   |  1   |  1   |  1   |  1  |
--         |  1   |  1   |  1   ||  1   |  0   |  0   |  1   |  0  |
--         |  x   |  x   |  0   ||  1   |  0   |  1   |  0   |  0  |
--         ---------------------------------------------------------
-- Qa : SET register output, Qb : CLEAR register output, NRST : Asynchronous
-- active low reset, Sa : Asynchronous set of Qa, Ra : Asynchronous reset of
-- Qa, Sb : Asynchronous set of Qb, Rb : Asynchronous reset of Qb, Out : Output
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.rtl_attributes.all;

entity edge_sr_cell_0 is
    port (
        NRST  : in std_logic; -- Asynchronous active low reset 
        SET   : in std_logic; -- Edge sensitive set
        CLEAR : in std_logic; -- Edge sensitive clear
        Q     : out std_logic -- Output
    );
end entity edge_sr_cell_0;

architecture rtl of edge_sr_cell_0 is
    -- Registers
    signal a_reg : std_logic; -- Qa, SET register
    signal b_reg : std_logic; -- Qb, CLEAR register

    -- Asynchronous set/reset of the flip-flops
    signal a_set : std_logic; -- Sa (active low)
    signal a_reset : std_logic; -- Ra (active low)
    signal b_set : std_logic; -- Sb (active low)
    signal b_reset : std_logic; -- Rb (active low)

    -- Attributes to signal that only one of the two signals can be active
    -- at the same time. This is used to avoid unncecessary priority logic
    --  that could be inserted by the synthesis tool.
    attribute ONE_COLD of a_set, a_reset;
    attribute ONE_COLD of b_set, b_reset;
begin

    -- Output
    Q <= (a_reg and not b_reg) when NRST = '1' else
        '0';

    -- Asynchronous set/reset of the flip-flops
    a_set <= not a_reg or b_reg when NRST = '1' else
        '1';
    a_reset <= not b_reg when NRST = '1' else
        '0';
    b_set <= not a_reg or not b_reg when NRST = '1' else
        '1';
    b_reset <= a_reg when NRST = '1' else
        '0';

    -- Flip-flops as process
    -- Register A
    reg_a_proc : process (a_set, a_reset, SET)
    begin
        if a_set = '0' then
            a_reg <= '1';
        elsif a_reset = '0' then
            a_reg <= '0';
        elsif rising_edge(SET) then
            a_reg <= '1';
        end if;
    end process reg_a_proc;

    -- Register B
    reg_b_proc : process (b_set, b_reset, CLEAR)
    begin
        if b_set = '0' then
            b_reg <= '1';
        elsif b_reset = '0' then
            b_reg <= '0';
        elsif rising_edge(CLEAR) then
            b_reg <= '1';
        end if;
    end process reg_b_proc;
end architecture rtl;
