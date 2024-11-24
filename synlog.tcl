history clear
project -load ICE40UP5K_PROGRAM_syn.prj
text_select 252 20 252 26
text_select 250 17 250 27
text_select 253 20 253 26
project -run  
set_option -vhdl2008 1
project -run  
project -save "C:/Users/Michal/Documents/Magisterka/Magisterka dokumenty wyjsciowe/FPGA/PROGRAM/CONTROL_FPGA_QSW_DC_DC_10KW_FPGA_VHDL/ICE40UP5K_PROGRAM_syn.prj" 
project -close "C:/Users/Michal/Documents/Magisterka/Magisterka dokumenty wyjsciowe/FPGA/PROGRAM/CONTROL_FPGA_QSW_DC_DC_10KW_FPGA_VHDL/ICE40UP5K_PROGRAM_syn.prj"
