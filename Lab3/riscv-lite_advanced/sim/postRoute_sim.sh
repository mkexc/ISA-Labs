source /software/scripts/init_msim6.2g

vlib work

vcom ../src/constants.vhd
vcom ../src/MEM/DRAM.vhd
vcom ../src/MEM/IRAM.vhd
vlog ../innovus/RISCV.v
vcom ../tb/RISCV_tb.vhd

#for NOGUI: -c options
vsim -vopt -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /RISCV_tb/riscv_i=../innovus/RISCV.sdf work.riscv_tb -voptargs=+acc -do waves_gate.tcl


