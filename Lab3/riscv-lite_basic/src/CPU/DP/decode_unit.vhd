library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decode_unit is
    port (
        clk, rst, en                  : in  std_logic;
        RF_RD1, RF_RD2, RF_WR         : in  std_logic;
        IF_FLUSH                      : in  std_logic;
        PC_IN                         : in  std_logic_vector(31 downto 0);
        IR_IN                         : in  std_logic_vector(31 downto 0);
        EXE_MEM_IN                    : in    std_logic_vector(31 downto 0);
        ADD_WR                        : in  std_logic_vector(4 downto 0);
        DATAIN                        : in  std_logic_vector(31 downto 0);
        MUX_IMM_SEL                   : in  std_logic_vector(2 downto 0);
        RF_OUT1_SEL, RF_OUT2_SEL      : in  std_logic_vector(1 downto 0);
        OPCODE                        : out std_logic_vector(6 downto 0); -- Instruction field for CU
        FUNC3                         : out std_logic_vector(2 downto 0); -- Instruction field for CU
        EQU_FLAG                      : out   std_logic;
        RF_OUT1, RF_OUT2, PC_OUT, IMM : out std_logic_vector(31 downto 0);
        JMP_ADDR				      : out   std_logic_vector(31 downto 0);
        RD, RS1, RS2                  : out std_logic_vector(4 downto 0)
    );
end entity decode_unit;

architecture rtl of decode_unit is
    
    component register_file is
        generic (
            NBITS : integer := 32
        );
        port (
            CLK     : in std_logic;
            RESET   : in std_logic;
            ENABLE  : in std_logic;
            RD1     : in std_logic;
            RD2     : in std_logic;
            WR      : in std_logic;
            ADD_WR  : in std_logic_vector(4 downto 0);
            ADD_RD1 : in std_logic_vector(4 downto 0);
            ADD_RD2 : in std_logic_vector(4 downto 0);
            DATAIN  : in std_logic_vector(NBITS - 1 downto 0);
            OUT1    : out std_logic_vector(NBITS - 1 downto 0);
            OUT2    : out std_logic_vector(NBITS - 1 downto 0)
        );
      end component register_file;
    
    signal currIR, currPC, RF_OUT1_m, RF_OUT2_m, IMM_m, RF_OUT1_int, RF_OUT2_int: std_logic_vector(31 downto 0);
    signal RF_ADDR1, RF_ADDR2: std_logic_vector(4 downto 0);

begin
    
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(rst='1') then
                currPC<=(others => '0');
            elsif(en='1') then
                currPC<=PC_IN;
            end if;
            -- IF_FLUSH is set if a jump occures => a reset is performed to propagate a NOP
            if((rst or IF_FLUSH)='1') then
                currIR<=(others => '0');
            elsif(en = '1') then
                currIR<=IR_IN;
            end if;
        end if;
    end process;
    
    PC_OUT<=currPC; --Sign extension of PC (current address)

    rf: register_file 
    port map (
        CLK     => clk,
        RESET   => rst,
        ENABLE  => en,
        RD1     => RF_RD1,
        RD2     => RF_RD2,
        WR      => RF_WR,
        ADD_WR  => ADD_WR,
        ADD_RD1 => RF_ADDR1,
        ADD_RD2 => RF_ADDR2,
        DATAIN  => DATAIN,
        OUT1    => RF_OUT1_m,
        OUT2    => RF_OUT2_m
    );

    -- Instruction decoding

    --Immediate (@risc-spec pg. 18)
    IMM_m  <= (19 downto 0 => currIR(31))&currIR(31 downto 20)                                     when MUX_IMM_SEL = "000" else  -- I-type
            (19 downto 0 => currIR(31))&currIR(31 downto 25)&currIR(11 downto 7)                   when MUX_IMM_SEL = "001" else  -- S-Type
            (19 downto 0 => currIR(31))&currIR(7)&currIR(30 downto 25)&currIR(11 downto 8)&"0"     when MUX_IMM_SEL = "010" else  -- B-Type
            (11 downto 0 => currIR(31))&currIR(19 downto 12)&currIR(20)&currIR(30 downto 21)&"0"   when MUX_IMM_SEL = "011" else  -- J-Type
            currIR(31 downto 12)&(11 downto 0 => '0');                                                                            -- U-Type
    
    RD       <= currIR(11 downto 7);  --Destination register address
    RF_ADDR1 <= currIR(19 downto 15); --Source register 1 address
    RF_ADDR2 <= currIR(24 downto 20); --Source register 2 address
    OPCODE   <= currIR(6 downto 0);
    FUNC3    <= currIR(14 downto 12);
    
    RS1<= RF_ADDR1;
    RS2<= RF_ADDR2;
    
    RF_OUT1_int <= RF_OUT1_m when RF_OUT1_SEL = "00" else
                   EXE_MEM_IN when RF_OUT1_SEL = "01" else
                   DATAIN;

    RF_OUT2_int <=  RF_OUT2_m when RF_OUT2_SEL = "00" else
                    EXE_MEM_IN when RF_OUT2_SEL = "01" else
                    DATAIN;
 

    RF_OUT1<=RF_OUT1_int;
    RF_OUT2<=RF_OUT2_int;
    IMM<=IMM_m;
    
    -- Outcome of beq by comparison
    EQU_FLAG <= '1' when RF_OUT1_int=RF_OUT2_int else '0';

    -- Jump address = PC + IMMx2
    JMP_ADDR <= std_logic_vector(signed(currPC) + signed(IMM_m(31 downto 0)));
    
end architecture rtl;
