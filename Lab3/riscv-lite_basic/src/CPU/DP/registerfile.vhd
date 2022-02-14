library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--	standard register file behavioral implementation

entity register_file is

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
end register_file;

architecture Beh of register_file is

  -- support structures
  subtype REG_ADDR is natural range 0 to 31; -- using natural type
  type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NBITS - 1 downto 0);
  signal REGISTERS : REG_ARRAY;
begin

  -- asynchronous read process
  read_proc: process (ENABLE, RD1, RD2, REGISTERS, ADD_RD1, ADD_RD2)
  begin
    OUT1 <= (others => '0');
    OUT2 <= (others => '0');
    -- if enable is 1, read
    if ENABLE = '1' then
      -- read RD1
      if RD1 = '1' then
        OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1))); -- outputs to port1 the register at the address ADD_RD1
      end if;
      -- read RD2
      if RD2 = '1' then
        OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2))); -- outputs to port2 the register at the address ADD_RD2
      end if;
    end if;
  end process;

  -- synchronous write process
  write_proc : process (CLK) is
  begin
    if (CLK = '1' and CLK'event) then
      -- if reset is 1, initialise the register file
      if RESET = '1' then
        REGISTERS <= (others => (others => '0'));
      else
        -- write and bypass if needed
        if WR = '1' then
          -- if it's not register 0, write in 
          if ADD_WR /= (4 downto 0 => '0') then
            REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN; -- write datain to the register at ADD_WR address
          end if;
        end if;
      end if;
    end if;
  end process;

end Beh;