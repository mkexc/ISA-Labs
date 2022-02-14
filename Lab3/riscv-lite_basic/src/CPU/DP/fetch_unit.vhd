library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- The instruction memory is out of the fetching unit

entity fetch_unit is
    port (
        clk, rst, en    : in std_logic;
        PC_MUX_SEL  : in std_logic;
        IRAM_DOUT_IN: in std_logic_vector(31 downto 0);
        PC_JUMP_ADDR: in std_logic_vector(31 downto 0);
        PC          : out std_logic_vector(31 downto 0);
        IR_IN       : out std_logic_vector(31 downto 0)
    );
end entity fetch_unit;

architecture rtl of fetch_unit is
    signal currPC, nextPC : std_logic_vector(31 downto 0);
begin
    
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(rst = '1') then
                currPC<=(others => '0');
            elsif(en = '1') then
                currPC<=nextPC;
            end if;
        end if;
    end process;
  
    nextPC <=  std_logic_vector(signed(currPC)+to_signed(4,currPC'length)) when PC_MUX_SEL = '0' else -- next address
               PC_JUMP_ADDR;                                                                          -- jmp address (jal or beq)
    
    IR_IN<=IRAM_DOUT_IN; -- Instruction memory output

    PC<=currPC;

end architecture rtl;