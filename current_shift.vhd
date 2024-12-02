library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CURRENT_SHIFT is
    Port (
        clk             : in  std_logic;            -- System clock
        reset           : in  std_logic;            -- Synchronous reset
        S1              : in  std_logic;            -- Signal S1
        S3              : in  std_logic;            -- Signal S3
        control_out     : out integer               -- Output from PI controller
    );
end CURRENT_SHIFT;

architecture Behavioral of CURRENT_SHIFT is

    -- Declare the timer component
    component timer is
        Port (
            clk             : in  std_logic;            -- System clock (100 MHz)
            reset           : in  std_logic;            -- Synchronous reset
            start_timer     : in  std_logic;            -- Start timer
            stop_timer      : in  std_logic;            -- Stop timer
            elapsed_time_ns : out integer               -- Elapsed time in nanoseconds
        );
    end component;

    -- Declare the PI_CONTROLLER component
    component PI_CONTROLLER is
        Port (
            clk          : in  std_logic;       -- System clock
            reset        : in  std_logic;       -- Asynchronous reset
            enable       : in  std_logic;       -- Enable signal for sampling control
            setpoint     : in  integer;         -- Desired value (Integer)
            measured     : in  integer;         -- Measured value (Integer)
            kp           : in  integer;         -- Proportional gain (Integer)
            ki           : in  integer;         -- Integral gain (Integer)
            output_min   : in  integer;         -- Minimum output limit (Integer)
            output_max   : in  integer;         -- Maximum output limit (Integer)
            control_out  : out integer          -- Controller output (Integer)
        );
    end component;


  
  
    -- Signals for timer control
    signal start_timer_s1 : std_logic := '0';
    signal stop_timer_s1  : std_logic := '0';

    signal start_timer_phase : std_logic := '0';
    signal stop_timer_phase  : std_logic := '0';

    -- Signals for elapsed times
    signal elapsed_time_ns_s1 : integer := 0;

    signal elapsed_time_ns_phase : integer := 0;



    -- Signals for phase shift calculation
    signal control_input     : integer := 0;
    signal phase_bufor       : std_logic := '0';


begin
	
	
    -- Instance of the timer module for S1 frequency
    timer_s1: timer
        Port map (
            clk             => clk,
            reset           => reset,
            start_timer     => start_timer_s1,
            stop_timer      => stop_timer_s1,
            elapsed_time_ns => elapsed_time_ns_s1
        );

 

    -- Instance of the timer module for phase shift measurement
    timer_phase: timer
        Port map (
            clk             => clk,
            reset           => reset,
            start_timer     => start_timer_phase,
            stop_timer      => stop_timer_phase,
            elapsed_time_ns => elapsed_time_ns_phase
        );

    -- Instance of the PI_CONTROLLER module
    PI_CTRL: PI_CONTROLLER
        Port map (
            clk          => clk,
            reset        => reset,
            enable       => '1',
            setpoint     => 0,  -- Setpoint is zero (0.5 - phase_shift_ratio should be zero ideally)
            measured     => control_input,
            kp           => 1,  -- Proportional gain
            ki           => 10,  -- Integral gain
            output_min   => -1000, -- Min limit for control output
            output_max   => 1000,  -- Max limit for control output
            control_out  => control_out
        );

    process(S1, reset)
    begin
        if reset = '1' then
            -- Reset all signals
            start_timer_s1 <= '0';
            stop_timer_s1 <= '0';

        elsif rising_edge(S1) then
            -- Detect rising edge of S1 for frequency and phase measurement
            if start_timer_s1 = '0' then
                stop_timer_s1 <= '0';
                start_timer_s1 <= '1'; -- Start frequency timer for S1
                --start_timer_phase <= '1'; -- Start phase timer
            else
                start_timer_s1 <= '0';
                stop_timer_s1 <= '1';  -- Stop previous frequency measurement
            end if;

        end if;
    end process;



    process(S3, S1, reset)
    begin
        if reset = '1' then
            -- Reset all signals
            start_timer_phase <= '0';
            stop_timer_phase <= '0';
            phase_bufor <= '0';
        elsif rising_edge(S1) then
            -- Detect rising edge of S1 OR S3 for and phase measurement
            if start_timer_phase = '0' then
                stop_timer_phase <= '0';
                start_timer_phase <= '1'; -- tart phase timer for phase measurment
                phase_bufor <= '1';
            end if;
        elsif rising_edge(S3) AND phase_bufor = '1' then
            start_timer_phase <= '0';
            stop_timer_phase <= '1';  -- Stop previous frequency measurement
            phase_bufor <= '0';
        end if;
    end process;


    -- Calculate the phase shift ratio and feed it into the PI controller
    process(clk, elapsed_time_ns_s1, elapsed_time_ns_phase)
    begin

        -- Normalize and adjust the phase shift input for PI controller
        control_input <=  (elapsed_time_ns_s1/2 - elapsed_time_ns_phase)/8; -- Adjusting the phase shift

       
    end process;
   
end Behavioral;