#!/bin/bash

source /software/scripts/init_msim6.2g

vlib work

#vcom ../src/fpuvhdl/MBE/src/functions.vhd
#vcom ../src/fpuvhdl/MBE/src/ha.vhd
#vcom ../src/fpuvhdl/MBE/src/fa.vhd
#vcom ../src/fpuvhdl/MBE/src/register.vhd
#vcom ../src/fpuvhdl/MBE/src/booth_mod_enc.vhd
#vcom ../src/fpuvhdl/MBE/src/booth_gen.vhd
#vcom ../src/fpuvhdl/MBE/src/partial_products_gen.vhd
#vcom ../src/fpuvhdl/MBE/src/dadda_tree.vhd
#vcom ../src/fpuvhdl/MBE/src/adder.vhd
#vcom ../src/fpuvhdl/MBE/src/multiplier.vhd
vcom ../src/fpuvhdl/common/*.vhd
#vcom ../src/fpuvhdl/multiplier/flipflop.vhd
vcom ../src/fpuvhdl/multiplier/register.vhd
vcom ../src/fpuvhdl/multiplier/fpmul_stage1_struct.vhd
vcom ../src/fpuvhdl/multiplier/fpmul_stage2_struct.vhd
vcom ../src/fpuvhdl/multiplier/fpmul_stage3_struct.vhd
vcom ../src/fpuvhdl/multiplier/fpmul_stage4_struct.vhd
#vcom ../src/fpuvhdl/multiplier/fpmul_single_cycle.vhd
#vcom ../src/fpuvhdl/multiplier/fpmul_pipeline.vhd
vcom ../src/fpuvhdl/multiplier/fpmul_pipeline_inregs.vhd
#vcom ../src/fpuvhdl/multiplier/fpmul_pipeline_inregs_stage2regs.vhd


# in case you want to perform post synthesis simulation
#vlog ./postSyn.v


vcom ../tb/clk_gen.vhd
vcom ../tb/data_maker.vhd
vcom ../tb/data_sink.vhd
vlog ../tb/tb_fpmul.v

# NO GUI (with GUI: remove -c)
vsim work.tb_fpmul -do autorun.tcl


# in case you want to perform post synthesis simulation
#vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_fpmul/UUT=./postSyn.sdf work.tb_fpmul -do run.tcl
