library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity exe_unit is
    port (
        clk, rst, en                : in    std_logic;
        RF_OUT1, RF_OUT2, PC, IMM   : in    std_logic_vector(31 downto 0);
        EXE_MEM_IN, MEM_WB_IN       : in    std_logic_vector(31 downto 0);
        RD_IN, RS1_IN, RS2_IN       : in    std_logic_vector(4 downto 0);
        ALU_OP                      : in    type_op;
        ALU_OPA_SEL, ALU_OPB_SEL    : in    std_logic_vector(2 downto 0); 
        ALU_OUT, MEM_DATA			: out   std_logic_vector(31 downto 0);
        RD_OUT, RS1_OUT, RS2_OUT    : out   std_logic_vector(4 downto 0)
    );
end entity exe_unit;

architecture rtl of exe_unit is
    
    component alu is
    	generic (N : integer := 32);
    	port (
    		OP					: in type_op;
    		ALU_OPA, ALU_OPB	: in std_logic_vector(N-1 downto 0);
    		ALU_OUT				: out std_logic_vector(N-1 downto 0)
    	);
    end component alu;

    signal currRD, currRS1, currRS2 : std_logic_vector(4 downto 0);
    signal currRF1, currRF2, currPC, currIMM, ALU_OPA, ALU_OPB: std_logic_vector(31 downto 0);

begin

    alu_i: alu 
    port map (
        OP => ALU_OP,
        ALU_OPA => ALU_OPA,
        ALU_OPB => ALU_OPB,
        ALU_OUT => ALU_OUT
    );
    
    process (clk)
    begin
        if(rising_edge(clk)) then
            if(rst = '1') then
                currRD  <=(others=>'0');
                currRF1 <=(others=>'0');
                currRF2 <=(others=>'0');
                currPC<=(others=>'0');
                currIMM<=(others=>'0');
                currRS1<=(others => '0');
                currRS2<=(others => '0');
            elsif(en = '1') then
                currRD  <= RD_IN;
                currRF1 <= RF_OUT1;
                currRF2 <= RF_OUT2;
                currPC <= PC;
                currIMM<= IMM;
                currRS1<=RS1_IN;
                currRS2<=RS2_IN;
            end if;
        end if;
    end process;

    -- Input multiplexer of ALU
    ALU_OPA <=  currPC when ALU_OPA_SEL = "000" else                    -- Current address
                currRF1 when ALU_OPA_SEL = "001" else                   -- Source register 1 output
                (31 downto 0 => '0') when ALU_OPA_SEL = "010" else      -- "0" for LUI instruction (RD<-IMM+0)
                EXE_MEM_IN when ALU_OPA_SEL = "011" else                -- FWD from EXE_MEM
                MEM_WB_IN;                                              -- FWD from MEM_WB

    ALU_OPB <=  currRF2  when ALU_OPB_SEL = "000" else                          -- Source register 1 output
                currIMM  when ALU_OPB_SEL = "001" else                          -- Immediate value
                (28 downto 0 => '0')&"100" when ALU_OPB_SEL = "010" else        -- "4" for JAL instruction (RD<-PC+4)
                EXE_MEM_IN when ALU_OPB_SEL = "011" else                        -- FWD from EXE_MEM
                MEM_WB_IN;                                                      -- FWD from MEM_WB


    RD_OUT    <=  currRD; 
    RS1_OUT <= currRS1;
    RS2_OUT <= currRS2;
    MEM_DATA  <=  currRF2; -- sw (to store RS2 output in memory)

end architecture rtl;