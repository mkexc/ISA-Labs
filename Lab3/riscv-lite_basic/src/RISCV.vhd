-- Top level of risc-v lite processor (DP + CU)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity RISCV is
    port (
        clk, rst, en    : in std_logic;
        IRAM_OUT        : in std_logic_vector(31 downto 0); -- instruction from I-memory
        DRAM_OUT        : in std_logic_vector(31 downto 0); -- data from D-memory
        IRAM_ADDR       : out std_logic_vector(31 downto 0); -- address for I-memory
        DRAM_EN         : out std_logic; -- enable for D-memory
        DRAM_IN         : out std_logic_vector(31 downto 0); -- data for D-memory
        DRAM_ADDR       : out std_logic_vector(31 downto 0); -- address for D-memory
        DRAM_WR, DRAM_RD: out std_logic
    );
end entity RISCV;

architecture rtl of RISCV is

    component DP is
        port (
            clk, rst                                    : in std_logic;
            FETCH_EN, DECODE_EN, EXE_EN, MEM_EN, WB_EN  : in std_logic;
            IRAM_OUT                                    : in std_logic_vector(31 downto 0); -- instruction from I-memory
            DRAM_OUT                                    : in std_logic_vector(31 downto 0); -- data from D-memory
            DRAM_WR_IN, DRAM_RD_IN                      : in std_logic; -- control signals from CU
            RF_RD1, RF_RD2, RF_WR                       : in std_logic;
            JUMP, MUX_SEL_WB                            : in std_logic;
            RF_OUT1_SEL, RF_OUT2_SEL                    : in std_logic_vector(1 downto 0);
            ALU_OPA_SEL, ALU_OPB_SEL                    : in std_logic_vector(2 downto 0);
            MUX_SEL_IMM                                 : in std_logic_vector(2 downto 0); 
            ALU_OP                                      : in type_op;
            IRAM_ADDR                                   : out std_logic_vector(31 downto 0); -- address for I-memory
            DRAM_IN                                     : out std_logic_vector(31 downto 0); -- data for D-memory
            DRAM_ADDR                                   : out std_logic_vector(31 downto 0); -- address for D-memory
            DRAM_WR, DRAM_RD                            : out std_logic; -- ctrl signals for D-memory
            OPCODE                                      : out std_logic_vector(6 downto 0); -- state signals to CU
            FUNC3                                       : out std_logic_vector(2 downto 0);
            EQU                                         : out std_logic;
            RS1_IF_ID, RS2_IF_ID, RS1_ID_EXE, RS2_ID_EXE: out std_logic_vector(4 downto 0);
            RD_EXE_MEM, RD_MEM_WB, RD_ID_EXE            : out std_logic_vector(4 downto 0)
        );
    end component DP;

    component CU is
        port (
            clk, rst                                    : in std_logic;
            OPCODE                                      : in std_logic_vector(6 downto 0); -- state signals from DP
            FUNC3                                       : in std_logic_vector(2 downto 0);
            EQU                                         : in std_logic;
            RS1_IF_ID, RS2_IF_ID, RS1_ID_EXE, RS2_ID_EXE: in std_logic_vector(4 downto 0);
            RD_ID_EXE, RD_EXE_MEM, RD_MEM_WB            : in std_logic_vector(4 downto 0);
            DRAM_WR_IN, DRAM_RD_IN, DRAM_EN             : out std_logic; -- control signals to DP
            RF_RD1, RF_RD2, RF_WR                       : out std_logic;
            JUMP, MUX_SEL_WB                            : out std_logic;
            FETCH_EN, DECODE_EN, EXE_EN, MEM_EN, WB_EN  : out std_logic;
            RF_OUT1_SEL, RF_OUT2_SEL                    : out std_logic_vector(1 downto 0);
            ALU_OPA_SEL, ALU_OPB_SEL                    : out std_logic_vector(2 downto 0);
            MUX_SEL_IMM                                 : out std_logic_vector(2 downto 0); 
            ALU_OP                                      : out type_op
        );
    end component CU;

    -- Control signals (CU -> DP)
    signal DRAM_WR_IN_c, DRAM_RD_IN_c, RF_RD1_c, RF_RD2_c, RF_WR_c: std_logic;
	signal JUMP_c, MUX_SEL_WB_c: std_logic;
    signal ALU_OPA_SEL_c, ALU_OPB_SEL_c: std_logic_vector(2 downto 0);
    signal RF_OUT1_SEL, RF_OUT2_SEL : std_logic_vector(1 downto 0);
    signal MUX_SEL_IMM_c: std_logic_vector(2 downto 0);
    signal FETCH_EN_c, DECODE_EN_c, EXE_EN_c, MEM_EN_c, WB_EN_c : std_logic;
    
    signal ALU_OP_c: type_op;
    -- State signals (DP -> CU)
    signal OPCODE_s: std_logic_vector(6 downto 0);
    signal FUNC3_s: std_logic_vector(2 downto 0);
    signal EQU_s: std_logic;
    signal RS1_IF_ID : std_logic_vector(4 downto 0);
    signal RS2_IF_ID : std_logic_vector(4 downto 0);
    signal RS1_ID_EXE: std_logic_vector(4 downto 0);
    signal RS2_ID_EXE: std_logic_vector(4 downto 0);
    signal RD_EXE_MEM: std_logic_vector(4 downto 0);
    signal RD_MEM_WB : std_logic_vector(4 downto 0);
    signal RD_ID_EXE : std_logic_vector(4 downto 0);
