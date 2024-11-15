library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity phase_controller is
    Port (
        clk             : in  std_logic;  -- System clock
        reset           : in  std_logic;  -- Synchronous reset
        start           : in  std_logic;  -- Start signal
        IL_max_comp     : in  std_logic;  -- Comparator signal for max current
        IL_min_comp     : in  std_logic;  -- Comparator signal for min current
        delay_hc        : in  integer;    -- Delay in ns for the HC state
        delay_tr        : in  integer;    -- Delay in ns for the TR state
        S1              : out std_logic;  -- Output signal S1
        S2              : out std_logic;  -- Output signal S2
        state_error     : out std_logic   -- Error signal
    );
end phase_controller;

architecture Behavioral of phase_controller is

    type state_type is (ReadyToGo_STATE, T01A_STATE, T12A_STATE, T23A_STATE, T45A_STATE, Error_STATE);
    signal state       : state_type := ReadyToGo_STATE;
    signal start_flag  : std_logic := '0';

    -- Signals for interfacing with the stoper module
    signal hc_time_passed : std_logic;
    signal tr_time_passed : std_logic;

    signal start_timer_hc : std_logic := '0';
    signal start_timer_tr : std_logic := '0';
 -- Stoper component declaration
    component stoper is
        Port (
            clk             : in  std_logic;            -- System clock (100 MHz)
            reset           : in  std_logic;            -- Synchronous reset
            start    : in  std_logic;            -- Start timer
            duration_ns     : in integer;            -- stoper duration 
            time_passed : out  std_logic         -- time passed of stoper
        );
    end component;
begin

    -- Instance of the stoper module for delay_hc
    stoper_hc: stoper 
        Port map (
            clk             => clk,
            reset           => reset,
            start    => start_timer_hc,
            duration_ns     => delay_hc,  -- Connect the delay_hc input to the stoper module
            time_passed     => hc_time_passed
        );

    -- Instance of the stoper module for delay_tr
    stoper_tr: stoper 
        Port map (
            clk             => clk,
            reset           => reset,
            start     => start_timer_tr,
            duration_ns     => delay_tr,  -- Connect the delay_tr input to the stoper module
            time_passed     => tr_time_passed
        );

    process(clk, reset)
    begin
        if reset = '1' then
            state <= ReadyToGo_STATE;
            start_flag <= '0';
            S1 <= '0';
            S2 <= '0';
            state_error <= '0';
            start_timer_hc <= '0';
            start_timer_tr <= '0';
        elsif rising_edge(clk) then
            case state is

                when ReadyToGo_STATE =>
                    S1 <= '0';
                    S2 <= '0';
                    if start = '1' and start_flag = '0' then
                        start_flag <= '1';
                        state <= T01A_STATE;
                    end if;

                when T01A_STATE =>
                    S1 <= '1';
                    S2 <= '0';
                    if IL_max_comp = '1' then
                        state <= T12A_STATE;
                        start_timer_hc <= '1';  -- Start the stoper for delay_hc
                    end if;

                when T12A_STATE =>
                    S1 <= '0';
                    S2 <= '0';
		--start_timer_hc <= '0';  -- Stop the stoper for delay_hc after it starts
                    if hc_time_passed = '1' then
			start_timer_hc <= '0';  -- Stop the stoper for delay_hc after it starts

                        state <= T23A_STATE;
                        start_timer_tr <= '1';  -- Start the stoper for delay_tr
                    end if;

                when T23A_STATE =>
                    S1 <= '0';
                    S2 <= '1';
                    if IL_min_comp = '1' then
                        state <= T45A_STATE;
                        start_timer_tr <= '1';  -- Stop the stoper for delay_tr
                    end if;

                when T45A_STATE =>
                    S1 <= '0';
                    S2 <= '0';
                    if tr_time_passed = '1' then
			start_timer_tr <= '0';  -- Stop the stoper for delay_tr

                        state <= T01A_STATE;
                    end if;

                when others =>
                    state <= Error_STATE;

            end case;
        end if;
    end process;

end Behavioral;