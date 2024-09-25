--
-- Synopsys
-- Vhdl wrapper for top level design, written on Thu Sep 19 21:42:54 2024
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wrapper_for_MAIN is
   port (
      clk_12mhz : in std_logic;
      reset : in std_logic;
      start_stop : in std_logic;
      error_pin : in std_logic;
      il_max_comp1 : in std_logic;
      il_max_comp2 : in std_logic;
      il_min_comp1 : in std_logic;
      il_min_comp2 : in std_logic;
      delay_tr_input : in std_logic;
      delay_hc_input : in std_logic;
      s1_phy : out std_logic;
      s2_phy : out std_logic;
      s3_phy : out std_logic;
      s4_phy : out std_logic;
      pwm_output : out std_logic
   );
end wrapper_for_MAIN;

architecture behavioral of wrapper_for_MAIN is

component MAIN
 port (
   clk_12mhz : in std_logic;
   reset : in std_logic;
   start_stop : in std_logic;
   error_pin : in std_logic;
   il_max_comp1 : in std_logic;
   il_max_comp2 : in std_logic;
   il_min_comp1 : in std_logic;
   il_min_comp2 : in std_logic;
   delay_tr_input : in std_logic;
   delay_hc_input : in std_logic;
   s1_phy : out std_logic;
   s2_phy : out std_logic;
   s3_phy : out std_logic;
   s4_phy : out std_logic;
   pwm_output : out std_logic
 );
end component;

signal tmp_clk_12mhz : std_logic;
signal tmp_reset : std_logic;
signal tmp_start_stop : std_logic;
signal tmp_error_pin : std_logic;
signal tmp_il_max_comp1 : std_logic;
signal tmp_il_max_comp2 : std_logic;
signal tmp_il_min_comp1 : std_logic;
signal tmp_il_min_comp2 : std_logic;
signal tmp_delay_tr_input : std_logic;
signal tmp_delay_hc_input : std_logic;
signal tmp_s1_phy : std_logic;
signal tmp_s2_phy : std_logic;
signal tmp_s3_phy : std_logic;
signal tmp_s4_phy : std_logic;
signal tmp_pwm_output : std_logic;

begin

tmp_clk_12mhz <= clk_12mhz;

tmp_reset <= reset;

tmp_start_stop <= start_stop;

tmp_error_pin <= error_pin;

tmp_il_max_comp1 <= il_max_comp1;

tmp_il_max_comp2 <= il_max_comp2;

tmp_il_min_comp1 <= il_min_comp1;

tmp_il_min_comp2 <= il_min_comp2;

tmp_delay_tr_input <= delay_tr_input;

tmp_delay_hc_input <= delay_hc_input;

s1_phy <= tmp_s1_phy;

s2_phy <= tmp_s2_phy;

s3_phy <= tmp_s3_phy;

s4_phy <= tmp_s4_phy;

pwm_output <= tmp_pwm_output;



u1:   MAIN port map (
		clk_12mhz => tmp_clk_12mhz,
		reset => tmp_reset,
		start_stop => tmp_start_stop,
		error_pin => tmp_error_pin,
		il_max_comp1 => tmp_il_max_comp1,
		il_max_comp2 => tmp_il_max_comp2,
		il_min_comp1 => tmp_il_min_comp1,
		il_min_comp2 => tmp_il_min_comp2,
		delay_tr_input => tmp_delay_tr_input,
		delay_hc_input => tmp_delay_hc_input,
		s1_phy => tmp_s1_phy,
		s2_phy => tmp_s2_phy,
		s3_phy => tmp_s3_phy,
		s4_phy => tmp_s4_phy,
		pwm_output => tmp_pwm_output
       );
end behavioral;
