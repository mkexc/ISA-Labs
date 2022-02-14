-- Pipelined Datapath of risc-v lite processor
-- Instruction and Data memory are out of Datapath
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity DP is
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
        EXE_OUT_SEL                                 : in std_logic;
        IRAM_ADDR                                   : out std_logic_vector(31 downto 0); -- address for I-memory
        DRAM_IN                                     : out std_logic_vector(31 downto 0); -- data for D-memory
        DRAM_ADDR                                   : out std_logic_vector(31 downto 0); -- address for D-memory
        DRAM_WR, DRAM_RD                            : out std_logic; -- ctrl signals for D-memory
        OPCODE                                      : out std_logic_vector(6 downto 0); -- state signals to CU
        FUNC3                                       : out std_logic_vector(2 downto 0);
        FUNC7                                       : out std_logic_vector(6 downto 0);
        EQU                                         : out std_logic;
        RS1_IF_ID, RS2_IF_ID, RS1_ID_EXE, RS2_ID_EXE: out std_logic_vector(4 downto 0);
        RD_EXE_MEM, RD_MEM_WB, RD_ID_EXE            : out std_logic_vector(4 downto 0)
	);
end DP;

architecture rtl of DP is

    component fetch_unit is
        port (
            clk, rst, en    : in std_logic;
            PC_MUX_SEL  : in std_logic;
            IRAM_DOUT_IN: in std_logic_vector(31 downto 0);
            PC_JUMP_ADDR: in std_logic_vector(31 downto 0);
            PC          : out std_logic_vector(31 downto 0);
            IR_IN       : out std_logic_vector(31 downto 0)
        );
    end component fetch_unit;

    component decode_unit is
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
            FUNC7                         : out std_logic_vector(6 downto 0);
            EQU_FLAG                      : out   std_logic;
            RF_OUT1, RF_OUT2, PC_OUT, IMM : out std_logic_vector(31 downto 0);
            JMP_ADDR				      : out   std_logic_vector(31 downto 0);
            RD, RS1, RS2                  : out std_logic_vector(4 downto 0)
        );
    end component decode_unit;

    component exe_unit is
        port (
            clk, rst, en                : in    std_logic;
            RF_OUT1, RF_OUT2, PC, IMM   : in    std_logic_vector(31 downto 0);
            EXE_MEM_IN, MEM_WB_IN       : in    std_logic_vector(31 downto 0);
            RD_IN, RS1_IN, RS2_IN       : in    std_logic_vector(4 downto 0);
            ALU_OP                      : in    type_op;
            ALU_OPA_SEL, ALU_OPB_SEL    : in    std_logic_vector(2 downto 0); 
            OUT_SEL                     : in    std_logic;
            ALU_OUT, MEM_DATA			: out   std_logic_vector(31 downto 0);
            RD_OUT, RS1_OUT, RS2_OUT    : out   std_logic_vector(4 downto 0)
        );
    end component exe_unit;

    component mem_unit is
        port (
            clk, rst, en                                    : in std_logic;
            ALU_OUT_IN, MEM_DATA, DRAM_OUT_IN               : in std_logic_vector(31 downto 0);
            DRAM_WR_IN, DRAM_RD_IN                          : in std_logic;
            RD_IN                                           : in std_logic_vector(4 downto 0);
            RD_OUT                                          : out std_logic_vector(4 downto 0);
            DRAM_WR, DRAM_RD                                : out std_logic;
            ALU_OUT, DRAM_OUT, DRAM_IN         	 	        : out std_logic_vector(31 downto 0)             
        );
    end component mem_unit;

    component wb_unit is
        port (
            clk, rst, en                       : in std_logic;
            RD_IN                              : in std_logic_vector(4 downto 0);
            ALU_OUT, DRAM_OUT                  : in std_logic_vector(31 downto 0);
            MUX_SEL                            : in std_logic;
            RD_OUT                             : out std_logic_vector(4 downto 0);
            WB_OUT                             : out std_logic_vector(31 downto 0)
        );
    end component wb_unit;

    -- Signals to connect the units
    signal wb_out_m, rf_out1_m, rf_out2_m, pc_ext_m, imm_m, mem_data_m: std_logic_vector(31 downto 0);
    signal alu_out_m1, alu_out_m2, dram_out_m: std_logic_vector(31 downto 0);
    signal pc_jump_addr_m, pc_m, ir_m, jump_addr_m : std_logic_vector(31 downto 0);
    signal addr_wr_m, rd_m1, rd_m2, rd_m3, rs1_dec, rs2_dec, rs1_exe, rs2_exe : std_logic_vector(4 downto 0);

