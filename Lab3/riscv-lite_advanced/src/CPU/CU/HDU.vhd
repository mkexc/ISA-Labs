library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity HDU is
    port (
        RS1_IF_ID, RS2_IF_ID : in std_logic_vector(4 downto 0);
        RD_ID_EXE : in std_logic_vector(4 downto 0);
        RD_EXE_MEM : in std_logic_vector(4 downto 0);
        MEM_LD_EXE : in std_logic;
        MEM_LD_MEM : in std_logic;
        IS_COND_JUMP: in std_logic;
        STALL : out std_logic
    );
end entity HDU;

architecture rtl of HDU is

begin

    hazard_man: process(RS1_IF_ID, RS2_IF_ID, RD_ID_EXE, RD_EXE_MEM, MEM_LD_EXE, MEM_LD_MEM, IS_COND_JUMP)
    begin
        if (MEM_LD_EXE = '1' or IS_COND_JUMP = '1') and (RS1_IF_ID = RD_ID_EXE or RS2_IF_ID = RD_ID_EXE) then
            STALL<='1';
        elsif (MEM_LD_MEM = '1' and IS_COND_JUMP = '1') and (RS1_IF_ID = RD_EXE_MEM or RS2_IF_ID = RD_EXE_MEM) then
            STALL <= '1';
        else
            STALL<='0';
        end if;
    end process hazard_man;

end architecture;