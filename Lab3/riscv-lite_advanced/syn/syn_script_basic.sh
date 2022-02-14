#!/bin/bash

source /software/scripts/init_synopsys_64.18

	### REMOVE WORK DIRECTORY IN CASE OF RE-RUN

mkdir work

dc_shell-xg-t -f shell_script.tcl
