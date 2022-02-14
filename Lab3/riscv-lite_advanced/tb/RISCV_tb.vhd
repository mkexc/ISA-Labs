-- Testbench of risc-v top level (with Instruction and Data memories)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity RISCV_tb is
end entity RISCV_tb;

architecture test of RISCV_tb is

    component RISCV is
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
    end component RISCV;

    component IRAM is
        generic (
            RAM_DEPTH   : integer := NumInstr;
            I_SIZE      : integer := InstrSize;
            WORD_SIZE   : integer := WordSize;
            FILE_PATH   : string  := InstrPath);
        port (
            rst  : in  std_logic;
            addr : in  std_logic_vector(I_SIZE - 1 downto 0);
            Dout : out std_logic_vector(I_SIZE - 1 downto 0));
    end component IRAM;

    component DRAM is
        generic (
            RAM_DEPTH   : integer := NumInstr;
            I_SIZE      : integer := InstrSize;
            WORD_SIZE   : integer := WordSize;
            FILE_PATH   : string  := InstrPath);
        port (
            rst  : in  std_logic;
            addr : in  std_logic_vector(I_SIZE - 1 downto 0);
            clk  : in  std_logic;
            en   : in  std_logic;
            RD   : in  std_logic;
            WR   : in  std_logic;
            Din  : in  std_logic_vector(I_SIZE - 1 downto 0);
            Dout : out std_logic_vector(I_SIZE - 1 downto 0));
    end component DRAM;

    signal clk_sim, rst_sim, en_sim: std_logic;
    -- signal to connect the memories
    signal IRAM_ADDR_m, IRAM_OUT_m: std_logic_vector(31 downto 0);
    signal DRAM_OUT_m, DRAM_IN_m, DRAM_ADDR_m: std_logic_vector(31 downto 0);
    signal DRAM_WR_m, DRAM_RD_m, DRAM_EN_m: std_logic;
    signal DRAM_ADDR_REAL : std_logic_vector(31 downto 0);
    signal IRAM_ADDR_REAL : std_logic_vector(31 downto 0);
    
begin

    -- clock process
    clk_process: process
    begin
        clk_sim <='0';
        wait for 10 ns;
        clk_sim <='1';
        wait for 10 ns;
    end process;

    -- rst signal
    rst_process: process
    begin
        rst_sim<='1';
        wait for 12 ns;
        rst_sim<='0';
        wait;
    end process;

	en_sim <= '1';

    -- RISCV instance
    riscv_i : RISCV 
    port map(
        clk         => clk_sim,
        rst         => rst_sim,
		en			=> en_sim,
        IRAM_OUT    => IRAM_OUT_m,
        DRAM_OUT    => DRAM_OUT_m,
        IRAM_ADDR   => IRAM_ADDR_m,
        DRAM_EN     => DRAM_EN_m,
        DRAM_IN     => DRAM_IN_m,
        DRAM_ADDR   => DRAM_ADDR_m,
        DRAM_WR     => DRAM_WR_m,
        DRAM_RD     => DRAM_RD_m
    );

    -- IRAM instance
    iram_i : IRAM
    port map(
        rst     => rst_sim,
        addr    => IRAM_ADDR_REAL,
        Dout    => IRAM_OUT_m
    );

    -- DRAM instance
    dram_i : DRAM
    generic map (
        RAM_DEPTH => 4096,
        FILE_PATH => "../src/MEM/data_segment.mem"
    )
    port map(
        clk     => clk_sim,
        rst     => rst_sim,
        en      => DRAM_EN_m,
        RD      => DRAM_RD_m,
        WR      => DRAM_WR_m,
        addr    => DRAM_ADDR_REAL,
        Din     => DRAM_IN_m,
        Dout    => DRAM_OUT_m
    );

    DRAM_ADDR_REAL <= (15 downto 0 => '0')&DRAM_ADDR_m(15 downto 0);
    IRAM_ADDR_REAL <= (15 downto 0 => '0')&IRAM_ADDR_m(15 downto 0);
end architecture test;
