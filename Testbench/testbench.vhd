-- Testbench for MAIN.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MAIN_tb is
end MAIN_tb;

architecture Behavioral of MAIN_tb is

    -- Component declaration for MAIN
    component MAIN
        Port (
            -- Inputs
            reset          : in  std_logic;
            start_stop     : in  std_logic;
            error_pin      : in  std_logic;
            il_max_comp1   : in  std_logic;
            il_max_comp2   : in  std_logic;
            il_min_comp1   : in  std_logic;
            il_min_comp2   : in  std_logic;
            delay_tr_input : in  std_logic;
            delay_hc_input : in  std_logic;
            
            -- Outputs
            s1_phy         : out std_logic;
            s2_phy         : out std_logic;
            s3_phy         : out std_logic;
            s4_phy         : out std_logic;
            pwm_output     : out std_logic;
            rgb_r          : out std_logic;
            rgb_g          : out std_logic;
            rgb_b          : out std_logic
        );
    end component;

    -- Signals to connect to MAIN ports
    signal reset          : std_logic := '0';
    signal start_stop     : std_logic := '0';
    signal error_pin      : std_logic := '0';
    signal il_max_comp1   : std_logic := '0';
    signal il_max_comp2   : std_logic := '0';
    signal il_min_comp1   : std_logic := '0';
    signal il_min_comp2   : std_logic := '0';
    signal delay_tr_input : std_logic := '0';
    signal delay_hc_input : std_logic := '0';

    signal s1_phy         : std_logic;
    signal s2_phy         : std_logic;
    signal s3_phy         : std_logic;
    signal s4_phy         : std_logic;
    signal pwm_output     : std_logic;
    signal rgb_r          : std_logic;
    signal rgb_g          : std_logic;
    signal rgb_b          : std_logic;

    -- Clock signal for driving simulation
    signal clk_100mhz     : std_logic := '0';

begin

    -- Instantiate the MAIN module
    uut: MAIN
        port map (
            reset          => reset,
            start_stop     => start_stop,
            error_pin      => error_pin,
            il_max_comp1   => il_max_comp1,
            il_max_comp2   => il_max_comp2,
            il_min_comp1   => il_min_comp1,
            il_min_comp2   => il_min_comp2,
            delay_tr_input => delay_tr_input,
            delay_hc_input => delay_hc_input,
            s1_phy         => s1_phy,
            s2_phy         => s2_phy,
            s3_phy         => s3_phy,
            s4_phy         => s4_phy,
            pwm_output     => pwm_output,
            rgb_r          => rgb_r,
            rgb_g          => rgb_g,
            rgb_b          => rgb_b
        );

    -- Clock generation process
    clk_process: process
    begin
        clk_100mhz <= '0';
        wait for 5 ns;
        clk_100mhz <= '1';
        wait for 5 ns;
    end process clk_process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Initial reset
        reset <= '1';
        wait for 500 ns;
        reset <= '0';
        
        -- Start the FPGA logic
        start_stop <= '1';
        wait for 50 ns;
        
        -- Apply some test stimulus
       -- il_max_comp1 <= '1';
       -- il_min_comp1 <= '1';
       -- wait for 20 ns;
        
        --il_max_comp2 <= '1';
        --il_min_comp2 <= '1';
        --wait for 20 ns;

        delay_tr_input <= '1';
        wait for 1000 ns;
        delay_tr_input <= '0';

        delay_hc_input <= '1';
        wait for 1000 ns;
	delay_hc_input <= '0';
        
        -- Deactivate start
        --start_stop <= '0';
       -- wait for 50 ns;

        -- Monitor responses for a while
        wait for 200 ns;

        -- End simulation
        wait;
    end process stimulus_process;

end Behavioral;
