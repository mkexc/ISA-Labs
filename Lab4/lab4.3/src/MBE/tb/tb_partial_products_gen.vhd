library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_partial_products_gen is
end entity tb_partial_products_gen;

architecture rtl of tb_partial_products_gen is
    component partial_products_gen is
        generic (
            N : integer := 32
        );
        port (
            A, B : in std_logic_vector(N-1 downto 0);
            O : out std_logic_vector((N/2+1)*N*2-1 downto 0)
        );
    end component partial_products_gen;

    constant N : integer := 8;
    signal A_s,B_s : std_logic_vector(N-1 downto 0);
    signal O_s : std_logic_vector((N/2+1)*N*2-1 downto 0);

begin
    
    ppgen: partial_products_gen
    generic map (
        N=>N
    )
    port map (
        A=>A_s,
        B=>B_s,
        O=>O_s
    );
    
    testvect: process
    begin
        A_s<="10101001";
        B_s<="00010101"; 
        wait for 10 ns;
        A_s<="01010010";
        B_s<="11101001"; 
        wait for 10 ns;
        A_s<="00101010";
        B_s<="11110100"; 
        wait for 10 ns;
        A_s<="01001011";
        B_s<="00010010"; 
        wait for 10 ns;
        wait;
    end process testvect;

end architecture rtl;