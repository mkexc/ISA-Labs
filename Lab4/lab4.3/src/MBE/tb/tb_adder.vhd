library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_adder is
end entity tb_adder;

architecture beh of tb_adder is
    component adder is
        generic (
            N : integer := 32
        );
        port (
            A, B : in std_logic_vector(N-1 downto 0);
            Cin  : in std_logic;
            Y    : out std_logic_vector(N-1 downto 0);
            Cout : out std_logic
        );
    end component adder;

    constant N : integer := 8;
    
    signal A_s, B_s, Y_s : std_logic_vector(N-1 downto 0);
    signal Cin_s, Cout_s : std_logic;

begin
    
    UUT: adder 
    generic map (
        N=>N
    )
    port map (
        A=>A_s, 
        B=>B_s,
        Cin=>Cin_s, 
        Y=>Y_s, 
        Cout=>Cout_s
    );

    process 
    begin
        A_s<="11111111"; B_s<="11111111"; Cin_s<='1';
        wait for 10 ns;
        assert unsigned('0'&A_s)+unsigned('0'&B_s)+unsigned(std_logic_vector'(""&Cin_s))=unsigned(Cout_s&Y_s) report "ADDER ERROR";
        A_s<="10100100"; B_s<="11110010"; Cin_s<='0';
        wait for 10 ns;
        assert unsigned('0'&A_s)+unsigned('0'&B_s)+unsigned(std_logic_vector'(""&Cin_s))=unsigned(Cout_s&Y_s) report "ADDER ERROR";
        A_s<="00010010"; B_s<="10010010"; Cin_s<='1';
        wait for 10 ns;
        assert unsigned('0'&A_s)+unsigned('0'&B_s)+unsigned(std_logic_vector'(""&Cin_s))=unsigned(Cout_s&Y_s) report "ADDER ERROR";
        A_s<="00100101"; B_s<="11110001"; Cin_s<='1';
        wait for 10 ns;
        assert unsigned('0'&A_s)+unsigned('0'&B_s)+unsigned(std_logic_vector'(""&Cin_s))=unsigned(Cout_s&Y_s) report "ADDER ERROR";
        A_s<="11100001"; B_s<="00101010"; Cin_s<='0';
        wait for 10 ns;
        assert unsigned('0'&A_s)+unsigned('0'&B_s)+unsigned(std_logic_vector'(""&Cin_s))=unsigned(Cout_s&Y_s) report "ADDER ERROR";
        A_s<="00000000"; B_s<="00000000"; Cin_s<='0';
        wait for 10 ns;
        assert unsigned('0'&A_s)+unsigned('0'&B_s)+unsigned(std_logic_vector'(""&Cin_s))=unsigned(Cout_s&Y_s) report "ADDER ERROR";
        wait;
    end process;
    
end architecture beh;