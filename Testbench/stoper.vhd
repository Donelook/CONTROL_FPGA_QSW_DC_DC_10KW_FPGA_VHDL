library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stoper is
    Port (
        clk          : in  std_logic;          -- System clock
        reset        : in  std_logic;          -- Synchronous reset
        start        : in  std_logic;          -- Start the stoper
        duration_ns  : in  integer;            -- Time duration in nanoseconds to measure
        time_passed  : out std_logic           -- Output signal indicating that the time has passed
    );
end stoper;

architecture Behavioral of stoper is
    constant CLK_FREQ      : integer := 100_000_000;  -- Clock frequency in Hz (example: 100 MHz)
    constant TICK_TIME_NS  : integer := 10;          -- Clock period in nanoseconds (for 100 MHz, 1 tick = 10 ns)

    signal accumulated_time : integer := 0;          -- Accumulated time in nanoseconds
    signal target_time      : integer := 0;          -- Target time in nanoseconds
    signal running          : std_logic := '0';      -- Flag to indicate the stoper is running
    signal start_latched    : std_logic := '0';      -- Latch for detecting start signal edge
begin

    -- Process to handle the stoper functionality
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset all signals
            accumulated_time <= 0;
            target_time <= 0;
            running <= '0';
            time_passed <= '0';
            start_latched <= '0';
        elsif rising_edge(clk) then
            if start = '1' and start_latched = '0' then
                -- Detect rising edge of start signal
                start_latched <= '1';
                running <= '1';
                accumulated_time <= 0;
                time_passed <= '0';
                target_time <= duration_ns;  -- Set target time directly
            elsif start = '0' then
                -- Reset the latch when the start signal is low
                start_latched <= '0';
            elsif running = '1' then
                if accumulated_time >= target_time then
                    -- Stop when accumulated time exceeds or matches the target time
                    running <= '0';
                    time_passed <= '1';
                else
                    -- Increment the accumulated time
                    accumulated_time <= accumulated_time + TICK_TIME_NS;
                end if;
            end if;
        end if;
    end process;

end Behavioral;

