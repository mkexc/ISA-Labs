source /software/scripts/init_msim6.2g

vlib work

vcom constants.vhd
vcom CPU/DP/fetch_unit.vhd
vcom CPU/DP/registerfile.vhd
vcom CPU/DP/decode_unit.vhd
vcom CPU/DP/alu.vhd
vcom CPU/DP/abs_unit.vhd
vcom CPU/DP/exe_unit.vhd
vcom CPU/DP/mem_unit.vhd
vcom CPU/DP/wb_unit.vhd
vcom CPU/DP/DP.vhd
vcom CPU/CU/CU.vhd
vcom CPU/CU/FWD_DEC.vhd
vcom CPU/CU/FWD_EXE.vhd
vcom CPU/CU/HDU.vhd
vcom MEM/DRAM.vhd
vcom MEM/IRAM.vhd
vcom RISCV.vhd
vcom RISCV_tb.vhd

#for NOGUI: -c options
vsim -vopt work.riscv_tb -voptargs=+acc -do autorun.tcl


