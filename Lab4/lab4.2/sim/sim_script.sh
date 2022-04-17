#!/bin/bash

if [ -d "work" ]; then
rm -rf work
fi

source /software/scripts/init_questa10.7c

vlib work

vcom ../src/functions.vhd
vcom ../src/*.vhd

vlog -sv ../tb/top.sv

vsim -c top -do run.tcl > MBE_out.txt
