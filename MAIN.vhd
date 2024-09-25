-- ###################################################################
-- # Title       : Main
-- # Description : Interleaved boost converter 400V -> 800V, 10kW Control
-- #
-- # Author      : Michal Karas
-- # Date        : 24.09.2024
-- #
-- # Target Device  : [FPGA/ASIC Device (e.g., iCE40UP5K)]
-- # Clock Frequency: 100 MHz
-- #
-- # Revision History
-- # Rev  Date        Author         Description
-- # ---  ----------- -------------- ---------------------------------
-- # 1.0  24.09.2024  Michal Karas   Initial version
-- #
-- ###################################################################
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MAIN is
    Port (
        -- Clock and control signals
        --clk_12mhz      : in  std_logic;   -- 12 MHz system clock for PLL
        reset          : in  std_logic;   -- Reset signal
        start_stop     : in  std_logic;   -- Start/Stop control
        error_pin      : in  std_logic;   -- Error pin

        -- Current sensing signals
        il_max_comp1   : in  std_logic;   -- Current limit comparator 1 (max)
        il_max_comp2   : in  std_logic;   -- Current limit comparator 2 (max)
        il_min_comp1   : in  std_logic;   -- Current limit comparator 1 (min)
        il_min_comp2   : in  std_logic;   -- Current limit comparator 2 (min)

        -- Physical delay measurement signals
        delay_tr_input : in  std_logic;   -- Physical input signal for delay_tr
        delay_hc_input : in  std_logic;   -- Physical input signal for delay_hc

        -- Transistor control outputs (for driving transistors)
        s1_phy             : out std_logic;
        s2_phy             : out std_logic;
        s3_phy             : out std_logic;
        s4_phy             : out std_logic;

        -- PWM output to be read by the microcontroller
        pwm_output     : out std_logic    -- Output PWM signal from current_shift
    );
end MAIN;

architecture Behavioral of MAIN is
	-- Internal signal for the 12 MHz clock from HFOSC
	signal clk_12mhz : std_logic;
    signal osc_enable   : std_logic := '1';  -- Enable oscillator
    signal osc_powerup  : std_logic := '1';  -- Power up oscillator
    -- Internal Oscillator Component Declaration
    component SB_HFOSC  
	GENERIC( CLKHF_DIV :string :="0b10");
		PORT(
        CLKHFEN: IN STD_LOGIC ;
        CLKHFPU: IN STD_LOGIC;
        CLKHF:OUT STD_LOGIC
        );
	END COMPONENT;

	attribute CLKHF_DIV : string;
-- PLL Component Declaration
    component ICE40_MAIN_PROGRAM_100MHZ_pll
        Port (
            REFERENCECLK : in  std_logic;
            PLLOUTCORE   : out std_logic;
            PLLOUTGLOBAL : out std_logic;
            RESET        : in  std_logic
        );
    end component;
    
    -- Component declaration for current_shift
    component current_shift
        Port (
            clk            : in  std_logic;
            reset          : in  std_logic;
            S1             : in  std_logic;
            S3             : in  std_logic;
            control_out    : out integer
        );
    end component;

    -- Component declaration for PWM_GENERATOR
    component PWM_GENERATOR
        Port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            duty_input : in  integer;
            pwm_out    : out std_logic
        );
    end component;

    -- Component declaration for delay_measurement
    component delay_measurement
        Port (
            clk             : in  std_logic;
            reset           : in  std_logic;
            delay_tr_signal : in  std_logic;
            delay_hc_signal : in  std_logic;
            delay_tr        : out integer;
            delay_hc        : out integer
        );
    end component;

    -- Component declaration for PHASE_CONTROLLER
    component PHASE_CONTROLLER
        Port (
            clk           : in  std_logic;
            reset         : in  std_logic;
            start         : in  std_logic;
            IL_max_comp   : in  std_logic;
            IL_min_comp   : in  std_logic;
            delay_hc      : in  integer;
            delay_tr      : in  integer;
            S1            : out std_logic;
            S2            : out std_logic;
            state_error   : out std_logic
        );
    end component;

    -- Internal signals for clocking and control
    signal clk_100mhz         : std_logic;   -- PLL generated 100 MHz clock
    signal pwm_out1, pwm_out2 : std_logic;   -- PWM outputs for phase controllers
    signal state_error1, state_error2 : std_logic; -- Error signals for both controllers

    -- Signals for delay measurement
    signal measured_delay_tr  : integer;
    signal measured_delay_hc  : integer;

    -- Signals for current shift and PWM duty cycle
    signal pwm_duty_input     : integer := 0;  -- Output of current_shift to control the PWM duty cycle
    signal freq_S1            : integer;       -- Frequency of S1 signal
    signal freq_S3            : integer;       -- Frequency of S3 signal
    signal phase_shift_ns     : integer;       -- Phase shift between S1 and S3
	signal S1_buffor     : std_logic;       -- 
    signal S3_buffor     : std_logic;       -- 


