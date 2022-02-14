;# add all files
analyze -f vhdl -lib WORK ../src/constants.vhd
analyze -f vhdl -lib WORK ../src/CPU/DP/fetch_unit.vhd
analyze -f vhdl -lib WORK ../src/CPU/DP/registerfile.vhd
analyze -f vhdl -lib WORK ../src/CPU/DP/decode_unit.vhd
analyze -f vhdl -lib WORK ../src/CPU/DP/alu.vhd
analyze -f vhdl -lib WORK ../src/CPU/DP/exe_unit.vhd
analyze -f vhdl -lib WORK ../src/CPU/DP/mem_unit.vhd
analyze -f vhdl -lib WORK ../src/CPU/DP/wb_unit.vhd
analyze -f vhdl -lib WORK ../src/CPU/DP/DP.vhd
analyze -f vhdl -lib WORK ../src/CPU/CU/FWD_DEC.vhd
analyze -f vhdl -lib WORK ../src/CPU/CU/FWD_EXE.vhd
analyze -f vhdl -lib WORK ../src/CPU/CU/HDU.vhd
analyze -f vhdl -lib WORK ../src/CPU/CU/CU.vhd
analyze -f vhdl -lib WORK ../src/RISCV.vhd

###set power_preserve_rtl_hier_names true
elaborate RISCV -arch rtl -lib WORK

# Force DC to flatten the hierarchy and synthesize. Find max frequency and area.
#ungroup -all -flatten

### specify clock constraints 
#create_clock -name my_clk -period $env(P_VAL) clk
create_clock -name my_clk -period 1.57 clk
#create_clock -name my_clk -period 1.57 clk
set_dont_touch_network my_clk
set_clock_uncertainty 0.07 [get_clocks my_clk]
set_input_delay 0.5 -max -clock my_clk [remove_from_collection [all_inputs] clk]
set_output_delay 0.5 -max -clock my_clk [all_outputs]

set oload [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $oload [all_outputs]

#compile
compile_ultra

#report_resources

report_timing > riscv_timing_ultra.txt
report_area > riscv_area_ultra.txt

#change_names -hierarchy -rules verilog
#write_sdf ../netlist/RISCV.sdf
#write -f verilog -hierarchy -output ../netlist/RISCV.v
#write_sdc ../netlist/RISCV.sdc

quit