begin

    --Datapath
    DP_u : DP port map(
        clk         =>  clk,
        rst         =>  rst,
        IRAM_OUT    => IRAM_OUT,
        FETCH_EN    => FETCH_EN_c,
        DECODE_EN   => DECODE_EN_c,
        EXE_EN      => EXE_EN_c,
        MEM_EN      => MEM_EN_c,
        WB_EN       => WB_EN_c,
        DRAM_OUT    => DRAM_OUT,
        DRAM_WR_IN  => DRAM_WR_IN_c,
        DRAM_RD_IN  => DRAM_RD_IN_c,
        RF_RD1      => RF_RD1_c,
        RF_RD2      => RF_RD2_c,
        RF_WR       => RF_WR_c,
        JUMP        => JUMP_c,
        MUX_SEL_WB  => MUX_SEL_WB_c,
        RF_OUT1_SEL => RF_OUT1_SEL,
        RF_OUT2_SEL => RF_OUT2_SEL,
        ALU_OPA_SEL => ALU_OPA_SEL_c,
        ALU_OPB_SEL => ALU_OPB_SEL_c,
        MUX_SEL_IMM => MUX_SEL_IMM_c,
        ALU_OP      => ALU_OP_c,
        IRAM_ADDR   => IRAM_ADDR,
        DRAM_IN     => DRAM_IN,
        DRAM_ADDR   => DRAM_ADDR,
        DRAM_WR     => DRAM_WR,
        DRAM_RD     => DRAM_RD,
        OPCODE      => OPCODE_s,
        FUNC3       => FUNC3_s,
        EQU         => EQU_s,
        RS1_IF_ID   => RS1_IF_ID,    
        RS2_IF_ID   => RS2_IF_ID ,
        RS1_ID_EXE  => RS1_ID_EXE,
        RS2_ID_EXE  => RS2_ID_EXE,
        RD_ID_EXE   => RD_ID_EXE,
        RD_EXE_MEM  => RD_EXE_MEM,
        RD_MEM_WB   => RD_MEM_WB                       
    );

    --Control Unit
    CU_u : CU port map(
        clk         => clk,
        rst         => rst,
        OPCODE      => OPCODE_s,
        FUNC3       => FUNC3_s,
        FETCH_EN    => FETCH_EN_c,
        DECODE_EN   => DECODE_EN_c,
        EXE_EN      => EXE_EN_c,
        MEM_EN      => MEM_EN_c,
        DRAM_EN     => DRAM_EN,
        WB_EN       => WB_EN_c,
        EQU         => EQU_s,
        DRAM_WR_IN  => DRAM_WR_IN_c,
        DRAM_RD_IN  => DRAM_RD_IN_c,
        RF_RD1      => RF_RD1_c,
        RF_RD2      => RF_RD2_c,
        RF_WR       => RF_WR_c,
        JUMP        => JUMP_c,
        MUX_SEL_WB  => MUX_SEL_WB_c,
        RF_OUT1_SEL => RF_OUT1_SEL,
        RF_OUT2_SEL => RF_OUT2_SEL,
        ALU_OPA_SEL => ALU_OPA_SEL_c,
        ALU_OPB_SEL => ALU_OPB_SEL_c,
        MUX_SEL_IMM => MUX_SEL_IMM_c,
        ALU_OP      => ALU_OP_c,
        RS1_IF_ID   => RS1_IF_ID,    
        RS2_IF_ID   => RS2_IF_ID ,
        RS1_ID_EXE  => RS1_ID_EXE,
        RS2_ID_EXE  => RS2_ID_EXE,
        RD_ID_EXE   => RD_ID_EXE,
        RD_EXE_MEM  => RD_EXE_MEM,
        RD_MEM_WB   => RD_MEM_WB
    );

    
    
end architecture rtl;
