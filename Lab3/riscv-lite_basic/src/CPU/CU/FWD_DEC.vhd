library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FWD_DEC is
    port (
        RS1_IF_ID : in std_logic_vector(4 downto 0);
        RS2_IF_ID : in std_logic_vector(4 downto 0);
        IS_COND_JUMP: in std_logic;
        RD_EX_MEM  : in std_logic_vector(4 downto 0);
        RD_MEM_WB  : in std_logic_vector(4 downto 0);
        MUX_REGA_SEL : out std_logic_vector(1 downto 0);
        MUX_REGB_SEL : out std_logic_vector(1 downto 0)
    );
end entity FWD_DEC;

architecture rtl of FWD_DEC is
    
begin
    
    process (RS1_IF_ID , RS2_IF_ID , IS_COND_JUMP, RD_EX_MEM , RD_MEM_WB)
    begin
        if IS_COND_JUMP = '1' and RS1_IF_ID=RD_EX_MEM and RS1_IF_ID /= (4 downto 0 => '0') then
            MUX_REGA_SEL<="01";
        elsif RS1_IF_ID=RD_MEM_WB and RS1_IF_ID /= (4 downto 0 => '0') then
            MUX_REGA_SEL<="10";
        else
            MUX_REGA_SEL<="00";
        end if;

        if IS_COND_JUMP = '1' and RS2_IF_ID=RD_EX_MEM and RS2_IF_ID /= (4 downto 0 => '0') then
            MUX_REGB_SEL<="01";
        elsif RS2_IF_ID=RD_MEM_WB and RS2_IF_ID /= (4 downto 0 => '0') then
            MUX_REGB_SEL<="10";
        else
            MUX_REGB_SEL<="00";
        end if;
    end process;
    
end architecture rtl;