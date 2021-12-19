;# add all files

;# MBE
analyze -f vhdl -lib WORK ../src/fpuvhdl/MBE/src/functions.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/MBE/src/ha.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/MBE/src/fa.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/MBE/src/booth_mod_enc.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/MBE/src/booth_gen.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/MBE/src/partial_products_gen.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/MBE/src/dadda_tree.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/MBE/src/adder.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/MBE/src/multiplier.vhd
;# common
analyze -f vhdl -lib WORK ../src/fpuvhdl/common/fpnormalize_fpnormalize.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/common/fpround_fpround.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/common/packfp_packfp.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/common/unpackfp_unpackfp.vhd
;# multiplier
analyze -f vhdl -lib WORK ../src/fpuvhdl/multiplier/register.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/multiplier/flipflop.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/multiplier/fpmul_stage1_struct.vhd
#analyze -f vhdl -lib WORK ../src/fpuvhdl/multiplier/fpmul_stage2_struct.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/multiplier/fpmul_stage2_dadda_struct.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/multiplier/fpmul_stage3_struct.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/multiplier/fpmul_stage4_struct.vhd
#analyze -f vhdl -lib WORK ../src/fpuvhdl/multiplier/fpmul_pipeline.vhd
#analyze -f vhdl -lib WORK ../src/fpuvhdl/multiplier/fpmul_pipeline_inregs.vhd
analyze -f vhdl -lib WORK ../src/fpuvhdl/multiplier/fpmul_pipeline_inregs_stage2regs.vhd

###set power_preserve_rtl_hier_names true
elaborate FPmul -arch pipeline -lib WORK

# Force DC to flatten the hierarchy and synthesize. Find max frequency and area.
ungroup -all -flatten

# Force DC to flatten the hierarchy and to implement CSA mult. Find max frequency and area.
#set_implementation DW02_mult/csa [find cell I2/mult_134]

# Force DC to flatten the hierarchy and to implement pparch mult. Find max frequency and area.
#set_implementation DW02_mult/pparch [find cell I2/mult_134]

# Force DC to flatten the hierarchy and to implement pparch add. Find max frequency and area.
#set_implementation DW01_add/pparch [find cell I2/mult/addr/add_26]


### specify clock constraints 
#create_clock -name my_clk -period $env(P_VAL) clk
create_clock -name my_clk -period 2.88 clk
set_dont_touch_network my_clk
set_clock_uncertainty 0.07 [get_clocks my_clk]
set_input_delay 0.5 -max -clock my_clk [remove_from_collection [all_inputs] clk]
set_output_delay 0.5 -max -clock my_clk [all_outputs]

set oload [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $oload [all_outputs]

#compile_ultra
compile
#optimize_registers
report_resources

report_timing > syn_timing_original.txt
report_area > syn_area_original.txt

;# in case you want to perform post synthesis simulation
#write_sdf ./../src/fpuvhdl/multiplier/postSyn.sdf
#write -f verilog -hierarchy -output ./../src/fpuvhdl/multiplier/postSyn.v

quit
