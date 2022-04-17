#!/bin/bash

rm -rf work

source /software/scripts/init_questa10.7c

vlib work

vlog -sv ../tb/top.sv

vsim -c top -do run.tcl > adderOut_wrongSign.txt
