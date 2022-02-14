library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FWD_EXE is
    port (
        RS1_ID_EX       : in std_logic_vector(4 downto 0);
        RS2_ID_EX       : in std_logic_vector(4 downto 0);
        RD_EX_MEM       : in std_logic_vector(4 downto 0);
        RD_MEM_WB       : in std_logic_vector(4 downto 0);
        MUX_OPA_SEL_STD : in std_logic_vector(2 downto 0);
        MUX_OPB_SEL_STD : in std_logic_vector(2 downto 0);
        EXE_MEM_WR      : in std_logic;
        MEM_WB_WR       : in std_logic;
        MUX_OPA_SEL     : out std_logic_vector(2 downto 0);
        MUX_OPB_SEL     : out std_logic_vector(2 downto 0)
    );
end entity FWD_EXE;

architecture rtl of FWD_EXE is
    
begin
    
    mux_op_man: process (RS1_ID_EX, RS2_ID_EX, RD_EX_MEM, RD_MEM_WB, MUX_OPA_SEL_STD, MUX_OPB_SEL_STD, EXE_MEM_WR, MEM_WB_WR)
    begin
        -- OPA
        if RS1_ID_EX = RD_EX_MEM and EXE_MEM_WR = '1' and RD_EX_MEM /= (4 downto 0 => '0') then
            MUX_OPA_SEL <= "011";
        elsif RS1_ID_EX = RD_MEM_WB and MEM_WB_WR = '1' and RD_MEM_WB /= (4 downto 0 => '0') then
            MUX_OPA_SEL <= "100";
        else
            MUX_OPA_SEL <= MUX_OPA_SEL_STD;
        end if;

        -- OPB
        if RS2_ID_EX = RD_EX_MEM and EXE_MEM_WR = '1' and RD_EX_MEM /= (4 downto 0 => '0') then
            MUX_OPB_SEL <= "011";
        elsif RS2_ID_EX = RD_MEM_WB and MEM_WB_WR = '1' and RD_MEM_WB /= (4 downto 0 => '0') then
            MUX_OPB_SEL <= "100";
        else
            MUX_OPB_SEL <= MUX_OPB_SEL_STD;
        end if;
    end process mux_op_man;
    

    
end architecture rtl;