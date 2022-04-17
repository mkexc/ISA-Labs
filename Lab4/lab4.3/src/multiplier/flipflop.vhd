LIBRARY IEEE;
use IEEE.std_logic_1164.all;

entity flipflop is
    port(
        CLK : in std_logic;
        RST_n: in std_logic;
        D   : in std_logic;
        Q   : out std_logic
    );
end entity flipflop;

architecture beh of flipflop is
    signal Q_int : std_logic;
begin
    
    r: process (CLK, RST_n)
    begin
        if(RST_n = '0') then
            Q_int<='0';
        elsif(rising_edge(CLK)) then
            Q_int<=D;
        end if;
    end process;

    Q<=Q_int;

end architecture beh;
