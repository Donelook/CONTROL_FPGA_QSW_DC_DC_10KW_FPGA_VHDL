library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
    Port (
        clk             : in  std_logic;            -- System clock (100 MHz)
        reset           : in  std_logic;            -- Synchronous reset
        start_timer     : in  std_logic;            -- Start timer
        stop_timer      : in  std_logic;            -- Stop timer
        elapsed_time_ns : out integer               -- Elapsed time in nanoseconds
    );
end timer;

architecture Behavioral of timer is
    constant CLK_FREQ       : integer := 100_000_000;  -- Clock frequency in Hz (100 MHz)
    constant TICK_TIME_NS   : integer := 10;           -- Time per clock tick in nanoseconds (for 100 MHz, 1 tick = 10 ns)

    -- Define the width of the counter based on the maximum expected duration
    constant COUNTER_WIDTH  : integer := 32;           -- 32-bit wide counter

    signal counter          : std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => '0');  -- Clock cycle counter
    signal running          : std_logic := '0';        -- Timer running flag
    signal elapsed_ticks    : std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => '0');  -- Total elapsed ticks
begin

    -- Timer process
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset the timer
            counter <= (others => '0');
            running <= '0';
            elapsed_ticks <= (others => '0');
            elapsed_time_ns <= 0;
        elsif rising_edge(clk) then
            if start_timer = '1' and running = '0' then
                -- Start the timer
                running <= '1';
                counter <= (others => '0');
            elsif stop_timer = '1' and running = '1' then
                -- Stop the timer
                running <= '0';
                elapsed_ticks <= counter;
                elapsed_time_ns <= to_integer(unsigned(counter) * 2) + (to_integer(unsigned(counter) * 8));  -- Multiply by 10 using (2 + 8) --to_integer(unsigned(counter)); --* TICK_TIME_NS;  -- Calculate the elapsed time in nanoseconds
            elsif running = '1' then
                -- Increment the counter while the timer is running
                counter <= std_logic_vector(unsigned(counter) + 1);
            end if;
        end if;
    end process;

end Behavioral;