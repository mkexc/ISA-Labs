library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity wb_unit is
    port (
        clk, rst, en                       : in std_logic;
        RD_IN                              : in std_logic_vector(4 downto 0);
        ALU_OUT, DRAM_OUT                  : in std_logic_vector(31 downto 0);
        MUX_SEL                            : in std_logic;
        RD_OUT                             : out std_logic_vector(4 downto 0);
        WB_OUT                             : out std_logic_vector(31 downto 0)
    );
end entity wb_unit;

architecture rtl of wb_unit is
    signal currALU, currMEM: std_logic_vector(31 downto 0);
    signal currRD : std_logic_vector(4 downto 0);
begin
    
    process (clk)
    begin
        if (rising_edge(clk)) then
            if(rst = '1') then
                currALU<=(others=>'0');
                currMEM<=(others=>'0');
                currRD<=(others=>'0');
            elsif (en = '1') then
                currALU<=ALU_OUT;
                currMEM<=DRAM_OUT;
                currRD<=RD_IN;
            end if;
        end if;
    end process;

    RD_OUT <= currRD;
    WB_OUT <= currALU when MUX_SEL = '0' else currMEM;  
    
end architecture rtl;