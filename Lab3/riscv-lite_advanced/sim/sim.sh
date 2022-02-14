source /software/scripts/init_msim6.2g

vlib work

vcom ../src/constants.vhd
vcom ../src/CPU/DP/fetch_unit.vhd
vcom ../src/CPU/DP/registerfile.vhd
vcom ../src/CPU/DP/decode_unit.vhd
vcom ../src/CPU/DP/alu.vhd
vcom ../src/CPU/DP/abs_unit.vhd
vcom ../src/CPU/DP/exe_unit.vhd
vcom ../src/CPU/DP/mem_unit.vhd
vcom ../src/CPU/DP/wb_unit.vhd
vcom ../src/CPU/DP/DP.vhd
vcom ../src/CPU/CU/FWD_DEC.vhd
vcom ../src/CPU/CU/FWD_EXE.vhd
vcom ../src/CPU/CU/HDU.vhd
vcom ../src/CPU/CU/CU.vhd
vcom ../src/MEM/DRAM.vhd
vcom ../src/MEM/IRAM.vhd
vcom ../src/RISCV.vhd
vcom ../tb/RISCV_tb.vhd

#for NOGUI: -c options
vsim -vopt work.riscv_tb -voptargs=+acc -do autorun.tcl


