####---- CreateClock list ----2
create_clock  -period 10.00 -waveform {0.00 5.00} -name {MAIN|delay_tr_input} [get_ports {delay_tr_input}] 
create_clock  -period 10.00 -waveform {0.00 5.00} -name {MAIN|delay_hc_input} [get_ports {delay_hc_input}] 

####---- SetFalsePath list ----2
set_false_path  -from [get_clocks {MAIN|delay_hc_input}]  -to [get_clocks {MAIN|delay_tr_input}]
set_false_path  -from [get_clocks {MAIN|delay_tr_input}]  -to [get_clocks {MAIN|delay_hc_input}]

