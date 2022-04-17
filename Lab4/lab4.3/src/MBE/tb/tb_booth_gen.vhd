library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_booth_gen is
end entity tb_booth_gen;

architecture rtl of tb_booth_gen is
    component booth_gen is
        generic (
            N : integer := 32
        );
        port (
            B : in std_logic_vector(N-1 downto 0);
            O: out std_logic_vector((N/2+1)*3-1 downto 0)
        );
    end component booth_gen;

    constant N : integer := 8;
    signal B_s: std_logic_vector(N-1 downto 0);
    signal O_s: std_logic_vector((N/2+1)*3-1 downto 0);

begin
    
    booth: booth_gen
    generic map (
        N=>N
    )
    port map (
        B=>B_s,
        O=>O_s
    );
    
    process 
    begin
        B_s<="11100010";
        wait for 10 ns;
        B_s<="00110001";
        wait for 10 ns;
        B_s<="11001010";
        wait for 10 ns;
        B_s<="00000000";
        wait for 10 ns;
        B_s<="11111111";
        wait for 10 ns;
        B_s<="11001010";
        wait for 10 ns;
        wait;
    end process;
    
end architecture rtl;