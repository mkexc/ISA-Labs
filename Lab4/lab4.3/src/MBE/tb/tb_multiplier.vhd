library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_multiplier is
end entity tb_multiplier;

architecture beh of tb_multiplier is
    
    component multiplier is
        generic (
            N : integer := 32
        );
        port (
            A, B : in std_logic_vector(N-1 downto 0);
            Y    : out std_logic_vector(2*N-1 downto 0)
        );
    end component multiplier;

    constant N : integer := 32;
    signal A_s, B_s : std_logic_vector(N-1 downto 0);
    signal Y_s : std_logic_vector(2*N-1 downto 0);

begin
    
    UUT: multiplier 
    generic map (
        N=>N
    )
    port map (
        A=>A_s, 
        B=>B_s, 
        Y=>Y_s
    );
    
    process 
    begin
        A_s<="11111111111111111111111111111111"; B_s<="11111111111111111111111111111111";
        wait for 10 ns;
        assert unsigned(Y_s)=unsigned(A_s)*unsigned(B_s) report "MULTIPLIER ERROR";
        A_s<="00000000000000000000000000000000"; B_s<="00000000000000000000000000000000";
        wait for 10 ns;
        assert unsigned(Y_s)=unsigned(A_s)*unsigned(B_s) report "MULTIPLIER ERROR";
        A_s<="11001010010100101010010100101011"; B_s<="10010100101010010101001010100100";
        wait for 10 ns;
        assert unsigned(Y_s)=unsigned(A_s)*unsigned(B_s) report "MULTIPLIER ERROR";
        A_s<="00101001010101010101010100101001"; B_s<="00010010101011110101010010100000";
        wait for 10 ns;
        assert unsigned(Y_s)=unsigned(A_s)*unsigned(B_s) report "MULTIPLIER ERROR";
        A_s<="11100101001010100000101011101010"; B_s<="00010010101010010101011111111000";
        wait for 10 ns;
        assert unsigned(Y_s)=unsigned(A_s)*unsigned(B_s) report "MULTIPLIER ERROR";
        wait;
    end process;
    
end architecture beh;