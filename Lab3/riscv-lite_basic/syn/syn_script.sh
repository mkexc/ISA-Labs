#!/bin/bash

source /software/scripts/init_synopsys_64.18

	### REMOVE WORK DIRECTORY IN CASE OF RE-RUN

# set up the environment
#rm -rf work
mkdir work
# start with constraint 0.00 to get the minimum period 
p_ini=0.00
echo "period=$p_ini"
# invoke DC
export P_VAL=$p_ini
dc_shell-xg-t -f shell_script.tcl > /dev/null
# analyze timing report
slack=$(grep slack riscv_timing_ultra.txt) 
echo $slack
res=$(grep MET riscv_timing_ultra.txt)
p_ini=$(echo $slack | sed "s/[^0-9.][^0-9]*//g")
#echo "period=$p_ini"
# keep the minimum period separated (see later)
p_new=$p_ini
export P_VAL=$p_new

# iterate until the slack is MET and it is 0.00 
while [ "$p_new" != "0.00" ] || [ "$res" == "" ]
do
	echo "period=$p_ini"
	# invoke DC
	dc_shell-xg-t -f shell_script.tcl > /dev/null
	# analyze timing report
	slack=$(grep slack riscv_timing_ultra.txt) 
	echo $slack
	res=$(grep MET riscv_timing_ultra.txt)
	p_new=$(echo $slack | sed "s/[^0-9.][^0-9]*//g")
	p_ini=$(bc -l <<< "$p_ini+0.01")
	#echo "period=$p_ini"
	# clean the environment
	export P_VAL=$p_ini	
	rm -rf work
done
