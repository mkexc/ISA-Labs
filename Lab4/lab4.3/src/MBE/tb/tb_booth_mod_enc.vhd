library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_booth_mod_enc is
end entity tb_booth_mod_enc;

architecture rtl of tb_booth_mod_enc is
    component booth_mod_enc is
        port (
            A: in std_logic_vector(2 downto 0);
            O: out std_logic_vector(2 downto 0)
        );
    end component booth_mod_enc;

    signal A_s, O_s : std_logic_vector(2 downto 0);

begin
    
    booth_enc: booth_mod_enc
    port map (
        A=>A_s,
        O=>O_s
    );
    
    process
    begin
        A_s<="000";
        wait for 10 ns;
        A_s<="001";
        wait for 10 ns;
        A_s<="010";
        wait for 10 ns;
        A_s<="011";
        wait for 10 ns;
        A_s<="100";
        wait for 10 ns;
        A_s<="101";
        wait for 10 ns;
        A_s<="110";
        wait for 10 ns;
        A_s<="111";
        wait for 10 ns;
        wait;
    end process;

end architecture rtl;