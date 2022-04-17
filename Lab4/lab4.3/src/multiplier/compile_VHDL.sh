#!/bin/bash

source /software/scripts/init_msim6.2g

vlib work

vcom ../MBE/src/functions.vhd
vcom ../MBE/src/ha.vhd
vcom ../MBE/src/fa.vhd
vcom ../MBE/src/register.vhd
vcom ../MBE/src/booth_mod_enc.vhd
vcom ../MBE/src/booth_gen.vhd
vcom ../MBE/src/partial_products_gen.vhd
vcom ../MBE/src/dadda_tree.vhd
vcom ../MBE/src/adder.vhd
vcom ../MBE/src/multiplier.vhd
vcom ../common/*.vhd
vcom ./flipflop.vhd
vcom ./fpmul_stage1_struct.vhd
vcom ./fpmul_stage2_struct.vhd
vcom ./fpmul_stage3_struct.vhd
vcom ./fpmul_stage4_struct.vhd
#vcom ./fpmul_single_cycle.vhd
#vcom ./fpmul_pipeline.vhd
#vcom ./fpmul_pipeline_inregs.vhd
vcom ./fpmul_pipeline_inregs_stage2regs.vhd
