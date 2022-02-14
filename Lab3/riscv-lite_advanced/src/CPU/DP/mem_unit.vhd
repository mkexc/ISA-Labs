library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--DRAM_WR and DRAM_RD are the control signals from CU. They pass thorugh DP and go to data memory (out of DP)

entity mem_unit is
    port (
        clk, rst, en                                    : in std_logic;
        ALU_OUT_IN, MEM_DATA, DRAM_OUT_IN               : in std_logic_vector(31 downto 0);
        DRAM_WR_IN, DRAM_RD_IN                          : in std_logic;
        RD_IN                                           : in std_logic_vector(4 downto 0);
        RD_OUT                                          : out std_logic_vector(4 downto 0);
        DRAM_WR, DRAM_RD                                : out std_logic;
        ALU_OUT, DRAM_OUT, DRAM_IN         	 	        : out std_logic_vector(31 downto 0)             
    );
end entity mem_unit;

architecture rtl of mem_unit is
    signal currALU, currMEM_DATA    : std_logic_vector(31 downto 0);
    signal currRD                   : std_logic_vector(4 downto 0);
begin
    
    process (clk)
    begin
        if(rising_edge(clk)) then
            if(rst = '1') then
                currALU      <=  (others=>'0');
                currMEM_DATA <=  (others=>'0');
                currRD       <=  (others=>'0');
            elsif (en = '1') then
                currALU      <=  ALU_OUT_IN;
                currMEM_DATA <=  MEM_DATA;
                currRD       <=  RD_IN;
            end if;
        end if;
    end process;
    
    RD_OUT        <= currRD;
    ALU_OUT       <= currALU;
    DRAM_IN       <= currMEM_DATA;
    DRAM_OUT      <= DRAM_OUT_IN;
    DRAM_WR       <= DRAM_WR_IN;
    DRAM_RD       <= DRAM_RD_IN;
    
end architecture rtl;
