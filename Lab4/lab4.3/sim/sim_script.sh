#!/bin/bash

if [ -d "work" ]; then
rm -rf work
fi

source /software/scripts/init_questa10.7c

vlib work

vcom ../src/common/*.vhd
vcom ../src/MBE/src/functions.vhd
vcom ../src/MBE/src/*.vhd
#vcom ../src/fpuvhdl/multiplier/flipflop.vhd
vcom ../src/multiplier/register.vhd
vcom ../src/multiplier/fpmul_stage1_struct.vhd
vcom ../src/multiplier/fpmul_stage2_dadda_struct.vhd
vcom ../src/multiplier/fpmul_stage3_struct.vhd
vcom ../src/multiplier/fpmul_stage4_struct.vhd
#vcom ../src/fpuvhdl/multiplier/fpmul_single_cycle.vhd
vcom ../src/multiplier/fpmul_pipeline.vhd
#vcom ../src/fpuvhdl/multiplier/fpmul_pipeline_inregs.vhd
#vcom ../src/fpuvhdl/multiplier/fpmul_pipeline_inregs_stage2regs.vhd

#vcom ../src/multiplier/*.vhd

vlog -sv ../tb/top.sv

vsim -c top -do run.tcl > FPMUL_OUT.txt
