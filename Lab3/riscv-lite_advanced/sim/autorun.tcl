#add wave *
#add wave -position insertpoint sim:/riscv_tb/riscv_i/DP_u/FETCH_U/*
#add wave -position insertpoint sim:/riscv_tb/riscv_i/DP_u/DECODE_U/*
#add wave -position insertpoint sim:/riscv_tb/riscv_i/DP_u/EXE_U/*
#add wave -position insertpoint sim:/riscv_tb/riscv_i/DP_u/MEM_U/*
#add wave -position insertpoint sim:/riscv_tb/riscv_i/DP_u/WB_U/*
#add wave -position insertpoint sim:/riscv_tb/riscv_i/CU_u/*
#add wave -position insertpoint sim:/riscv_tb/riscv_i/DP_u/DECODE_U/rf/REGISTERS
#run 460 ns
#quit

# For server
add wave *
add wave sim:/riscv_tb/riscv_i/DP_u/DECODE_U/rf/REGISTERS
add wave sim:/riscv_tb/riscv_i/CU_u/*
add wave sim:/riscv_tb/riscv_i/DP_u/FETCH_U/*
add wave sim:/riscv_tb/riscv_i/DP_u/DECODE_U/*
add wave sim:/riscv_tb/riscv_i/DP_u/EXE_U/*
add wave sim:/riscv_tb/riscv_i/DP_u/MEM_U/*
add wave sim:/riscv_tb/riscv_i/DP_u/WB_U/*
add wave sim:/riscv_tb/riscv_i/cu_u/forward_unit_exe/*
add wave sim:/riscv_tb/riscv_i/cu_u/forward_unit_dec/*
add wave sim:/riscv_tb/riscv_i/cu_u/hazard_unit/*
run 3 us
