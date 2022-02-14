--riscV control unit
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity CU is
    port (
        clk, rst                                    : in std_logic;
        OPCODE                                      : in std_logic_vector(6 downto 0); -- state signals from DP
        FUNC3                                       : in std_logic_vector(2 downto 0);
        FUNC7                                       : in std_logic_vector(6 downto 0);
        EQU                                         : in std_logic;
        RS1_IF_ID, RS2_IF_ID, RS1_ID_EXE, RS2_ID_EXE: in std_logic_vector(4 downto 0);
        RD_ID_EXE, RD_EXE_MEM, RD_MEM_WB            : in std_logic_vector(4 downto 0);
        DRAM_WR_IN, DRAM_RD_IN, DRAM_EN             : out std_logic; -- control signals to DP
        RF_RD1, RF_RD2, RF_WR                       : out std_logic;
        JUMP, MUX_SEL_WB                            : out std_logic;
        FETCH_EN, DECODE_EN, EXE_EN, MEM_EN, WB_EN  : out std_logic;
        EXE_OUT_SEL                                 : out std_logic;
        RF_OUT1_SEL, RF_OUT2_SEL                    : out std_logic_vector(1 downto 0);
        ALU_OPA_SEL, ALU_OPB_SEL                    : out std_logic_vector(2 downto 0);
        MUX_SEL_IMM                                 : out std_logic_vector(2 downto 0); 
        ALU_OP                                      : out type_op
    );
end entity CU;

architecture rtl of CU is

    component FWD_EXE is
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
    end component FWD_EXE;

    component FWD_DEC is
        port (
            RS1_IF_ID : in std_logic_vector(4 downto 0);
            RS2_IF_ID : in std_logic_vector(4 downto 0);
            IS_COND_JUMP: in std_logic;
            RD_EX_MEM  : in std_logic_vector(4 downto 0);
            RD_MEM_WB  : in std_logic_vector(4 downto 0);
            MUX_REGA_SEL : out std_logic_vector(1 downto 0);
            MUX_REGB_SEL : out std_logic_vector(1 downto 0)
        );
    end component FWD_DEC;

    component HDU is
        port (
            RS1_IF_ID, RS2_IF_ID : in std_logic_vector(4 downto 0);
            RD_ID_EXE : in std_logic_vector(4 downto 0);
            RD_EXE_MEM : in std_logic_vector(4 downto 0);
            MEM_LD_EXE : in std_logic;
            MEM_LD_MEM : in std_logic;
            IS_COND_JUMP : in std_logic;
            STALL : out std_logic
        );
    end component HDU;

    --23 bits of control
    signal ctrl_word   : std_logic_vector(23 downto 0);
    --groups of control bits based on pipelining
	signal ctrl_word_E, next_ctrl_word_E : std_logic_vector(13 downto 0);
    signal ctrl_word_M : std_logic_vector(5 downto 0);
    signal ctrl_word_W : std_logic_vector(1 downto 0);
    
    signal alu_ctrl, alu_ctrl1 : type_op;

    signal MUX_OPA_SEL_STD, MUX_OPB_SEL_STD : std_logic_vector(2 downto 0); 
    signal EXE_MEM_WR, MEM_WB_WR, STALL, IS_COND_JUMP : std_logic;
    
