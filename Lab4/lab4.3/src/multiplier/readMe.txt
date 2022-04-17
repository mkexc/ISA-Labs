use compile_VHDL.sh just to make sure that the VHDL syntax of the files .vhd is correct.
go to to /sim directory to run simulation. 


fpmulpipeline.vhd is the standard multiplier.

fpmulpipeline_inregs.vhd is the multiplier with registers to the inputs.

fpmulpipeline_inregs_stage2regs.vhd is the multiplier with regs both at the input and at the stage2 input.

NB. fpmul_pipeline_stage2regs is a previous version of the multiplier that MUST NOT be considered.

extension .bk is used to avoid the compilation of the file.
