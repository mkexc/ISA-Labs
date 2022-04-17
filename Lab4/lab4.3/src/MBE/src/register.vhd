LIBRARY IEEE;
use IEEE.std_logic_1164.all;

entity regi is
    generic(
        N : integer :=32
    );
    port(
        CLK : in std_logic;
        RST_n: in std_logic;
        D   : in std_logic_vector(N-1 downto 0);
        Q   : out std_logic_vector(N-1 downto 0)
    );
end entity regi;

architecture beh of regi is
    signal Q_int : std_logic_vector(N-1 downto 0);
begin
    
    r: process (CLK, RST_n)
    begin
        if(RST_n = '0') then
            Q_int<=(others=>'0');
        elsif(rising_edge(CLK)) then
            Q_int<=D;
        end if;
    end process;

    Q<=Q_int;

end architecture beh;