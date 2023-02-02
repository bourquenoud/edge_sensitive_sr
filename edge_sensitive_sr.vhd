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
-- In each stable state, the corresponding flip-flop is forced to its state
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
--         |  0   |  0   |  1   ||  1   |  1   |  1   |  0   |  0  | Stable
--         |  0   |  1   |  1   ||  1   |  0   |  1   |  0   |  0  | Unstable
--         |  1   |  0   |  1   ||  0   |  1   |  1   |  1   |  1  | Stable
--         |  1   |  1   |  1   ||  1   |  0   |  0   |  1   |  0  | Unstable
--         |  x   |  x   |  0   ||  1   |  0   |  1   |  0   |  0  | Reset
--         ---------------------------------------------------------
-- Qa : SET register output, Qb : CLEAR register output, NRST : Asynchronous
-- active low reset, Sa : Asynchronous set of Qa, Ra : Asynchronous reset of
-- Qa, Sb : Asynchronous set of Qb, Rb : Asynchronous reset of Qb, Out : Output
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity edge_sr_cell_0 is
    generic (
        RESET_POSITIVE : boolean := false; -- Reset polarity (true = active low)
        RESET_LOW : boolean := false; -- Reset value (true = '0')
        SET_POSITIVE : boolean := true; -- Set edge polarity (true = rising edge)
        CLEAR_POSITIVE : boolean := true; -- Clear edge polarity (true = rising edge)
        FAST_SET : boolean := true -- Set which edge is faster (true = SET)
    );
    port (
        RST   : in std_logic; -- Asynchronous active low reset 
        SET   : in std_logic; -- Edge sensitive set
        CLEAR : in std_logic; -- Edge sensitive clear
        Q     : out std_logic -- Output
    );
end entity edge_sr_cell_0;

architecture rtl of edge_sr_cell_0 is

    -- Necessary for constant selection, std_logic version
    function selection(condition : boolean; select_true, select_false : std_logic) return std_logic is
    begin
        if condition then
            return select_true;
        else
            return select_false;
        end if;
    end function;

    -- Necessary for constant selection, boolean version
    function selection(condition : boolean; select_true, select_false : boolean) return boolean is
    begin
        if condition then
            return select_true;
        else
            return select_false;
        end if;
    end function;

    -- Computed constants
    constant A_SET_B_CLEAR : boolean := FAST_SET; -- Swap A and B to change the faster edge, change the output polarity and thus the reset value
    constant RST_VALUE : std_logic := selection(A_SET_B_CLEAR = RESET_LOW, '0', '1');
    constant RST_ACTIVE_VALUE : std_logic := selection(RESET_POSITIVE, '1', '0');
    constant A_POSITIVE : boolean := selection(A_SET_B_CLEAR, SET_POSITIVE, CLEAR_POSITIVE); -- A to B is faster than B to A
    constant B_POSITIVE : boolean := selection(A_SET_B_CLEAR, CLEAR_POSITIVE, SET_POSITIVE); -- A to B is faster than B to A
    constant A_ACTIVE_VALUE : std_logic := selection(A_POSITIVE, '1', '0');
    constant B_ACTIVE_VALUE : std_logic := selection(B_POSITIVE, '1', '0');

    -- Generic mapped signals
    signal a_in : std_logic; -- A edge sensitive input
    signal b_in : std_logic; -- B edge sensitive input
    signal output : std_logic; -- Output before inversion

    -- Registers
    signal a_reg : std_logic; -- Qa
    signal b_reg : std_logic; -- Qb

    -- Asynchronous set/reset of the flip-flops
    signal a_set : std_logic; -- Sa (active low)
    signal a_reset : std_logic; -- Ra (active low)
    signal b_set : std_logic; -- Sb (active low)
    signal b_reset : std_logic; -- Rb (active low)

    -- Attributes to signal that only one of the two signals can be active
    -- at the same time. This is used to avoid unncecessary priority logic
    --  that could be inserted by the synthesis tool.
    attribute ONE_COLD : boolean;
    attribute ONE_COLD of a_set, a_reset : signal is true;
    attribute ONE_COLD of b_set, b_reset : signal is true;
begin

    -- Internal mapping of the inputs
    a_in <= SET when A_SET_B_CLEAR else
        CLEAR;
    b_in <= CLEAR when A_SET_B_CLEAR else
        SET;
    Q <= output when A_SET_B_CLEAR else -- Output inversion if A and B are swapped
        not output;

    -- Output
    output <= (a_reg and not b_reg);

    -- Asynchronous set/reset of the flip-flops
    -- Reset at "00" if the RST value is '0' and at "10" if the RST value is '1'
    a_set <= not a_reg or b_reg when RST /= RST_ACTIVE_VALUE else
        not RST_VALUE;
    a_reset <= not b_reg when RST /= RST_ACTIVE_VALUE else
        RST_VALUE;
    b_set <= not a_reg or not b_reg when RST /= RST_ACTIVE_VALUE else
        '1';
    b_reset <= a_reg when RST /= RST_ACTIVE_VALUE else
        '0';

    -- Flip-flops as process
    -- Register A
    reg_a_proc : process (a_set, a_reset, a_in)
    begin
        if a_set = '0' then
            a_reg <= '1';
        elsif a_reset = '0' then
            a_reg <= '0';
        elsif a_in'event and a_in = A_ACTIVE_VALUE then
            a_reg <= '1';
        end if;
    end process reg_a_proc;

    -- Register B
    reg_b_proc : process (b_set, b_reset, b_in)
    begin
        if b_set = '0' then
            b_reg <= '1';
        elsif b_reset = '0' then
            b_reg <= '0';
        elsif b_in'event and b_in = B_ACTIVE_VALUE then
            b_reg <= '1';
        end if;
    end process reg_b_proc;
end architecture rtl;
