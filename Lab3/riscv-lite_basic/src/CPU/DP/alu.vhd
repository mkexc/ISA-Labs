-- riscv_alu:
-- supported instructions: add,addi,auipc,lui,beq,lw,srai,andi,xor,slt,jal,sw	
-- operations to be supported by alu:
-- ADD 		-> add,addi,auipc,lw,sw		OVERFLOW ARE IGNORED (see manual @page 20)
-- BITAND 	-> andi
-- BITXOR 	-> xor
-- SAR		-> srai
-- EQU		-> beq
-- CMP		-> slt (signed compare)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity alu is
	generic (N : integer := 32);
	port (
		OP					: in type_op;
		ALU_OPA, ALU_OPB	: in std_logic_vector(N-1 downto 0);
		ALU_OUT				: out std_logic_vector(N-1 downto 0)
	);
end alu;

architecture behavior of alu is
begin

	aluProc : process (OP, ALU_OPA, ALU_OPB)
	begin
		case OP is

			when BITAND		=> 	ALU_OUT	<= ALU_OPA and ALU_OPB;

			when BITXOR		=> 	ALU_OUT	<= ALU_OPA xor ALU_OPB;

			--SRAI: shift right of ALU_OPA of 'shamt' positions
			--'shamt' = instr(24 downto 20) that is moved at positions (4 downto 0) of ALU input (@risc-spec pg 19)
			--This allows to shift of a maximum of 2^5 positions
			when SAR		=>	for i in N-1 downto 0 loop
									if (i >= (N-(to_integer(unsigned(ALU_OPB(4 downto 0)))))) then
										ALU_OUT(i) <= ALU_OPA(N-1);
									else
										ALU_OUT(i) <= ALU_OPA(i+(to_integer(unsigned(ALU_OPB(4 downto 0)))));
									end if;
								end loop;

			when CMP		=>	if (signed(ALU_OPA)<signed(ALU_OPB)) then
									ALU_OUT <= (N-1 downto 1 => '0')&'1';
								else
									ALU_OUT <= (N-1 downto 0 => '0');
								end if;
								
			when others 	=> 	ALU_OUT	<= std_logic_vector(signed(ALU_OPA)+signed(ALU_OPB));
		
		end case;
	end process aluProc;
end behavior;