begin

	-- Instantiate the internal high-frequency oscillator (HFOSC)
   	osc:SB_HFOSC
		generic map
		(
  			CLKHF_DIV     =>"0b10"    --12Mhz
		)
		port map
		(
  			CLKHFEN   =>'1',
  			CLKHFPU   =>'1',
  			CLKHF => clk_12mhz
		);
		--reset<= error_pin;
   -- PLL Instance for clock generation (12 MHz to 100.5 MHz)
    pll_inst: ICE40_MAIN_PROGRAM_100MHZ_pll
        Port map (
            REFERENCECLK => clk_12mhz,    -- 12 MHz input clock
            PLLOUTCORE   => open,   -- 100 MHz output clock
            PLLOUTGLOBAL => clk_100mhz,         -- Not used
            RESET        => reset         -- Reset input for PLL
        );
   

    -- Instantiate delay_measurement module for measuring delay_tr and delay_hc
    delay_measurement_inst: delay_measurement
        Port map (
            clk             => clk_100mhz,
            reset           => reset,
            delay_tr_signal => delay_tr_input,
            delay_hc_signal => delay_hc_input,
            delay_tr        => measured_delay_tr,  -- Output measured TR delay
            delay_hc        => measured_delay_hc   -- Output measured HC delay
        );

    -- Instantiate the first PHASE_CONTROLLER module (for controlling S1 and S2)
    phase_controller_inst1: PHASE_CONTROLLER
        Port map (
            clk             => clk_100mhz,
            reset           => reset,
            start           => start_stop,         -- Use start/stop control
            IL_max_comp     => il_max_comp1,       -- Connect comparator signal 1 (max current)
            IL_min_comp     => il_min_comp1,       -- Connect comparator signal 1 (min current)
            delay_hc        => measured_delay_hc,  -- Use measured delay for HC from delay_measurement
            delay_tr        => measured_delay_tr,  -- Use measured delay for TR from delay_measurement
            S1              => s1_phy,                 -- Output to transistor S1
            S2              => s2_phy,                 -- Output to transistor S2
            state_error     => state_error1        -- Error output signal
        );

    -- Instantiate the second PHASE_CONTROLLER module (for controlling S3 and S4)
    phase_controller_inst2: PHASE_CONTROLLER
        Port map (
            clk             => clk_100mhz,
            reset           => reset,
            start           => start_stop,         -- Same start/stop control
            IL_max_comp     => il_max_comp2,       -- Connect comparator signal 2 (max current)
            IL_min_comp     => il_min_comp2,       -- Connect comparator signal 2 (min current)
            delay_hc        => measured_delay_hc,  -- Same measured delay for HC
            delay_tr        => measured_delay_tr,  -- Same measured delay for TR
            S1              => s3_phy,                 -- Output to transistor S3
            S2              => s4_phy,                 -- Output to transistor S4
            state_error     => state_error2        -- Error output signal
        );
		S1_buffor<=s1_phy;
		S3_buffor<=s3_phy;
		 -- Instantiate the current_shift module to calculate the integer value
    current_shift_inst: current_shift
        Port map (
            clk             => clk_100mhz,
            reset           => reset,
            S1              => S1_buffor,                -- Input S1 signal
            S3              => S3_buffor,                -- Input S3 signal
            control_out     => pwm_duty_input     -- Output for PWM duty cycle control
        );

    -- Instantiate the PWM_GENERATOR to convert integer from current_shift into PWM signal
    pwm_generator_inst: PWM_GENERATOR
        Port map (
            clk => clk_100mhz,
            reset => reset,
            duty_input => pwm_duty_input,  -- Input from current_shift integer output
            pwm_out => pwm_output          -- Output PWM signal to be read by the microcontroller
        );
end Behavioral;