begin

    forward_unit_exe : FWD_EXE 
    port map (
        RS1_ID_EX       => RS1_ID_EXE     ,
        RS2_ID_EX       => RS2_ID_EXE     ,
        RD_EX_MEM       => RD_EXE_MEM     ,
        RD_MEM_WB       => RD_MEM_WB      ,
        MUX_OPA_SEL_STD => MUX_OPA_SEL_STD,
        MUX_OPB_SEL_STD => MUX_OPB_SEL_STD,
        EXE_MEM_WR      => EXE_MEM_WR     ,
        MEM_WB_WR       => MEM_WB_WR      ,
        MUX_OPA_SEL     => ALU_OPA_SEL    ,
        MUX_OPB_SEL     => ALU_OPB_SEL    
    );

    forward_unit_dec : FWD_DEC
    port map (
        RS1_IF_ID    => RS1_IF_ID,
        RS2_IF_ID    => RS2_IF_ID,
        IS_COND_JUMP => IS_COND_JUMP,
        RD_EX_MEM    => RD_EXE_MEM,
        RD_MEM_WB    => RD_MEM_WB,
        MUX_REGA_SEL => RF_OUT1_SEL,
        MUX_REGB_SEL => RF_OUT2_SEL
    );
    
    hazard_unit: HDU
    port map (
        RS1_IF_ID   => RS1_IF_ID,
        RS2_IF_ID   => RS2_IF_ID,
        RD_ID_EXE   => RD_ID_EXE,  
        RD_EXE_MEM  => RD_EXE_MEM,
        MEM_LD_EXE  => ctrl_word_E(3),
        MEM_LD_MEM  => ctrl_word_M(3),
        IS_COND_JUMP=>IS_COND_JUMP,
        STALL       => STALL
    );
    MUX_OPA_SEL_STD <= ctrl_word_E(13 downto 11);
    MUX_OPB_SEL_STD <= ctrl_word_E(10 downto 8);
    EXE_MEM_WR  <= ctrl_word_M(0);
    MEM_WB_WR   <= ctrl_word_W(0);

    -- Control word fields:
    -- FETCH_EN/DECODE_EN|MUX_IMM_SEL(3)|RF_RD1|RF_RD2|BEQ|JAL/EXE_EN|ALU_OPA(3)|ALU_OPB(3)|OUT_SEL/MEM_EN|DRAM_EN|MEM_WR|MEM_RD/WB_EN|MX_SEL|RF_WR
    
    -- Process to build the control word
    process(OPCODE,FUNC3,FUNC7)
    begin
        IS_COND_JUMP<='0';
        -- I-type (ADDI, ANDI, SRAI)
        if(OPCODE = "0010011") then
            ctrl_word<="1" & "10001000" & "10010010" & "1000" & "101";
            if(FUNC3 = "000") then alu_ctrl <= ADD;       -- ADDI
            elsif(FUNC3 = "111") then alu_ctrl <= BITAND; -- ANDI
            elsif(FUNC3 = "101") then alu_ctrl <= SAR;    -- SRAI
            else alu_ctrl <= ADD; end if;                 -- NOP

        -- I-type (LW)
        elsif(OPCODE = "0000011") then
            ctrl_word<="1" & "10001000" & "10010010" & "1101" & "111";
            alu_ctrl<=ADD;

        -- U-type (LUI)
        elsif(OPCODE = "0110111") then
            ctrl_word<="1" & "11000000" & "10100010" & "1000" & "101";
            alu_ctrl<=ADD;

        -- U-type (AUIPC)
        elsif(OPCODE = "0010111") then
            ctrl_word<="1" & "11000000" & "10000010" & "1000" & "101";
            alu_ctrl<=ADD;

        -- J-type (JAL)
        elsif(OPCODE = "1101111") then
            ctrl_word<="1" & "10110001" & "10000100" & "1000" & "101";
            alu_ctrl<=ADD;

        -- B-type (BEQ)
        elsif(OPCODE = "1100011") then
            ctrl_word<="1" & "10101110" & "10000000" & "1000" & "100";
            alu_ctrl<=ADD;
            IS_COND_JUMP<='1';

        -- S-type (SW)
        elsif(OPCODE = "0100011") then
            ctrl_word<="1" & "10011100" & "10010010" & "1110" & "100";
            alu_ctrl<=ADD;

        -- R-type (ADD, SLT, XOR)
        elsif(OPCODE = "0110011") then
            if FUNC7 = "1000000" then
                ctrl_word<="1" & "10101100" & "10010001" & "1000" & "101";
            else
                ctrl_word<="1" & "10101100" & "10010000" & "1000" & "101";
            end if;
            if(FUNC3 = "000") then alu_ctrl <= ADD; -- ADD
            elsif(FUNC3 = "010") then alu_ctrl <= CMP; -- SLT
            elsif(FUNC3 = "100") then alu_ctrl <= BITXOR; -- XOR
            else alu_ctrl <= ADD; end if; --NOP

        else
            ctrl_word<="1" & "10000000" & "00000000" & "0000" & "000";
            alu_ctrl <= ADD;

        end if;
    end process;

    -- Pipeline registers to delay the control signals
    pipeline: process(clk)
    begin
      if(rising_edge(clk)) then
        if(rst='1') then
          ctrl_word_E<=(others=>'0');
          ctrl_word_M<=(others=>'0');
          ctrl_word_W<=(others=>'0');
          alu_ctrl1<=ADD;
        else
          ctrl_word_E<=next_ctrl_word_E;
          ctrl_word_M<=ctrl_word_E(5 downto 0);
          ctrl_word_W<=ctrl_word_M(1 downto 0);
          alu_ctrl1<=alu_ctrl;
        end if;
      end if;
    end process pipeline;

    -- Control word decoding to build the CU outputs (consider pipeline stages)
    -- FETCH_EN/DECODE_EN|MUX_IMM_SEL(3)|RF_RD1|RF_RD2|BEQ|JAL/EXE_EN|ALU_OPA(3)|ALU_OPB(3)|OUT_SEL/MEM_EN|DRAM_EN|MEM_WR|MEM_RD/WB_EN|MX_SEL|RF_WR

    next_ctrl_word_E <= ctrl_word(13 downto 0) when STALL = '0' else 
                        (13 downto 0 => '0');
    -- FETCH
    FETCH_EN <= ctrl_word(23) when STALL = '0' else
                '0';

    -- Control signals of Decode stage
    DECODE_EN <= ctrl_word(22) when STALL = '0' else
        '0';
    MUX_SEL_IMM <= ctrl_word(21 downto 19);
    RF_RD1 <= ctrl_word(18);
    RF_RD2 <= ctrl_word(17);
    JUMP <= (EQU and ctrl_word(16) and not(STALL) ) or ctrl_word(15); --(EQU and BEQ) or JAL
    EXE_EN <= ctrl_word(14);

    -- Control signals of Execution stage
    ALU_OP <= alu_ctrl1;
    EXE_OUT_SEL <= ctrl_word_E(7);
    MEM_EN <= ctrl_word_E(6);

    -- Control signals of Memory stage
    DRAM_EN <= ctrl_word_M(5);
    DRAM_WR_IN <= ctrl_word_M(4);
    DRAM_RD_IN <= ctrl_word_M(3);
    WB_EN    <= ctrl_word_M(2);

    -- Control signals of WriteBack stage
    MUX_SEL_WB <= ctrl_word_W(1);
    RF_WR <= ctrl_word_W(0);

end rtl;


