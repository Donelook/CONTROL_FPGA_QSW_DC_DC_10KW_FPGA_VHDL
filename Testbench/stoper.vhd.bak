library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stoper is
    Port (
        clk          : in  std_logic;               -- System clock
        reset        : in  std_logic;               -- Synchronous reset
        start        : in  std_logic;               -- Start the stoper
        duration_ns  : in  integer;                 -- Time duration in nanoseconds to measure
        time_passed  : out std_logic                -- Output signal indicating that the time has passed
    );
end stoper;

architecture Behavioral of stoper is
    constant CLK_FREQ       : integer := 100_000_000;  -- Clock frequency in Hz (example: 100 MHz)
    constant TICK_TIME_NS   : integer := 8;           -- Time per clock tick in nanoseconds (for 100 MHz, 1 tick = 10 ns)

    signal counter          : std_logic_vector(31 downto 0) := (others => '0');  -- Counter to count the elapsed time in ticks
    signal running          : std_logic := '0';        -- Flag indicating whether the stoper is running
    signal target_ticks     : std_logic_vector(31 downto 0) := (others => '0');  -- The target number of ticks for the specified duration
    signal start_latched    : std_logic := '0';        -- Latched start signal to detect rising edge
begin

    -- Process to handle the stoper functionality
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset the stoper
            counter <= (others => '0');
            running <= '0';
            time_passed <= '0';
            start_latched <= '0';
        elsif rising_edge(clk) then
            if start = '1' and start_latched = '0' then
                -- Detect rising edge of start signal
                start_latched <= '1';
                -- Start the stoper
                running <= '1';
                counter <= (others => '0');
                time_passed <= '0';
                -- Calculate the target number of ticks based on the specified duration in nanoseconds
                target_ticks <= std_logic_vector(to_unsigned(duration_ns / TICK_TIME_NS, 32));
            elsif start = '0' then
                -- Reset the latch when start signal goes low
                start_latched <= '0';
                time_passed <= '0';
            elsif running = '1' then
                if unsigned(counter) >= unsigned(target_ticks) then
                    -- Time duration has passed, stop the stoper
                    running <= '0';
                    time_passed <= '1';
                else
                    -- Increment the counter while the stoper is running
                    counter <= std_logic_vector(unsigned(counter) + 1);
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
