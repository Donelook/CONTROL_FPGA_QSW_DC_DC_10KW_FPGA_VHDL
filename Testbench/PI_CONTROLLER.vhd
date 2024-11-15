library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;  -- Use this for integer arithmetic
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PI_CONTROLLER is
    Port (
        clk          : in  STD_LOGIC;       -- System clock
        reset        : in  STD_LOGIC;       -- Asynchronous reset
        enable       : in  STD_LOGIC;       -- Enable signal for sampling control
        setpoint     : in  INTEGER;         -- Desired value (Integer)
        measured     : in  INTEGER;         -- Measured value (Integer)
        kp           : in  INTEGER;         -- Proportional gain (Integer)
        ki           : in  INTEGER;         -- Integral gain (Integer)
        output_min   : in  INTEGER;         -- Minimum output limit (Integer)
        output_max   : in  INTEGER;         -- Maximum output limit (Integer)
        control_out  : out INTEGER          -- Controller output (Integer)
    );
end PI_CONTROLLER;

architecture Behavioral of PI_CONTROLLER is

    signal error_control : INTEGER := 0;    -- Control error signal (Integer)
    signal prop_term     : INTEGER := 0;    -- Proportional term (Integer)
    signal int_term      : INTEGER := 0;    -- Accumulated integral term (Integer)
    signal output_unclamped : INTEGER := 0; -- Unclamped control output (Integer)
    signal prev_error    : INTEGER := 0;    -- Previous error signal (Integer)
    signal integrator    : INTEGER := 0;    -- Integrator state (Integer)
    signal anti_windup   : INTEGER := 0;    -- Anti-windup correction term (Integer)

begin

    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset all states
            error_control <= 0;
            prop_term <= 0;
            int_term <= 0;
            output_unclamped <= 0;
            prev_error <= 0;
            integrator <= 0;
            control_out <= 0;
            anti_windup <= 0;
        elsif rising_edge(clk) then
            if enable = '1' then  -- Check if the controller is enabled for this cycle
                -- Calculate the control error
                error_control <= setpoint - measured;

                -- Proportional term
                prop_term <= kp * error_control;

                -- Integral term calculation
                integrator <= integrator + (ki * error_control);

                -- Calculate unclamped output
                output_unclamped <= prop_term + integrator;
                
				if integrator > output_max then
                    integrator <= output_max;
                    
                elsif integrator < output_min then
                    integrator <= output_min;
                 
                end if;
                -- Anti-windup: If output is clamped, stop the integrator from accumulating
                if output_unclamped > output_max then
                    control_out <= output_max;
                    
                elsif output_unclamped < output_min then
                    control_out <= output_min;

                else
                    control_out <= output_unclamped;

                end if;

                -- Apply anti-windup correction
                --integrator <= integrator + anti_windup;

                -- Store previous error for next cycle
                prev_error <= error_control;
            end if;
        end if;
    end process;

end Behavioral;