begin

    FETCH_U: fetch_unit 
    port map (
        clk          => clk,
        rst          => rst,
        en           => FETCH_EN,
        PC_MUX_SEL   => JUMP,
        IRAM_DOUT_IN => IRAM_OUT,
        PC_JUMP_ADDR => pc_jump_addr_m, -- from decode unit
        PC           => pc_m, -- to decode unit
        IR_IN        => ir_m -- to decode unit
    );

    IRAM_ADDR <= pc_m;

    DECODE_U: decode_unit 
    port map (
        clk          => clk,
        rst          => rst,
        en           => DECODE_EN,
        RF_RD1       => RF_RD1,
        RF_RD2       => RF_RD2,
        RF_WR        => RF_WR,
        IF_FLUSH     => JUMP,
        PC_IN        => pc_m, -- from fetch unit
        IR_IN        => ir_m, -- from fetch unit
        ADD_WR       => addr_wr_m, -- from wb unit
        DATAIN       => wb_out_m, -- from wb unit
        EXE_MEM_IN   => alu_out_m2,
        RF_OUT1_SEL  => RF_OUT1_SEL,
        RF_OUT2_SEL  => RF_OUT2_SEL,
        MUX_IMM_SEL  => MUX_SEL_IMM,
        OPCODE       => OPCODE,
        FUNC3        => FUNC3,
        FUNC7        => FUNC7,
        EQU_FLAG     => EQU,
        RF_OUT1      => rf_out1_m, -- to exec unit
        RF_OUT2      => rf_out2_m, -- to exec unit
        PC_OUT       => pc_ext_m, -- to exec unit
        IMM          => imm_m, -- to exec unit
        JMP_ADDR     => pc_jump_addr_m, -- to fetch unit
        RD           => rd_m1, --to exec unit
        RS1          => rs1_dec,
        RS2          => rs2_dec
    );

    EXE_U: exe_unit 
    port map (
        clk          => clk,
        rst          => rst,
        en           => EXE_EN,
        RF_OUT1      => rf_out1_m, -- from decode unit
        RF_OUT2      => rf_out2_m, -- from decode unit
        EXE_MEM_IN   => alu_out_m2,
        MEM_WB_IN    => wb_out_m,
        PC           => pc_ext_m, -- from decode unit
        IMM          => imm_m, -- from decode unit
        RD_IN        => rd_m1, -- from decode unit
        RS1_IN       => rs1_dec,
        RS2_IN       => rs2_dec,
        ALU_OP       => ALU_OP,
        ALU_OPA_SEL  => ALU_OPA_SEL,
        ALU_OPB_SEL  => ALU_OPB_SEL,
        OUT_SEL      => EXE_OUT_SEL,
        ALU_OUT      => alu_out_m1, -- to mem unit
        MEM_DATA     => mem_data_m, -- to mem unit
        RD_OUT       => rd_m2, --to mem unit
        RS1_OUT      => rs1_exe,
        RS2_OUT      => rs2_exe
    );
    
    MEM_U: mem_unit 
    port map (
        clk          => clk,
        rst          => rst,
        en           => MEM_EN,
        ALU_OUT_IN   => alu_out_m1, --from ex unit
        MEM_DATA     => mem_data_m, --from ex unit
        DRAM_OUT_IN  => DRAM_OUT,
        DRAM_WR_IN   => DRAM_WR_IN,
        DRAM_RD_IN   => DRAM_RD_IN,
        RD_IN        => rd_m2, -- from ex unit
        RD_OUT       => rd_m3, -- to wb unit
        DRAM_WR      => DRAM_WR,     
        DRAM_RD      => DRAM_RD,
        ALU_OUT      => alu_out_m2, -- to wb unit
        DRAM_OUT     => dram_out_m, -- to wb unit
        DRAM_IN      => DRAM_IN
    );

    DRAM_ADDR <= alu_out_m2;

    WB_U: wb_unit 
    port map (
        clk          => clk,
        rst          => rst,
        en           => WB_EN,
        RD_IN        => rd_m3, -- from mem unit
        ALU_OUT      => alu_out_m2, -- fromt mem unit
        DRAM_OUT     => dram_out_m, -- from mem unit
        MUX_SEL      => MUX_SEL_WB,
        RD_OUT       => addr_wr_m, -- to decode unit
        WB_OUT       => wb_out_m --to decode unit
    );

    RS1_IF_ID   <= rs1_dec;
    RS2_IF_ID   <= rs2_dec;
    RS1_ID_EXE  <= rs1_exe;
    RS2_ID_EXE  <= rs2_exe;
    RD_ID_EXE   <= rd_m2;
    RD_EXE_MEM  <= rd_m3;
    RD_MEM_WB   <= addr_wr_m;
	
end rtl;
