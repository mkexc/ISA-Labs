library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use WORK.constants.all;

entity DRAM is
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
end DRAM;

architecture beh of DRAM is

    type RAMtype is array (0 to RAM_DEPTH - 1) of std_logic_vector(WORD_SIZE-1 downto 0); --byte 
  
    signal DRAM_mem : RAMtype;
  
begin  
  
    --OUT PROCESS
    process (en, RD, DRAM_mem, addr)
    begin
        if en='1' and RD='1' then
            Dout(I_SIZE-1 downto I_SIZE-8) 		<= DRAM_mem(to_integer(unsigned(addr))+3);  --Most significant byte
            Dout(I_SIZE-9 downto I_SIZE-16) 	<= DRAM_mem(to_integer(unsigned(addr))+2);
            Dout(I_SIZE-17 downto I_SIZE-24) 	<= DRAM_mem(to_integer(unsigned(addr))+1);
            Dout(I_SIZE-25 downto 0) 			<= DRAM_mem(to_integer(unsigned(addr)));--Least significant byte
        end if;
    end process;

    --FILL PROCESS
    FILL_MEM: process (rst,en, WR,clk,addr,Din, DRAM_mem)
        file mem_fp: text;
        variable file_line : line;
        variable index : integer := 0;
        variable tmp_data_u : std_logic_vector(I_SIZE-1 downto 0);
    begin  
        if (rst = '1') then
            file_open(mem_fp,FILE_PATH,READ_MODE);
			index := 0;
            while (not endfile(mem_fp)) loop
                readline(mem_fp,file_line);
                hread(file_line,tmp_data_u);
                DRAM_mem(index+3)   <= tmp_data_u(I_SIZE-1 downto I_SIZE-8);   --Most significant byte
                DRAM_mem(index+2) <= tmp_data_u(I_SIZE-9 downto I_SIZE-16);  
                DRAM_mem(index+1) <= tmp_data_u(I_SIZE-17 downto I_SIZE-24); --Least significant byte 
                DRAM_mem(index) <= tmp_data_u(I_SIZE-25 downto 0);  
                index := index + 4;		-- because next PC = PC + 4
            end loop;
                file_close(mem_fp);
        elsif(rising_edge(clk)) then 
            if(en = '1' and WR ='1') then 
                DRAM_mem(to_integer(unsigned(addr))+3)    <= Din(I_SIZE-1 downto I_SIZE-8) 	;
                DRAM_mem(to_integer(unsigned(addr))+2)  <= Din(I_SIZE-9 downto I_SIZE-16) ;
                DRAM_mem(to_integer(unsigned(addr))+1)  <= Din(I_SIZE-17 downto I_SIZE-24);
                DRAM_mem(to_integer(unsigned(addr)))  <= Din(I_SIZE-25 downto 0) 		;
            end if;
        end if;
    end process FILL_MEM;

end beh;
