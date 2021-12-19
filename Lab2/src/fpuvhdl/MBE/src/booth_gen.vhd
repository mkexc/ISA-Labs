library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity booth_gen is
    generic (
        N : integer := 32
    );
    port (
        B : in std_logic_vector(N-1 downto 0);
        O: out std_logic_vector((N/2+1)*3-1 downto 0)
    );
end entity booth_gen;

architecture rtl of booth_gen is
    signal out_int : std_logic_vector((N/2+1)*3-1 downto 0);
    signal B_int : std_logic_vector(N+2 downto 0);

    component booth_mod_enc is
        port (
            A: in std_logic_vector(2 downto 0);
            O: out std_logic_vector(2 downto 0)
        );
    end component booth_mod_enc;

begin
    
    B_int<="00"&B&"0";

    booth_generator: for i in 0 to N/2 generate
        booth_i: booth_mod_enc
        port map(
            A=>B_int(i*2+2 downto i*2),
            O=>out_int(i*3+2 downto i*3)
        );
    end generate booth_generator;
    
    O<=out_int;
    
end architecture rtl;