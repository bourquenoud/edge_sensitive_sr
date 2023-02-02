library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.all;

entity edge_sensitive_sr_tb is

end entity edge_sensitive_sr_tb;

architecture tb of edge_sensitive_sr_tb is
    component edge_sensitive_sr is
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
    end component;

    signal NRST : std_logic;
    signal SET : std_logic;
    signal CLEAR : std_logic;

    signal RST0 : std_logic;
    signal RST1 : std_logic;
    signal RST2 : std_logic;
    signal RST3 : std_logic;
    signal RST4 : std_logic;
    signal SET0 : std_logic;
    signal SET1 : std_logic;
    signal SET2 : std_logic;
    signal SET3 : std_logic;
    signal SET4 : std_logic;
    signal CLEAR0 : std_logic;
    signal CLEAR1 : std_logic;
    signal CLEAR2 : std_logic;
    signal CLEAR3 : std_logic;
    signal CLEAR4 : std_logic;
    signal Q0 : std_logic;
    signal Q1 : std_logic;
    signal Q2 : std_logic;
    signal Q3 : std_logic;
    signal Q4 : std_logic;
begin

    -- Negative reset, positive set and clear, fast set
    RST0 <= NRST;
    SET0 <= SET;
    CLEAR0 <= CLEAR;
    uut0 : edge_sensitive_sr
    generic map(
        RESET_POSITIVE => false,
        RESET_LOW => true,
        SET_POSITIVE => true,
        CLEAR_POSITIVE => true,
        FAST_SET => true
    )
    port map(
        RST   => RST0,
        SET   => SET0,
        CLEAR => CLEAR0,
        Q     => Q0
    );

    -- Negative reset, positive set and clear, fast clear
    RST1 <= NRST;
    SET1 <= SET;
    CLEAR1 <= CLEAR;
    uut1 : edge_sensitive_sr
    generic map(
        RESET_POSITIVE => false,
        RESET_LOW => true,
        SET_POSITIVE => true,
        CLEAR_POSITIVE => true,
        FAST_SET => false
    )
    port map(
        RST   => RST1,
        SET   => SET1,
        CLEAR => CLEAR1,
        Q     => Q1
    );

    -- Negative reset, negative set and clear, fast set
    RST2 <= NRST;
    SET2 <= not SET;
    CLEAR2 <= not CLEAR;
    uut2 : edge_sensitive_sr
    generic map(
        RESET_POSITIVE => false,
        RESET_LOW => true,
        SET_POSITIVE => false,
        CLEAR_POSITIVE => false,
        FAST_SET => true
    )
    port map(
        RST   => RST2,
        SET   => SET2,
        CLEAR => CLEAR2,
        Q     => Q2
    );

    -- Negative reset, negative set and clear, fast clear
    RST3 <= NRST;
    SET3 <= not SET;
    CLEAR3 <= not CLEAR;
    uut3 : edge_sensitive_sr
    generic map(
        RESET_POSITIVE => false,
        RESET_LOW => true,
        SET_POSITIVE => false,
        CLEAR_POSITIVE => false,
        FAST_SET => false
    )
    port map(
        RST   => RST3,
        SET   => SET3,
        CLEAR => CLEAR3,
        Q     => Q3
    );

    -- Negative reset, positive set and clear, fast set, reset high
    RST4 <= NRST;
    SET4 <= SET;
    CLEAR4 <= CLEAR;
    uut4 : edge_sensitive_sr
    generic map(
        RESET_POSITIVE => false,
        RESET_LOW => false,
        SET_POSITIVE => true,
        CLEAR_POSITIVE => true,
        FAST_SET => true
    )
    port map(
        RST   => RST4,
        SET   => SET4,
        CLEAR => CLEAR4,
        Q     => Q4
    );

    process
    begin
        -- Set signals to a known state
        SET <= '0';
        CLEAR <= '0';

        -- Reset the cell
        NRST <= '0';
        wait for 10 ns;
        NRST <= '1';
        wait for 10 ns;

        -- Set the cell
        SET <= '1';
        wait for 5 ns;
        SET <= '0';
        wait for 5 ns;

        -- Clear the cell
        CLEAR <= '1';
        wait for 5 ns;
        CLEAR <= '0';
        wait for 5 ns;

        -- Re-clear the cell
        CLEAR <= '1';
        wait for 5 ns;
        CLEAR <= '0';
        wait for 5 ns;

        -- Set the cell
        SET <= '1';
        wait for 5 ns;
        SET <= '0';
        wait for 5 ns;

        -- Re-set the cell
        SET <= '1';
        wait for 5 ns;
        SET <= '0';
        wait for 5 ns;

        -- Reset the cell
        NRST <= '0';
        wait for 10 ns;
        NRST <= '1';
        wait for 10 ns;

        -- Set the cell
        SET <= '1';
        wait for 5 ns;
        SET <= '0';
        wait for 5 ns;

        -- Reset the cell
        NRST <= '0';
        wait for 10 ns;
        NRST <= '1';
        wait for 10 ns;

        -- Clear the cell
        CLEAR <= '1';
        wait for 5 ns;
        CLEAR <= '0';
        wait for 5 ns;

        -- Done
        stop;

    end process;

end architecture tb;
