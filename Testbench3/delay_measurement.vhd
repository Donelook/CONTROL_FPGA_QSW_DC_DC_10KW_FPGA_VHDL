library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity delay_measurement is
    Port (
        clk             : in  std_logic;  -- Input clock signal, typically from a PLL or system clock
        reset           : in  std_logic;  -- Synchronous reset signal for the module
        delay_tr_signal : in  std_logic;  -- Input signal representing delay_tr, used for period measurement
        delay_hc_signal : in  std_logic;  -- Input signal representing delay_hc, used for period measurement
        delay_tr        : out integer;    -- Output representing the measured period for delay_tr
        delay_hc        : out integer     -- Output representing the measured period for delay_hc
    );
end delay_measurement;

architecture Behavioral of delay_measurement is

    -- Signal declarations for interfacing with the timer module
    signal start_timer_tr    : std_logic := '0';
    signal stop_timer_tr     : std_logic := '0';
    signal start_timer_hc    : std_logic := '0';
    signal stop_timer_hc     : std_logic := '0';
    signal elapsed_time_tr   : integer := 0;
    signal elapsed_time_hc   : integer := 0;
    
    -- Signal to capture previous state of delay_tr_signal and delay_hc_signal
    signal prev_delay_tr     : std_logic := '0';
    signal prev_delay_hc     : std_logic := '0';

    -- Timer component declaration
    component timer is
        Port (
            clk             : in  std_logic;            -- System clock (100 MHz)
            reset           : in  std_logic;            -- Synchronous reset
            start_timer     : in  std_logic;            -- Start timer
            stop_timer      : in  std_logic;            -- Stop timer
            elapsed_time_ns : out integer               -- Elapsed time in nanoseconds
        );
    end component;

begin

    -- Instantiate the timer for delay_tr_signal
    delay_tr_timer: timer
        Port map (
            clk             => clk,
            reset           => reset,
            start_timer     => start_timer_tr,
            stop_timer      => stop_timer_tr,
            elapsed_time_ns => elapsed_time_tr
        );

    -- Instantiate the timer for delay_hc_signal
    delay_hc_timer: timer
        Port map (
            clk             => clk,
            reset           => reset,
            start_timer     => start_timer_hc,
            stop_timer      => stop_timer_hc,
            elapsed_time_ns => elapsed_time_hc
        );

    -- Control logic for delay_tr_signal measurement
    process(delay_tr_signal, reset)
    begin
        if reset = '1' then
            -- Reset signals related to delay_tr period measurement
            start_timer_tr <= '0';
            stop_timer_tr <= '0';
            prev_delay_tr <= '0';
        elsif rising_edge(delay_tr_signal) then
            -- Detect rising edge of delay_tr_signal
            
                if start_timer_tr = '0' then
                    -- Start the timer on the first rising edge
                    start_timer_tr <= '1';
                    stop_timer_tr <= '0';
                else
                    -- Stop the timer on the next rising edge
                    stop_timer_tr <= '1';
                    start_timer_tr <= '0';
                  --  delay_tr <= elapsed_time_tr;   
                end if;
                
        end if;
        if elapsed_time_tr > 0  then 
            delay_tr <= elapsed_time_tr; -- Assign the final measured period for delay_tr to the output
        end if; 
    end process;

    -- Control logic for delay_hc_signal measurement
    process(delay_hc_signal, reset)
    begin
        if reset = '1' then
            -- Reset signals related to delay_hc period measurement
            start_timer_hc <= '0';
            stop_timer_hc <= '0';
            prev_delay_hc <= '0';
        elsif rising_edge(delay_hc_signal) then
            -- Detect rising edge of delay_hc_signal
             
                if start_timer_hc = '0' then
                    -- Start the timer on the first rising edge
                    start_timer_hc <= '1';
                    stop_timer_hc <= '0';
                else
                    -- Stop the timer on the next rising edge
                    stop_timer_hc <= '1';
                    start_timer_hc <= '0';
                   -- delay_hc <= elapsed_time_hc;
                end if;
        end if;
        if elapsed_time_hc > 0  then 
            delay_hc <= elapsed_time_hc; -- Assign the final measured period for delay_hc to the output
        end if;
    end process;

    -- Output the measured delays
--if elapsed_time_tr > 0  then 
   -- delay_tr <= elapsed_time_tr; -- Assign the final measured period for delay_tr to the output
--end if; 
--if elapsed_time_hc > 0  then 
  --  delay_hc <= elapsed_time_hc; -- Assign the final measured period for delay_hc to the output
--end if;

end Behavioral;
