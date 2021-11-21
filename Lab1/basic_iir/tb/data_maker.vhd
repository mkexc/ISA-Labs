library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

entity data_maker is  
  port (
    CLK     : in  std_logic;
    RST_n   : in  std_logic;
    VOUT    : out std_logic;
    DOUT    : out std_logic_vector(12 downto 0);
    A1      : out std_logic_vector(12 downto 0);
    B0      : out std_logic_vector(12 downto 0);
    B1      : out std_logic_vector(12 downto 0);
    END_SIM : out std_logic);
end data_maker;

architecture beh of data_maker is

  constant tco : time := 1 ns;

  signal sEndSim : std_logic;
  signal END_SIM_i : std_logic_vector(0 to 10);  

begin  -- beh

  A1 <= conv_std_logic_vector(-649,13);
  B0 <= conv_std_logic_vector(1723,13);
  B1 <= conv_std_logic_vector(1723,13); 

  process (CLK, RST_n)
    file fp_in : text open READ_MODE is "./sources.mem";
	  file fp_vin : text open READ_MODE is "./vin.mem";
    variable line_in : line;
    variable x : integer;
	  variable line_vin : line;
	  variable v : std_logic;
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      DOUT <= (others => '0') after tco;      
      VOUT <= '0' after tco;
      sEndSim <= '0' after tco;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if not endfile(fp_in) then
        readline(fp_in, line_in);
        read(line_in, x);
		    readline(fp_vin, line_vin);
		    read(line_vin, v);
        DOUT <= conv_std_logic_vector(x, 13) after tco;
        VOUT <= v after tco;
        sEndSim <= '0' after tco;
      else
        VOUT <= '0' after tco;        
        sEndSim <= '1' after tco;
      end if;
    end if;
  end process;


  -- process(clk,RST_n)
  --   file fp_in : text open READ_MODE is "./vin.mem";
  --   variable line_in : line;
  --   variable x : integer;
  --   variable temp: std_logic_vector(0 downto 0);
  -- begin
  --   if(RST_n='0') then
  --     VOUT<= '0';
  --   elsif(rising_edge(clk)) then
  --     if not endfile(fp_in) then
  --       readline(fp_in, line_in);
  --       read(line_in, x);
  --       temp := std_logic_vector(to_unsigned(x, 1));
  --       VOUT <= temp(0);
  --     else
  --       VOUT <= '0';
  --     end if;
  --   end if;
  -- end process;


  process (CLK, RST_n)
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      END_SIM_i <= (others => '0') after tco;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      END_SIM_i(0) <= sEndSim after tco;
      END_SIM_i(1 to 10) <= END_SIM_i(0 to 9) after tco;
    end if;
  end process;

  END_SIM <= END_SIM_i(10);  

end beh;
