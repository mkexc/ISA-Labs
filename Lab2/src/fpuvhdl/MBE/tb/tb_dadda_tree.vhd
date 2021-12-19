library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_dadda_tree is
end entity tb_dadda_tree;

architecture rtl of tb_dadda_tree is
    component partial_products_gen is
        generic (
            N : integer := 32
        );
        port (
            A, B : in std_logic_vector(N-1 downto 0);
            O : out std_logic_vector((N/2+1)*N*2-1 downto 0)
        );
    end component partial_products_gen;

    component dadda_tree is
        generic (
            N: integer := 32
        );
        port (
            A : in std_logic_vector((N/2+1)*N*2-1 downto 0);
            O_1 : out std_logic_vector(N*2-1 downto 0);
            O_2 : out std_logic_vector(N*2-1 downto 0)
        );
    end component dadda_tree;

    constant N : integer := 16;
    signal A_s, B_s : std_logic_vector(N-1 downto 0);
    signal O_s: std_logic_vector((N/2+1)*N*2-1 downto 0);
    signal O_1_s, O_2_s : std_logic_vector(2*N-1 downto 0);
    
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

    dadda: dadda_tree
    generic map (
        N=>N
    )
    port map (
        A=>O_s,
        O_1=>O_1_s,
        O_2=>O_2_s
    );
    
    testvect: process
    begin
        A_s<="1010100110101001";
        B_s<="0001010100010101"; 
        wait for 10 ns;
        assert unsigned(O_1_s)+unsigned(O_2_s)=unsigned(A_s)*unsigned(B_s) report "DADDA ERROR";
        A_s<="0101001001010010";
        B_s<="1110100111101001"; 
        wait for 10 ns;
        assert unsigned(O_1_s)+unsigned(O_2_s)=unsigned(A_s)*unsigned(B_s) report "DADDA ERROR";
        A_s<="0010101000101010";
        B_s<="1111010011110100"; 
        wait for 10 ns;
        assert unsigned(O_1_s)+unsigned(O_2_s)=unsigned(A_s)*unsigned(B_s) report "DADDA ERROR";
        A_s<="0100101101001011";
        B_s<="0001001000010010"; 
        wait for 10 ns;
        assert unsigned(O_1_s)+unsigned(O_2_s)=unsigned(A_s)*unsigned(B_s) report "DADDA ERROR";
        A_s<="1111111111111111";
        B_s<="1111111111111111"; 
        wait for 10 ns;
        assert unsigned(O_1_s)+unsigned(O_2_s)=unsigned(A_s)*unsigned(B_s) report "DADDA ERROR";
        A_s<="0000000000000000";
        B_s<="0000000000000000"; 
        wait for 10 ns;
        assert unsigned(O_1_s)+unsigned(O_2_s)=unsigned(A_s)*unsigned(B_s) report "DADDA ERROR";
        
        wait;
    end process testvect;
    
end architecture rtl;